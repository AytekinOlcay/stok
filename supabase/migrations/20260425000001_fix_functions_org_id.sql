-- Fix trigger functions and RPCs to include org_id after multi-tenancy migration.
-- inventory_logs.org_id is now NOT NULL, so all inserts must include it.

-- ============================================================
-- TRIGGERS: include org_id from package row
-- ============================================================
create or replace function log_package_added()
  returns trigger
  language plpgsql
  security definer
  set search_path = public
as $$
begin
  insert into inventory_logs (
    package_id, product_id, shelf_id, org_id,
    action_type, quantity, unit, performed_by
  ) values (
    new.id, new.product_id, new.shelf_id, new.org_id,
    'package_added', new.quantity, new.unit, new.created_by
  );
  return new;
end;
$$;

create or replace function log_package_removed()
  returns trigger
  language plpgsql
  security definer
  set search_path = public
as $$
begin
  insert into inventory_logs (
    package_id, product_id, shelf_id, org_id,
    action_type, quantity, unit, performed_by
  ) values (
    old.id, old.product_id, old.shelf_id, old.org_id,
    'package_removed', old.quantity, old.unit, old.created_by
  );
  return old;
end;
$$;

-- ============================================================
-- RPC: consume_package — include org_id in log insert
-- ============================================================
create or replace function consume_package(
  p_package_id uuid,
  p_amount     numeric
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pkg        packages%rowtype;
  v_remaining  numeric;
begin
  select * into v_pkg from packages where id = p_package_id for update;

  if not found then
    raise exception 'Package not found';
  end if;

  if p_amount <= 0 then
    raise exception 'Amount must be positive';
  end if;

  if p_amount > v_pkg.quantity then
    raise exception 'Amount exceeds available quantity (%.2f %)', v_pkg.quantity, v_pkg.unit;
  end if;

  v_remaining := v_pkg.quantity - p_amount;

  if v_remaining = 0 then
    delete from packages where id = p_package_id;
    return jsonb_build_object('action', 'removed', 'remaining', 0);
  else
    update packages set quantity = v_remaining where id = p_package_id;

    insert into inventory_logs (
      package_id, product_id, shelf_id, org_id,
      action_type, quantity, unit, performed_by
    ) values (
      v_pkg.id, v_pkg.product_id, v_pkg.shelf_id, v_pkg.org_id,
      'quantity_adjusted', p_amount, v_pkg.unit, v_pkg.created_by
    );

    return jsonb_build_object('action', 'adjusted', 'remaining', v_remaining);
  end if;
end;
$$;
