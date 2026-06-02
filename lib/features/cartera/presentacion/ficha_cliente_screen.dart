import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'ficha_cliente_viewmodel.dart';
import '../../ficha_cliente/presentation/consulta_buro_screen.dart';

class FichaClienteScreen extends ConsumerStatefulWidget {
  final String clienteId;

  const FichaClienteScreen({super.key, required this.clienteId});

  @override
  ConsumerState<FichaClienteScreen> createState() => _FichaClienteScreenState();
}

class _FichaClienteScreenState extends ConsumerState<FichaClienteScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      ref.read(fichaClienteViewModelProvider.notifier).cargarDetalleCliente(widget.clienteId)
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fichaClienteViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.consultaBuro,
          style: TextStyle(fontFamily: 'BaiJamjuree', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.cliente == null
              ? const Center(child: Text(AppStrings.errorGenerico))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Tarjeta Principal de Identidad
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.cliente!.nombreCompleto,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            Text('DNI: ${state.cliente!.documento}', style: const TextStyle(color: AppColors.textSecondary)),
                            Text('Celular: ${state.cliente!.celular}', style: const TextStyle(color: AppColors.textSecondary)),
                            const Divider(height: 24),
                            // Indicador dinámico de Semáforo SBS (RF-28)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Calificación SBS:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.colorPorCalificacionSbs(state.cliente!.calificacionSbs),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    state.cliente!.calificacionSbs,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => ConsultaBuroScreen(
                                      clienteDni: state.cliente!.documento,
                                      clienteNombre: state.cliente!.nombreCompleto,
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.assessment),
                                label: const Text('Consultar SBS'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tarjeta de Resumen Financiero y deudas
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Posición Integral del Cliente', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const Divider(height: 20),
                            _infoRow('Deuda en Caja Cusco', 'S/ ${state.cliente!.saldoDeudaCaja.toStringAsFixed(2)}'),
                            _infoRow('Deuda Otras Entidades', 'S/ ${state.cliente!.saldoDeudaOtros.toStringAsFixed(2)}'),
                            _infoRow('Días de Mora reportados', '${state.cliente!.diasMora} días'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tarjeta de Datos de Terreno / Domicilio
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Datos de Ubicación y Negocio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const Divider(height: 20),
                            Text(AppStrings.datosNegocio, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(state.cliente!.actividadEconomica, style: const TextStyle(color: AppColors.textPrimary)),
                            const SizedBox(height: 14),
                            const Text('Dirección de la Visita', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(state.cliente!.direccionCompleta, style: const TextStyle(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _infoRow(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: const TextStyle(color: AppColors.textSecondary)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}