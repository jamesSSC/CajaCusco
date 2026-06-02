import '../../../core/storage/local_db.dart';
import 'auth_remote_datasource.dart';
import '../domain/asesor_model.dart';

/// Capa repositorio de autenticación.
class AuthRepository {
  AuthRepository(this._remote);

  final AuthRemoteDatasource _remote;

  Future<AsesorModel> signIn({
    required String codigo,
    required String password,
  }) =>
      _remote.signIn(codigo: codigo, password: password);

  Future<AsesorModel?> getSessionAsesor() => _remote.getCurrentAsesor();

  /// Cierra sesión y borra datos sensibles del caché local (RF-07).
  /// Garantiza limpieza local incluso si falla el signOut remoto.
  Future<void> signOut() async {
    try {
      await _remote.signOut();
    } finally {
      await LocalDb.instance.clearAllSensitiveData();
    }
  }

  bool get hasActiveSession => _remote.hasActiveSession;
}