import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter/foundation.dart';

/// Estados de conectividad posibles
enum ConnectionStatus {
  /// Dispositivo conectado y con acceso real a Internet
  online,
  
  /// Dispositivo conectado a una red pero sin acceso a Internet
  noInternet,
  
  /// Dispositivo sin conexión de red
  offline,
}

/// Servicio global para monitorear el estado de conectividad
/// 
/// Combina connectivity_plus (detecta cambios de red rápidos) con
/// internet_connection_checker_plus (verifica acceso real a Internet)
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();
  
  final StreamController<ConnectionStatus> _statusController =
      StreamController<ConnectionStatus>.broadcast();

  ConnectionStatus _currentStatus = ConnectionStatus.offline;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<InternetStatus>? _internetSubscription;
  bool _isInitialized = false;

  /// Stream que emite cada cambio de estado de conectividad
  /// El stream emite inmediatamente el estado actual al suscribirse
  Stream<ConnectionStatus> get statusStream async* {
    // Emitir el estado actual inmediatamente
    yield _currentStatus;
    // Luego escuchar los cambios
    yield* _statusController.stream;
  }

  /// Estado actual de conectividad
  ConnectionStatus get currentStatus => _currentStatus;

  /// Indica si el servicio ya fue inicializado
  bool get isInitialized => _isInitialized;

  /// Inicializa el servicio y comienza a escuchar cambios
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ ConnectivityService ya fue inicializado');
      return;
    }

    debugPrint('🚀 Inicializando ConnectivityService...');
    
    // Verificar estado inicial de forma síncrona primero
    await _checkConnection();
    
    _isInitialized = true;
    debugPrint('✅ ConnectivityService inicializado con estado: $_currentStatus');

    // Escuchar cambios en el tipo de conexión (WiFi, móvil, ninguno)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        debugPrint('🔄 Cambio de conectividad detectado: $results');
        await _checkConnection();
      },
    );

    // Escuchar verificaciones periódicas de acceso a Internet
    _internetSubscription = _internetChecker.onStatusChange.listen(
      (InternetStatus status) {
        debugPrint('🌐 Estado de Internet cambió: $status');
        _updateStatusFromInternetCheck(status);
      },
    );
  }

  /// Verifica el estado completo de la conexión
  Future<void> _checkConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      
      // Si no hay ninguna conexión de red
      if (connectivityResults.contains(ConnectivityResult.none)) {
        _updateStatus(ConnectionStatus.offline);
        return;
      }

      // Si hay conexión de red, verificar acceso real a Internet
      final hasInternetAccess = await _internetChecker.hasInternetAccess;
      
      if (hasInternetAccess) {
        _updateStatus(ConnectionStatus.online);
      } else {
        _updateStatus(ConnectionStatus.noInternet);
      }
    } catch (e) {
      debugPrint('❌ Error verificando conexión: $e');
      _updateStatus(ConnectionStatus.offline);
    }
  }

  /// Actualiza el estado basándose en la verificación de Internet
  void _updateStatusFromInternetCheck(InternetStatus status) {
    switch (status) {
      case InternetStatus.connected:
        _updateStatus(ConnectionStatus.online);
        break;
      case InternetStatus.disconnected:
        // Puede estar conectado a red local pero sin Internet
        _updateStatus(ConnectionStatus.noInternet);
        break;
    }
  }

  /// Actualiza el estado y notifica a los listeners
  void _updateStatus(ConnectionStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
      
      // Log para debugging
      final emoji = newStatus == ConnectionStatus.online
          ? '✅'
          : newStatus == ConnectionStatus.noInternet
              ? '⚠️'
              : '❌';
      debugPrint('$emoji Estado de conexión: $newStatus');
    }
  }

  /// Verifica manualmente si hay conexión antes de operaciones críticas
  /// 
  /// Útil para llamar antes de hacer peticiones importantes al backend
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      
      if (connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      return await _internetChecker.hasInternetAccess;
    } catch (e) {
      debugPrint('❌ Error verificando conexión: $e');
      return false;
    }
  }

  /// Libera los recursos del servicio
  void dispose() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    _statusController.close();
  }
}
