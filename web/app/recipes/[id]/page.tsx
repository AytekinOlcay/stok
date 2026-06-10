import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { DeleteRecipeButton } from "./_components/delete-recipe-button";
import { MarkdownBody } from "@/components/markdown-body";

interface Props {
  params: Promise<{ id: string }>;
}

export default async function RecipeDetailPage({ params }: Props) {
  const { id } = await params;
  const supabase = await createClient();

  const { data: recipe } = await supabase
    .from("recipes")
    .select(
      `
      *,
      recipe_products (
        id,
        quantity,
        unit,
        sort_order,
        products ( id, name, category, default_unit )
      )
    `
    )
    .eq("id", id)
    .single();

  if (!recipe) notFound();

  const ingredients = [...(recipe.recipe_products ?? [])].sort(
    (a: { sort_order: number }, b: { sort_order: number }) => a.sort_order - b.sort_order
  );

  const canEmbed =
    recipe.video_embed_url &&
    (recipe.video_source === "youtube" || recipe.video_source === "vimeo");

  const externalSources = ["instagram", "tiktok", "other"];
  const isExternalOnly =
    recipe.video_url &&
    (externalSources.includes(recipe.video_source) || !canEmbed);

  const createdDate = new Date(recipe.created_at).toLocaleDateString("tr-TR", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });

  return (
    <main className="p-6 max-w-3xl space-y-6">
      {/* Breadcrumb */}
      <div className="flex items-center gap-2 text-sm text-muted-foreground">
        <Link href="/recipes" className="hover:text-foreground">
          Tarifler
        </Link>
        <span>/</span>
        <span className="text-foreground font-medium">{recipe.title}</span>
      </div>

      {/* Header */}
      <div className="flex items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold">{recipe.title}</h1>
          <p className="text-sm text-muted-foreground mt-1">
            {createdDate} tarihinde eklendi
          </p>
        </div>
        <div className="flex gap-2 shrink-0">
          <Link
            href={`/recipes/${recipe.id}/edit`}
            className="text-xs px-2 py-1 rounded border hover:bg-muted transition-colors"
          >
            Düzenle
          </Link>
          <DeleteRecipeButton id={recipe.id} />
        </div>
      </div>

      {/* Description */}
      {recipe.description && (
        <MarkdownBody source={recipe.description} className="prose prose-sm max-w-none" />
      )}

      {/* Meta pills */}
      <div className="flex flex-wrap gap-2">
        {recipe.prep_time_min && (
          <span className="rounded-full border px-3 py-1 text-sm">
            ⏱ {recipe.prep_time_min} dakika
          </span>
        )}
        {recipe.video_source && (
          <span className="rounded-full border px-3 py-1 text-sm capitalize">
            📹 {recipe.video_source}
          </span>
        )}
      </div>

      {/* Video embed */}
      {canEmbed && (
        <div className="rounded-lg overflow-hidden border aspect-video">
          <iframe
            src={recipe.video_embed_url}
            className="w-full h-full"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
            title={recipe.title}
          />
        </div>
      )}

      {/* External video link (Instagram / TikTok / other) */}
      {isExternalOnly && (
        <div className="rounded-lg border bg-muted/40 px-4 py-4 flex items-center justify-between gap-4">
          <div>
            <p className="font-medium text-sm">Video mevcut</p>
            <p className="text-xs text-muted-foreground">
              Bu platform embed desteklemiyor.
            </p>
          </div>
          <a
            href={recipe.video_url}
            target="_blank"
            rel="noopener noreferrer"
            className="rounded-md border px-4 py-2 text-sm hover:bg-background transition-colors"
          >
            Videoyu Aç ↗
          </a>
        </div>
      )}

      {/* Ingredients */}
      {ingredients.length > 0 && (
        <section className="space-y-3">
          <h2 className="font-semibold text-lg">🥦 Malzemeler</h2>
          <ul className="divide-y rounded-lg border overflow-hidden">
            {ingredients.map((rp: {
              id: string;
              quantity: number | null;
              unit: string | null;
              sort_order: number;
              products: { id: string; name: string; category: string | null; default_unit: string } | null;
            }) => {
              const product = rp.products;
              if (!product) return null;
              const qty = rp.quantity
                ? `${rp.quantity} ${rp.unit ?? product.default_unit}`
                : null;
              return (
                <li key={rp.id} className="flex items-center justify-between px-4 py-2 text-sm hover:bg-muted/30">
                  <span className="font-medium">{product.name}</span>
                  {qty && (
                    <span className="text-muted-foreground">{qty}</span>
                  )}
                </li>
              );
            })}
          </ul>
        </section>
      )}
    </main>
  );
}
