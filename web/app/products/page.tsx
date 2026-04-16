import { createClient } from "@/lib/supabase/server";

export default async function ProductsPage() {
  const supabase = await createClient();
  const { data: products } = await supabase
    .from("products")
    .select("*")
    .order("name");

  return (
    <main className="p-6 space-y-4">
      <h1 className="text-2xl font-bold">Products</h1>
      <table className="w-full text-sm border rounded-lg overflow-hidden">
        <thead className="bg-muted text-left">
          <tr>
            <th className="px-4 py-2">Name</th>
            <th className="px-4 py-2">Category</th>
            <th className="px-4 py-2">Default Unit</th>
            <th className="px-4 py-2">Storage Days</th>
          </tr>
        </thead>
        <tbody>
          {products?.map((p) => (
            <tr key={p.id} className="border-t">
              <td className="px-4 py-2">{p.name}</td>
              <td className="px-4 py-2">{p.category}</td>
              <td className="px-4 py-2">{p.default_unit}</td>
              <td className="px-4 py-2">{p.recommended_freezer_storage_days}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </main>
  );
}
