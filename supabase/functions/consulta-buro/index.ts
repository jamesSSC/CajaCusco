// ============================================================
// Edge Function: consulta-buro (MOCK para el curso)
// Proyecto: App Fuerza de Ventas — Caja Cusco
// RF-58: Simula respuesta de Equifax/SBS según el DNI
// ============================================================
// En producción conectaría con APIs reales de SBS/Equifax.
// Para el curso, el resultado depende del último dígito del DNI:
//   0-1 → Normal    (verde)
//   2-3 → CPP       (amarillo)
//   4   → Deficiente(naranja)
//   5-6 → Dudoso    (rojo)
//   7+  → Normal    (verde, pero con historial)
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
    const { dni, solicitud_id } = await req.json();

    if (!dni || dni.length < 8) {
      return new Response(
        JSON.stringify({ error: "DNI inválido" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Lógica mock basada en último dígito
    const ultimoDigito = parseInt(dni.slice(-1));

    let calificacion: string;
    let entidades: number;
    let deudaTotal: number;
    let mayorDeuda: number;
    let diasMora: number;
    let interpretacion: string;

    if (ultimoDigito <= 1) {
      calificacion = "Normal";
      entidades = 1;
      deudaTotal = 8500;
      mayorDeuda = 8500;
      diasMora = 0;
      interpretacion = `Cliente con historial en 1 entidad. Deuda total S/${deudaTotal.toLocaleString()}. Sin mora histórica. Recomendación: proceder con la evaluación.`;
    } else if (ultimoDigito <= 3) {
      calificacion = "CPP";
      entidades = 2;
      deudaTotal = 15400;
      mayorDeuda = 12000;
      diasMora = 15;
      interpretacion = `Cliente con historial en 2 entidades. Deuda total S/${deudaTotal.toLocaleString()}. Mora histórica de ${diasMora} días. Recomendación: evaluar con cuidado.`;
    } else if (ultimoDigito === 4) {
      calificacion = "Deficiente";
      entidades = 3;
      deudaTotal = 28000;
      mayorDeuda = 18000;
      diasMora = 62;
      interpretacion = `Cliente con deuda en 3 entidades. Deuda total S/${deudaTotal.toLocaleString()}. Mora de ${diasMora} días. Requiere comité especial.`;
    } else if (ultimoDigito <= 6) {
      calificacion = "Dudoso";
      entidades = 4;
      deudaTotal = 45000;
      mayorDeuda = 30000;
      diasMora = 120;
      interpretacion = `Alto riesgo. Deuda en 4 entidades por S/${deudaTotal.toLocaleString()}. Mora de ${diasMora} días. Evaluación no recomendada.`;
    } else {
      calificacion = "Normal";
      entidades = 1;
      deudaTotal = 5000;
      mayorDeuda = 5000;
      diasMora = 0;
      interpretacion = `Cliente con historial limpio. Deuda total S/${deudaTotal.toLocaleString()}. Sin mora. Recomendación: proceder con la evaluación.`;
    }

    // Verificar lista negra en la BD
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: clienteData } = await supabase
      .from("clientes")
      .select("en_lista_negra, motivo_lista_negra")
      .eq("numero_documento", dni)
      .single();

    const enListaNegra = clienteData?.en_lista_negra ?? false;
    const motivoLista = clienteData?.motivo_lista_negra ?? null;

    const resultado = {
      dni_consultado: dni,
      en_lista_negra: enListaNegra,
      motivo_lista_negra: motivoLista,
      calificacion_sbs: calificacion,
      entidades_con_deuda: entidades,
      deuda_total_pen: deudaTotal,
      mayor_deuda: mayorDeuda,
      dias_mayor_mora: diasMora,
      interpretacion,
      timestamp: new Date().toISOString(),
      fuente: "MOCK - Simulación para curso",
    };

    return new Response(
      JSON.stringify(resultado),
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
