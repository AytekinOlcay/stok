"use client";

import { useRef, useState, useTransition } from "react";
import { createRecipe } from "../../actions";
import { MarkdownEditor } from "@/components/markdown-editor";

interface Product {
  id: string;
  name: string;
  category: string | null;
  default_unit: string;
}

interface IngredientEntry {
  quantity: string;
  unit: string;
}

interface Props {
  products: Product[];
}

export function RecipeForm({ products }: Props) {
  const [isPending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [videoUrl, setVideoUrl] = useState("");
  // Map of productId → { quantity, unit }
  const [ingredients, setIngredients] = useState<Record<string, IngredientEntry>>({});
  const formRef = useRef<HTMLFormElement>(null);

  const selectedIds = Object.keys(ingredients);

  function addIngredient(p: Product) {
    if (ingredients[p.id]) return;
    setIngredients((prev) => ({
      ...prev,
      [p.id]: { quantity: "", unit: p.default_unit },
    }));
  }

  function removeIngredient(id: string) {
    setIngredients((prev) => {
      const next = { ...prev };
      delete next[id];
      return next;
    });
  }

  function updateIngredient(id: string, field: keyof IngredientEntry, value: string) {
    setIngredients((prev) => ({
      ...prev,
      [id]: { ...prev[id], [field]: value },
    }));
  }

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);
    const data = new FormData(e.currentTarget);

    // Inject per-product quantity/unit as named fields
    selectedIds.forEach((pid) => {
      data.append("product_ids", pid);
      const entry = ingredients[pid];
      if (entry.quantity) data.set(`product_qty_${pid}`, entry.quantity);
      if (entry.unit)     data.set(`product_unit_${pid}`, entry.unit);
    });

    startTransition(async () => {
      const result = await createRecipe(data);
      if (result?.error) setError(result.error);
    });
  }

  const unselected = products.filter((p) => !ingredients[p.id]);

  return (
    <form ref={formRef} onSubmit={handleSubmit} className="space-y-6 max-w-2xl">
      {error && (
        <div className="rounded-md bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          {error}
        </div>
      )}

      {/* Temel bilgiler */}
      <section className="space-y-4">
        <h2 className="font-semibold text-sm text-muted-foreground uppercase tracking-wide">
          Temel Bilgiler
        </h2>

        <div>
          <label className="block text-sm font-medium mb-1" htmlFor="title">
            Tarif Adı <span className="text-red-500">*</span>
          </label>
          <input
            id="title"
            name="title"
            required
            className="w-full rounded-md border px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            placeholder="örn. Fırında Tavuk"
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">
            Açıklama
          </label>
          <MarkdownEditor
            name="description"
            placeholder="Kısa bir açıklama, malzeme notları, pişirme ipuçları..."
            height={240}
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1" htmlFor="prep_time_min">
            Hazırlık Süresi (dakika)
          </label>
          <input
            id="prep_time_min"
            name="prep_time_min"
            type="number"
            min={1}
            className="w-48 rounded-md border px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            placeholder="30"
          />
        </div>
      </section>

      {/* Video */}
      <section className="space-y-3">
        <h2 className="font-semibold text-sm text-muted-foreground uppercase tracking-wide">
          Video (isteğe bağlı)
        </h2>
        <div>
          <label className="block text-sm font-medium mb-1" htmlFor="video_url">
            YouTube, Vimeo veya Instagram linki
          </label>
          <input
            id="video_url"
            name="video_url"
            type="url"
            value={videoUrl}
            onChange={(e) => setVideoUrl(e.target.value)}
            className="w-full rounded-md border px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            placeholder="https://www.youtube.com/watch?v=..."
          />
          {videoUrl && (
            <p className="mt-1 text-xs text-muted-foreground">
              Platform otomatik algılanacak ve embed bilgisi kaydedilecek.
            </p>
          )}
        </div>
      </section>

      {/* Malzemeler */}
      <section className="space-y-3">
        <h2 className="font-semibold text-sm text-muted-foreground uppercase tracking-wide">
          Malzemeler (buzluktan)
        </h2>

        {/* Selected ingredients with quantity + unit */}
        {selectedIds.length > 0 && (
          <div className="rounded-lg border divide-y">
            {/* Header row */}
            <div className="grid grid-cols-[1fr_100px_90px_32px] gap-2 px-3 py-1.5 bg-muted/50 text-xs text-muted-foreground font-medium">
              <span>Ürün</span>
              <span>Miktar</span>
              <span>Birim</span>
              <span />
            </div>
            {selectedIds.map((pid) => {
              const product = products.find((p) => p.id === pid)!;
              const entry = ingredients[pid];
              return (
                <div
                  key={pid}
                  className="grid grid-cols-[1fr_100px_90px_32px] gap-2 items-center px-3 py-2"
                >
                  <span className="text-sm font-medium truncate">{product.name}</span>
                  <input
                    type="number"
                    min={0}
                    step="any"
                    value={entry.quantity}
                    onChange={(e) => updateIngredient(pid, "quantity", e.target.value)}
                    placeholder="—"
                    className="rounded border px-2 py-1 text-sm w-full focus:outline-none focus:ring-1 focus:ring-primary"
                  />
                  <input
                    type="text"
                    value={entry.unit}
                    onChange={(e) => updateIngredient(pid, "unit", e.target.value)}
                    placeholder="g / kg / adet"
                    className="rounded border px-2 py-1 text-sm w-full focus:outline-none focus:ring-1 focus:ring-primary"
                  />
                  <button
                    type="button"
                    onClick={() => removeIngredient(pid)}
                    className="text-muted-foreground hover:text-red-500 transition-colors text-base leading-none"
                    title="Kaldır"
                  >
                    ×
                  </button>
                </div>
              );
            })}
          </div>
        )}

        {/* Unselected products to add */}
        {products.length === 0 ? (
          <p className="text-sm text-muted-foreground italic">
            Henüz ürün tanımlanmamış.
          </p>
        ) : unselected.length > 0 ? (
          <div>
            <p className="text-xs text-muted-foreground mb-2">
              Eklemek için ürüne tıkla:
            </p>
            <div className="flex flex-wrap gap-2">
              {unselected.map((p) => (
                <button
                  key={p.id}
                  type="button"
                  onClick={() => addIngredient(p)}
                  className="rounded-full border px-3 py-1 text-sm hover:bg-muted transition-colors"
                >
                  + {p.name}
                </button>
              ))}
            </div>
          </div>
        ) : (
          <p className="text-xs text-muted-foreground">Tüm ürünler eklendi.</p>
        )}
      </section>

      <button
        type="submit"
        disabled={isPending}
        className="rounded-md bg-primary text-primary-foreground px-6 py-2 text-sm font-medium hover:bg-primary/90 disabled:opacity-50 transition-colors"
      >
        {isPending ? "Kaydediliyor..." : "Tarifi Kaydet"}
      </button>
    </form>
  );
}
