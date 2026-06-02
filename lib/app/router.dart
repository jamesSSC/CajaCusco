import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/login_viewmodel.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/cartera/presentacion/cartera_screen.dart';
import '../features/cartera/presentacion/ficha_cliente_screen.dart';
import '../features/ruta/presentacion/planificacion_ruta_screen.dart';
import '../features/solicitudes/presentation/solicitudes_screen.dart';
import '../features/solicitudes/presentation/estado_solicitudes_screen.dart';
import '../features/simulador/presentation/simulador_screen.dart';
import '../features/cobranza/presentation/cobranza_screen.dart';
import '../features/reportes/presentation/reportes_screen.dart';

// ── Listenable que refleja el estado de auth para GoRouter ─────────────────
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    isAuthenticated = ref.read(loginViewModelProvider).isAuthenticated;

    ref.listen<LoginState>(loginViewModelProvider, (prev, next) {
      isAuthenticated = next.isAuthenticated;
      if (prev?.isAuthenticated != next.isAuthenticated) {
        notifyListeners();
      }
    });
  }

  bool isAuthenticated = false;
}

final _authListenableProvider =
    ChangeNotifierProvider<_AuthChangeNotifier>((ref) {
  return _AuthChangeNotifier(ref);
});

// ── Router principal ───────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(_authListenableProvider);

  return GoRouter(
    refreshListenable: authNotifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authNotifier.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isAuth && !isLoginRoute) return '/login';
      if (isAuth && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // ── Módulos operativos con pantallas integradas ────────────────────────
      GoRoute(
        path: '/cartera',
        name: 'cartera',
        builder: (context, state) {
          final asesor = ref.read(loginViewModelProvider).asesor;
          final idAsesor = asesor?.id ?? '2020';
          return CarteraScreen(asesorId: idAsesor);
        },
      ),
      GoRoute(
        path: '/ficha-cliente/:clienteId',
        name: 'ficha_cliente',
        builder: (context, state) {
          final clienteId = state.pathParameters['clienteId'] ?? '';
          return FichaClienteScreen(clienteId: clienteId);
        },
      ),
      // ── MODIFICADO: Ahora renderiza la pantalla real interactiva con flutter_map ──
      GoRoute(
        path: '/ruta',
        name: 'ruta',
        builder: (context, state) => const PlanificacionRutaScreen(),
      ),
      GoRoute(
        path: '/solicitudes',
        name: 'solicitudes',
        builder: (context, state) => const SolicitudesScreen(),
      ),
      GoRoute(
        path: '/estado-solicitudes',
        name: 'estado_solicitudes',
        builder: (context, state) => const EstadoSolicitudesScreen(),
      ),
      GoRoute(
        path: '/simulador',
        name: 'simulador',
        builder: (context, state) => const SimuladorScreen(),
      ),
      GoRoute(
        path: '/cobranza',
        name: 'cobranza',
        builder: (context, state) => const CobranzaScreen(),
      ),
      GoRoute(
        path: '/reportes',
        name: 'reportes',
        builder: (context, state) => const ReportesScreen(),
      ),
    ],
  );
});