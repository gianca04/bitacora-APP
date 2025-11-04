import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connectivity_preferences.dart';
import '../services/connectivity_preferences_service.dart';

/// Provider del servicio de preferencias
final connectivityPreferencesServiceProvider = Provider<ConnectivityPreferencesService>((ref) {
  return ConnectivityPreferencesService();
});

/// StateNotifier para manejar el estado de las preferencias de forma más eficiente
class ConnectivityPreferencesNotifier extends StateNotifier<ConnectivityPreferences> {
  ConnectivityPreferencesNotifier(this._service) : super(ConnectivityPreferences.defaultPreferences) {
    _loadPreferences();
  }

  final ConnectivityPreferencesService _service;

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _service.getPreferences();
      if (mounted) {
        state = prefs;
      }
    } catch (e) {
      // Si hay error, usar preferencias por defecto
      if (mounted) {
        state = ConnectivityPreferences.defaultPreferences;
      }
    }
  }

  Future<void> updatePreference({
    bool? isEnabled,
    int? displayMode,
    bool? showWhenOnline,
    bool? showNotifications,
    bool? vibrateOnDisconnect,
    bool? playSoundOnChange,
  }) async {
    // Actualizar estado local inmediatamente para UI reactiva
    state = state.copyWith(
      isEnabled: isEnabled,
      displayMode: displayMode,
      showWhenOnline: showWhenOnline,
      showNotifications: showNotifications,
      vibrateOnDisconnect: vibrateOnDisconnect,
      playSoundOnChange: playSoundOnChange,
    );

    // Guardar en base de datos en segundo plano
    await _service.updatePreference(
      isEnabled: isEnabled,
      displayMode: displayMode,
      showWhenOnline: showWhenOnline,
      showNotifications: showNotifications,
      vibrateOnDisconnect: vibrateOnDisconnect,
      playSoundOnChange: playSoundOnChange,
    );
  }

  Future<void> resetToDefaults() async {
    state = ConnectivityPreferences.defaultPreferences;
    await _service.resetToDefaults();
  }
}

/// Provider principal de preferencias (StateNotifier - más rápido)
final connectivityPreferencesNotifierProvider = 
    StateNotifierProvider<ConnectivityPreferencesNotifier, ConnectivityPreferences>((ref) {
  final service = ref.watch(connectivityPreferencesServiceProvider);
  return ConnectivityPreferencesNotifier(service);
});

/// Provider de las preferencias de conectividad (Stream) - mantener para compatibilidad
final connectivityPreferencesProvider = StreamProvider<ConnectivityPreferences?>((ref) {
  final service = ref.watch(connectivityPreferencesServiceProvider);
  return service.watchPreferences();
});

/// Provider de las preferencias actuales (síncrono)
final currentConnectivityPreferencesProvider = FutureProvider<ConnectivityPreferences>((ref) async {
  final service = ref.watch(connectivityPreferencesServiceProvider);
  return await service.getPreferences();
});
