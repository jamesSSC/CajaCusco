import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/cartera_diaria_model.dart';

class CarteraItemCard extends StatefulWidget {
  final CarteraDiariaModel item;
  final VoidCallback onTap;

  const CarteraItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  State<CarteraItemCard> createState() => _CarteraItemCardState();
}

class _CarteraItemCardState extends State<CarteraItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.colorPorTipoGestion(widget.item.tipoGestion);
    final esVisitado = widget.item.estadoVisita == 'visitado';

    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 1.01)
          .animate(_animController),
      child: GestureDetector(
        onTapDown: (_) => _animController.forward(),
        onTapUp: (_) => _animController.reverse(),
        onTapCancel: () => _animController.reverse(),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: statusColor.withAlpha(30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: esVisitado ? Colors.grey.shade50 : Colors.white,
                border: Border(
                  left: BorderSide(
                    color: statusColor,
                    width: 4,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Tipo de gestión + Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(80),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.item.tipoGestion.replaceAll('_', ' '),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(100),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Score: ${widget.item.scorePrioridad}',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Nombre del cliente
                  Text(
                    widget.item.clienteNombre,
                    style: TextStyle(
                      color: esVisitado
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration:
                          esVisitado ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Documento
                  Row(
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.item.clienteDocumento,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Estado de la visita
                  if (esVisitado) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Visitado',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
