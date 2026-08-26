-- ============================================================
-- Project Atlas / Funko Vault
-- Subscription Entitlements
-- ============================================================
--
-- Premium access is server-controlled.
-- Authenticated clients may read their own entitlement,
-- but may not insert, update, or delete entitlement rows.
-- Trusted server workflows such as RevenueCat webhooks
-- will manage this table later.
-- ============================================================

create table if not exists public.subscription_entitlements (
  profile_id uuid primary key references auth.users(id) on delete cascade,

  tier text not null default 'basic'
    check (tier in ('basic', 'premium')),

  status text not null default 'inactive'
    check (
      status in (
        'inactive',
        'active',
        'trialing',
        'past_due',
        'canceled'
      )
    ),

  provider text,

  provider_customer_id text,

  billing_period text
    check (
      billing_period is null
      or billing_period in ('monthly', 'yearly')
    ),

  current_period_end timestamptz,

  will_cancel_at_period_end boolean not null default false,

  updated_at timestamptz not null default now()
);

-- ============================================================
-- Row Level Security
-- ============================================================

alter table public.subscription_entitlements
enable row level security;

drop policy if exists
  "subscription_entitlements_select_own"
on public.subscription_entitlements;

create policy
  "subscription_entitlements_select_own"
on public.subscription_entitlements
for select
to authenticated
using (
  profile_id = auth.uid()
);

-- No insert/update/delete policies are intentionally created.
-- Subscription state must be changed only by trusted server-side
-- workflows using elevated Supabase credentials.