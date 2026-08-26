import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

type RevenueCatEvent = Record<string, unknown>;

type EntitlementUpdate = {
  tier: "basic" | "premium";
  status:
    | "inactive"
    | "active"
    | "trialing"
    | "past_due"
    | "canceled";
  isPremium: boolean;
  willCancelAtPeriodEnd: boolean;
};

const entitlementStateEventTypes = [
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "SUBSCRIPTION_EXTENDED",
  "TEMPORARY_ENTITLEMENT_GRANT",
  "CANCELLATION",
  "BILLING_ISSUE",
  "EXPIRATION",
  "SUBSCRIPTION_PAUSED",
];

serve(async (request: Request): Promise<Response> => {
  if (request.method !== "POST") {
    return jsonResponse(
      {
        error: "Method not allowed",
      },
      405,
    );
  }

  const expectedAuthorization =
    Deno.env.get("REVENUECAT_WEBHOOK_AUTHORIZATION");

  if (!expectedAuthorization) {
    console.error(
      "REVENUECAT_WEBHOOK_AUTHORIZATION is not configured.",
    );

    return jsonResponse(
      {
        error: "Webhook configuration error",
      },
      500,
    );
  }

  const authorization =
    request.headers.get("Authorization");

  if (authorization !== expectedAuthorization) {
    return jsonResponse(
      {
        error: "Unauthorized",
      },
      401,
    );
  }

  const supabaseUrl =
    Deno.env.get("SUPABASE_URL");

  const serviceRoleKey =
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.error(
      "Supabase server credentials are not configured.",
    );

    return jsonResponse(
      {
        error: "Webhook configuration error",
      },
      500,
    );
  }

  let payload: unknown;

  try {
    payload = await request.json();
  } catch {
    return jsonResponse(
      {
        error: "Invalid JSON payload",
      },
      400,
    );
  }

  const event = readEvent(payload);

  if (!event) {
    return jsonResponse(
      {
        error: "Invalid RevenueCat event",
      },
      400,
    );
  }

  const eventId =
    readString(event, "id");

  const eventType =
    readString(event, "type");

  const appUserId =
    readString(event, "app_user_id");

  const eventTimestampMs =
    readNumber(
      event,
      "event_timestamp_ms",
    );

  if (
    !eventId ||
    !eventType ||
    !appUserId ||
    eventTimestampMs == null
  ) {
    return jsonResponse(
      {
        error: "RevenueCat event is missing required fields",
      },
      400,
    );
  }

  const supabase = createClient(
    supabaseUrl,
    serviceRoleKey,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    },
  );

  // ----------------------------------------------------------
  // Duplicate delivery protection
  // ----------------------------------------------------------

  const {
    data: existingEvent,
    error: existingEventError,
  } =
    await supabase
      .from("revenuecat_webhook_events")
      .select("event_id")
      .eq("event_id", eventId)
      .maybeSingle();

  if (existingEventError) {
    console.error(
      "Failed to check RevenueCat webhook event history.",
      existingEventError,
    );

    return jsonResponse(
      {
        error: "Webhook synchronization failed",
      },
      500,
    );
  }

  if (existingEvent) {
    console.log(
      JSON.stringify({
        source: "revenuecat",
        eventId,
        eventType,
        appUserId,
        action: "duplicate_ignored",
      }),
    );

    return jsonResponse({
      received: true,
      processed: false,
      duplicate: true,
    });
  }

  const update =
    entitlementUpdateForEvent(
      eventType,
      event,
    );

  // Events that do not change Atlas entitlement state are
  // acknowledged without modifying subscription state.
  if (!update) {
    console.log(
      JSON.stringify({
        source: "revenuecat",
        eventId,
        eventType,
        appUserId,
        action: "ignored",
      }),
    );

    return jsonResponse({
      received: true,
      processed: false,
    });
  }

  // ----------------------------------------------------------
  // Out-of-order delivery protection
  // ----------------------------------------------------------
  //
  // Only entitlement-changing events participate in ordering.
  // Informational/ignored RevenueCat events must not block a
  // later subscription state update.

  const {
    data: latestEvents,
    error: latestEventError,
  } =
    await supabase
      .from("revenuecat_webhook_events")
      .select(
        "event_id,event_type,event_timestamp_ms",
      )
      .eq("app_user_id", appUserId)
      .in(
        "event_type",
        entitlementStateEventTypes,
      )
      .order(
        "event_timestamp_ms",
        {
          ascending: false,
        },
      )
      .limit(1);

  if (latestEventError) {
    console.error(
      "Failed to read RevenueCat webhook ordering state.",
      latestEventError,
    );

    return jsonResponse(
      {
        error: "Webhook synchronization failed",
      },
      500,
    );
  }

  const latestEvent =
    latestEvents?.[0] ?? null;

  const latestTimestampMs =
    latestEvent == null
      ? null
      : readDatabaseNumber(
          latestEvent.event_timestamp_ms,
        );

  if (
    latestTimestampMs != null &&
    eventTimestampMs < latestTimestampMs
  ) {
    const recorded =
      await recordWebhookEvent(
        supabase,
        {
          eventId,
          eventType,
          appUserId,
          eventTimestampMs,
        },
      );

    if (!recorded) {
      return jsonResponse(
        {
          error: "Webhook synchronization failed",
        },
        500,
      );
    }

    console.log(
      JSON.stringify({
        source: "revenuecat",
        eventId,
        eventType,
        appUserId,
        action: "stale_event_ignored",
        eventTimestampMs,
        latestTimestampMs,
      }),
    );

    return jsonResponse({
      received: true,
      processed: false,
      stale: true,
    });
  }

  // ----------------------------------------------------------
  // Subscription entitlement synchronization
  // ----------------------------------------------------------

  const expirationAtMs =
    readNumber(
      event,
      "expiration_at_ms",
    );

  const currentPeriodEnd =
    expirationAtMs == null
      ? null
      : new Date(
          expirationAtMs,
        ).toISOString();

  const periodType =
    readString(
      event,
      "period_type",
    );

  const billingPeriod =
    billingPeriodForEvent(event);

  const provider =
    providerForEvent(event);

  const providerCustomerId =
    readString(
      event,
      "original_app_user_id",
    ) ?? appUserId;

  const subscriptionStatus =
    periodType === "TRIAL" &&
    update.isPremium
      ? "trialing"
      : update.status;

  const {
    error: entitlementError,
  } =
    await supabase
      .from("subscription_entitlements")
      .upsert(
        {
          profile_id: appUserId,
          tier: update.tier,
          status: subscriptionStatus,
          provider,
          provider_customer_id:
            providerCustomerId,
          billing_period:
            billingPeriod,
          current_period_end:
            currentPeriodEnd,
          will_cancel_at_period_end:
            update.willCancelAtPeriodEnd,
          updated_at:
            new Date().toISOString(),
        },
        {
          onConflict: "profile_id",
        },
      );

  if (entitlementError) {
    console.error(
      "Failed to update subscription entitlement.",
      entitlementError,
    );

    return jsonResponse(
      {
        error: "Entitlement synchronization failed",
      },
      500,
    );
  }

  // ----------------------------------------------------------
  // Supabase auth metadata synchronization
  // ----------------------------------------------------------

  const {
    data: userResult,
    error: userError,
  } =
    await supabase.auth.admin.getUserById(
      appUserId,
    );

  if (
    userError ||
    !userResult.user
  ) {
    console.error(
      "Failed to load Supabase user.",
      userError,
    );

    return jsonResponse(
      {
        error: "Account synchronization failed",
      },
      500,
    );
  }

  const existingAppMetadata =
    userResult.user.app_metadata ?? {};

  const {
    error: metadataError,
  } =
    await supabase.auth.admin.updateUserById(
      appUserId,
      {
        app_metadata: {
          ...existingAppMetadata,
          tier: update.tier,
          is_premium:
            update.isPremium,
        },
      },
    );

  if (metadataError) {
    console.error(
      "Failed to update Supabase app metadata.",
      metadataError,
    );

    return jsonResponse(
      {
        error: "Account synchronization failed",
      },
      500,
    );
  }

  // ----------------------------------------------------------
  // Record successful processing
  // ----------------------------------------------------------

  const recorded =
    await recordWebhookEvent(
      supabase,
      {
        eventId,
        eventType,
        appUserId,
        eventTimestampMs,
      },
    );

  if (!recorded) {
    // Returning 500 asks RevenueCat to retry. The subscription
    // writes above are idempotent, so repeating them is safe.
    return jsonResponse(
      {
        error: "Webhook event recording failed",
      },
      500,
    );
  }

  console.log(
    JSON.stringify({
      source: "revenuecat",
      eventId,
      eventType,
      appUserId,
      tier: update.tier,
      status: subscriptionStatus,
      isPremium:
        update.isPremium,
      action: "processed",
    }),
  );

  return jsonResponse({
    received: true,
    processed: true,
  });
});

