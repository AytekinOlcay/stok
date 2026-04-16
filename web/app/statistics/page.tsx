import { createClient } from "@/lib/supabase/server";

export default async function StatisticsPage() {
  const supabase = await createClient();

  // Monthly consumption: sum of package_removed actions in current month
  const startOfMonth = new Date();
  startOfMonth.setDate(1);
  startOfMonth.setHours(0, 0, 0, 0);

  const { data: consumption } = await supabase
    .from("inventory_logs")
    .select("quantity, unit, products(name)")
    .eq("action_type", "package_removed")
    .gte("created_at", startOfMonth.toISOString());

  // Group by product
  const grouped: Record<string, { name: string; total: number; unit: string }> = {};
  for (const row of consumption ?? []) {
    const name = (row.products as { name: string } | null)?.name ?? "Unknown";
    if (!grouped[name]) grouped[name] = { name, total: 0, unit: row.unit };
    grouped[name].total += Number(row.quantity);
  }

  return (
    <main className="p-6 space-y-4">
      <h1 className="text-2xl font-bold">Statistics</h1>
      <h2 className="text-lg font-semibold">This month you consumed:</h2>
      {Object.values(grouped).length === 0 ? (
        <p className="text-muted-foreground">No consumption recorded this month.</p>
      ) : (
        <ul className="space-y-2">
          {Object.values(grouped).map((item) => (
            <li key={item.name} className="flex gap-2">
              <span className="font-medium">{item.total}{item.unit}</span>
              <span>{item.name}</span>
            </li>
          ))}
        </ul>
      )}
    </main>
  );
}
