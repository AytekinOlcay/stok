"use client";

import { signOut } from "@/app/login/actions";

export function SignOutButton() {
  return (
    <button
      onClick={() => signOut()}
      className="w-full flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium text-muted-foreground hover:bg-accent hover:text-accent-foreground transition-colors"
    >
      🚪 Çıkış Yap
    </button>
  );
}
