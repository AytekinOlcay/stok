"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export async function createShelf(formData: FormData) {
  const supabase = await createClient();

  const name = formData.get("name") as string;
  const position = Number(formData.get("position"));

  if (!name || !position) {
    throw new Error("Name and position are required.");
  }

  const { error } = await supabase.from("shelves").insert({ name, position });
  if (error) throw new Error(error.message);
  revalidatePath("/shelves");
}

export async function updateShelf(id: string, formData: FormData) {
  const supabase = await createClient();

  const name = formData.get("name") as string;
  const position = Number(formData.get("position"));

  if (!name || !position) {
    throw new Error("Name and position are required.");
  }

  const { error } = await supabase
    .from("shelves")
    .update({ name, position })
    .eq("id", id);

  if (error) throw new Error(error.message);
  revalidatePath("/shelves");
}

export async function deleteShelf(id: string) {
  const supabase = await createClient();
  const { error } = await supabase.from("shelves").delete().eq("id", id);
  if (error) throw new Error(error.message);
  revalidatePath("/shelves");
}
