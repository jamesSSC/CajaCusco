import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/supabase/supabase_client.dart';
import '../domain/asesor_model.dart';

class AuthRemoteDatasource {
  /// Inicia sesión por código de empleado (RF-01, RF-02).
  ///
  /// El sistema convierte el código en un correo interno
  /// (p. ej. 10001 -> 10001@cajacusco.app) para autenticar contra Supabase Auth.
  Future<AsesorModel> signIn({
    required String codigo,
    required String password,
  }) async {
    final email = _codigoToEmail(codigo);

    final response = await AppSupabase.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw const AuthException('Credenciales inválidas');
    }

    return _fetchAsesor(response.user!.id);
  }

  /// Convierte el código de empleado en el correo interno de autenticación.
  /// Si por alguna razón ya llega con dominio, se respeta tal cual.
  String _codigoToEmail(String codigo) {
    final limpio = codigo.trim();
    if (limpio.contains('@')) return limpio;
    return '$limpio${AppStrings.emailDomain}';
  }

  /// Recupera el asesor de la sesión activa (RF-03).
  Future<AsesorModel?> getCurrentAsesor() async {
    final user = AppSupabase.client.auth.currentUser;
    if (user == null) return null;

    try {
      return await _fetchAsesor(user.id);
    } catch (_) {
      return null;
    }
  }

  /// Cierra sesión en Supabase (RF-07).
  /// Si falla (sin red), continúa silenciosamente para permitir logout local.
  Future<void> signOut() async {
    try {
      await AppSupabase.client.auth.signOut(
        scope: SignOutScope.global,
      );
    } catch (_) {
      // Si falla remotamente, igual permitir logout local
    }
  }

  bool get hasActiveSession =>
      AppSupabase.client.auth.currentSession != null;

  Future<AsesorModel> _fetchAsesor(String userId) async {
    final data = await AppSupabase.client
        .from('asesores_negocio')
        .select()
        .eq('user_id', userId)
        .single();

    return AsesorModel.fromJson(data);
  }
}