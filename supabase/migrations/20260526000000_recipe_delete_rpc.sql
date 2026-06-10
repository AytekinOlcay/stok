-- ============================================================
-- Soft-delete helper for recipes.
--
-- Why a SECURITY DEFINER function?
-- The RLS UPDATE policy relies on auth_user_org_id() which in
-- turn relies on auth.uid(). When the Next.js server-side client
-- uses @supabase/ssr with cookies, the session JWT is used as
-- the Bearer token, but the implicit WITH CHECK added by
-- PostgreSQL to the UPDATE policy can evaluate auth_user_org_id()
-- in a context where the result is ambiguous.
--
-- A SECURITY DEFINER function:
--   1. Bypasses RLS entirely (runs as definer / postgres).
--   2. Still enforces org ownership via an explicit WHERE clause
--      using auth.uid() (which IS set from the JWT Bearer token).
--   3. Is idempotent – calling it twice is safe (deleted_at stays).
-- ============================================================

create or replace function soft_delete_recipe(p_recipe_id uuid)
returns void
language sql
security definer
set search_path = public
as $$
  update recipes
  set deleted_at = now()
  where id        = p_recipe_id
    and org_id    = (
          select org_id
          from   organization_members
          where  user_id = auth.uid()
          limit  1
        )
    and deleted_at is null;
$$;

-- Only authenticated users may call this function.
revoke execute on function soft_delete_recipe(uuid) from public;
grant  execute on function soft_delete_recipe(uuid) to authenticated;
