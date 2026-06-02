// ============================================================
// Edge Function: pre-evaluar (MOCK para el curso)
// RF-38: Pre-evaluación crediticia en campo
// Resultado depende del DNI y monto solicitado
// ============================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

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
    const {
      numero_documento,
      ingresos_estimados,
      monto_solicitado,
      antiguedad_negocio_meses,
    } = await req.json();

    if (!numero_documento) {
      return new Response(
        JSON.stringify({ error: "Número de documento requerido" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const ultimoDigito = parseInt(numero_documento.slice(-1));
    const relacion = ingresos_estimados > 0
      ? monto_solicitado / ingresos_estimados
      : 99;

    let calificacion: "APTO" | "REVISAR" | "NO_PROCEDE";
    let motivo: string | null = null;
    let puntaje: number;

    // Reglas de pre-evaluación mock
    if (ultimoDigito >= 7) {
      // DNI termina en 7,8,9 → APTO
      calificacion = "APTO";
      puntaje = 70 + ultimoDigito * 2;
    } else if (ultimoDigito >= 4) {
      // DNI termina en 4,5,6 → REVISAR
      calificacion = "REVISAR";
      puntaje = 40 + ultimoDigito * 3;
      motivo = "Historial crediticio requiere análisis adicional.";
    } else {
      // DNI termina en 0,1,2,3 → depende de relación cuota/ingreso
      if (relacion <= 3 && antiguedad_negocio_meses >= 6) {
        calificacion = "APTO";
        puntaje = 65;
      } else if (relacion <= 5) {
        calificacion = "REVISAR";
        puntaje = 45;
        motivo = "Relación monto/ingresos elevada.";
      } else {
        calificacion = "NO_PROCEDE";
        puntaje = 20;
        motivo = "Monto solicitado excede la capacidad de pago estimada.";
      }
    }

    // Antigüedad mínima: 6 meses
    if (antiguedad_negocio_meses < 6) {
      calificacion = "NO_PROCEDE";
      puntaje = 0;
      motivo = "El negocio no cumple con la antigüedad mínima requerida (6 meses).";
    }

    return new Response(
      JSON.stringify({
        calificacion,
        motivo,
        puntaje_interno: puntaje,
        timestamp: new Date().toISOString(),
        fuente: "MOCK - Simulación para curso",
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
