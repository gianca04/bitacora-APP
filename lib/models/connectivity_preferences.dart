import 'package:isar/isar.dart';

part 'connectivity_preferences.g.dart';

/// Preferencias de usuario para el indicador de conectividad
@collection
class ConnectivityPreferences {
  Id id = Isar.autoIncrement;

  /// Si el indicador debe estar visible o no
  @Index()
  bool isEnabled;

  /// Modo de visualización del indicador
  /// 0: iconOnly, 1: iconWithText, 2: dotOnly, 3: badge
  @Index()
  int displayMode;

  /// Si debe mostrar el indicador cuando está online
  bool showWhenOnline;

  /// Si debe mostrar notificaciones cuando cambia el estado
  bool showNotifications;

  /// Si debe vibrar cuando se pierde la conexión
  bool vibrateOnDisconnect;

  /// Si debe reproducir sonido en cambios de estado
  bool playSoundOnChange;

  /// Última actualización de las preferencias
  DateTime lastUpdated;

  ConnectivityPreferences({
    this.isEnabled = true,
    this.displayMode = 0, // iconOnly por defecto
    this.showWhenOnline = false,
    this.showNotifications = true,
    this.vibrateOnDisconnect = false,
    this.playSoundOnChange = false,
  }) : lastUpdated = DateTime.now();

  /// Copia las preferencias con valores opcionales modificados
  ConnectivityPreferences copyWith({
    bool? isEnabled,
    int? displayMode,
    bool? showWhenOnline,
    bool? showNotifications,
    bool? vibrateOnDisconnect,
    bool? playSoundOnChange,
  }) {
    final updated = ConnectivityPreferences(
      isEnabled: isEnabled ?? this.isEnabled,
      displayMode: displayMode ?? this.displayMode,
      showWhenOnline: showWhenOnline ?? this.showWhenOnline,
      showNotifications: showNotifications ?? this.showNotifications,
      vibrateOnDisconnect: vibrateOnDisconnect ?? this.vibrateOnDisconnect,
      playSoundOnChange: playSoundOnChange ?? this.playSoundOnChange,
    );
    updated.lastUpdated = DateTime.now();
    return updated;
  }

  /// Obtiene el nombre del modo de visualización
  String get displayModeName {
    switch (displayMode) {
      case 0:
        return 'Solo icono';
      case 1:
        return 'Icono con texto';
      case 2:
        return 'Punto de color';
      case 3:
        return 'Badge';
      default:
        return 'Solo icono';
    }
  }

  /// Preferencias por defecto
  static ConnectivityPreferences get defaultPreferences => ConnectivityPreferences();
}
