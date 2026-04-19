"use client";

import { useTransition } from "react";
import { Button } from "@/components/ui/button";
import { deleteShelf } from "../actions";

export function DeleteShelfButton({ id }: { id: string }) {
  const [isPending, startTransition] = useTransition();

  function handleDelete() {
    if (!confirm("Delete this shelf? All packages on it must be removed first.")) return;
    startTransition(async () => {
      await deleteShelf(id);
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
