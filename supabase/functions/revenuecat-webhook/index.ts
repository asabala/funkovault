import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (request: Request): Promise<Response> => {
  if (request.method !== "POST") {
    return new Response(
      JSON.stringify({
        error: "Method not allowed",
      }),
      {
        status: 405,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  }

  const expectedAuthorization =
    Deno.env.get("REVENUECAT_WEBHOOK_AUTHORIZATION");

  if (!expectedAuthorization) {
    console.error(
      "REVENUECAT_WEBHOOK_AUTHORIZATION is not configured.",
    );

    return new Response(
      JSON.stringify({
        error: "Webhook configuration error",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  }

  const authorization =
    request.headers.get("Authorization");

  if (authorization !== expectedAuthorization) {
    return new Response(
      JSON.stringify({
        error: "Unauthorized",
      }),
      {
        status: 401,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  }

  let payload: unknown;

  try {
    payload = await request.json();
  } catch {
    return new Response(
      JSON.stringify({
        error: "Invalid JSON payload",
      }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  }

  if (
    typeof payload !== "object" ||
    payload === null ||
    !("event" in payload)
  ) {
    return new Response(
      JSON.stringify({
        error: "Missing RevenueCat event",
      }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  }

  const event =
    (payload as Record<string, unknown>).event;

  if (
    typeof event !== "object" ||
    event === null
  ) {
    return new Response(
      JSON.stringify({
        error: "Invalid RevenueCat event",
      }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  }

  const eventRecord =
    event as Record<string, unknown>;

  const eventType =
    typeof eventRecord.type === "string"
      ? eventRecord.type
      : null;

  const appUserId =
    typeof eventRecord.app_user_id === "string"
      ? eventRecord.app_user_id
      : null;

  if (!eventType || !appUserId) {
    return new Response(
      JSON.stringify({
        error: "RevenueCat event is missing required fields",
      }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  }

  console.log(
    JSON.stringify({
      source: "revenuecat",
      eventType,
      appUserId,
    }),
  );

  return new Response(
    JSON.stringify({
      received: true,
    }),
    {
      status: 200,
      headers: {
        "Content-Type": "application/json",
      },
    },
  );
});