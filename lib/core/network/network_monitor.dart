import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream que emite true cuando hay red, false cuando no la hay.
final networkStreamProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
        (results) => results.any((r) => r != ConnectivityResult.none),
      );
});

/// Provider booleano simple: ¿hay conexión ahora mismo?
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(networkStreamProvider).maybeWhen(
        data: (online) => online,
        orElse: () => true, // Asume online si aún no hay dato
      );
});
