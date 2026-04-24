-- ============================================================
-- Fix: Self-referential RLS loop on organization_members.
-- All policies that check membership were querying organization_members
-- under the user's RLS context, which itself had the same check —
-- causing infinite recursion / empty results.
--
-- Solution: A SECURITY DEFINER function that bypasses RLS to
-- look up the current user's org_id. All policies use this instead.
-- ============================================================

-- Helper: returns the org_id of the currently authenticated user.
-- SECURITY DEFINER bypasses RLS on organization_members.
create or replace function auth_user_org_id()
returns uuid
language sql
security definer
stable
set search_path = public
as $$
  select org_id
  from organization_members
  where user_id = auth.uid()
  limit 1;
$$;

-- ============================================================
-- Rebuild: organization_members policies (self-referential fix)
-- ============================================================
drop policy if exists "members_select" on organization_members;
drop policy if exists "members_insert" on organization_members;

create policy "members_select"
  on organization_members for select to authenticated
  using (org_id = auth_user_org_id());

create policy "members_insert"
  on organization_members for insert to authenticated
  with check (
    user_id = auth.uid() or
    org_id = auth_user_org_id()
  );

-- ============================================================
-- Rebuild: organizations
-- ============================================================
drop policy if exists "org_member_select" on organizations;
drop policy if exists "org_member_insert" on organizations;
drop policy if exists "org_member_update" on organizations;

create policy "org_member_select"
  on organizations for select to authenticated
  using (id = auth_user_org_id());

create policy "org_member_insert"
  on organizations for insert to authenticated
  with check (true);

create policy "org_member_update"
  on organizations for update to authenticated
  using (id = auth_user_org_id());

-- ============================================================
-- Rebuild: freezers
-- ============================================================
drop policy if exists "freezers_select" on freezers;
drop policy if exists "freezers_insert" on freezers;
drop policy if exists "freezers_update" on freezers;
drop policy if exists "freezers_delete" on freezers;

create policy "freezers_select"
  on freezers for select to authenticated
  using (org_id = auth_user_org_id());

create policy "freezers_insert"
  on freezers for insert to authenticated
  with check (org_id = auth_user_org_id());

create policy "freezers_update"
  on freezers for update to authenticated
  using (org_id = auth_user_org_id());

create policy "freezers_delete"
  on freezers for delete to authenticated
  using (org_id = auth_user_org_id());

-- ============================================================
-- Rebuild: shelves
-- ============================================================
drop policy if exists "shelves_select" on shelves;
drop policy if exists "shelves_insert" on shelves;
drop policy if exists "shelves_update" on shelves;
drop policy if exists "shelves_delete" on shelves;

create policy "shelves_select"
  on shelves for select to authenticated
  using (org_id = auth_user_org_id());

create policy "shelves_insert"
  on shelves for insert to authenticated
  with check (org_id = auth_user_org_id());

create policy "shelves_update"
  on shelves for update to authenticated
  using (org_id = auth_user_org_id());

create policy "shelves_delete"
  on shelves for delete to authenticated
  using (org_id = auth_user_org_id());

-- ============================================================
-- Rebuild: products
-- ============================================================
drop policy if exists "products_select" on products;
drop policy if exists "products_insert" on products;
drop policy if exists "products_update" on products;
drop policy if exists "products_delete" on products;

create policy "products_select"
  on products for select to authenticated
  using (org_id = auth_user_org_id());

create policy "products_insert"
  on products for insert to authenticated
  with check (org_id = auth_user_org_id());

create policy "products_update"
  on products for update to authenticated
  using (org_id = auth_user_org_id());

create policy "products_delete"
  on products for delete to authenticated
  using (org_id = auth_user_org_id());

-- ============================================================
-- Rebuild: packages
-- ============================================================
drop policy if exists "packages_select" on packages;
drop policy if exists "packages_insert" on packages;
drop policy if exists "packages_update" on packages;
drop policy if exists "packages_delete" on packages;

create policy "packages_select"
  on packages for select to authenticated
  using (org_id = auth_user_org_id());

create policy "packages_insert"
  on packages for insert to authenticated
  with check (org_id = auth_user_org_id());

create policy "packages_update"
  on packages for update to authenticated
  using (org_id = auth_user_org_id());

create policy "packages_delete"
  on packages for delete to authenticated
  using (org_id = auth_user_org_id());

-- ============================================================
-- Rebuild: inventory_logs
-- ============================================================
drop policy if exists "logs_select" on inventory_logs;

create policy "logs_select"
  on inventory_logs for select to authenticated
  using (org_id = auth_user_org_id());
