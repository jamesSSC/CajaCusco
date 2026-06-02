import 'dart:io';
import '../../../core/supabase/supabase_client.dart';

class DocumentosDataSource {
  static Future<String?> subirDocumento({
    required String solicitudId,
    required String tipoDocumento,
    required File archivo,
  }) async {
    try {
      final nombreArchivo = '$solicitudId/$tipoDocumento.jpg';
      final bytes = await archivo.readAsBytes();

      await AppSupabase.client.storage
          .from('documentos-solicitudes')
          .uploadBinary(nombreArchivo, bytes);

      final urlPublica = AppSupabase.client.storage
          .from('documentos-solicitudes')
          .getPublicUrl(nombreArchivo);

      return urlPublica;
    } catch (e) {
      return null;
    }
  }

  static Future<void> guardarRegistroDocumento({
    required String solicitudId,
    required String tipoDocumento,
    required String storageUrl,
    required int tamaniokb,
  }) async {
    try {
      await AppSupabase.client.from('solicitudes_documentos').insert({
        'solicitud_id': solicitudId,
        'tipo_documento': tipoDocumento,
        'storage_url': storageUrl,
        'tamanio_kb': tamaniokb,
        'nitidez_score': 85.0,
      });
    } catch (e) {
      rethrow;
    }
  }
}
