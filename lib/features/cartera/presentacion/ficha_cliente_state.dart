import '../domain/cliente_detalle_model.dart';

class FichaClienteState {
  final ClienteDetalleModel? cliente;
  final bool isLoading;
  final String? errorMessage;

  FichaClienteState({
    this.cliente,
    this.isLoading = false,
    this.errorMessage,
  });

  FichaClienteState copyWith({
    ClienteDetalleModel? cliente,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FichaClienteState(
      cliente: cliente ?? this.cliente,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}