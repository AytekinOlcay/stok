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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { createProduct, updateProduct } from "../actions";

type Product = {
  id: string;
  name: string;
  category: string | null;
  default_unit: string;
  recommended_freezer_storage_days: number;
};

type Props = {
  product?: Product;
  trigger?: React.ReactElement;
};

export function ProductFormDialog({ product, trigger }: Props) {
  const [open, setOpen] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();
  const formRef = useRef<HTMLFormElement>(null);

  const isEdit = Boolean(product);

  async function handleSubmit(formData: FormData) {
    setError(null);
    startTransition(async () => {
      try {
        if (isEdit) {
          await updateProduct(product!.id, formData);
        } else {
          await createProduct(formData);
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
      <DialogTrigger render={trigger ?? <Button size="sm">+ Add Product</Button>} />
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>{isEdit ? "Edit Product" : "Add Product"}</DialogTitle>
        </DialogHeader>
        <form ref={formRef} action={handleSubmit} className="space-y-4 pt-2">
          <div className="space-y-1">
            <Label htmlFor="name">Name *</Label>
            <Input
              id="name"
              name="name"
              defaultValue={product?.name}
              required
            />
          </div>

          <div className="space-y-1">
            <Label htmlFor="category">Category</Label>
            <Input
              id="category"
              name="category"
              defaultValue={product?.category ?? ""}
              placeholder="e.g. Meat, Fish, Vegetable"
            />
          </div>

          <div className="space-y-1">
            <Label htmlFor="default_unit">Default Unit *</Label>
            <Select
              name="default_unit"
              defaultValue={product?.default_unit ?? "g"}
            >
              <SelectTrigger id="default_unit">
                <SelectValue placeholder="Select unit" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="g">g (gram)</SelectItem>
                <SelectItem value="kg">kg (kilogram)</SelectItem>
                <SelectItem value="piece">piece</SelectItem>
                <SelectItem value="ml">ml</SelectItem>
                <SelectItem value="l">l (litre)</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-1">
            <Label htmlFor="recommended_freezer_storage_days">
              Storage Days *
            </Label>
            <Input
              id="recommended_freezer_storage_days"
              name="recommended_freezer_storage_days"
              type="number"
              min={1}
              defaultValue={product?.recommended_freezer_storage_days ?? 90}
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
