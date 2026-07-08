-- ============================================================
-- Project Atlas / Funko Vault
-- Enable RLS and basic authenticated policies
-- ============================================================

-- ============================================================
-- 1. Enable Row Level Security
-- ============================================================

alter table public.roles enable row level security;
alter table public.profiles enable row level security;
alter table public.collections enable row level security;
alter table public.collection_members enable row level security;
alter table public.owned_pops enable row level security;
alter table public.products enable row level security;
alter table public.audit_log enable row level security;
alter table public.approval_requests enable row level security;
alter table public.scan_history enable row level security;
alter table public.notifications enable row level security;
alter table public.collection_stats enable row level security;

-- ============================================================
-- 2. Drop old policies if re-running this script
-- ============================================================

drop policy if exists "roles_select_authenticated" on public.roles;

drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;

drop policy if exists "collections_select_member" on public.collections;
drop policy if exists "collections_insert_authenticated" on public.collections;
drop policy if exists "collections_update_editor" on public.collections;
drop policy if exists "collections_delete_deleter" on public.collections;

drop policy if exists "collection_members_select_related" on public.collection_members;
drop policy if exists "collection_members_insert_self" on public.collection_members;
drop policy if exists "collection_members_update_deleter" on public.collection_members;
drop policy if exists "collection_members_delete_deleter" on public.collection_members;

drop policy if exists "owned_pops_select_member" on public.owned_pops;
drop policy if exists "owned_pops_insert_editor" on public.owned_pops;
drop policy if exists "owned_pops_update_editor" on public.owned_pops;
drop policy if exists "owned_pops_delete_deleter" on public.owned_pops;

drop policy if exists "products_select_authenticated" on public.products;

drop policy if exists "audit_log_select_own_collection" on public.audit_log;

drop policy if exists "approval_requests_select_related" on public.approval_requests;
drop policy if exists "approval_requests_insert_authenticated" on public.approval_requests;
drop policy if exists "approval_requests_update_approver" on public.approval_requests;

drop policy if exists "scan_history_select_own" on public.scan_history;
drop policy if exists "scan_history_insert_own" on public.scan_history;
drop policy if exists "scan_history_delete_own" on public.scan_history;

drop policy if exists "notifications_select_own" on public.notifications;
drop policy if exists "notifications_update_own" on public.notifications;

drop policy if exists "collection_stats_select_member" on public.collection_stats;

-- ============================================================
-- 3. Roles
-- ============================================================
-- Safe read-only role lookup for signed-in users.
-- No insert/update/delete policies for normal users.

create policy "roles_select_authenticated"
on public.roles
for select
to authenticated
using (true);

-- ============================================================
-- 4. Profiles
-- ============================================================
-- Users can read and update only their own profile.

create policy "profiles_select_own"
on public.profiles
for select
to authenticated
using (id = auth.uid());

create policy "profiles_update_own"
on public.profiles
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

-- ============================================================
-- 5. Collections
-- ============================================================
-- Users can read collections where they are a collection member.
-- Users can create collections.
--
-- NOTE:
-- Because collections has no owner_id/profile_id column, new collections
-- need a matching collection_members row before the creator can read it
-- under the select policy.

create policy "collections_select_member"
on public.collections
for select
to authenticated
using (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = collections.id
      and cm.profile_id = auth.uid()
  )
);

create policy "collections_insert_authenticated"
on public.collections
for insert
to authenticated
with check (true);

create policy "collections_update_editor"
on public.collections
for update
to authenticated
using (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = collections.id
      and cm.profile_id = auth.uid()
      and cm.can_edit = true
  )
)
with check (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = collections.id
      and cm.profile_id = auth.uid()
      and cm.can_edit = true
  )
);

create policy "collections_delete_deleter"
on public.collections
for delete
to authenticated
using (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = collections.id
      and cm.profile_id = auth.uid()
      and cm.can_delete = true
  )
);

-- ============================================================
-- 6. Collection Members
-- ============================================================
-- Users can see their own memberships.
-- Users with can_delete on a collection can manage members.
-- Users can insert themselves as a member.
--
-- NOTE:
-- This self-insert policy is helpful for initial collection creation,
-- but later we may tighten it with a database function.

create policy "collection_members_select_related"
on public.collection_members
for select
to authenticated
using (
  profile_id = auth.uid()
  or exists (
    select 1
    from public.collection_members owner_cm
    where owner_cm.collection_id = collection_members.collection_id
      and owner_cm.profile_id = auth.uid()
      and owner_cm.can_delete = true
  )
);

create policy "collection_members_insert_self"
on public.collection_members
for insert
to authenticated
with check (profile_id = auth.uid());

