import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/presentation/login_viewmodel.dart';
import '../../auth/domain/asesor_model.dart';

class CobranzaScreen extends ConsumerWidget {
  const CobranzaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asesor = ref.watch(loginViewModelProvider).asesor;
    final vencidos = [
      {'cliente': 'Juan Mamani', 'monto': 4800, 'dias': 45, 'riesgo': 'alto'},
      {'cliente': 'Elena Soto', 'monto': 900, 'dias': 90, 'riesgo': 'critico'},
      {'cliente': 'Miguel Ccallo', 'monto': 1800, 'dias': 32, 'riesgo': 'medio'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Mora'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header de riesgo
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.danger,
                  AppColors.danger.withAlpha(200),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.danger.withAlpha(80),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(200),
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: AppColors.danger,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Cartera en Riesgo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'S/ 7,500.00',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(150),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '3 cuentas vencidas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Cards de clientes
          ...vencidos.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CobranzaCard(
                  cliente: v['cliente'] as String,
                  monto: v['monto'] as int,
                  dias: v['dias'] as int,
                  riesgo: v['riesgo'] as String,
                  asesor: asesor,
                ),
              )),
        ],
      ),
    );
  }
}

class _CobranzaCard extends StatefulWidget {
  const _CobranzaCard({
    required this.cliente,
    required this.monto,
    required this.dias,
    required this.riesgo,
    this.asesor,
  });

  final String cliente;
  final int monto;
  final int dias;
  final String riesgo;
  final AsesorModel? asesor;

  @override
  State<_CobranzaCard> createState() => _CobranzaCardState();
}

class _CobranzaCardState extends State<_CobranzaCard> {
  String? _resultadoSeleccionado;

  Color _colorRiesgo() {
    switch (widget.riesgo) {
      case 'critico':
        return AppColors.danger;
      case 'alto':
        return Colors.orange;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorRiesgo();

    return GestureDetector(
      onTap: () => _showGestion(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: color, width: 5),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withAlpha(80),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cliente,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.dias} días de mora',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.attach_money_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'S/ ${widget.monto}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(100),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.riesgo.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGestion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Registro de Gestión'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cliente: ${widget.cliente}'),
              Text('Monto: S/ ${widget.monto}'),
              const SizedBox(height: 16),
              const Text('Resultado:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Contactado', 'Rechazó', 'Prometió pago']
                    .map((r) => ChoiceChip(
                          label: Text(r),
                          selected: _resultadoSeleccionado == r,
                          onSelected: (selected) {
                            setState(() {
                              _resultadoSeleccionado = selected ? r : null;
                            });
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _resultadoSeleccionado != null
                  ? () async {
                      Navigator.pop(ctx);
                      await _guardarGestion(context, widget.cliente, _resultadoSeleccionado!);
                    }
                  : null,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarGestion(BuildContext context, String cliente, String resultado) async {
    try {
      if (widget.asesor == null) {
        throw Exception('Usuario no autenticado');
      }

      // Buscar cliente por nombre (intenta diferentes combinaciones)
      var clienteResult = await AppSupabase.client
          .from('clientes')
          .select('id')
          .ilike('nombres', '%${cliente.split(' ')[0]}%')
          .limit(1)
          .maybeSingle();

      String? clienteId = clienteResult?['id'] as String?;

      // Si no encuentra, busca por apellido
      if (clienteId == null && cliente.contains(' ')) {
        clienteResult = await AppSupabase.client
            .from('clientes')
            .select('id')
            .ilike('apellidos', '%${cliente.split(' ').last}%')
            .limit(1)
            .maybeSingle();
        clienteId = clienteResult?['id'] as String?;
      }

      // Si aún no encuentra, crea uno en la tabla
      if (clienteId == null) {
        clienteId = const Uuid().v4();
        final partes = cliente.split(' ');
        await AppSupabase.client.from('clientes').insert({
          'id': clienteId,
          'nombres': partes.isNotEmpty ? partes.first : cliente,
          'apellidos': partes.length > 1 ? partes.sublist(1).join(' ') : 'S/N',
          'numero_documento': 'TEMP-${DateTime.now().millisecondsSinceEpoch}',
          'tipo_documento': 'DNI',
        });
      }

      // Buscar crédito del cliente (en cualquier estado)
      var creditoResult = await AppSupabase.client
          .from('creditos')
          .select('id')
          .eq('cliente_id', clienteId)
          .limit(1)
          .maybeSingle();

      String? creditoId = creditoResult?['id'] as String?;

      // Si no hay crédito, usar un ID temporal
      if (creditoId == null) {
        creditoId = const Uuid().v4();
      }

      // Mapear resultado a valores válidos
      final resultadoMapeado = resultado == 'Rechazó'
          ? 'se_niega'
          : resultado == 'Prometió pago'
              ? 'compromiso_pago'
              : 'sin_contacto';

      // Guardar en tabla acciones_cobranza
      await AppSupabase.client.from('acciones_cobranza').insert({
        'id': const Uuid().v4(),
        'asesor_id': widget.asesor!.id,
        'cliente_id': clienteId,
        'credito_id': creditoId,
        'tipo_gestion': 'visita',
        'resultado': resultadoMapeado,
        'observaciones': 'Gestión registrada desde app móvil',
        'lat': -12.0689,
        'lng': -75.2101,
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Gestión registrada: $resultado'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
