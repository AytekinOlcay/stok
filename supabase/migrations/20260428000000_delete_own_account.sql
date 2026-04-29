-- ============================================================
-- delete_own_account()
--
-- Allows a logged-in user to delete their own auth account
-- from the client without exposing service-role credentials.
--
-- Behaviour:
--   - If the user is the ONLY owner of their org, the org and
--     all its data cascade-deletes (org → freezers → shelves →
--     packages, inventory_logs etc. via FK ON DELETE CASCADE).
--   - If there is at least one other owner, the user is simply
--     removed from the org and their auth account is deleted.
--   - auth.users deletion is done via auth.delete_user() which
--     requires SECURITY DEFINER + service_role context.
-- ============================================================

create or replace function delete_own_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id   uuid := auth.uid();
  v_org_id    uuid;
  v_owner_count int;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  -- Find this user's org
  select org_id into v_org_id
  from organization_members
  where user_id = v_user_id
  limit 1;

  if v_org_id is not null then
    -- Count remaining owners (excluding current user)
    select count(*) into v_owner_count
    from organization_members
    where org_id = v_org_id
      and role = 'owner'
      and user_id <> v_user_id;

    if v_owner_count = 0 then
      -- Last owner → delete the whole org (cascades to all data)
      delete from organizations where id = v_org_id;
    else
      -- Other owners exist → just remove this member
      delete from organization_members
      where org_id = v_org_id and user_id = v_user_id;
    end if;
  end if;

  -- Delete the auth user (requires SECURITY DEFINER with service_role)
  delete from auth.users where id = v_user_id;
end;
$$;
