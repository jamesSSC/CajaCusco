// ============================================================
// Edge Function: consulta-posicion (RF-30)
// Devuelve la posición consolidada del cliente en el sistema
// ============================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { cliente_id } = await req.json();

    if (!cliente_id) {
      return new Response(
        JSON.stringify({ error: "cliente_id requerido" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: creditos } = await supabase
      .from("creditos")
      .select("*")
      .eq("cliente_id", cliente_id);

    if (!creditos || creditos.length === 0) {
      return new Response(
        JSON.stringify({
          deuda_total: 0,
          cuentas_vigentes: 0,
          cuentas_en_mora: 0,
          dias_mayor_mora: 0,
          ultimo_pago: null,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const deudaTotal = creditos.reduce((s: number, c: any) => s + (c.saldo_actual || 0), 0);
    const cuentasVigentes = creditos.filter((c: any) => c.estado === "vigente").length;
    const cuentasEnMora = creditos.filter((c: any) => c.dias_mora > 0).length;
    const diasMayorMora = Math.max(...creditos.map((c: any) => c.dias_mora || 0));

    return new Response(
      JSON.stringify({
        deuda_total: deudaTotal,
        cuentas_vigentes: cuentasVigentes,
        cuentas_en_mora: cuentasEnMora,
        dias_mayor_mora: diasMayorMora,
        ultimo_pago: null, // Se implementaría con tabla de pagos
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: "Error interno", detalle: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
