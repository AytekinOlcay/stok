-- Allow anonymous (unauthenticated) access for mobile home-use without auth.
-- TODO: When user authentication is added, tighten these policies to require auth.

create policy "anon_select_shelves"
  on shelves for select to anon using (true);

create policy "anon_select_products"
  on products for select to anon using (true);

create policy "anon_insert_products"
  on products for insert to anon with check (true);

create policy "anon_update_products"
  on products for update to anon using (true) with check (true);

create policy "anon_select_packages"
  on packages for select to anon using (true);

create policy "anon_insert_packages"
  on packages for insert to anon with check (true);

create policy "anon_update_packages"
  on packages for update to anon using (true) with check (true);

create policy "anon_delete_packages"
  on packages for delete to anon using (true);

create policy "anon_select_logs"
  on inventory_logs for select to anon using (true);
