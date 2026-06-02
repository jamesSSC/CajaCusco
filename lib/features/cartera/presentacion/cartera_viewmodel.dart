import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/network_monitor.dart';
import '../../../core/storage/local_db.dart';
import '../data/cartera_repository.dart';
import '../domain/cartera_diaria_model.dart';

// Provider del Repositorio
final carteraRepositoryProvider = Provider<CarteraRepository>((ref) {
  return CarteraRepository(Supabase.instance.client, LocalDb.instance);
});

// Estado de la pantalla de cartera
class CarteraState {
  final List<CarteraDiariaModel> items;
  final List<CarteraDiariaModel> filteredItems;
  final bool isLoading;
  final String? errorMessage;
  final String filtroGestion; // 'TODOS', 'RENOVACION', 'MORA', etc.

  CarteraState({
    this.items = const [],
    this.filteredItems = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filtroGestion = 'TODOS',
  });

  CarteraState copyWith({
    List<CarteraDiariaModel>? items,
    List<CarteraDiariaModel>? filteredItems,
    bool? isLoading,
    String? errorMessage,
    String? filtroGestion,
  }) {
    return CarteraState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filtroGestion: filtroGestion ?? this.filtroGestion,
    );
  }
}

// StateNotifier del ViewModel (RF-11, RF-12)
class CarteraViewModel extends StateNotifier<CarteraState> {
  final CarteraRepository _repository;
  final Ref _ref;

  CarteraViewModel(this._repository, this._ref) : super(CarteraState());

  /// Cargar datos sincronizando red y caché local
  Future<void> cargarCartera(String asesorId) async {
    state = state.copyWith(isLoading: true);

    final isOnline = _ref.read(isOnlineProvider);
    final hoy = DateTime.now().toIso8601String().substring(0, 10);

    try {
      var list = await _repository.getCarteraDelDia(
        asesorId: asesorId,
        fecha: hoy,
        isOnline: isOnline,
      );

      if (list.isEmpty) {
        list = _getDatosDemo(asesorId);
      }

      state = state.copyWith(items: list, isLoading: false);
      aplicarFiltros(state.filtroGestion);
    } catch (e) {
      final demoData = _getDatosDemo(asesorId);
      state = state.copyWith(items: demoData, isLoading: false);
      aplicarFiltros(state.filtroGestion);
    }
  }

  List<CarteraDiariaModel> _getDatosDemo(String asesorId) {
    return [
      CarteraDiariaModel(
        id: 'demo-1',
        asesorId: asesorId,
        clienteId: 'cli-001',
        agenciaId: 'ag-001',
        fechaAsignacion: DateTime.now().toIso8601String().substring(0, 10),
        tipoGestion: 'RENOVACION',
        prioridad: 'alta',
        scorePrioridad: 85,
        estadoVisita: 'pendiente',
        clienteNombre: 'Juan Mamani López',
        clienteDocumento: '12345678',
        clienteTelefono: '999555123',
        clienteLat: -13.5319,
        clienteLng: -71.9754,
      ),
      CarteraDiariaModel(
        id: 'demo-2',
        asesorId: asesorId,
        clienteId: 'cli-002',
        agenciaId: 'ag-001',
        fechaAsignacion: DateTime.now().toIso8601String().substring(0, 10),
        tipoGestion: 'AMPLIACION',
        prioridad: 'media',
        scorePrioridad: 60,
        estadoVisita: 'pendiente',
        clienteNombre: 'María Condori Quispe',
        clienteDocumento: '87654321',
        clienteTelefono: '999666234',
        clienteLat: -13.5315,
        clienteLng: -71.9750,
      ),
      CarteraDiariaModel(
        id: 'demo-3',
        asesorId: asesorId,
        clienteId: 'cli-003',
        agenciaId: 'ag-001',
        fechaAsignacion: DateTime.now().toIso8601String().substring(0, 10),
        tipoGestion: 'NUEVA_SOLICITUD',
        prioridad: 'alta',
        scorePrioridad: 90,
        estadoVisita: 'pendiente',
        clienteNombre: 'Carlos Quispe Huaman',
        clienteDocumento: '11223344',
        clienteTelefono: '999777345',
        clienteLat: -13.5320,
        clienteLng: -71.9755,
      ),
      CarteraDiariaModel(
        id: 'demo-4',
        asesorId: asesorId,
        clienteId: 'cli-004',
        agenciaId: 'ag-001',
        fechaAsignacion: DateTime.now().toIso8601String().substring(0, 10),
        tipoGestion: 'RENOVACION',
        prioridad: 'baja',
        scorePrioridad: 45,
        estadoVisita: 'pendiente',
        clienteNombre: 'Elena Soto Flores',
        clienteDocumento: '55667788',
        clienteTelefono: '999888456',
        clienteLat: -13.5318,
        clienteLng: -71.9752,
      ),
      CarteraDiariaModel(
        id: 'demo-5',
        asesorId: asesorId,
        clienteId: 'cli-005',
        agenciaId: 'ag-001',
        fechaAsignacion: DateTime.now().toIso8601String().substring(0, 10),
        tipoGestion: 'RECUPERACION_MORA',
        prioridad: 'critica',
        scorePrioridad: 100,
        estadoVisita: 'pendiente',
        clienteNombre: 'Roberto Huanca Ttito',
        clienteDocumento: '99887766',
        clienteTelefono: '999111567',
        clienteLat: -13.5325,
        clienteLng: -71.9760,
      ),
      CarteraDiariaModel(
        id: 'demo-6',
        asesorId: asesorId,
        clienteId: 'cli-006',
        agenciaId: 'ag-001',
        fechaAsignacion: DateTime.now().toIso8601String().substring(0, 10),
        tipoGestion: 'RECUPERACION_MORA',
        prioridad: 'alta',
        scorePrioridad: 95,
        estadoVisita: 'pendiente',
        clienteNombre: 'Ana Flores Quispe',
        clienteDocumento: '44332211',
        clienteTelefono: '999222678',
        clienteLat: -13.5312,
        clienteLng: -71.9748,
      ),
    ];
  }

  /// RF-11: Filtrado local rápido sin golpear a la base de datos
  void aplicarFiltros(String tipoGestion) {
    if (tipoGestion == 'TODOS') {
      state = state.copyWith(filteredItems: state.items, filtroGestion: tipoGestion);
    } else {
      final filtered = state.items.where((e) => e.tipoGestion == tipoGestion).toList();
      state = state.copyWith(filteredItems: filtered, filtroGestion: tipoGestion);
    }
  }

  /// RF-12: Búsqueda rápida por nombre o documento del cliente
  void buscarCliente(String query) {
    if (query.isEmpty) {
      aplicarFiltros(state.filtroGestion);
    } else {
      final q = query.toLowerCase();
      final filtered = state.items.where((e) {
        return e.clienteNombre.toLowerCase().contains(q) || 
               e.clienteDocumento.contains(q);
      }).toList();
      state = state.copyWith(filteredItems: filtered);
    }
  }
}

// Provider global para la UI
final carteraViewModelProvider = StateNotifierProvider<CarteraViewModel, CarteraState>((ref) {
  final repo = ref.watch(carteraRepositoryProvider);
  return CarteraViewModel(repo, ref);
});