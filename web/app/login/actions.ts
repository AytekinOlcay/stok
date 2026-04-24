"use server";

import { redirect } from "next/navigation";
import { createAuthClient } from "@/lib/supabase/auth-server";

export async function signIn(formData: FormData) {
  const email = formData.get("email") as string;
  const password = formData.get("password") as string;

  const supabase = await createAuthClient();
  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    return { error: "E-posta veya şifre hatalı." };
  }

  redirect("/dashboard");
}

export async function signOut() {
  const supabase = await createAuthClient();
  await supabase.auth.signOut();
  redirect("/login");
}
