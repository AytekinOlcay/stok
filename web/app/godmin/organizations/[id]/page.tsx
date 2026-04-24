import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Organizasyon Detayı — Godmin" };

export default async function GodminOrgDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createClient();

  const [{ data: org }, { data: members }, { data: freezers }] =
    await Promise.all([
      supabase
        .from("organizations")
        .select("id, name, created_at")
        .eq("id", id)
        .single(),
      supabase
        .from("organization_members")
        .select("id, user_id, role, created_at")
        .eq("org_id", id)
        .order("created_at"),
      supabase
        .from("freezers")
        .select("id, name, shelf_count, created_at")
        .eq("org_id", id)
        .order("created_at"),
    ]);

  if (!org) notFound();

  // Enrich members with emails via auth admin API
  let userEmails: Record<string, string> = {};
  try {
    const { data: { users } } = await supabase.auth.admin.listUsers({
      perPage: 1000,
    });
    if (users) {
      userEmails = Object.fromEntries(users.map((u) => [u.id, u.email ?? u.id]));
    }
  } catch {
    // auth.admin not available — fall back to showing user IDs
  }

  return (
    <div className="p-8 space-y-8 max-w-4xl">
      <div className="flex items-center gap-3">
        <Link
          href="/godmin/organizations"
          className="text-sm text-muted-foreground hover:underline"
        >
          ← Organizasyonlar
        </Link>
      </div>

      {/* Org info */}
      <div className="rounded-lg border p-5 bg-muted/20">
        <h1 className="text-2xl font-bold">{org.name}</h1>
        <p className="text-sm text-muted-foreground mt-1">
          Oluşturulma: {new Date(org.created_at).toLocaleDateString("tr-TR")}
        </p>
        <p className="text-xs text-muted-foreground mt-0.5 font-mono">{org.id}</p>
      </div>

      {/* Members */}
      <section>
        <h2 className="text-lg font-semibold mb-3">
          Üyeler ({members?.length ?? 0})
        </h2>
        <div className="rounded-lg border overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-muted/50">
              <tr>
                <th className="text-left px-4 py-3 font-semibold">E-posta</th>
                <th className="text-left px-4 py-3 font-semibold">Rol</th>
                <th className="text-left px-4 py-3 font-semibold">Katıldı</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {!members || members.length === 0 ? (
                <tr>
                  <td colSpan={3} className="px-4 py-6 text-center text-muted-foreground">
                    Üye yok.
                  </td>
                </tr>
              ) : (
                members.map((m) => (
                  <tr key={m.id} className="hover:bg-muted/30 transition-colors">
                    <td className="px-4 py-3">
                      {userEmails[m.user_id] ?? (
                        <span className="font-mono text-xs text-muted-foreground">
                          {m.user_id}
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <span
                        className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${
                          m.role === "owner"
                            ? "bg-amber-100 text-amber-800"
                            : "bg-slate-100 text-slate-700"
                        }`}
                      >
                        {m.role === "owner" ? "Sahip" : "Üye"}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-muted-foreground">
                      {new Date(m.created_at).toLocaleDateString("tr-TR")}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>

      {/* Freezers — names only, no contents */}
      <section>
        <h2 className="text-lg font-semibold mb-3">
          Dondurucular ({freezers?.length ?? 0})
        </h2>
        <div className="rounded-lg border overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-muted/50">
              <tr>
                <th className="text-left px-4 py-3 font-semibold">Ad</th>
                <th className="text-left px-4 py-3 font-semibold">Raf Sayısı</th>
                <th className="text-left px-4 py-3 font-semibold">Oluşturulma</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {!freezers || freezers.length === 0 ? (
                <tr>
                  <td colSpan={3} className="px-4 py-6 text-center text-muted-foreground">
                    Dondurucu yok.
                  </td>
                </tr>
              ) : (
                freezers.map((f) => (
                  <tr key={f.id} className="hover:bg-muted/30 transition-colors">
                    <td className="px-4 py-3 font-medium">{f.name}</td>
                    <td className="px-4 py-3 text-muted-foreground">{f.shelf_count}</td>
                    <td className="px-4 py-3 text-muted-foreground">
                      {new Date(f.created_at).toLocaleDateString("tr-TR")}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
