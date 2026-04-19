-- Atomic consume function. Runs as owner (SECURITY DEFINER) so it can
-- write to inventory_logs regardless of the caller's RLS context.
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
  -- Lock the row
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
    -- Full consumption: delete triggers log_package_removed automatically
    delete from packages where id = p_package_id;
    return jsonb_build_object('action', 'removed', 'remaining', 0);
  else
    -- Partial consumption: update quantity and log manually
    update packages set quantity = v_remaining where id = p_package_id;

    insert into inventory_logs (
      package_id, product_id, shelf_id,
      action_type, quantity, unit, performed_by
    ) values (
      v_pkg.id, v_pkg.product_id, v_pkg.shelf_id,
      'quantity_adjusted', p_amount, v_pkg.unit, v_pkg.created_by
    );

    return jsonb_build_object('action', 'adjusted', 'remaining', v_remaining);
  end if;
end;
$$;

-- Allow anon to call this RPC
grant execute on function consume_package(uuid, numeric) to anon;
