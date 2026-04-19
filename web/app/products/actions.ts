"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export async function createProduct(formData: FormData) {
  const supabase = await createClient();

  const name = formData.get("name") as string;
  const category = (formData.get("category") as string) || null;
  const default_unit = formData.get("default_unit") as string;
  const recommended_freezer_storage_days = Number(
    formData.get("recommended_freezer_storage_days")
  );

  if (!name || !default_unit || !recommended_freezer_storage_days) {
    throw new Error("Name, unit and storage days are required.");
  }

  const { error } = await supabase.from("products").insert({
    name,
    category,
    default_unit,
    recommended_freezer_storage_days,
  });

  if (error) throw new Error(error.message);
  revalidatePath("/products");
}

export async function updateProduct(id: string, formData: FormData) {
  const supabase = await createClient();

  const name = formData.get("name") as string;
  const category = (formData.get("category") as string) || null;
  const default_unit = formData.get("default_unit") as string;
  const recommended_freezer_storage_days = Number(
    formData.get("recommended_freezer_storage_days")
  );

  if (!name || !default_unit || !recommended_freezer_storage_days) {
    throw new Error("Name, unit and storage days are required.");
  }

  const { error } = await supabase
    .from("products")
    .update({ name, category, default_unit, recommended_freezer_storage_days })
    .eq("id", id);

  if (error) throw new Error(error.message);
  revalidatePath("/products");
}

export async function deleteProduct(id: string) {
  const supabase = await createClient();
  const { error } = await supabase.from("products").delete().eq("id", id);
  if (error) throw new Error(error.message);
  revalidatePath("/products");
}
