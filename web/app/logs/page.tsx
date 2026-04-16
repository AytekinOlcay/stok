import { createClient } from "@/lib/supabase/server";

export default async function LogsPage() {
  const supabase = await createClient();
  const { data: logs } = await supabase
    .from("inventory_logs")
    .select("id, action_type, quantity, unit, created_at, products(name), shelves(name)")
    .order("created_at", { ascending: false })
    .limit(100);

  return (
    <main className="p-6 space-y-4">
      <h1 className="text-2xl font-bold">Inventory Logs</h1>
      <table className="w-full text-sm border rounded-lg overflow-hidden">
        <thead className="bg-muted text-left">
          <tr>
            <th className="px-4 py-2">Date</th>
            <th className="px-4 py-2">Action</th>
            <th className="px-4 py-2">Product</th>
            <th className="px-4 py-2">Shelf</th>
            <th className="px-4 py-2">Qty</th>
          </tr>
        </thead>
        <tbody>
          {logs?.map((l) => (
            <tr key={l.id} className="border-t">
              <td className="px-4 py-2">{new Date(l.created_at).toLocaleDateString()}</td>
              <td className="px-4 py-2">{l.action_type}</td>
              <td className="px-4 py-2">{(l.products as { name: string } | null)?.name ?? "—"}</td>
              <td className="px-4 py-2">{(l.shelves as { name: string } | null)?.name ?? "—"}</td>
              <td className="px-4 py-2">{l.quantity} {l.unit}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </main>
  );
}