async function recordWebhookEvent(
  supabase: ReturnType<
    typeof createClient
  >,
  {
    eventId,
    eventType,
    appUserId,
    eventTimestampMs,
  }: {
    eventId: string;
    eventType: string;
    appUserId: string;
    eventTimestampMs: number;
  },
): Promise<boolean> {
  const {
    error,
  } =
    await supabase
      .from(
        "revenuecat_webhook_events",
      )
      .insert({
        event_id: eventId,
        event_type: eventType,
        app_user_id: appUserId,
        event_timestamp_ms:
          eventTimestampMs,
      });

  if (!error) {
    return true;
  }

  // PostgreSQL unique_violation. A concurrent retry may have
  // recorded the same RevenueCat event while this request was
  // processing. That still counts as successfully recorded.
  if (error.code === "23505") {
    return true;
  }

  console.error(
    "Failed to record RevenueCat webhook event.",
    error,
  );

  return false;
}

function entitlementUpdateForEvent(
  eventType: string,
  event: RevenueCatEvent,
): EntitlementUpdate | null {
  switch (eventType) {
    case "INITIAL_PURCHASE":
    case "RENEWAL":
    case "UNCANCELLATION":
    case "SUBSCRIPTION_EXTENDED":
    case "TEMPORARY_ENTITLEMENT_GRANT":
      return {
        tier: "premium",
        status: "active",
        isPremium: true,
        willCancelAtPeriodEnd: false,
      };

    case "CANCELLATION":
      return {
        tier: "premium",
        status: "active",
        isPremium: true,
        willCancelAtPeriodEnd: true,
      };

    case "BILLING_ISSUE":
      return {
        tier: "premium",
        status: "past_due",
        isPremium: true,
        willCancelAtPeriodEnd: false,
      };

    case "EXPIRATION":
      return {
        tier: "basic",
        status: "inactive",
        isPremium: false,
        willCancelAtPeriodEnd: false,
      };

    case "SUBSCRIPTION_PAUSED":
      return {
        tier: "premium",
        status: "active",
        isPremium: true,
        willCancelAtPeriodEnd: true,
      };

    case "PRODUCT_CHANGE":
    case "NON_RENEWING_PURCHASE":
    case "TRANSFER":
    case "REFUND_REVERSED":
    case "INVOICE_ISSUANCE":
    case "TEST":
      return null;

    default:
      console.log(
        JSON.stringify({
          source: "revenuecat",
          eventType,
          action:
            "unrecognized_event",
          eventId:
            readString(
              event,
              "id",
            ),
        }),
      );

      return null;
  }
}

