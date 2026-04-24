import Link from "next/link";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Kullanıcılar — Godmin" };

export default async function GodminUsersPage() {
  const supabase = await createClient();

  // Fetch all org members with org names
  const { data: members, error } = await supabase
    .from("organization_members")
    .select("id, user_id, org_id, role, created_at, organizations(name)")
    .order("created_at", { ascending: false });

  // Enrich with emails via auth admin API
  let userEmails: Record<string, string> = {};
  try {
    const {
      data: { users },
    } = await supabase.auth.admin.listUsers({ perPage: 1000 });
    if (users) {
      userEmails = Object.fromEntries(
        users.map((u) => [u.id, u.email ?? u.id])
      );
    }
  } catch {
    // Fallback: show user IDs
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Kullanıcılar</h1>

      {error && (
        <p className="text-red-500 text-sm mb-4">Hata: {error.message}</p>
      )}

      <div className="rounded-lg border overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-muted/50">
            <tr>
              <th className="text-left px-4 py-3 font-semibold">E-posta</th>
              <th className="text-left px-4 py-3 font-semibold">Organizasyon</th>
              <th className="text-left px-4 py-3 font-semibold">Rol</th>
              <th className="text-left px-4 py-3 font-semibold">Katıldı</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {!members || members.length === 0 ? (
              <tr>
                <td
                  colSpan={4}
                  className="px-4 py-8 text-center text-muted-foreground"
                >
                  Henüz kullanıcı yok.
                </td>
              </tr>
            ) : (
              members.map((m) => {
                const orgName = Array.isArray(m.organizations)
                  ? (m.organizations[0] as { name: string } | undefined)?.name
                  : (m.organizations as { name: string } | null)?.name;

                return (
                  <tr
                    key={m.id}
                    className="hover:bg-muted/30 transition-colors"
                  >
                    <td className="px-4 py-3">
                      {userEmails[m.user_id] ?? (
                        <span className="font-mono text-xs text-muted-foreground">
                          {m.user_id}
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-muted-foreground">
                      <Link
                        href={`/godmin/organizations/${m.org_id}`}
                        className="hover:underline text-blue-600"
                      >
                        {orgName ?? m.org_id}
                      </Link>
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
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
