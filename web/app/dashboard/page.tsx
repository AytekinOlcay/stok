import { createClient } from "@/lib/supabase/server";

export default async function DashboardPage() {
  const supabase = await createClient();

  const [{ count: productCount }, { count: packageCount }, { count: shelfCount }] =
    await Promise.all([
      supabase.from("products").select("*", { count: "exact", head: true }),
      supabase.from("packages").select("*", { count: "exact", head: true }),
      supabase.from("shelves").select("*", { count: "exact", head: true }),
    ]);

  return (
    <main className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Dashboard</h1>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard label="Products" value={productCount ?? 0} />
        <StatCard label="Packages in Freezer" value={packageCount ?? 0} />
        <StatCard label="Shelves" value={shelfCount ?? 0} />
      </div>
    </main>
  );
}

function StatCard({ label, value }: { label: string; value: number }) {
  return (
    <div className="rounded-lg border bg-card p-4 shadow-sm">
      <p className="text-sm text-muted-foreground">{label}</p>
      <p className="text-3xl font-bold mt-1">{value}</p>
    </div>
  );
}
