import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createAuthClient } from "@/lib/supabase/auth-server";

const godminNav = [
  { href: "/godmin/organizations", label: "🏢 Organizasyonlar" },
  { href: "/godmin/users", label: "👥 Kullanıcılar" },
];

export default async function GodminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const authClient = await createAuthClient();
  const {
    data: { user },
  } = await authClient.auth.getUser();

  if (!user) redirect("/login");

  // Double-check platform admin status (middleware is the first gate,
  // this layout is the second — service role bypasses RLS).
  const supabase = await createClient();
  const { data: adminRow } = await supabase
    .from("platform_admins")
    .select("user_id")
    .eq("user_id", user.id)
    .maybeSingle();

  if (!adminRow) redirect("/dashboard");

  return (
    <div className="flex h-full">
      {/* Godmin sub-sidebar */}
      <aside className="w-52 shrink-0 border-r bg-amber-50/50 flex flex-col">
        <div className="px-4 py-4 border-b">
          <p className="text-xs font-semibold text-amber-600 uppercase tracking-wider">
            Godmin Panel
          </p>
          <p className="text-xs text-muted-foreground mt-0.5 truncate">
            {user.email}
          </p>
        </div>
        <nav className="flex-1 px-2 py-3 space-y-1">
          {godminNav.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium hover:bg-amber-100 transition-colors"
            >
              {item.label}
            </Link>
          ))}
        </nav>
        <div className="px-2 py-3 border-t">
          <Link
            href="/dashboard"
            className="flex items-center gap-2 rounded-md px-3 py-2 text-sm text-muted-foreground hover:bg-accent transition-colors"
          >
            ← Panele Dön
          </Link>
        </div>
      </aside>

      <div className="flex-1 overflow-auto">{children}</div>
    </div>
  );
}
