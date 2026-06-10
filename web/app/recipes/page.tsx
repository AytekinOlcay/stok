import Link from "next/link";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Tarifler" };

export default async function RecipesPage() {
  const supabase = await createClient();

  const { data: recipes } = await supabase
    .from("recipes")
    .select(
      "id, title, description, prep_time_min, video_source, video_thumbnail, created_at, recipe_products(count)"
    )
    .order("created_at", { ascending: false });

  return (
    <main className="p-6 space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">🍳 Tarifler</h1>
        <Link
          href="/recipes/new"
          className="inline-flex items-center gap-1 rounded-md bg-primary text-primary-foreground px-4 py-2 text-sm font-medium hover:bg-primary/90 transition-colors"
        >
          + Yeni Tarif
        </Link>
      </div>

      {!recipes || recipes.length === 0 ? (
        <div className="rounded-lg border border-dashed p-12 text-center text-muted-foreground">
          <p className="text-4xl mb-3">🍳</p>
          <p className="font-medium">Henüz tarif eklenmemiş.</p>
          <p className="text-sm mt-1">
            <Link href="/recipes/new" className="underline hover:text-foreground">
              İlk tarifi ekle
            </Link>
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {recipes.map((r) => {
            const ingredientCount =
              Array.isArray(r.recipe_products)
                ? (r.recipe_products[0] as { count: number } | undefined)?.count ?? 0
                : 0;

            return (
              <Link
                key={r.id}
                href={`/recipes/${r.id}`}
                className="group rounded-lg border bg-card overflow-hidden hover:shadow-md transition-shadow"
              >
                {/* Thumbnail */}
                {r.video_thumbnail ? (
                  <div className="aspect-video relative overflow-hidden bg-muted">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={r.video_thumbnail}
                      alt={r.title}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                    <span className="absolute top-2 right-2 rounded bg-black/60 px-1.5 py-0.5 text-xs text-white uppercase">
                      {r.video_source}
                    </span>
                  </div>
                ) : (
                  <div className="aspect-video bg-muted flex items-center justify-center text-4xl text-muted-foreground">
                    {r.video_source ? (
                      <span className="text-xs font-medium uppercase text-muted-foreground">
                        {r.video_source}
                      </span>
                    ) : (
                      "🍳"
                    )}
                  </div>
                )}

                {/* Info */}
                <div className="p-4">
                  <h2 className="font-semibold text-base leading-snug group-hover:text-primary transition-colors">
                    {r.title}
                  </h2>
                  {r.description && (
                    <p className="text-sm text-muted-foreground mt-1 line-clamp-2">
                      {r.description}
                    </p>
                  )}
                  <div className="flex items-center gap-3 mt-3 text-xs text-muted-foreground">
                    {r.prep_time_min && (
                      <span>⏱ {r.prep_time_min} dk</span>
                    )}
                    {ingredientCount > 0 && (
                      <span>🥦 {ingredientCount} malzeme</span>
                    )}
                  </div>
                </div>
              </Link>
            );
          })}
        </div>
      )}
    </main>
  );
}
