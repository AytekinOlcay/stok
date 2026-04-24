import Link from "next/link";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Organizasyonlar — Godmin" };

export default async function GodminOrganizationsPage() {
  const supabase = await createClient();

  const { data: orgs, error } = await supabase
    .from("organizations")
    .select(
      `id, name, created_at,
       organization_members(count),
       freezers(count)`
    )
    .order("created_at", { ascending: false });

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Organizasyonlar</h1>

      {error && (
        <p className="text-red-500 text-sm mb-4">Hata: {error.message}</p>
      )}

      <div className="rounded-lg border overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-muted/50">
            <tr>
              <th className="text-left px-4 py-3 font-semibold">Ad</th>
              <th className="text-left px-4 py-3 font-semibold">Üye</th>
              <th className="text-left px-4 py-3 font-semibold">Dondurucular</th>
              <th className="text-left px-4 py-3 font-semibold">Oluşturulma</th>
              <th className="px-4 py-3" />
            </tr>
          </thead>
          <tbody className="divide-y">
            {!orgs || orgs.length === 0 ? (
              <tr>
                <td colSpan={5} className="px-4 py-8 text-center text-muted-foreground">
                  Henüz organizasyon yok.
                </td>
              </tr>
            ) : (
              orgs.map((org) => {
                // Supabase returns count queries as [{ count: N }]
                const memberCount =
                  Array.isArray(org.organization_members)
                    ? (org.organization_members[0] as { count: number } | undefined)?.count ?? 0
                    : 0;
                const freezerCount =
                  Array.isArray(org.freezers)
                    ? (org.freezers[0] as { count: number } | undefined)?.count ?? 0
                    : 0;

                return (
                  <tr key={org.id} className="hover:bg-muted/30 transition-colors">
                    <td className="px-4 py-3 font-medium">{org.name}</td>
                    <td className="px-4 py-3 text-muted-foreground">{memberCount}</td>
                    <td className="px-4 py-3 text-muted-foreground">{freezerCount}</td>
                    <td className="px-4 py-3 text-muted-foreground">
                      {new Date(org.created_at).toLocaleDateString("tr-TR")}
                    </td>
                    <td className="px-4 py-3 text-right">
                      <Link
                        href={`/godmin/organizations/${org.id}`}
                        className="text-xs font-medium text-blue-600 hover:underline"
                      >
                        Detay →
                      </Link>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
