import '../../cartera/domain/cartera_diaria_model.dart';

class PlanificacionRutaState {
  final List<CarteraDiariaModel> puntosVisita;
  final CarteraDiariaModel? itemSeleccionado;
  final bool isLoading;

  PlanificacionRutaState({
    this.puntosVisita = const [],
    this.itemSeleccionado,
    this.isLoading = false,
  });

  PlanificacionRutaState copyWith({
    List<CarteraDiariaModel>? puntosVisita,
    CarteraDiariaModel? itemSeleccionado,
    bool? isLoading,
  }) {
    return PlanificacionRutaState(
      puntosVisita: puntosVisita ?? this.puntosVisita,
      itemSeleccionado: itemSeleccionado ?? this.itemSeleccionado,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}