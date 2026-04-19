import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/badge";
import { ShelfFormDialog } from "./_components/shelf-form-dialog";
import { DeleteShelfButton } from "./_components/delete-shelf-button";

export default async function ShelvesPage() {
  const supabase = await createClient();

  const [{ data: shelves }, { count: packageCount }] = await Promise.all([
    supabase
      .from("shelves")
      .select("id, name, position, qr_code")
      .order("position"),
    supabase
      .from("packages")
      .select("shelf_id", { count: "exact", head: true }),
  ]);

  // Package count per shelf
  const { data: perShelf } = await supabase
    .from("packages")
    .select("shelf_id")
    .not("shelf_id", "is", null);

  const countMap: Record<string, number> = {};
  for (const row of perShelf ?? []) {
    countMap[row.shelf_id] = (countMap[row.shelf_id] ?? 0) + 1;
  }

  return (
    <main className="p-6 space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Shelves</h1>
          <p className="text-sm text-muted-foreground mt-0.5">
            {shelves?.length ?? 0} shelves · {packageCount ?? 0} packages total
          </p>
        </div>
        <ShelfFormDialog />
      </div>

      <table className="w-full text-sm border rounded-lg overflow-hidden">
        <thead className="bg-muted text-left">
          <tr>
            <th className="px-4 py-2">#</th>
            <th className="px-4 py-2">Name</th>
            <th className="px-4 py-2">Packages</th>
            <th className="px-4 py-2">QR Code</th>
            <th className="px-4 py-2 w-28">Actions</th>
          </tr>
        </thead>
        <tbody>
          {shelves?.map((s) => (
            <tr key={s.id} className="border-t hover:bg-muted/30">
              <td className="px-4 py-2 text-muted-foreground">{s.position}</td>
              <td className="px-4 py-2 font-medium">{s.name}</td>
              <td className="px-4 py-2">
                <Badge variant="outline">{countMap[s.id] ?? 0}</Badge>
              </td>
              <td className="px-4 py-2 font-mono text-xs text-muted-foreground">
                {s.qr_code ?? "—"}
              </td>
              <td className="px-4 py-2">
                <div className="flex gap-1">
                  <ShelfFormDialog
                    shelf={s}
                    trigger={
                      <button className="text-xs px-2 py-1 rounded hover:bg-muted border">
                        Edit
                      </button>
                    }
                  />
                  <DeleteShelfButton id={s.id} />
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </main>
  );
}
