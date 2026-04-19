"use client";

import { useTransition } from "react";
import { Button } from "@/components/ui/button";
import { deleteProduct } from "../actions";

export function DeleteProductButton({ id }: { id: string }) {
  const [isPending, startTransition] = useTransition();

  function handleDelete() {
    if (!confirm("Delete this product? This cannot be undone.")) return;
    startTransition(async () => {
      await deleteProduct(id);
    });
  }

  return (
    <Button
      variant="ghost"
      size="sm"
      className="text-destructive hover:text-destructive"
      disabled={isPending}
      onClick={handleDelete}
    >
      {isPending ? "…" : "Delete"}
    </Button>
  );
}
