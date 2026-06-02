import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/storage/local_db.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../auth/domain/asesor_model.dart';
import '../../auth/presentation/login_viewmodel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asesor = ref.watch(loginViewModelProvider).asesor;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(200),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.appName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => _showNotificaciones(context),
                  tooltip: 'Alertas',
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFD54F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: _AppDrawer(asesor: asesor),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: _DashboardBody(asesor: asesor),
          ),
        ],
      ),
    );
  }

  void _showNotificaciones(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notificaciones'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _notificationItem(
                icon: Icons.person_add_rounded,
                titulo: 'Nueva asignación',
                descripcion: 'Se asignó cliente Juan Mamani',
                hora: 'Hace 5 min',
                color: AppColors.success,
              ),
              const Divider(height: 16),
              _notificationItem(
                icon: Icons.warning_rounded,
                titulo: 'Cartera vencida',
                descripcion: 'Elena Soto - 90 días de mora',
                hora: 'Hace 2 horas',
                color: AppColors.danger,
              ),
              const Divider(height: 16),
              _notificationItem(
                icon: Icons.check_circle_rounded,
                titulo: 'Solicitud aprobada',
                descripcion: 'Expediente EXP-20260602-0001',
                hora: 'Hace 4 horas',
                color: AppColors.success,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _notificationItem({
    required IconData icon,
    required String titulo,
    required String descripcion,
    required String hora,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(80),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                descripcion,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hora,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Cuerpo del dashboard ──────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.asesor});

  final AsesorModel? asesor;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Saludo personalizado
        Text(
          'Bienvenido, ${asesor?.nombres ?? ''}',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Agencia Cusco  ·  ${_labelPerfil(asesor?.perfil)}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Módulos operativos. Cada uno navega a su ruta; mientras no esté
        // implementado, la ruta muestra un placeholder "En desarrollo".
        _ModuloCard(
          icon: Icons.list_alt_rounded,
          titulo: AppStrings.cartera,
          subtitulo: 'Ver clientes asignados del día',
          color: AppColors.tipoRenovacion,
          disponible: true,
          onTap: () => context.pushNamed('cartera'),
        ),
        const SizedBox(height: 10),
        _ModuloCard(
          icon: Icons.map_outlined,
          titulo: AppStrings.ruta,
          subtitulo: 'Planificar y optimizar visitas',
          color: AppColors.success,
          disponible: true,
          onTap: () => context.pushNamed('ruta'),
        ),
        const SizedBox(height: 10),
        _ModuloCard(
          icon: Icons.description_outlined,
          titulo: AppStrings.solicitudes,
          subtitulo: 'Nueva solicitud de crédito',
          color: AppColors.tipoNuevaSolicitud,
          disponible: true,
          onTap: () => context.pushNamed('solicitudes'),
        ),
        const SizedBox(height: 10),
        _ModuloCard(
          icon: Icons.calculate_outlined,
          titulo: AppStrings.simulador,
          subtitulo: 'Calcular cuota al instante',
          color: AppColors.info,
          disponible: true,
          onTap: () => context.pushNamed('simulador'),
        ),
        const SizedBox(height: 10),
        _ModuloCard(
          icon: Icons.account_balance_wallet_outlined,
          titulo: AppStrings.cobranza,
          subtitulo: 'Gestión de mora y cobranza',
          color: AppColors.danger,
          disponible: true,
          onTap: () => context.pushNamed('cobranza'),
        ),

        // Módulos solo para supervisores / administradores
        if (asesor?.puedeVerReportes ?? false) ...[
          const SizedBox(height: 10),
          _ModuloCard(
            icon: Icons.bar_chart_rounded,
            titulo: AppStrings.reportes,
            subtitulo: 'Supervisión y productividad',
            color: AppColors.tipoDesertor,
            disponible: true,
            onTap: () => context.pushNamed('reportes'),
          ),
        ],

        const SizedBox(height: 32),
        // Versión — útil para demo
        Center(
          child: Text(
            'v1.0.0  ·  ${AppStrings.appName}',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  String _labelPerfil(String? perfil) {
    switch (perfil) {
      case 'operador':
        return 'Asesor de Negocios';
      case 'super_operador':
        return 'Jefe de Comité';
      case 'supervisor':
        return 'Supervisor de Agencia';
      case 'administrador':
        return 'Administrador';
      default:
        return '';
    }
  }
}

// ── Tarjeta de módulo ─────────────────────────────────────────────────────

class _ModuloCard extends StatefulWidget {
  const _ModuloCard({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.disponible,
    required this.onTap,
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;
  final Color color;
  final bool disponible;
  final VoidCallback onTap;

  @override
  State<_ModuloCard> createState() => _ModuloCardState();
}

class _ModuloCardState extends State<_ModuloCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation =
        Tween<double>(begin: 1, end: 1.02).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _animController.forward(),
        onTapUp: (_) => _animController.reverse(),
        onTapCancel: () => _animController.reverse(),
        onTap: widget.disponible ? widget.onTap : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha(40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color,
                          widget.color.withAlpha(200),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withAlpha(80),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.disponible
                              ? widget.subtitulo
                              : 'Próximamente',
                          style: TextStyle(
                            color: widget.disponible
                                ? AppColors.textSecondary
                                : AppColors.disabled,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: widget.color,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Drawer lateral adaptativo por perfil (RF-05) ──────────────────────────

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer({required this.asesor});

  final AsesorModel? asesor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Navega a un módulo cerrando primero el drawer. Capturamos el router
    // ANTES del pop para no usar un context que ya quedó fuera del árbol.
    void irA(String routeName) {
      final router = GoRouter.of(context);
      Navigator.pop(context); // cierra el drawer
      router.pushNamed(routeName);
    }

    return Drawer(
      child: Column(
        children: [
          // Cabecera con datos del asesor
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(
              asesor?.nombreCompleto ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              _labelPerfil(asesor?.perfil),
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.primaryDark,
              child: Text(
                asesor?.nombres.isNotEmpty == true
                    ? asesor!.nombres[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Opciones según perfil (RF-05: las no autorizadas no aparecen)
          _DrawerItem(
            icon: Icons.dashboard_outlined,
            label: 'Inicio',
            onTap: () => Navigator.pop(context), // ya estamos en el dashboard
          ),
          _DrawerItem(
            icon: Icons.list_alt_rounded,
            label: AppStrings.cartera,
            onTap: () => irA('cartera'),
          ),
          _DrawerItem(
            icon: Icons.map_outlined,
            label: AppStrings.ruta,
            onTap: () => irA('ruta'),
          ),
          _DrawerItem(
            icon: Icons.description_outlined,
            label: AppStrings.solicitudes,
            onTap: () => irA('solicitudes'),
          ),
          _DrawerItem(
            icon: Icons.calculate_outlined,
            label: AppStrings.simulador,
            onTap: () => irA('simulador'),
          ),
          _DrawerItem(
            icon: Icons.account_balance_wallet_outlined,
            label: AppStrings.cobranza,
            onTap: () => irA('cobranza'),
          ),

          // Solo supervisores y administradores
          if (asesor?.puedeVerReportes ?? false)
            _DrawerItem(
              icon: Icons.bar_chart_rounded,
              label: AppStrings.reportes,
              onTap: () => irA('reportes'),
            ),

          const Divider(),
          const Spacer(),

          // Cerrar sesión siempre visible (HU-03)
          _DrawerItem(
            icon: Icons.logout,
            label: AppStrings.cerrarSesion,
            color: AppColors.danger,
            onTap: () async {
              _confirmLogout(context, ref);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _labelPerfil(String? perfil) {
    switch (perfil) {
      case 'operador':
        return 'Asesor de Negocios';
      case 'super_operador':
        return 'Jefe de Comité en Campo';
      case 'supervisor':
        return 'Supervisor de Agencia';
      case 'administrador':
        return 'Administrador';
      default:
        return '';
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    // RF-08: Avisar si hay solicitudes pendientes de sync
    final pendientes = await _getPendientesSync();

    if (!context.mounted) return;

    final String mensaje = pendientes > 0
        ? 'Tienes $pendientes solicitud${pendientes > 1 ? 'es' : ''} sin sincronizar. '
            '¿Cerrar de todas formas?'
        : '¿Deseas cerrar sesión?';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.cerrarSesion),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              AppStrings.cerrarSesion,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    // Si canceló, cerrar el drawer
    if (confirmed != true) {
      Navigator.pop(context);
      return;
    }

    // Si confirmó, intentar logout
    try {
      await ref.read(loginViewModelProvider.notifier).signOut();
      if (context.mounted) {
        Navigator.pop(context); // Cerrar drawer si aún existe
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cerrar sesión. Intenta de nuevo.'),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context); // Cerrar drawer de todas formas
      }
    }
  }

  Future<int> _getPendientesSync() async {
    try {
      return await LocalDb.instance.countPendienteSync();
    } catch (_) {
      return 0;
    }
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(label, style: TextStyle(color: effectiveColor)),
      onTap: onTap,
      dense: true,
    );
  }
}