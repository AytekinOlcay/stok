-- Fix create_invitation: replace gen_random_bytes() (requires pgcrypto)
-- with gen_random_uuid() which is always available in Postgres 13+.

create or replace function create_invitation()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_org_id  uuid;
  v_token   text;
  v_expires timestamptz;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select org_id into v_org_id
  from organization_members
  where user_id = v_user_id and role = 'owner'
  limit 1;

  if v_org_id is null then
    raise exception 'Yalnızca sahipler davet oluşturabilir';
  end if;

  -- Generate unique 6-char uppercase token from UUID (no pgcrypto needed)
  loop
    v_token := upper(substring(replace(gen_random_uuid()::text, '-', '') from 1 for 6));
    exit when not exists (select 1 from invitations where token = v_token);
  end loop;

  v_expires := now() + interval '7 days';

  insert into invitations (org_id, token, created_by, expires_at)
  values (v_org_id, v_token, v_user_id, v_expires);

  return jsonb_build_object(
    'token', v_token,
    'expires_at', v_expires
  );
end;
$$;
