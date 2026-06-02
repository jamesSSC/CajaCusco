import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class EstadoSolicitudesScreen extends StatelessWidget {
  const EstadoSolicitudesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final solicitudes = [
      {
        'id': 'SOL-001',
        'cliente': 'Pedro Avendaño',
        'monto': 8000,
        'estado': 'aprobada',
        'progreso': 1.0,
        'pasos': ['Evaluación', 'Aprobación', 'Desembolso'],
        'paso_actual': 3,
      },
      {
        'id': 'SOL-002',
        'cliente': 'Lucía Ttito',
        'monto': 5000,
        'estado': 'en_proceso',
        'progreso': 0.67,
        'pasos': ['Evaluación', 'Aprobación', 'Desembolso'],
        'paso_actual': 2,
      },
      {
        'id': 'SOL-003',
        'cliente': 'Juan Mamani',
        'monto': 12000,
        'estado': 'pendiente',
        'progreso': 0.33,
        'pasos': ['Evaluación', 'Aprobación', 'Desembolso'],
        'paso_actual': 1,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Estado de Solicitudes')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: solicitudes.length,
        itemBuilder: (ctx, i) => _SolicitudCard(solicitud: solicitudes[i]),
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final Map<String, dynamic> solicitud;
  const _SolicitudCard({required this.solicitud});

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'aprobada':
        return AppColors.success;
      case 'en_proceso':
        return AppColors.info;
      case 'rechazada':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  String _labelEstado(String estado) {
    final labels = {
      'aprobada': 'Aprobada',
      'en_proceso': 'En Evaluación',
      'rechazada': 'Rechazada',
      'pendiente': 'Pendiente',
    };
    return labels[estado] ?? estado;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      solicitud['id'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      solicitud['cliente'],
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _colorEstado(solicitud['estado']).withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _labelEstado(solicitud['estado']),
                    style: TextStyle(
                      color: _colorEstado(solicitud['estado']),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'S/ ${solicitud['monto']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _Timeline(
              pasos: solicitud['pasos'],
              pasoActual: solicitud['paso_actual'],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: solicitud['progreso'],
                minHeight: 6,
                backgroundColor: AppColors.textSecondary.withAlpha(40),
                valueColor: AlwaysStoppedAnimation(_colorEstado(solicitud['estado'])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<dynamic> pasos;
  final int pasoActual;

  const _Timeline({required this.pasos, required this.pasoActual});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(pasos.length, (i) {
        final completado = i < pasoActual;
        final actual = i == pasoActual - 1;

        return Expanded(
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completado || actual ? AppColors.success : AppColors.textSecondary.withAlpha(40),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: completado || actual ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pasos[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: actual ? AppColors.success : AppColors.textSecondary,
                  fontWeight: actual ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
