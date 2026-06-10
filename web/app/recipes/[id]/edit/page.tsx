import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { RecipeEditForm } from "./_components/recipe-edit-form";

interface Props {
  params: Promise<{ id: string }>;
}

export async function generateMetadata({ params }: Props) {
  const { id } = await params;
  const supabase = await createClient();
  const { data } = await supabase.from("recipes").select("title").eq("id", id).single();
  return { title: data ? `Düzenle: ${data.title}` : "Tarif Düzenle" };
}

export default async function EditRecipePage({ params }: Props) {
  const { id } = await params;
  const supabase = await createClient();

  const [{ data: recipe }, { data: products }] = await Promise.all([
    supabase
      .from("recipes")
      .select("*, recipe_products(product_id, quantity, unit, sort_order)")
      .eq("id", id)
      .single(),
    supabase.from("products").select("id, name, default_unit").order("name"),
  ]);

  if (!recipe) notFound();

  const initialIngredients = [...(recipe.recipe_products ?? [])].sort(
    (a, b) => (a.sort_order ?? 0) - (b.sort_order ?? 0)
  );

  return (
    <main className="p-6 space-y-6">
      <div className="flex items-center gap-3 text-sm text-muted-foreground">
        <Link href="/recipes" className="hover:text-foreground">Tarifler</Link>
        <span>/</span>
        <Link href={`/recipes/${id}`} className="hover:text-foreground">{recipe.title}</Link>
        <span>/</span>
        <span className="text-foreground font-medium">Düzenle</span>
      </div>

      <h1 className="text-2xl font-bold">Tarifi Düzenle</h1>

      <RecipeEditForm
        recipeId={id}
        initialTitle={recipe.title}
        initialDescription={recipe.description ?? ""}
        initialPrepTime={recipe.prep_time_min ?? null}
        initialVideoUrl={recipe.video_url ?? null}
        initialIngredients={initialIngredients}
        products={products ?? []}
      />
    </main>
  );
}
