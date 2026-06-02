import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/storage/local_db.dart';
import '../domain/cartera_diaria_model.dart';

class CarteraRepository {
  final SupabaseClient _supabase;
  final LocalDb _localDb;

  CarteraRepository(this._supabase, this._localDb);

  /// Obtiene la cartera del día (desde Supabase si hay red, si no desde SQLite)
  Future<List<CarteraDiariaModel>> getCarteraDelDia({
    required String asesorId,
    required String fecha,
    required bool isOnline,
  }) async {
    if (isOnline) {
      try {
        // RF-09: Consulta remota trayendo datos anidados del cliente
        final response = await _supabase
            .from('cartera_diaria')
            .select('*, clientes(*)')
            .eq('asesor_id', asesorId)
            .eq('fecha_asignacion', fecha);

        final remoteItems = (response as List)
            .map((item) => CarteraDiariaModel.fromSupabase(item))
            .toList();

        // Actualizar la base de datos local (Caché) de forma atómica
        if (remoteItems.isNotEmpty) {
          final localMaps = remoteItems.map((e) => e.toSqliteMap()).toList();
          await _localDb.upsertCarteraItems(localMaps);
        }

        return remoteItems;
      } catch (e) {
        // Si falla la red por latencia, hacemos fallback silencioso a la caché local
        return _getCarteraLocal(asesorId, fecha);
      }
    } else {
      // Offline-First total
      return _getCarteraLocal(asesorId, fecha);
    }
  }

  Future<List<CarteraDiariaModel>> _getCarteraLocal(String asesorId, String fecha) async {
    final localData = await _localDb.getCartera(asesorId, fecha);
    return localData.map((e) => CarteraDiariaModel.fromSqlite(e)).toList();
  }

  /// RF-17: Guardar el resultado de la visita (Motor offline-first)
  Future<void> registrarVisita({
    required String carteraId,
    required String resultado,
    String? observacion,
    double? lat,
    double? lng,
    required bool isOnline,
  }) async {
    final timestamp = DateTime.now().toIso8601String();

    final dataLocalYRemoto = {
      'estado_visita': 'visitado',
      'resultado_visita': resultado,
      'observacion_visita': observacion,
      'timestamp_visita': timestamp,
      'lat_visita': lat,
      'lng_visita': lng,
    };

    // 1. Actualizar caché local de inmediato para feedback visual rápido
    await _localDb.updateEstadoVisita(carteraId, dataLocalYRemoto);

    if (isOnline) {
      try {
        // Enviar directo a Supabase
        await _supabase
            .from('cartera_diaria')
            .update(dataLocalYRemoto)
            .eq('id', carteraId);
      } catch (e) {
        // Si el envío falla en plena transacción, lo mandamos a la cola offline
        await _guardarEnColaOffline(carteraId, resultado, observacion, timestamp, lat, lng);
      }
    } else {
      // 2. Si está offline, se encola en la tabla visitas_pendientes
      await _guardarEnColaOffline(carteraId, resultado, observacion, timestamp, lat, lng);
    }
  }

  Future<void> _guardarEnColaOffline(String id, String res, String? obs, String ts, double? lat, double? lng) async {
    await _localDb.insertVisitaPendiente({
      'id': id,
      'cartero_id': id, // ID del registro de cartera diaria
      'resultado': res,
      'observacion': obs,
      'timestamp_visita': ts,
      'lat': lat,
      'lng': lng,
      'pendiente_sync': 1
    });
  }
}