-- ============================================================
-- Project Atlas / Funko Vault
-- RevenueCat Webhook Event Tracking
-- ============================================================
--
-- Stores processed RevenueCat webhook events so duplicate
-- deliveries can be ignored safely.
--
-- This table is server-managed only.
-- ============================================================

create table if not exists public.revenuecat_webhook_events (
  event_id text primary key,
  event_type text not null,
  app_user_id uuid not null references auth.users(id) on delete cascade,
  event_timestamp_ms bigint,
  processed_at timestamptz not null default now()
);

alter table public.revenuecat_webhook_events
enable row level security;

-- No client policies are intentionally created.
-- Only trusted server-side workflows may read or write this table.