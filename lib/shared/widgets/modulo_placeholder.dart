import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Pantalla temporal para los módulos que todavía no están implementados.
///
/// Cada módulo del roadmap (Cartera, Ruta, Solicitudes, etc.) apunta aquí
/// hasta que se construya su pantalla real. Cuando implementes un módulo
/// (p. ej. Fase 4 — Cartera), crea su propia Screen dentro de
/// `lib/features/<modulo>/presentation/` y cambia el `builder` de su ruta en
/// `router.dart` para que use esa pantalla en lugar de este placeholder.
class ModuloPlaceholder extends StatelessWidget {
  const ModuloPlaceholder({
    super.key,
    required this.titulo,
    required this.icon,
    required this.fase,
    required this.descripcion,
    this.color = AppColors.primary,
  });

  final String titulo;
  final IconData icon;
  final String fase;
  final String descripcion;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: color.withAlpha(30),
                child: Icon(icon, size: 44, color: color),
              ),
              const SizedBox(height: 24),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'En desarrollo  ·  $fase',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                descripcion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}