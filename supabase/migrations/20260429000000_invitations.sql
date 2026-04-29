-- ============================================================
-- Invitation System
--
-- Org owners create short-lived 6-char tokens.
-- Any authenticated user can join an org by entering the token.
-- QR payload: {"type":"invitation","token":"ABCDEF"}
-- ============================================================

-- 1. Invitations table
create table invitations (
  id         uuid primary key default gen_random_uuid(),
  org_id     uuid not null references organizations(id) on delete cascade,
  token      text not null unique,
  created_by uuid not null references auth.users(id) on delete cascade,
  expires_at timestamptz not null default now() + interval '7 days',
  used_at    timestamptz,
  used_by    uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table invitations enable row level security;

-- Org owners can read/manage their own org's invitations
create policy "invitations_owner_select"
  on invitations for select
  using (
    org_id = auth_user_org_id()
    and exists (
      select 1 from organization_members
      where org_id = invitations.org_id
        and user_id = auth.uid()
        and role = 'owner'
    )
  );

-- 2. RPC: create_invitation
--    Only org owners may call. Returns {token, expires_at}.
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

  -- Find caller's org where they are owner
  select org_id into v_org_id
  from organization_members
  where user_id = v_user_id and role = 'owner'
  limit 1;

  if v_org_id is null then
    raise exception 'Yalnızca sahipler davet oluşturabilir';
  end if;

  -- Generate unique 6-char uppercase hex token
  loop
    v_token := upper(substring(encode(gen_random_bytes(4), 'hex') from 1 for 6));
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

-- 3. RPC: join_org_by_token
--    Any authenticated user can call. Returns {org_id, org_name}.
create or replace function join_org_by_token(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id   uuid := auth.uid();
  v_inv       invitations%rowtype;
  v_org_name  text;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  -- Find valid, unused, unexpired invitation
  select * into v_inv
  from invitations
  where token = upper(trim(p_token))
    and used_at is null
    and expires_at > now();

  if not found then
    raise exception 'Geçersiz veya süresi dolmuş davet kodu';
  end if;

  -- Already a member?
  if exists (
    select 1 from organization_members
    where org_id = v_inv.org_id and user_id = v_user_id
  ) then
    raise exception 'Bu organizasyona zaten üyesiniz';
  end if;

  select name into v_org_name from organizations where id = v_inv.org_id;

  -- Add as member
  insert into organization_members (org_id, user_id, role)
  values (v_inv.org_id, v_user_id, 'member');

  -- Mark invitation as used
  update invitations
  set used_at = now(), used_by = v_user_id
  where id = v_inv.id;

  return jsonb_build_object(
    'org_id', v_inv.org_id,
    'org_name', v_org_name
  );
end;
$$;
