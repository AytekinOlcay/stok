"use client";

import { useTransition } from "react";
import { useRouter } from "next/navigation";
import { deleteRecipe } from "../../actions";

export function DeleteRecipeButton({ id }: { id: string }) {
  const [isPending, startTransition] = useTransition();
  const router = useRouter();

  function handleClick() {
    if (!confirm("Bu tarifi silmek istediğinizden emin misiniz?")) return;
    startTransition(async () => {
      const result = await deleteRecipe(id);
      if (result.error) {
        alert(`Silinemedi: ${result.error}`);
      } else {
        router.push("/recipes");
      }
    });
  }

  return (
    <button
      onClick={handleClick}
      disabled={isPending}
      className="text-xs px-2 py-1 rounded border text-red-600 hover:bg-red-50 disabled:opacity-50 transition-colors"
    >
      {isPending ? "Siliniyor..." : "Sil"}
    </button>
  );
}

