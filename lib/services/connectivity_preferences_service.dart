import '../models/connectivity_preferences.dart';
import 'isar_service.dart';

/// Servicio para gestionar las preferencias de conectividad
class ConnectivityPreferencesService {
  ConnectivityPreferencesService._();
  static final ConnectivityPreferencesService _instance = ConnectivityPreferencesService._();
  factory ConnectivityPreferencesService() => _instance;

  final IsarService _isarService = IsarService();

  /// Obtiene las preferencias guardadas o las crea por defecto
  Future<ConnectivityPreferences> getPreferences() async {
    final isar = _isarService.instance;
    
    // Buscar preferencias existentes (siempre usamos ID 1 para preferencias únicas)
    var preferences = await isar.connectivityPreferences.get(1);
    
    // Si no existen, crear preferencias por defecto
    if (preferences == null) {
      preferences = ConnectivityPreferences.defaultPreferences;
      await savePreferences(preferences);
    }
    
    return preferences;
  }

  /// Guarda las preferencias
  Future<void> savePreferences(ConnectivityPreferences preferences) async {
    final isar = _isarService.instance;
    
    await isar.writeTxn(() async {
      // Guardar con ID fijo (1) para tener una única instancia de preferencias
      preferences.id = 1;
      await isar.connectivityPreferences.put(preferences);
    });
  }

  /// Actualiza una preferencia específica
  Future<void> updatePreference({
    bool? isEnabled,
    int? displayMode,
    bool? showWhenOnline,
    bool? showNotifications,
    bool? vibrateOnDisconnect,
    bool? playSoundOnChange,
  }) async {
    final current = await getPreferences();
    final updated = current.copyWith(
      isEnabled: isEnabled,
      displayMode: displayMode,
      showWhenOnline: showWhenOnline,
      showNotifications: showNotifications,
      vibrateOnDisconnect: vibrateOnDisconnect,
      playSoundOnChange: playSoundOnChange,
    );
    
    await savePreferences(updated);
  }

  /// Resetea las preferencias a los valores por defecto
  Future<void> resetToDefaults() async {
    await savePreferences(ConnectivityPreferences.defaultPreferences);
  }

  /// Stream de cambios en las preferencias
  Stream<ConnectivityPreferences?> watchPreferences() {
    final isar = _isarService.instance;
    return isar.connectivityPreferences.watchObject(1, fireImmediately: true);
  }
}