create policy "collection_members_update_deleter"
on public.collection_members
for update
to authenticated
using (
  exists (
    select 1
    from public.collection_members owner_cm
    where owner_cm.collection_id = collection_members.collection_id
      and owner_cm.profile_id = auth.uid()
      and owner_cm.can_delete = true
  )
)
with check (
  exists (
    select 1
    from public.collection_members owner_cm
    where owner_cm.collection_id = collection_members.collection_id
      and owner_cm.profile_id = auth.uid()
      and owner_cm.can_delete = true
  )
);

create policy "collection_members_delete_deleter"
on public.collection_members
for delete
to authenticated
using (
  exists (
    select 1
    from public.collection_members owner_cm
    where owner_cm.collection_id = collection_members.collection_id
      and owner_cm.profile_id = auth.uid()
      and owner_cm.can_delete = true
  )
);

-- ============================================================
-- 7. Owned Pops
-- ============================================================
-- Users can access owned pops if they are a member of the collection.
-- Edit requires can_edit.
-- Delete requires can_delete.

create policy "owned_pops_select_member"
on public.owned_pops
for select
to authenticated
using (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = owned_pops.collection_id
      and cm.profile_id = auth.uid()
  )
);

create policy "owned_pops_insert_editor"
on public.owned_pops
for insert
to authenticated
with check (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = owned_pops.collection_id
      and cm.profile_id = auth.uid()
      and cm.can_edit = true
  )
);

create policy "owned_pops_update_editor"
on public.owned_pops
for update
to authenticated
using (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = owned_pops.collection_id
      and cm.profile_id = auth.uid()
      and cm.can_edit = true
  )
)
with check (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = owned_pops.collection_id
      and cm.profile_id = auth.uid()
      and cm.can_edit = true
  )
);

create policy "owned_pops_delete_deleter"
on public.owned_pops
for delete
to authenticated
using (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = owned_pops.collection_id
      and cm.profile_id = auth.uid()
      and cm.can_delete = true
  )
);

-- ============================================================
-- 8. Products
-- ============================================================
-- Product catalog is read-only for signed-in users.
-- No client insert/update/delete policies for normal users.

create policy "products_select_authenticated"
on public.products
for select
to authenticated
using (true);

-- ============================================================
-- 9. Audit Log
-- ============================================================
-- Users can read audit rows for collections they belong to.
-- No client insert/update/delete policies for normal users.
-- Future inserts should happen through trusted server/admin workflows.

create policy "audit_log_select_own_collection"
on public.audit_log
for select
to authenticated
using (
  collection_id is not null
  and exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = audit_log.collection_id
      and cm.profile_id = auth.uid()
  )
);

-- ============================================================
-- 10. Approval Requests
-- ============================================================
-- Users can read requests they created, approved, or that belong
-- to a collection where they are a member.
-- Users can create their own requests.
-- Collection managers can update requests for their collection.

create policy "approval_requests_select_related"
on public.approval_requests
for select
to authenticated
using (
  requested_by = auth.uid()
  or approved_by = auth.uid()
  or exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = approval_requests.collection_id
      and cm.profile_id = auth.uid()
  )
);

create policy "approval_requests_insert_authenticated"
on public.approval_requests
for insert
to authenticated
with check (requested_by = auth.uid());

create policy "approval_requests_update_approver"
on public.approval_requests
for update
to authenticated
using (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = approval_requests.collection_id
      and cm.profile_id = auth.uid()
      and cm.can_delete = true
  )
)
with check (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = approval_requests.collection_id
      and cm.profile_id = auth.uid()
      and cm.can_delete = true
  )
);

-- ============================================================
-- 11. Scan History
-- ============================================================
-- Users can manage their own scan history.

create policy "scan_history_select_own"
on public.scan_history
for select
to authenticated
using (profile_id = auth.uid());

create policy "scan_history_insert_own"
on public.scan_history
for insert
to authenticated
with check (profile_id = auth.uid());

create policy "scan_history_delete_own"
on public.scan_history
for delete
to authenticated
using (profile_id = auth.uid());

-- ============================================================
-- 12. Notifications
-- ============================================================
-- Users can read/update their own notifications.
-- No client insert/delete policies for normal users.

create policy "notifications_select_own"
on public.notifications
for select
to authenticated
using (profile_id = auth.uid());

create policy "notifications_update_own"
on public.notifications
for update
to authenticated
using (profile_id = auth.uid())
with check (profile_id = auth.uid());

-- ============================================================
-- 13. Collection Stats
-- ============================================================
-- Users can read collection stats for collections they belong to.
-- No client insert/update/delete policies for normal users.

create policy "collection_stats_select_member"
on public.collection_stats
for select
to authenticated
using (
  exists (
    select 1
    from public.collection_members cm
    where cm.collection_id = collection_stats.collection_id
      and cm.profile_id = auth.uid()
  )
);