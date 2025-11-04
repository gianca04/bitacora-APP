import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';

/// Clase de ayuda para hacer llamadas al backend con verificación de conexión
/// 
/// Uso:
/// ```dart
/// final result = await ApiCallHelper.execute<MyData>(
///   apiCall: () => myRepository.fetchData(),
///   onNoConnection: () {
///     // Mostrar mensaje al usuario
///     showSnackbar('Sin conexión a Internet');
///   },
/// );
/// ```
class ApiCallHelper {
  /// Ejecuta una llamada al backend solo si hay conexión a Internet
  /// 
  /// Retorna null si no hay conexión
  static Future<T?> execute<T>({
    required Future<T> Function() apiCall,
    VoidCallback? onNoConnection,
  }) async {
    final hasConnection = await ConnectivityService().hasInternetConnection();
    
    if (!hasConnection) {
      debugPrint('⚠️ Cancelando llamada API: sin conexión a Internet');
      onNoConnection?.call();
      return null;
    }
    
    try {
      return await apiCall();
    } catch (e) {
      debugPrint('❌ Error en llamada API: $e');
      rethrow;
    }
  }

  /// Ejecuta una llamada al backend con reintentos si falla por conexión
  /// 
  /// Útil para operaciones críticas que deben completarse
  static Future<T?> executeWithRetry<T>({
    required Future<T> Function() apiCall,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    VoidCallback? onNoConnection,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      final hasConnection = await ConnectivityService().hasInternetConnection();
      
      if (!hasConnection) {
        debugPrint('⚠️ Intento ${attempts + 1}/$maxRetries: sin conexión');
        attempts++;
        
        if (attempts >= maxRetries) {
          onNoConnection?.call();
          return null;
        }
        
        await Future.delayed(retryDelay);
        continue;
      }
      
      try {
        return await apiCall();
      } catch (e) {
        debugPrint('❌ Error en intento ${attempts + 1}/$maxRetries: $e');
        attempts++;
        
        if (attempts < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          rethrow;
        }
      }
    }
    
    return null;
  }
}

/// Extensión para usar fácilmente la verificación de conexión en providers
extension ConnectivityCheck on Future<void> Function() {
  /// Ejecuta la función solo si hay conexión a Internet
  Future<void> callIfConnected({
    VoidCallback? onNoConnection,
  }) async {
    final hasConnection = await ConnectivityService().hasInternetConnection();
    
    if (!hasConnection) {
      debugPrint('⚠️ Operación cancelada: sin conexión a Internet');
      onNoConnection?.call();
      return;
    }
    
    await this();
  }
}
