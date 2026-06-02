import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cliente_detalle_model.dart';
import 'ficha_cliente_state.dart';

class FichaClienteViewModel extends StateNotifier<FichaClienteState> {
  FichaClienteViewModel() : super(FichaClienteState());

  void cargarDetalleCliente(String clienteId) async {
    state = state.copyWith(isLoading: true);
    
    // Simulación de retraso de red o lectura de SQLite
    await Future.delayed(const Duration(milliseconds: 600));

    // Data semilla basada en el perfil del cliente para pruebas
    final mockCliente = ClienteDetalleModel(
      id: clienteId,
      nombreCompleto: 'Juan De Dios Condori',
      documento: '45871293',
      celular: '954781236',
      direccionCompleta: 'Av. Próceres de la Independencia 420, Chilca',
      actividadEconomica: 'Comercio de abarrotes y ferretería menor',
      calificacionSbs: 'CPP', // Evaluará AppColors.colorPorCalificacionSbs
      saldoDeudaCaja: 12500.00,
      saldoDeudaOtros: 4300.00,
      diasMora: 14,
    );

    state = state.copyWith(cliente: mockCliente, isLoading: false);
  }
}

final fichaClienteViewModelProvider =
    StateNotifierProvider<FichaClienteViewModel, FichaClienteState>((ref) {
  return FichaClienteViewModel();
});