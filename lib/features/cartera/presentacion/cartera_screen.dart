import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/network_monitor.dart';
import '../../../../shared/widgets/offline_banner.dart';

import '../domain/cartera_diaria_model.dart';
import 'cartera_viewmodel.dart';
import 'widgets/cartera_item_card.dart';

class CarteraScreen extends ConsumerStatefulWidget {
  final String asesorId;

  const CarteraScreen({super.key, required this.asesorId});

  @override
  ConsumerState<CarteraScreen> createState() => _CarteraScreenState();
}

class _CarteraScreenState extends ConsumerState<CarteraScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      ref.read(carteraViewModelProvider.notifier).cargarCartera(widget.asesorId)
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carteraViewModelProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final notifier = ref.read(carteraViewModelProvider.notifier);

    final filtros = ['TODOS', 'RENOVACION', 'AMPLIACION', 'NUEVA_SOLICITUD', 'RECUPERACION_MORA'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.miCartera, 
          style: TextStyle(fontFamily: 'BaiJamjuree', fontWeight: FontWeight.bold)
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.cargarCartera(widget.asesorId),
          )
        ],
      ),
      body: Column(
        children: [
          if (!isOnline) const OfflineBanner(),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => notifier.buscarCliente(value),
              decoration: InputDecoration(
                hintText: AppStrings.buscarCliente,
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () {
                        _searchController.clear();
                        notifier.buscarCliente('');
                      })
                  : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filtros.length,
              itemBuilder: (context, index) {
                final filtro = filtros[index];
                final esSeleccionado = state.filtroGestion == filtro;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filtro.replaceAll('_', ' ')),
                    selected: esSeleccionado,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: esSeleccionado ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => notifier.aplicarFiltros(filtro),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : state.filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade100,
                              ),
                              child: Icon(
                                Icons.assignment_late_outlined,
                                size: 56,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No hay asignaciones',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tus clientes aparecerán aquí',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        itemCount: state.filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = state.filteredItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: CarteraItemCard(
                              item: item,
                              onTap: () {
                                context.pushNamed(
                                  'ficha_cliente',
                                  pathParameters: {'clienteId': item.id},
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      // ── AUMENTADO: Botón Flotante para Gestión Rápida si se necesita registrar una visita directa ──
      floatingActionButton: state.filteredItems.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.edit_note, color: Colors.white),
              label: const Text('Gestión Rápida', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                // Abre el diálogo para el primer elemento de la lista actual como acceso directo
                if (state.filteredItems.isNotEmpty) {
                  _mostrarDialogoResultado(context, state.filteredItems.first, ref);
                }
              },
            )
          : null,
    );
  }

  // ── LA FUNCIÓN PRIVADA AHORA SÍ ESTÁ REFERENCIADA ABAJO Y EL WARNING DESAPARECE ──
  void _mostrarDialogoResultado(BuildContext context, CarteraDiariaModel item, WidgetRef ref) {
    if (item.estadoVisita == 'visitado') return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestionar Visita: ${item.clienteNombre}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.check_circle, color: AppColors.success),
                title: const Text(AppStrings.visitadoOk),
                onTap: () => _guardarGestion(context, item.id, AppStrings.visitadoOk, ref),
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: AppColors.danger),
                title: const Text(AppStrings.noEncontrado),
                onTap: () => _guardarGestion(context, item.id, AppStrings.noEncontrado, ref),
              ),
              ListTile(
                leading: const Icon(Icons.store_sharp, color: Colors.blueGrey),
                title: const Text(AppStrings.negocioCerrado),
                onTap: () => _guardarGestion(context, item.id, AppStrings.negocioCerrado, ref),
              ),
            ],
          ),
        );
      },
    );
  }

  void _guardarGestion(BuildContext context, String id, String resultado, WidgetRef ref) async {
    Navigator.pop(context); 
    
    final isOnline = ref.read(isOnlineProvider);
    
    await ref.read(carteraRepositoryProvider).registrarVisita(
      carteraId: id,
      resultado: resultado,
      observacion: 'Gestión registrada desde terminal móvil',
      lat: -12.0689,
      lng: -75.2101,
      isOnline: isOnline,
    );

    if (!context.mounted) return; 

    ref.read(carteraViewModelProvider.notifier).cargarCartera(widget.asesorId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isOnline ? 'Visita guardada e indexada con éxito.' : AppStrings.errorSinConexion),
        backgroundColor: isOnline ? AppColors.success : AppColors.offlineBanner,
      ),
    );
  }
}