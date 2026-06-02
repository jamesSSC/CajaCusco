import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes y Supervisión'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Productividad del Equipo
            _buildSectionTitle('Productividad del Equipo'),
            const SizedBox(height: 16),
            _buildProductividadCard(),
            const SizedBox(height: 32),

            // Cartera por Estado
            _buildSectionTitle('Cartera por Estado'),
            const SizedBox(height: 16),
            _buildCarteraCard(),
            const SizedBox(height: 32),

            // Total Desembolsado
            _buildSectionTitle('Total Desembolsado'),
            const SizedBox(height: 16),
            _buildDesembolsoCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildProductividadCard() {
    final datos = [
      {'nombre': 'Carlos Quispe', 'valor': 8, 'color': AppColors.success},
      {'nombre': 'Ana Flores', 'valor': 12, 'color': AppColors.info},
      {'nombre': 'Roberto Huanca', 'valor': 5, 'color': AppColors.warning},
      {'nombre': 'María Condori', 'valor': 3, 'color': AppColors.danger},
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: List.generate(
              datos.length,
              (index) {
                final item = datos[index];
                final nombre = item['nombre'] as String;
                final valor = item['valor'] as int;
                final color = item['color'] as Color;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < datos.length - 1 ? 16 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              nombre,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '$valor',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (valor / 15).clamp(0, 1),
                          minHeight: 8,
                          backgroundColor: color.withAlpha(50),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarteraCard() {
    final estados = [
      {'estado': 'Vigente', 'cantidad': 35, 'color': AppColors.success},
      {'estado': 'Vencida', 'cantidad': 8, 'color': AppColors.danger},
      {'estado': 'CPP', 'cantidad': 3, 'color': AppColors.warning},
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: List.generate(
              estados.length,
              (index) {
                final item = estados[index];
                final estado = item['estado'] as String;
                final cantidad = item['cantidad'] as int;
                final color = item['color'] as Color;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < estados.length - 1 ? 16 : 0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(60),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          estado,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withAlpha(80),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$cantidad',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: color,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesembolsoCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withAlpha(200),
            AppColors.success.withAlpha(160),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Desembolsado',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'S/ 34,000.00',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Este mes: +S/ 8,000.00',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