function readEvent(
  payload: unknown,
): RevenueCatEvent | null {
  if (
    typeof payload !== "object" ||
    payload === null ||
    !("event" in payload)
  ) {
    return null;
  }

  const event =
    (
      payload as Record<
        string,
        unknown
      >
    ).event;

  if (
    typeof event !== "object" ||
    event === null
  ) {
    return null;
  }

  return event as RevenueCatEvent;
}

function readString(
  event: RevenueCatEvent,
  key: string,
): string | null {
  const value = event[key];

  return typeof value === "string"
    ? value
    : null;
}

function readNumber(
  event: RevenueCatEvent,
  key: string,
): number | null {
  const value = event[key];

  return typeof value === "number"
    ? value
    : null;
}

function readDatabaseNumber(
  value: unknown,
): number | null {
  if (
    typeof value === "number"
  ) {
    return value;
  }

  if (
    typeof value === "string"
  ) {
    const parsed =
      Number(value);

    return Number.isFinite(parsed)
      ? parsed
      : null;
  }

  return null;
}

function billingPeriodForEvent(
  event: RevenueCatEvent,
): "monthly" | "yearly" | null {
  const purchasedAt =
    readNumber(
      event,
      "purchased_at_ms",
    );

  const expirationAt =
    readNumber(
      event,
      "expiration_at_ms",
    );

  if (
    purchasedAt == null ||
    expirationAt == null ||
    expirationAt <= purchasedAt
  ) {
    return null;
  }

  const durationDays =
    (expirationAt - purchasedAt) /
    (1000 * 60 * 60 * 24);

  if (durationDays >= 300) {
    return "yearly";
  }

  if (durationDays >= 20) {
    return "monthly";
  }

  return null;
}

function providerForEvent(
  event: RevenueCatEvent,
): string | null {
  const store =
    readString(
      event,
      "store",
    );

  if (!store) {
    return "revenuecat";
  }

  return `revenuecat:${store.toLowerCase()}`;
}

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
): Response {
  return new Response(
    JSON.stringify(body),
    {
      status,
      headers: {
        "Content-Type":
          "application/json",
      },
    },
  );
}