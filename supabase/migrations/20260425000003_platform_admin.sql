-- ============================================================
-- Platform Admin (Godmin) Support
--
-- Adds a platform_admins table for super-admin accounts that
-- can manage organizations and users across the whole platform.
--
-- Visibility rules:
--   Godmin CAN see:   organizations, organization_members, freezers (names only)
--   Godmin CANNOT see: shelves, packages, products, inventory_logs
--
-- Creating the first godmin (must be done via Supabase Studio SQL editor):
--   INSERT INTO platform_admins (user_id) VALUES ('<auth-user-uuid>');
-- ============================================================

-- 1. Platform admins table
create table platform_admins (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table platform_admins enable row level security;

-- 2. SECURITY DEFINER helper: bypasses RLS on platform_admins to safely check status.
--    Must be created before the RLS policy that references it.
create or replace function is_platform_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from platform_admins where user_id = auth.uid()
  );
$$;

-- 3. RLS: platform admins can read the table (used by middleware to verify status)
create policy "platform_admins_select"
  on platform_admins for select
  using (is_platform_admin());

-- 4. Org-metadata read policies for godmin
--    These stack with existing org-member policies (OR logic in Postgres RLS).
--    Shelves / packages / products / inventory_logs intentionally excluded.

create policy "godmin_view_organizations"
  on organizations for select
  using (is_platform_admin());

create policy "godmin_view_org_members"
  on organization_members for select
  using (is_platform_admin());

create policy "godmin_view_freezers"
  on freezers for select
  using (is_platform_admin());
