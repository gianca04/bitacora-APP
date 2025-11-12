import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';
import '../services/connectivity_service.dart';
import 'cupertino_notification_banner.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../providers/connectivity_preferences_provider.dart';

/// Widget global que monitorea la conexión y muestra notificaciones Cupertino
/// cuando el estado cambia (en lugar del banner viejo de Material Design)
/// 
/// El indicador en el navbar sigue funcionando normal con LogoToConnectivityTransition
class NoConnectionBanner extends ConsumerStatefulWidget {
  final Widget child;

  const NoConnectionBanner({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<NoConnectionBanner> createState() => _NoConnectionBannerState();
}

class _NoConnectionBannerState extends ConsumerState<NoConnectionBanner> {
  ConnectionStatus? _previousStatus;

  @override
  Widget build(BuildContext context) {
    final connectionStatusAsync = ref.watch(connectionStatusProvider);

    return connectionStatusAsync.when(
      data: (status) {
        // Mostrar notificación Cupertino cuando cambia el estado
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleStatusChange(context, status);
        });
        
        // Solo retornamos el child - el indicador está en el navbar
        return widget.child;
      },
      loading: () => widget.child,
      error: (_, __) => widget.child,
    );
  }

  void _handleStatusChange(BuildContext context, ConnectionStatus status) async {
    // Leer preferencias del usuario para comportamiento háptico/sonoro
    final prefs = ref.read(connectivityPreferencesNotifierProvider);
    // Solo mostrar notificación si el estado cambió
    if (_previousStatus != null && _previousStatus != status) {
      // Conexión restaurada
      if (status == ConnectionStatus.online && _previousStatus != ConnectionStatus.online) {
        CupertinoNotificationBanner.show(
          context,
          message: 'Conexión restaurada',
          type: NotificationType.success,
          showLogo: true,
          duration: const Duration(seconds: 2),
        );
        // Reproducir sonido/haptics opcional si está habilitado
        try {
          if (prefs.playSoundOnChange) {
            SystemSound.play(SystemSoundType.alert);
          }
          // Optionally vibrate on restore only if explicitly desired
          // (vibrateOnDisconnect is intended for disconnects, so we don't
          // vibrate here unless a separate preference exists)
        } catch (e) {
          // Ignorar errores de haptics en plataformas que no soportan
        }
      }
      // Se perdió la conexión
      else if (status != ConnectionStatus.online && _previousStatus == ConnectionStatus.online) {
        CupertinoNotificationBanner.show(
          context,
          message: _getMessageForStatus(status),
          type: _getTypeForStatus(status),
          showLogo: true,
          duration: const Duration(seconds: 4),
        );
        // Vibrar si la preferencia está activada (sin bloquear)
        if (prefs.vibrateOnDisconnect) {
          _performVibration();
        }
        if (prefs.playSoundOnChange) {
          try {
            SystemSound.play(SystemSoundType.alert);
          } catch (e) {
            print('Error reproduciendo sonido: $e');
          }
        }
      }
    }
    
    _previousStatus = status;
  }

  /// Ejecuta la vibración de forma asíncrona sin bloquear la UI
  void _performVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 300);
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      print('Error al vibrar: $e');
      // Fallback silencioso a haptic feedback básico
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {
        // Si incluso HapticFeedback falla, no hacer nada
      }
    }
  }

  String _getMessageForStatus(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.offline:
        return 'Sin conexión a la red';
      case ConnectionStatus.noInternet:
        return 'Conectado sin acceso a Internet';
      case ConnectionStatus.online:
        return 'Conexión establecida';
    }
  }

  NotificationType _getTypeForStatus(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.offline:
        return NotificationType.error;
      case ConnectionStatus.noInternet:
        return NotificationType.warning;
      case ConnectionStatus.online:
        return NotificationType.success;
    }
  }
}

/// Pantalla completa de "Sin Conexión" (alternativa más prominente)
/// 
/// Se puede usar en lugar del banner para una experiencia más explícita
class NoConnectionScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoConnectionScreen({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 100,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Sin conexión a Internet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Verifica tu conexión WiFi o datos móviles\ne intenta nuevamente',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget helper para mostrar un overlay temporal cuando se recupera la conexión
class ConnectionRestoredOverlay extends StatelessWidget {
  const ConnectionRestoredOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            'Conexión restaurada',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
