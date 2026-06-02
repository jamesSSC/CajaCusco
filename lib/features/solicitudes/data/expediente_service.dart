import '../../../core/supabase/supabase_client.dart';

class ExpedienteService {
  static Future<String> generarNumero() async {
    final timestamp = DateTime.now();
    final year = timestamp.year;
    final mes = timestamp.month.toString().padLeft(2, '0');
    final dia = timestamp.day.toString().padLeft(2, '0');

    try {
      // Obtener contador del dia
      final response = await AppSupabase.client
          .from('solicitudes_credito')
          .select('id')
          .ilike('created_at', '${timestamp.toString().split(' ')[0]}%')
          .count();

      final contador = (response as int) + 1;
      return 'EXP-$year$mes$dia-${contador.toString().padLeft(4, '0')}';
    } catch (e) {
      // Fallback: usar timestamp
      return 'EXP-${timestamp.millisecondsSinceEpoch.toString().substring(4)}';
    }
  }
}
