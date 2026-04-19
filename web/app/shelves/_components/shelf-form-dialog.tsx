"use client";

import { useRef, useState, useTransition } from "react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createShelf, updateShelf } from "../actions";

type Shelf = {
  id: string;
  name: string;
  position: number;
};

type Props = {
  shelf?: Shelf;
  trigger?: React.ReactElement;
};

export function ShelfFormDialog({ shelf, trigger }: Props) {
  const [open, setOpen] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();
  const formRef = useRef<HTMLFormElement>(null);

  const isEdit = Boolean(shelf);

  async function handleSubmit(formData: FormData) {
    setError(null);
    startTransition(async () => {
      try {
        if (isEdit) {
          await updateShelf(shelf!.id, formData);
        } else {
          await createShelf(formData);
        }
        setOpen(false);
        formRef.current?.reset();
      } catch (err) {
        setError((err as Error).message);
      }
    });
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={trigger ?? <Button size="sm">+ Add Shelf</Button>} />
      <DialogContent className="sm:max-w-sm">
        <DialogHeader>
          <DialogTitle>{isEdit ? "Edit Shelf" : "Add Shelf"}</DialogTitle>
        </DialogHeader>
        <form ref={formRef} action={handleSubmit} className="space-y-4 pt-2">
          <div className="space-y-1">
            <Label htmlFor="name">Name *</Label>
            <Input
              id="name"
              name="name"
              defaultValue={shelf?.name}
              placeholder="e.g. Shelf 1"
              required
            />
          </div>

          <div className="space-y-1">
            <Label htmlFor="position">Position *</Label>
            <Input
              id="position"
              name="position"
              type="number"
              min={1}
              defaultValue={shelf?.position}
              required
            />
          </div>

          {error && (
            <p className="text-sm text-destructive">{error}</p>
          )}

          <div className="flex justify-end gap-2 pt-2">
            <Button
              type="button"
              variant="outline"
              onClick={() => setOpen(false)}
            >
              Cancel
            </Button>
            <Button type="submit" disabled={isPending}>
              {isPending ? "Saving…" : isEdit ? "Update" : "Create"}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
