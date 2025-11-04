import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';

/// Provider del servicio de conectividad (singleton)
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Provider del estado actual de conectividad
/// Inicia con el estado actual del servicio (no en loading)
final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  
  // Retornar el stream que emite inmediatamente el estado actual
  return service.statusStream;
});

/// Provider que indica si hay conexión a Internet (booleano simple)
final hasInternetProvider = Provider<bool>((ref) {
  final statusAsync = ref.watch(connectionStatusProvider);
  return statusAsync.when(
    data: (status) => status == ConnectionStatus.online,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider que indica si se debe mostrar el banner de "sin conexión"
final shouldShowNoConnectionBannerProvider = Provider<bool>((ref) {
  final statusAsync = ref.watch(connectionStatusProvider);
  return statusAsync.when(
    data: (status) => status != ConnectionStatus.online,
    loading: () => false,
    error: (_, __) => true,
  );
});
