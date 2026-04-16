import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// @deno-types="https://esm.sh/qrcode@1.5.3/lib/index.d.ts"
import QRCode from "https://esm.sh/qrcode@1.5.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { type, id } = await req.json() as { type: "shelf" | "package"; id: string };

    if (!type || !id) {
      return new Response(JSON.stringify({ error: "type and id are required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const payload = JSON.stringify({ type, id });
    const qrDataUrl: string = await QRCode.toDataURL(payload, { width: 300, margin: 2 });

    // Persist qr_code value back to the relevant table
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const table = type === "shelf" ? "shelves" : "packages";
    const { error } = await supabase.from(table).update({ qr_code: payload }).eq("id", id);

    if (error) throw error;

    return new Response(JSON.stringify({ qr_code: payload, data_url: qrDataUrl }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
