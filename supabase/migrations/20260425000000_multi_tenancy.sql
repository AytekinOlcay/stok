-- ============================================================
-- Multi-Tenancy: Organizations + Freezers
-- ============================================================

-- ============================================================
-- ORGANIZATIONS
-- ============================================================
create table organizations (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  created_at timestamptz not null default now()
);

-- ============================================================
-- ORGANIZATION MEMBERS
-- ============================================================
create type org_role as enum ('owner', 'member');

create table organization_members (
  id         uuid primary key default gen_random_uuid(),
  org_id     uuid not null references organizations(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  role       org_role not null default 'member',
  created_at timestamptz not null default now(),
  unique (org_id, user_id)
);

-- ============================================================
-- FREEZERS
-- ============================================================
create table freezers (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references organizations(id) on delete cascade,
  name        text not null,
  shelf_count integer not null default 7 check (shelf_count > 0),
  created_at  timestamptz not null default now()
);

-- ============================================================
-- ADD org_id + freezer_id TO EXISTING TABLES
-- (nullable first — will be filled, then set NOT NULL)
-- ============================================================
alter table shelves        add column org_id     uuid references organizations(id) on delete cascade;
alter table shelves        add column freezer_id uuid references freezers(id) on delete cascade;
alter table products       add column org_id     uuid references organizations(id) on delete cascade;
alter table packages       add column org_id     uuid references organizations(id) on delete cascade;
alter table inventory_logs add column org_id     uuid references organizations(id) on delete cascade;

-- ============================================================
-- MIGRATE EXISTING DATA → default organization + freezer
-- ============================================================

-- 1. Create default organization
insert into organizations (id, name)
values ('00000000-0000-0000-0000-000000000001', 'Varsayılan Ev');

-- 2. Create default freezer
insert into freezers (id, org_id, name, shelf_count)
values (
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000001',
  'Derin Dondurucu',
  7
);

-- 3. Assign all existing rows to default org + freezer
update shelves        set org_id = '00000000-0000-0000-0000-000000000001',
                          freezer_id = '00000000-0000-0000-0000-000000000002';
update products       set org_id = '00000000-0000-0000-0000-000000000001';
update packages       set org_id = '00000000-0000-0000-0000-000000000001';
update inventory_logs set org_id = '00000000-0000-0000-0000-000000000001';

-- 4. Now enforce NOT NULL
alter table shelves        alter column org_id     set not null;
alter table shelves        alter column freezer_id set not null;
alter table products       alter column org_id     set not null;
alter table packages       alter column org_id     set not null;
alter table inventory_logs alter column org_id     set not null;

-- ============================================================
-- RLS — NEW TABLES
-- ============================================================
alter table organizations        enable row level security;
alter table organization_members enable row level security;
alter table freezers             enable row level security;

-- Organizations: user sees only orgs they belong to
create policy "org_member_select"
  on organizations for select to authenticated
  using (
    id in (select org_id from organization_members where user_id = auth.uid())
  );

create policy "org_member_insert"
  on organizations for insert to authenticated
  with check (true); -- the trigger below adds the owner member

create policy "org_member_update"
  on organizations for update to authenticated
  using (
    id in (select org_id from organization_members where user_id = auth.uid() and role = 'owner')
  );

-- Organization members: members see their own org's members
create policy "members_select"
  on organization_members for select to authenticated
  using (
    org_id in (select org_id from organization_members where user_id = auth.uid())
  );

create policy "members_insert"
  on organization_members for insert to authenticated
  with check (
    -- only owner can add members, or it's the initial self-insert
    user_id = auth.uid() or
    org_id in (select org_id from organization_members where user_id = auth.uid() and role = 'owner')
  );

-- Freezers: org members can read; owners can write
create policy "freezers_select"
  on freezers for select to authenticated
  using (
    org_id in (select org_id from organization_members where user_id = auth.uid())
  );

create policy "freezers_insert"
  on freezers for insert to authenticated
  with check (
    org_id in (select org_id from organization_members where user_id = auth.uid() and role = 'owner')
  );

create policy "freezers_update"
  on freezers for update to authenticated
  using (
    org_id in (select org_id from organization_members where user_id = auth.uid() and role = 'owner')
  );

create policy "freezers_delete"
  on freezers for delete to authenticated
  using (
    org_id in (select org_id from organization_members where user_id = auth.uid() and role = 'owner')
  );

-- ============================================================
-- RLS — DROP OLD ANON POLICIES, ADD ORG-SCOPED POLICIES
-- ============================================================

-- Shelves
drop policy if exists "anon_select_shelves" on shelves;
drop policy if exists "Authenticated users can read shelves" on shelves;

create policy "shelves_select"
  on shelves for select to authenticated
  using (org_id in (select org_id from organization_members where user_id = auth.uid()));

create policy "shelves_insert"
  on shelves for insert to authenticated
  with check (org_id in (select org_id from organization_members where user_id = auth.uid() and role = 'owner'));

create policy "shelves_update"
  on shelves for update to authenticated
  using (org_id in (select org_id from organization_members where user_id = auth.uid() and role = 'owner'));

create policy "shelves_delete"
  on shelves for delete to authenticated
  using (org_id in (select org_id from organization_members where user_id = auth.uid() and role = 'owner'));

-- Products
drop policy if exists "anon_select_products" on products;
drop policy if exists "anon_insert_products" on products;
drop policy if exists "anon_update_products" on products;
drop policy if exists "Authenticated users can read products" on products;

create policy "products_select"
  on products for select to authenticated
  using (org_id in (select org_id from organization_members where user_id = auth.uid()));

create policy "products_insert"
  on products for insert to authenticated
  with check (org_id in (select org_id from organization_members where user_id = auth.uid()));

create policy "products_update"
  on products for update to authenticated
  using (org_id in (select org_id from organization_members where user_id = auth.uid()));

create policy "products_delete"
  on products for delete to authenticated
  using (org_id in (select org_id from organization_members where user_id = auth.uid() and role = 'owner'));

-- Packages
drop policy if exists "anon_select_packages" on packages;
drop policy if exists "anon_insert_packages" on packages;
drop policy if exists "anon_update_packages" on packages;
drop policy if exists "anon_delete_packages" on packages;
drop policy if exists "Authenticated users can read packages" on packages;

create policy "packages_select"
  on packages for select to authenticated
  using (org_id in (select org_id from organization_members where user_id = auth.uid()));

create policy "packages_insert"
  on packages for insert to authenticated
  with check (org_id in (select org_id from organization_members where user_id = auth.uid()));

create policy "packages_update"
  on packages for update to authenticated
  using (org_id in (select org_id from organization_members where user_id = auth.uid()));

create policy "packages_delete"
  on packages for delete to authenticated
  using (org_id in (select org_id from organization_members where user_id = auth.uid()));

-- Inventory logs
drop policy if exists "anon_select_logs" on inventory_logs;
drop policy if exists "Authenticated users can read logs" on inventory_logs;

create policy "logs_select"
  on inventory_logs for select to authenticated
  using (org_id in (select org_id from organization_members where user_id = auth.uid()));

-- ============================================================
-- TRIGGER: Auto-add owner when org is created
-- ============================================================
create or replace function add_org_owner()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  insert into organization_members (org_id, user_id, role)
  values (new.id, auth.uid(), 'owner');
  return new;
end;
$$;

create trigger trg_add_org_owner
after insert on organizations
for each row execute function add_org_owner();

-- ============================================================
-- FUNCTION: Create org + freezer + shelves in one call
-- (called from mobile onboarding)
-- ============================================================
create or replace function create_organization_with_freezer(
  p_org_name     text,
  p_freezer_name text,
  p_shelf_count  integer default 7
)
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  v_org_id     uuid;
  v_freezer_id uuid;
  i            integer;
begin
  -- Create org (trigger adds owner member automatically)
  insert into organizations (name) values (p_org_name) returning id into v_org_id;

  -- Create freezer
  insert into freezers (org_id, name, shelf_count)
  values (v_org_id, p_freezer_name, p_shelf_count)
  returning id into v_freezer_id;

  -- Create shelves
  for i in 1..p_shelf_count loop
    insert into shelves (org_id, freezer_id, name, position)
    values (v_org_id, v_freezer_id, 'Raf ' || i, i);
  end loop;

  return jsonb_build_object(
    'org_id',     v_org_id,
    'freezer_id', v_freezer_id
  );
end;
$$;

-- ============================================================
-- FUNCTION: Get user's organization (for mobile app init)
-- ============================================================
create or replace function get_my_org()
returns jsonb
language plpgsql security definer
set search_path = public
as $$
declare
  v_member organization_members%rowtype;
  v_org    organizations%rowtype;
begin
  select * into v_member
  from organization_members
  where user_id = auth.uid()
  limit 1;

  if not found then
    return null;
  end if;

  select * into v_org from organizations where id = v_member.org_id;

  return jsonb_build_object(
    'org_id',   v_org.id,
    'org_name', v_org.name,
    'role',     v_member.role
  );
end;
$$;
