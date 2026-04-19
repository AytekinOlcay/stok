-- Trigger functions run in the calling user's security context by default.
-- When the anon role inserts a package, the log trigger also runs as anon
-- and hits RLS on inventory_logs. SECURITY DEFINER makes the functions
-- execute as their owner (postgres/superuser), bypassing RLS.

create or replace function log_package_added()
  returns trigger
  language plpgsql
  security definer
  set search_path = public
as $$
begin
  insert into inventory_logs (package_id, product_id, shelf_id, action_type, quantity, unit, performed_by)
  values (new.id, new.product_id, new.shelf_id, 'package_added', new.quantity, new.unit, new.created_by);
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
  insert into inventory_logs (package_id, product_id, shelf_id, action_type, quantity, unit, performed_by)
  values (old.id, old.product_id, old.shelf_id, 'package_removed', old.quantity, old.unit, old.created_by);
  return old;
end;
$$;
