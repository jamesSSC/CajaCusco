import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import 'planificacion_ruta_viewmodel.dart';

class PlanificacionRutaScreen extends ConsumerStatefulWidget {
  const PlanificacionRutaScreen({super.key});

  @override
  ConsumerState<PlanificacionRutaScreen> createState() => _PlanificacionRutaScreenState();
}

class _PlanificacionRutaScreenState extends ConsumerState<PlanificacionRutaScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      ref.read(planificacionRutaViewModelProvider.notifier).inicializarRuta()
    );
  }

  // RF-06: Lanzador de GPS externo para Google Maps o navegador web alternativo
  Future<void> _abrirNavegadorExterno(double lat, double lng) async {
    final googleMapsUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo encontrar una aplicación de mapas compatible.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planificacionRutaViewModelProvider);
    final notifier = ref.read(planificacionRutaViewModelProvider.notifier);

    // Centro por defecto: Chilca, Huancayo
    const LatLng centroChilca = LatLng(-12.0831, -75.2102);

    // Determinamos el punto central de inicio de la cámara de forma segura
    final LatLng puntoInicial = (state.itemSeleccionado != null && state.coordenadasClientes.containsKey(state.itemSeleccionado!.id))
        ? state.coordenadasClientes[state.itemSeleccionado!.id]!
        : centroChilca;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Planificación de Ruta',
          style: TextStyle(fontFamily: 'BaiJamjuree', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
              children: [
                // 🌍 RENDERIZADO DEL MAPA OPENSTREETMAP
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: puntoInicial,
                    initialZoom: 14.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.cajacusco.flutter_application_1',
                    ),
                    
                    // 📍 MARCADORES EN BASE AL DICCIONARIO DE COORDENADAS
                    MarkerLayer(
                      markers: state.puntosVisita.map((cliente) {
                        final esSeleccionado = state.itemSeleccionado?.id == cliente.id;
                        final colorGestion = AppColors.colorPorTipoGestion(cliente.tipoGestion);
                        
                        // Si por algún motivo no tiene coordenadas asignadas, toma el centro por defecto
                        final posicion = state.coordenadasClientes[cliente.id] ?? centroChilca;

                        return Marker(
                          point: posicion,
                          width: 46,
                          height: 46,
                          child: GestureDetector(
                            onTap: () {
                              notifier.seleccionarCliente(cliente);
                              _mapController.move(posicion, 15.5);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: esSeleccionado ? colorGestion : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
                                ],
                                border: Border.all(color: esSeleccionado ? Colors.white : colorGestion, width: 3),
                              ),
                              child: Icon(
                                Icons.person_pin_circle_rounded,
                                color: esSeleccionado ? Colors.white : colorGestion,
                                size: esSeleccionado ? 28 : 24,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // 🎴 PANEL DE DETALLE INFERIOR DEL CLIENTE EN ENFOQUE
                if (state.itemSeleccionado != null)
                  Positioned(
                    bottom: 24,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.colorPorTipoGestion(state.itemSeleccionado!.tipoGestion).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    state.itemSeleccionado!.tipoGestion,
                                    style: TextStyle(
                                      color: AppColors.colorPorTipoGestion(state.itemSeleccionado!.tipoGestion),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: state.itemSeleccionado!.prioridad == 'ALTA' 
                                          ? AppColors.prioridadAlta 
                                          : AppColors.prioridadMedia,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Score: ${state.itemSeleccionado!.scorePrioridad}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.itemSeleccionado!.clienteNombre,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Documento: ${state.itemSeleccionado!.clienteDocumento}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const Divider(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.navigation_rounded, size: 20),
                                label: const Text('Iniciar Navegación GPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                onPressed: () {
                                  final coordenadas = state.coordenadasClientes[state.itemSeleccionado!.id];
                                  if (coordenadas != null) {
                                    _abrirNavegadorExterno(coordenadas.latitude, coordenadas.longitude);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}