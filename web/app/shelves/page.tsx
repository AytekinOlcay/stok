import { createClient } from "@/lib/supabase/server";

export default async function ShelvesPage() {
  const supabase = await createClient();
  const { data: shelves } = await supabase
    .from("shelves")
    .select("id, name, position, qr_code")
    .order("position");

  return (
    <main className="p-6 space-y-4">
      <h1 className="text-2xl font-bold">Shelves</h1>
      <table className="w-full text-sm border rounded-lg overflow-hidden">
        <thead className="bg-muted text-left">
          <tr>
            <th className="px-4 py-2">Position</th>
            <th className="px-4 py-2">Name</th>
            <th className="px-4 py-2">QR Code</th>
          </tr>
        </thead>
        <tbody>
          {shelves?.map((s) => (
            <tr key={s.id} className="border-t">
              <td className="px-4 py-2">{s.position}</td>
              <td className="px-4 py-2">{s.name}</td>
              <td className="px-4 py-2 font-mono text-xs">{s.qr_code ?? "—"}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </main>
  );
}
