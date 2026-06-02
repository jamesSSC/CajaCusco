import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Marca Caja Cusco ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFFE2231A);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color primaryLight = Color(0xFFFFCDD2);
  static const Color onPrimary = Colors.white;

  // ── Neutros ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color divider = Color(0xFFE0E0E0);

  // ── Semáforo SBS (RF-28) ──────────────────────────────────────────────────
  static const Color semaforoNormal = Color(0xFF2E7D32);      // Verde
  static const Color semaforoCpp = Color(0xFFF9A825);         // Amarillo
  static const Color semaforoDeficiente = Color(0xFFEF6C00);  // Naranja
  static const Color semaforoDudoso = Color(0xFFC62828);      // Rojo
  static const Color semaforoPerdida = Color(0xFF616161);     // Gris oscuro

  // ── Tipos de gestión cartera (RF-10) ─────────────────────────────────────
  static const Color tipoRenovacion = Color(0xFF1565C0);
  static const Color tipoAmpliacion = Color(0xFF2E7D32);
  static const Color tipoNuevaSolicitud = Color(0xFFE65100);
  static const Color tipoSeguimiento = Color(0xFF757575);
  static const Color tipoRecuperacionMora = Color(0xFFC62828);
  static const Color tipoDesertor = Color(0xFF6A1B9A);

  // ── Prioridad mapa (RF-19) ────────────────────────────────────────────────
  static const Color prioridadAlta = Color(0xFFC62828);
  static const Color prioridadMedia = Color(0xFFF9A825);
  static const Color prioridadNormal = Color(0xFF2E7D32);

  // ── Semáforo mora (RF-76) ─────────────────────────────────────────────────
  static const Color mora1a30 = Color(0xFFF9A825);
  static const Color mora31a60 = Color(0xFFEF6C00);
  static const Color moraMas60 = Color(0xFFC62828);

  // ── Estado de solicitud ───────────────────────────────────────────────────
  static const Color estadoEnviado = Color(0xFF1565C0);
  static const Color estadoAprobado = Color(0xFF2E7D32);
  static const Color estadoCondicionado = Color(0xFFF9A825);
  static const Color estadoRechazado = Color(0xFFC62828);
  static const Color estadoDesembolsado = Color(0xFF00897B);

  // ── Pre-evaluación (RF-39) ────────────────────────────────────────────────
  static const Color resultadoApto = Color(0xFF2E7D32);
  static const Color resultadoRevisar = Color(0xFFF9A825);
  static const Color resultadoNoProcede = Color(0xFFC62828);

  // ── Offline banner ────────────────────────────────────────────────────────
  static const Color offlineBanner = Color(0xFF424242);

  // ── Utilidades ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color danger = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);
  static const Color disabled = Color(0xFF9E9E9E);

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Color colorPorTipoGestion(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'RENOVACION':
        return tipoRenovacion;
      case 'AMPLIACION':
        return tipoAmpliacion;
      case 'NUEVA_SOLICITUD':
        return tipoNuevaSolicitud;
      case 'SEGUIMIENTO':
        return tipoSeguimiento;
      case 'RECUPERACION_MORA':
        return tipoRecuperacionMora;
      case 'DESERTOR':
        return tipoDesertor;
      default:
        return tipoSeguimiento;
    }
  }

  static Color colorPorCalificacionSbs(String calificacion) {
    switch (calificacion.toUpperCase()) {
      case 'NORMAL':
        return semaforoNormal;
      case 'CPP':
        return semaforoCpp;
      case 'DEFICIENTE':
        return semaforoDeficiente;
      case 'DUDOSO':
        return semaforoDudoso;
      case 'PERDIDA':
        return semaforoPerdida;
      default:
        return disabled;
    }
  }

  static Color colorPorDiasMora(int dias) {
    if (dias <= 0) return disabled;
    if (dias <= 30) return mora1a30;
    if (dias <= 60) return mora31a60;
    return moraMas60;
  }
}
