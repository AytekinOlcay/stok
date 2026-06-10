"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createAuthClient } from "@/lib/supabase/auth-server";
import { parseVideoUrl } from "@/lib/utils/video-parser";

export async function createRecipe(formData: FormData) {
  const supabase = await createClient();
  const authClient = await createAuthClient();

  const {
    data: { user },
  } = await authClient.auth.getUser();
  if (!user) redirect("/login");

  const title = formData.get("title") as string;
  const description = formData.get("description") as string;
  const prepTimeRaw = formData.get("prep_time_min") as string;
  const videoUrl = (formData.get("video_url") as string)?.trim();
  const productIds = formData.getAll("product_ids") as string[];

  if (!title?.trim()) return { error: "Tarif adı zorunludur." };

  // Parse video
  let videoSource = null;
  let videoEmbedUrl = null;
  let videoThumbnail = null;
  if (videoUrl) {
    const parsed = parseVideoUrl(videoUrl);
    videoSource = parsed.type;
    videoEmbedUrl = parsed.embedUrl;
    videoThumbnail = parsed.thumbnailUrl;
  }

  // Get org_id via RPC (respects RLS)
  const { data: orgData } = await supabase.rpc("get_my_org");
  if (!orgData) return { error: "Organizasyon bulunamadı." };

  const { data: recipe, error } = await supabase
    .from("recipes")
    .insert({
      org_id: orgData.org_id,
      title: title.trim(),
      description: description?.trim() || null,
      prep_time_min: prepTimeRaw ? parseInt(prepTimeRaw) : null,
      video_url: videoUrl || null,
      video_source: videoSource,
      video_embed_url: videoEmbedUrl,
      video_thumbnail: videoThumbnail,
      created_by: user.id,
      updated_by: user.id,
    })
    .select("id")
    .single();

  if (error) return { error: error.message };

  // Insert product links (with per-product quantity + unit)
  if (productIds.length > 0) {
    const links = productIds.map((pid, i) => {
      const qtyRaw = (formData.get(`product_qty_${pid}`) as string)?.trim();
      const unit = (formData.get(`product_unit_${pid}`) as string)?.trim() || null;
      return {
        recipe_id: recipe.id,
        product_id: pid,
        quantity: qtyRaw ? parseFloat(qtyRaw) : null,
        unit: unit || null,
        sort_order: i,
      };
    });
    await supabase.from("recipe_products").insert(links);
  }

  revalidatePath("/recipes");
  redirect(`/recipes/${recipe.id}`);
}

export async function deleteRecipe(id: string): Promise<{ error?: string }> {
  // Call the SECURITY DEFINER RPC so that:
  //  - RLS policies on `recipes` are bypassed by the definer privilege,
  //  - BUT org ownership is still enforced inside the function via auth.uid().
  // Use the auth client so the user's JWT is sent as the Bearer token,
  // ensuring auth.uid() is set inside the function.
  const supabase = await createAuthClient();

  const { error } = await supabase.rpc("soft_delete_recipe", {
    p_recipe_id: id,
  });

  if (error) return { error: error.message };

  revalidatePath("/recipes");
  return {};
}

export async function updateRecipe(
  id: string,
  formData: FormData
): Promise<{ error?: string }> {
  // Single auth client: session provides both auth.uid() and RLS context.
  const supabase = await createAuthClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Oturum açmanız gerekiyor." };

  const title = (formData.get("title") as string)?.trim();
  const description = (formData.get("description") as string)?.trim();
  const prepTimeRaw = formData.get("prep_time_min") as string;
  const videoUrl = (formData.get("video_url") as string)?.trim();
  const productIds = formData.getAll("product_ids") as string[];

  if (!title) return { error: "Tarif adı zorunludur." };

  let videoSource = null;
  let videoEmbedUrl = null;
  let videoThumbnail = null;
  if (videoUrl) {
    const parsed = parseVideoUrl(videoUrl);
    videoSource = parsed.type;
    videoEmbedUrl = parsed.embedUrl;
    videoThumbnail = parsed.thumbnailUrl;
  }

  const { error: updateError } = await supabase
    .from("recipes")
    .update({
      title,
      description: description || null,
      prep_time_min: prepTimeRaw ? parseInt(prepTimeRaw) : null,
      video_url: videoUrl || null,
      video_source: videoSource,
      video_embed_url: videoEmbedUrl,
      video_thumbnail: videoThumbnail,
      updated_by: user.id,
    })
    .eq("id", id);

  if (updateError) return { error: updateError.message };

  // Replace all product links
  await supabase.from("recipe_products").delete().eq("recipe_id", id);

  if (productIds.length > 0) {
    const links = productIds.map((pid, i) => {
      const qtyRaw = (formData.get(`product_qty_${pid}`) as string)?.trim();
      const unit = (formData.get(`product_unit_${pid}`) as string)?.trim();
      return {
        recipe_id: id,
        product_id: pid,
        quantity: qtyRaw ? parseFloat(qtyRaw) : null,
        unit: unit || null,
        sort_order: i,
      };
    });
    await supabase.from("recipe_products").insert(links);
  }

  revalidatePath(`/recipes/${id}`);
  revalidatePath("/recipes");
  return {};
}
