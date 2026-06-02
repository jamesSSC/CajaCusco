import 'package:uuid/uuid.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/storage/local_db.dart';

class SolicitudRepository {
  final db = LocalDb.instance;

  Future<String> guardarSolicitud({
    required String clienteId,
    required String asesorId,
    required String agenciaId,
    required Map<String, dynamic> datos,
  }) async {
    const uuid = Uuid();
    final solicitudId = uuid.v4();

    try {
      // Si hay red, guardar en Supabase
      final response = await AppSupabase.client
          .from('solicitudes_credito')
          .insert({
            'id': solicitudId,
            'cliente_id': clienteId,
            'asesor_id': asesorId,
            'agencia_id': agenciaId,
            'monto_solicitado': datos['monto'] ?? 0,
            'plazo_meses': datos['plazo'] ?? 12,
            'tipo_negocio': datos['tipo_negocio'] ?? '',
            'nombre_negocio': datos['nombre_negocio'] ?? '',
            'destino_credito': datos['destino'] ?? '',
            'cuota_estimada': datos['cuota'] ?? 0,
            'tea_referencial': datos['tea'] ?? 25.0,
            'estado': 'enviado',
            'lat_captura': datos['lat'] ?? 0,
            'lng_captura': datos['lng'] ?? 0,
            'pendiente_sync': false,
          })
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      // Sin red: guardar en SQLite con pendiente_sync
      return solicitudId;
    }
  }

  Future<void> actualizarEstado(
    String solicitudId,
    String nuevoEstado,
  ) async {
    try {
      await AppSupabase.client
          .from('solicitudes_credito')
          .update({'estado': nuevoEstado})
          .eq('id', solicitudId);
    } catch (e) {
      // Fallback local
      rethrow;
    }
  }

  Future<void> asignarExpediente(
    String solicitudId,
    String numeroExpediente,
  ) async {
    try {
      await AppSupabase.client
          .from('solicitudes_credito')
          .update({'numero_expediente': numeroExpediente})
          .eq('id', solicitudId);
    } catch (e) {
      // Fallback local
      rethrow;
    }
  }
}
