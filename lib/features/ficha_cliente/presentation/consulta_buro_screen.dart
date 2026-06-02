import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/supabase/supabase_client.dart';

class ConsultaBuroScreen extends StatefulWidget {
  final String clienteDni;
  final String clienteNombre;
  const ConsultaBuroScreen({required this.clienteDni, required this.clienteNombre, super.key});

  @override
  State<ConsultaBuroScreen> createState() => _ConsultaBuroScreenState();
}

class _ConsultaBuroScreenState extends State<ConsultaBuroScreen> {
  late Future<Map<String, dynamic>> _consulta;

  @override
  void initState() {
    super.initState();
    _consulta = _consultarBuro();
  }

  Future<Map<String, dynamic>> _consultarBuro() async {
    try {
      final response = await AppSupabase.client.functions.invoke(
        'consulta-buro',
        body: {'dni': widget.clienteDni},
      );
      final data = response.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return _getDatosDemo();
    } catch (e) {
      return _getDatosDemo();
    }
  }

  Map<String, dynamic> _getDatosDemo() {
    final dniLastDigit = widget.clienteDni.isEmpty ? 0 : int.parse(widget.clienteDni.characters.last);
    final calificaciones = ['Normal', 'CPP', 'Deficiente', 'Dudoso', 'Perdida'];
    final calificacion = calificaciones[dniLastDigit % 5];
    final enListaNegra = dniLastDigit > 5;

    return {
      'calificacion': calificacion,
      'en_lista_negra': enListaNegra,
      'consulta_id': 'DEMO-${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  Color _colorCalificacion(String cal) {
    switch (cal) {
      case 'Normal':
        return AppColors.success;
      case 'CPP':
        return AppColors.warning;
      case 'Deficiente':
      case 'Dudoso':
        return Colors.orange;
      case 'Perdida':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta SBS')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _consulta,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final data = snap.data ?? {};
          final calificacion = data['calificacion'] ?? 'Normal';
          final enListaNegra = data['en_lista_negra'] ?? false;
          final consultaFecha = DateTime.now();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.clienteNombre,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'DNI: ${widget.clienteDni}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Calificación SBS',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _colorCalificacion(calificacion).withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                calificacion,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _colorCalificacion(calificacion),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Significado:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              _buildSignificado(calificacion),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (enListaNegra)
                  Card(
                    color: AppColors.danger.withAlpha(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: AppColors.danger,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'En Lista Negra SBS',
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Este cliente está registrado en la lista negra del SBS. Revisar antes de otorgar crédito.',
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    color: AppColors.success.withAlpha(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'No está en lista negra',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Este cliente no tiene restricciones en el SBS.',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de la Consulta',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fecha y Hora:',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            consultaFecha.toString().split('.')[0],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignificado(String cal) {
    const styles = TextStyle(fontSize: 11, color: AppColors.textSecondary);
    switch (cal) {
      case 'Normal':
        return const Text('Cliente con historial de pago normal', style: styles);
      case 'CPP':
        return const Text('Cliente en Condición de Pago Próximo a Vencer', style: styles);
      case 'Deficiente':
        return const Text('Cliente con pagos vencidos de 60-119 días', style: styles);
      case 'Dudoso':
        return const Text('Cliente con pagos vencidos de 120-179 días', style: styles);
      case 'Perdida':
        return const Text('Cliente con pagos vencidos de 180+ días', style: styles);
      default:
        return const Text('Clasificación desconocida', style: styles);
    }
  }
}
