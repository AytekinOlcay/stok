-- Fix: log_package_removed must run BEFORE DELETE so the package row
-- still exists when the FK on inventory_logs.package_id is checked.
-- (AFTER DELETE fires after the row is gone → FK violation)

-- Drop old trigger first, then recreate as BEFORE DELETE
drop trigger if exists trg_log_package_removed on packages;

create or replace function log_package_removed()
  returns trigger
  language plpgsql
  security definer
  set search_path = public
as $$
begin
  insert into inventory_logs (
    package_id, product_id, shelf_id,
    action_type, quantity, unit, performed_by
  )
  values (
    old.id, old.product_id, old.shelf_id,
    'package_removed', old.quantity, old.unit, old.created_by
  );
  return old;
end;
$$;

create trigger trg_log_package_removed
before delete on packages
for each row execute function log_package_removed();
