import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { RecipeForm } from "./_components/recipe-form";

export const metadata = { title: "Yeni Tarif" };

export default async function NewRecipePage() {
  const supabase = await createClient();

  const { data: products } = await supabase
    .from("products")
    .select("id, name, category, default_unit")
    .order("name");

  return (
    <main className="p-6 space-y-6">
      <div className="flex items-center gap-3">
        <Link href="/recipes" className="text-sm text-muted-foreground hover:text-foreground">
          ← Tarifler
        </Link>
        <span className="text-muted-foreground">/</span>
        <h1 className="text-2xl font-bold">Yeni Tarif</h1>
      </div>

      <RecipeForm products={products ?? []} />
    </main>
  );
}
