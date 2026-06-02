import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/auth_remote_datasource.dart';
import '../data/auth_repository.dart';
import '../domain/asesor_model.dart';

// ── Estado inmutable ──────────────────────────────────────────────────────

class LoginState {
  const LoginState({
    this.asesor,
    this.isLoading = false,
    this.isCheckingSession = true,
    this.error,
    this.intentosFallidos = 0,
    this.bloqueadoHasta,
  });

  final AsesorModel? asesor;
  final bool isLoading;
  final bool isCheckingSession;
  final String? error;
  final int intentosFallidos;
  final DateTime? bloqueadoHasta;

  bool get isAuthenticated => asesor != null;

  bool get isBloqueado =>
      bloqueadoHasta != null && DateTime.now().isBefore(bloqueadoHasta!);

  Duration get tiempoBloqueoRestante {
    if (bloqueadoHasta == null) return Duration.zero;
    final remaining = bloqueadoHasta!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  LoginState copyWith({
    AsesorModel? asesor,
    bool? isLoading,
    bool? isCheckingSession,
    String? error,
    int? intentosFallidos,
    DateTime? bloqueadoHasta,
    bool clearError = false,
    bool clearAsesor = false,
    bool clearBloqueo = false,
  }) {
    return LoginState(
      asesor: clearAsesor ? null : (asesor ?? this.asesor),
      isLoading: isLoading ?? this.isLoading,
      isCheckingSession: isCheckingSession ?? this.isCheckingSession,
      error: clearError ? null : (error ?? this.error),
      intentosFallidos: intentosFallidos ?? this.intentosFallidos,
      bloqueadoHasta:
          clearBloqueo ? null : (bloqueadoHasta ?? this.bloqueadoHasta),
    );
  }
}

// ── ViewModel ─────────────────────────────────────────────────────────────

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel(this._repo, this._storage) : super(const LoginState()) {
    _init();
  }

  final AuthRepository _repo;
  final FlutterSecureStorage _storage;

  static const _kIntentos = 'login_intentos';
  static const _kBloqueadoHasta = 'login_bloqueado_hasta';

  Future<void> _init() async {
    await _restoreLockState();
    await _checkSession();
  }

  Future<void> _restoreLockState() async {
    final intentosStr = await _storage.read(key: _kIntentos);
    final bloqueadoStr = await _storage.read(key: _kBloqueadoHasta);

    final intentos = int.tryParse(intentosStr ?? '0') ?? 0;
    DateTime? bloqueadoHasta;

    if (bloqueadoStr != null) {
      bloqueadoHasta = DateTime.tryParse(bloqueadoStr);
      if (bloqueadoHasta != null &&
          DateTime.now().isAfter(bloqueadoHasta)) {
        bloqueadoHasta = null;
        await _storage.delete(key: _kBloqueadoHasta);
        await _storage.delete(key: _kIntentos);
      }
    }

    state = state.copyWith(
      intentosFallidos: intentos,
      bloqueadoHasta: bloqueadoHasta,
    );
  }

  Future<void> _checkSession() async {
    if (!_repo.hasActiveSession) {
      state = state.copyWith(isCheckingSession: false);
      return;
    }

    try {
      final asesor = await _repo.getSessionAsesor();
      state = state.copyWith(
        asesor: asesor,
        isCheckingSession: false,
      );
    } catch (_) {
      state = state.copyWith(isCheckingSession: false);
    }
  }

  // ── Login por código de empleado (RF-01, RF-02) ────────────────────────────

  Future<void> signIn({
    required String codigo,
    required String password,
  }) async {
    if (state.isBloqueado || state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final asesor = await _repo.signIn(
        codigo: codigo,
        password: password,
      );
      await _clearLock();
      state = state.copyWith(
        asesor: asesor,
        isLoading: false,
        intentosFallidos: 0,
        clearBloqueo: true,
      );
    } catch (e) {
      final intentos = state.intentosFallidos + 1;
      await _storage.write(key: _kIntentos, value: intentos.toString());

      DateTime? bloqueadoHasta;
      if (intentos >= 5) {
        bloqueadoHasta = DateTime.now().add(const Duration(minutes: 30));
        await _storage.write(
          key: _kBloqueadoHasta,
          value: bloqueadoHasta.toIso8601String(),
        );
      }

      state = state.copyWith(
        isLoading: false,
        error: _mensajeError(intentos),
        intentosFallidos: intentos,
        bloqueadoHasta: bloqueadoHasta,
      );
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    await _clearLock();
    state = const LoginState(isCheckingSession: false);
  }

  Future<void> _clearLock() async {
    await _storage.delete(key: _kIntentos);
    await _storage.delete(key: _kBloqueadoHasta);
  }

  String _mensajeError(int intentos) {
    if (intentos >= 5) {
      return 'Acceso bloqueado por 30 minutos tras 5 intentos fallidos.';
    }
    return 'Código o contraseña incorrectos. Intentos restantes: ${5 - intentos}.';
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

final _secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final _authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(AuthRemoteDatasource()),
);

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>(
  (ref) => LoginViewModel(
    ref.read(_authRepositoryProvider),
    ref.read(_secureStorageProvider),
  ),
);