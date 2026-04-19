import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/badge";
import { ProductFormDialog } from "./_components/product-form-dialog";
import { DeleteProductButton } from "./_components/delete-product-button";

export default async function ProductsPage() {
  const supabase = await createClient();
  const { data: products } = await supabase
    .from("products")
    .select("*")
    .order("name");

  return (
    <main className="p-6 space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Products</h1>
        <ProductFormDialog />
      </div>

      <table className="w-full text-sm border rounded-lg overflow-hidden">
        <thead className="bg-muted text-left">
          <tr>
            <th className="px-4 py-2">Name</th>
            <th className="px-4 py-2">Category</th>
            <th className="px-4 py-2">Unit</th>
            <th className="px-4 py-2">Storage Days</th>
            <th className="px-4 py-2 w-28">Actions</th>
          </tr>
        </thead>
        <tbody>
          {products?.map((p) => (
            <tr key={p.id} className="border-t hover:bg-muted/30">
              <td className="px-4 py-2 font-medium">{p.name}</td>
              <td className="px-4 py-2">
                {p.category ? (
                  <Badge variant="secondary">{p.category}</Badge>
                ) : (
                  <span className="text-muted-foreground">—</span>
                )}
              </td>
              <td className="px-4 py-2">{p.default_unit}</td>
              <td className="px-4 py-2">{p.recommended_freezer_storage_days} days</td>
              <td className="px-4 py-2">
                <div className="flex gap-1">
                  <ProductFormDialog
                    product={p}
                    trigger={
                      <button className="text-xs px-2 py-1 rounded hover:bg-muted border">
                        Edit
                      </button>
                    }
                  />
                  <DeleteProductButton id={p.id} />
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </main>
  );
}
