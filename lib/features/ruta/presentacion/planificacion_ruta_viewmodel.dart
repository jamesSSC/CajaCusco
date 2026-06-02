import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart'; // Asegúrate de tener este import
import '../../cartera/presentacion/cartera_viewmodel.dart';

// Modificamos el estado local de la vista para manejar las coordenadas limpiamente
class PlanificacionRutaState {
  final List<dynamic> puntosVisita; // Mantiene los clientes de la cartera
  final dynamic itemSeleccionado;
  final Map<String, LatLng> coordenadasClientes; // ── NUEVO: Diccionario de coordenadas ──
  final bool isLoading;

  PlanificacionRutaState({
    this.puntosVisita = const [],
    this.itemSeleccionado,
    this.coordenadasClientes = const {},
    this.isLoading = false,
  });

  PlanificacionRutaState copyWith({
    List<dynamic>? puntosVisita,
    dynamic itemSeleccionado,
    Map<String, LatLng>? coordenadasClientes,
    bool? isLoading,
  }) {
    return PlanificacionRutaState(
      puntosVisita: puntosVisita ?? this.puntosVisita,
      itemSeleccionado: itemSeleccionado ?? this.itemSeleccionado,
      coordenadasClientes: coordenadasClientes ?? this.coordenadasClientes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PlanificacionRutaViewModel extends StateNotifier<PlanificacionRutaState> {
  PlanificacionRutaViewModel(this._ref) : super(PlanificacionRutaState());

  final Ref _ref;

  void inicializarRuta() {
    state = state.copyWith(isLoading: true);

    // Tomamos la lista original intacta del proveedor de cartera
    final carteraItems = _ref.read(carteraViewModelProvider).filteredItems;

    // Coordenadas fijas distribuidas estratégicamente en Chilca y Huancayo Centro
    final List<LatLng> coordenadasChilca = [
      const LatLng(-12.0831, -75.2102), // Parque Principal de Chilca
      const LatLng(-12.0785, -75.2114), // Av. 9 de Diciembre con Real
      const LatLng(-12.0892, -75.2145), // Av. Próceres de la Independencia
      const LatLng(-12.0715, -75.2078), // Mercado Modelo / Toribio Luzuriaga
      const LatLng(-12.0672, -75.2048), // Inmediaciones de Real Plaza
    ];

    // Mapeamos el ID de cada cliente a una coordenada de la lista
    final Map<String, LatLng> mapaGeolocalizacion = {};
    for (int i = 0; i < carteraItems.length; i++) {
      final item = carteraItems[i];
      final coordenada = coordenadasChilca[i % coordenadasChilca.length];
      mapaGeolocalizacion[item.id] = coordenada;
    }

    state = state.copyWith(
      puntosVisita: carteraItems,
      coordenadasClientes: mapaGeolocalizacion,
      itemSeleccionado: carteraItems.isNotEmpty ? carteraItems.first : null,
      isLoading: false,
    );
  }

  void seleccionarCliente(dynamic item) {
    state = state.copyWith(itemSeleccionado: item);
  }
}

final planificacionRutaViewModelProvider =
    StateNotifierProvider<PlanificacionRutaViewModel, PlanificacionRutaState>((ref) {
  return PlanificacionRutaViewModel(ref);
});