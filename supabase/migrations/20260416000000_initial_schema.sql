-- ============================================================
-- Freezer Inventory System — Initial Schema
-- ============================================================

-- gen_random_uuid() is built-in on PostgreSQL 14+; no extension needed.

-- ============================================================
-- SHELVES
-- ============================================================
create table shelves (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  position    integer not null,
  qr_code     text unique,
  created_at  timestamptz not null default now()
);

-- Seed default 7 shelves
insert into shelves (name, position) values
  ('Shelf 1', 1),
  ('Shelf 2', 2),
  ('Shelf 3', 3),
  ('Shelf 4', 4),
  ('Shelf 5', 5),
  ('Shelf 6', 6),
  ('Shelf 7', 7);

-- ============================================================
-- PRODUCTS
-- ============================================================
create table products (
  id                              uuid primary key default gen_random_uuid(),
  name                            text not null,
  category                        text,
  default_unit                    text not null default 'g',
  recommended_freezer_storage_days integer not null default 90,
  created_at                      timestamptz not null default now()
);

-- ============================================================
-- PACKAGES (inventory items)
-- ============================================================
create table packages (
  id                       uuid primary key default gen_random_uuid(),
  product_id               uuid not null references products(id) on delete restrict,
  shelf_id                 uuid not null references shelves(id) on delete restrict,
  quantity                 numeric not null check (quantity > 0),
  unit                     text not null,
  qr_code                  text unique,
  added_at                 timestamptz not null default now(),
  recommended_consume_before date,
  expiration_date          date,
  notes                    text,
  created_by               uuid references auth.users(id),
  created_at               timestamptz not null default now()
);

-- Auto-calculate recommended_consume_before on insert
create or replace function set_recommended_consume_before()
returns trigger language plpgsql as $$
declare
  storage_days integer;
begin
  if new.recommended_consume_before is null then
    select recommended_freezer_storage_days
      into storage_days
      from products
     where id = new.product_id;

    new.recommended_consume_before := (new.added_at::date + storage_days);
  end if;
  return new;
end;
$$;

create trigger trg_set_recommended_consume_before
before insert on packages
for each row execute function set_recommended_consume_before();

-- ============================================================
-- INVENTORY LOGS
-- ============================================================
create type inventory_action as enum (
  'package_added',
  'package_removed',
  'quantity_adjusted',
  'shelf_changed'
);

create table inventory_logs (
  id           uuid primary key default gen_random_uuid(),
  package_id   uuid references packages(id) on delete set null,
  product_id   uuid references products(id) on delete set null,
  shelf_id     uuid references shelves(id) on delete set null,
  action_type  inventory_action not null,
  quantity     numeric,
  unit         text,
  performed_by uuid references auth.users(id),
  notes        text,
  created_at   timestamptz not null default now()
);

-- Auto-log when a package is inserted
create or replace function log_package_added()
returns trigger language plpgsql as $$
begin
  insert into inventory_logs (package_id, product_id, shelf_id, action_type, quantity, unit, performed_by)
  values (new.id, new.product_id, new.shelf_id, 'package_added', new.quantity, new.unit, new.created_by);
  return new;
end;
$$;

create trigger trg_log_package_added
after insert on packages
for each row execute function log_package_added();

-- Auto-log when a package is deleted
create or replace function log_package_removed()
returns trigger language plpgsql as $$
begin
  insert into inventory_logs (package_id, product_id, shelf_id, action_type, quantity, unit)
  values (old.id, old.product_id, old.shelf_id, 'package_removed', old.quantity, old.unit);
  return old;
end;
$$;

create trigger trg_log_package_removed
after delete on packages
for each row execute function log_package_removed();

-- ============================================================
-- RLS POLICIES
-- ============================================================
alter table shelves         enable row level security;
alter table products        enable row level security;
alter table packages        enable row level security;
alter table inventory_logs  enable row level security;

-- Authenticated users can read everything
create policy "Authenticated users can read shelves"
  on shelves for select to authenticated using (true);

create policy "Authenticated users can read products"
  on products for select to authenticated using (true);

create policy "Authenticated users can read packages"
  on packages for select to authenticated using (true);

create policy "Authenticated users can read logs"
  on inventory_logs for select to authenticated using (true);

-- Authenticated users can write packages
create policy "Authenticated users can insert packages"
  on packages for insert to authenticated with check (true);

create policy "Authenticated users can update packages"
  on packages for update to authenticated using (true);

create policy "Authenticated users can delete packages"
  on packages for delete to authenticated using (true);

-- Authenticated users can manage products and shelves
create policy "Authenticated users can manage products"
  on products for all to authenticated using (true);

create policy "Authenticated users can manage shelves"
  on shelves for all to authenticated using (true);

-- ============================================================
-- RPC: total stock per product
-- ============================================================
create or replace function get_product_total_stock(p_product_id uuid)
returns table (product_id uuid, total_quantity numeric, unit text)
language sql stable as $$
  select
    product_id,
    sum(quantity) as total_quantity,
    unit
  from packages
  where product_id = p_product_id
  group by product_id, unit;
$$;
