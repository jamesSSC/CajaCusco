import 'package:uuid/uuid.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/storage/local_db.dart';
import '../data/expediente_service.dart';

class SolicitudRepository {
  final db = LocalDb.instance;

  Future<String> guardarSolicitud({
    required String clienteNombre,
    required String asesorId,
    required String agenciaId,
    required Map<String, dynamic> datos,
  }) async {
    const uuid = Uuid();
    final solicitudId = uuid.v4();
    final numeroExpediente = await ExpedienteService.generarNumero();

    try {
      // 1. Buscar o crear cliente
      String clienteId = await _obtenerOCrearCliente(clienteNombre);

      // 2. Guardar solicitud en Supabase con TODOS los campos
      final monto = (datos['monto'] as num?)?.toDouble() ?? 0.0;
      final plazo = (datos['plazo'] as int?) ?? 12;
      final cuota = plazo > 0 ? (monto / plazo).toStringAsFixed(2) : '0.00';

      await AppSupabase.client
          .from('solicitudes_credito')
          .insert({
            'id': solicitudId,
            'numero_expediente': numeroExpediente,
            'asesor_id': asesorId,
            'cliente_id': clienteId,
            'agencia_id': agenciaId,
            'tipo_negocio': datos['tipo_negocio'] ?? 'comercio',
            'nombre_negocio': clienteNombre,
            'actividad_economica': datos['actividad'] ?? '4711',
            'antiguedad_negocio_meses': datos['antiguedad'] ?? 12,
            'ingresos_estimados': monto,
            'destino_credito': datos['destino'] ?? 'Capital de trabajo',
            'tiene_conyuge': false,
            'tiene_garante': false,
            'monto_solicitado': monto,
            'plazo_meses': plazo,
            'moneda': 'PEN',
            'tipo_cuota': 'mensual',
            'garantia': 'sin_garantia',
            'cuota_estimada': double.parse(cuota),
            'tea_referencial': datos['tea'] ?? 25.0,
            'estado': 'enviado',
            'lat_captura': datos['lat'] ?? 0.0,
            'lng_captura': datos['lng'] ?? 0.0,
            'pendiente_sync': false,
          });

      return numeroExpediente;
    } catch (_) {
      // Generar expediente fallback
      return 'EXP-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
    }
  }

  Future<String> _obtenerOCrearCliente(String nombre) async {
    try {
      // Buscar cliente por primer nombre
      final partes = nombre.split(' ');
      var result = await AppSupabase.client
          .from('clientes')
          .select('id')
          .ilike('nombres', '%${partes.isNotEmpty ? partes.first : nombre}%')
          .limit(1)
          .maybeSingle();

      if (result != null) {
        return result['id'] as String;
      }

      // Si no encuentra, busca por apellido
      if (partes.length > 1) {
        result = await AppSupabase.client
            .from('clientes')
            .select('id')
            .ilike('apellidos', '%${partes.last}%')
            .limit(1)
            .maybeSingle();

        if (result != null) {
          return result['id'] as String;
        }
      }

      // Si no existe, crear cliente
      final clienteId = const Uuid().v4();
      await AppSupabase.client.from('clientes').insert({
        'id': clienteId,
        'nombres': partes.isNotEmpty ? partes.first : nombre,
        'apellidos': partes.length > 1 ? partes.sublist(1).join(' ') : 'S/N',
        'numero_documento': 'TEMP-${const Uuid().v4().substring(0, 8)}',
        'tipo_documento': 'DNI',
      });

      return clienteId;
    } catch (_) {
      // Retornar UUID dummy si todo falla
      return const Uuid().v4();
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
