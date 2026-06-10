-- ============================================================
-- Recipe System
-- Recipes are org-scoped. Video metadata is stored pre-parsed
-- so clients never need to parse URLs at read time.
-- ============================================================

-- 1. Video source enum
create type video_source_type as enum (
  'youtube', 'vimeo', 'instagram', 'tiktok', 'other'
);

-- 2. Recipes table
create table recipes (
  id              uuid primary key default gen_random_uuid(),
  org_id          uuid not null references organizations(id) on delete cascade,
  title           text not null,
  description     text,
  prep_time_min   integer,
  -- original URL pasted by the user
  video_url       text,
  -- parsed fields stored at write time
  video_source    video_source_type,
  video_embed_url text,          -- null means no embed available
  video_thumbnail text,
  -- attribution
  created_by      uuid references auth.users(id) on delete set null,
  updated_by      uuid references auth.users(id) on delete set null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  deleted_at      timestamptz          -- soft delete
);

-- 3. Recipe ↔ Product mapping (many-to-many)
create table recipe_products (
  id         uuid primary key default gen_random_uuid(),
  recipe_id  uuid not null references recipes(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  quantity   numeric,
  unit       text,
  sort_order integer not null default 0,
  unique (recipe_id, product_id)
);

-- 4. Indexes
create index recipes_org_idx      on recipes (org_id) where deleted_at is null;
create index recipe_products_recipe_idx  on recipe_products (recipe_id);
create index recipe_products_product_idx on recipe_products (product_id);

-- 5. updated_at trigger
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger recipes_set_updated_at
  before update on recipes
  for each row execute function set_updated_at();

-- 6. RLS
alter table recipes         enable row level security;
alter table recipe_products enable row level security;

-- Recipes: org members can read active recipes
create policy "recipes_select" on recipes
  for select using (org_id = auth_user_org_id() and deleted_at is null);

create policy "recipes_insert" on recipes
  for insert with check (org_id = auth_user_org_id());

create policy "recipes_update" on recipes
  for update using (org_id = auth_user_org_id());

-- recipe_products: accessible when parent recipe is accessible
create policy "recipe_products_select" on recipe_products
  for select using (
    exists (
      select 1 from recipes
      where id = recipe_id
        and org_id = auth_user_org_id()
        and deleted_at is null
    )
  );

create policy "recipe_products_insert" on recipe_products
  for insert with check (
    exists (
      select 1 from recipes
      where id = recipe_id
        and org_id = auth_user_org_id()
    )
  );

create policy "recipe_products_delete" on recipe_products
  for delete using (
    exists (
      select 1 from recipes
      where id = recipe_id
        and org_id = auth_user_org_id()
    )
  );

-- Godmin can view recipe metadata (title, counts) but not contents —
-- consistent with the visibility rules established for organizations.
create policy "godmin_view_recipes" on recipes
  for select using (is_platform_admin());
