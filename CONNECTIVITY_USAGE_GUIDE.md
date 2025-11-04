# Guía de Uso - Sistema de Conectividad

Este documento explica cómo usar el sistema de monitoreo de conectividad implementado en la app.

## 📦 Componentes

### 1. ConnectivityService
Servicio singleton que combina:
- **connectivity_plus**: Detecta cambios rápidos de red (WiFi ↔ móvil ↔ ninguno)
- **internet_connection_checker_plus**: Verifica acceso real a Internet

### 2. Estados de Conexión

```dart
enum ConnectionStatus {
  online,      // Conectado con acceso a Internet ✅
  noInternet,  // Conectado a red pero sin Internet ⚠️
  offline,     // Sin conexión de red ❌
}
```

### 3. Providers Disponibles

```dart
// Estado actual de conectividad (Stream)
connectionStatusProvider

// Booleano simple: ¿hay Internet?
hasInternetProvider

// Booleano: ¿mostrar banner de "sin conexión"?
shouldShowNoConnectionBannerProvider
```

## 🚀 Ejemplos de Uso

### Ejemplo 1: Verificar conexión antes de llamada al backend

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_call_helper.dart';
import '../repositories/work_report_repository.dart';

class WorkReportViewModel extends StateNotifier<AsyncValue<List<WorkReport>>> {
  WorkReportViewModel(this.ref) : super(const AsyncValue.loading());
  
  final Ref ref;

  Future<void> fetchReports() async {
    // Opción 1: Usando ApiCallHelper
    final result = await ApiCallHelper.execute<List<WorkReport>>(
      apiCall: () => WorkReportRepository().fetchAll(),
      onNoConnection: () {
        // Mostrar mensaje al usuario
        state = AsyncValue.error('Sin conexión a Internet', StackTrace.current);
      },
    );
    
    if (result != null) {
      state = AsyncValue.data(result);
    }
  }

  Future<void> syncReport(WorkReport report) async {
    // Opción 2: Con reintentos automáticos
    final result = await ApiCallHelper.executeWithRetry<bool>(
      apiCall: () => WorkReportRepository().sync(report),
      maxRetries: 3,
      retryDelay: Duration(seconds: 2),
      onNoConnection: () {
        print('No se pudo sincronizar después de 3 intentos');
      },
    );
    
    if (result == true) {
      print('✅ Reporte sincronizado exitosamente');
    }
  }
}
```

### Ejemplo 2: Mostrar UI diferente según estado de conexión

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';
import '../services/connectivity_service.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(connectionStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Pantalla')),
      body: connectionStatus.when(
        data: (status) {
          // Mostrar contenido según el estado
          switch (status) {
            case ConnectionStatus.online:
              return _buildOnlineContent();
            case ConnectionStatus.noInternet:
              return _buildNoInternetWarning();
            case ConnectionStatus.offline:
              return _buildOfflineContent();
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildErrorContent(),
      ),
    );
  }

  Widget _buildOnlineContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text('Conectado a Internet'),
        ],
      ),
    );
  }

  Widget _buildNoInternetWarning() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text('Conectado pero sin acceso a Internet'),
          Text('Algunas funciones pueden no estar disponibles'),
        ],
      ),
    );
  }

  Widget _buildOfflineContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Sin conexión'),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(child: Text('Error verificando conexión'));
  }
}
```

### Ejemplo 3: Deshabilitar botones sin conexión

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';

class SyncButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const SyncButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInternet = ref.watch(hasInternetProvider);

    return ElevatedButton.icon(
      onPressed: hasInternet ? onPressed : null,
      icon: Icon(Icons.sync),
      label: Text(hasInternet ? 'Sincronizar' : 'Sin conexión'),
      style: ElevatedButton.styleFrom(
        backgroundColor: hasInternet ? Colors.blue : Colors.grey,
      ),
    );
  }
}
```

### Ejemplo 4: Verificación manual antes de operación crítica

```dart
import '../services/connectivity_service.dart';

Future<void> uploadImportantData() async {
  // Verificar conexión manualmente antes de proceder
  final hasConnection = await ConnectivityService().hasInternetConnection();
  
  if (!hasConnection) {
    print('❌ No se puede subir datos: sin conexión');
    // Guardar en cola local para intentar después
    await saveToLocalQueue();
    return;
  }
  
  // Proceder con la subida
  try {
    await apiClient.upload(data);
    print('✅ Datos subidos exitosamente');
  } catch (e) {
    print('❌ Error subiendo datos: $e');
  }
}
```

### Ejemplo 5: Reaccionar a cambios de conexión en tiempo real

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';
import '../services/connectivity_service.dart';

class AutoSyncWidget extends ConsumerStatefulWidget {
  const AutoSyncWidget({super.key});

  @override
  ConsumerState<AutoSyncWidget> createState() => _AutoSyncWidgetState();
}

class _AutoSyncWidgetState extends ConsumerState<AutoSyncWidget> {
  @override
  Widget build(BuildContext context) {
    // Escuchar cambios de conexión
    ref.listen<AsyncValue<ConnectionStatus>>(
      connectionStatusProvider,
      (previous, next) {
        next.whenData((status) {
          if (status == ConnectionStatus.online) {
            // Conexión restaurada - sincronizar datos pendientes
            _syncPendingData();
            
            // Mostrar mensaje al usuario
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Conexión restaurada'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      },
    );

    return Container(
      // Tu widget aquí
    );
  }

  Future<void> _syncPendingData() async {
    print('🔄 Sincronizando datos pendientes...');
    // Implementar lógica de sincronización
  }
}
```

## 🎨 Componentes UI Disponibles

### NoConnectionBanner
Banner superior que se muestra automáticamente cuando no hay conexión:

```dart
// Ya está integrado en main.dart, no necesitas hacer nada más
// Se muestra automáticamente en toda la app
```

### NoConnectionScreen
Pantalla completa para mostrar cuando no hay conexión:

```dart
import '../widgets/no_connection_banner.dart';

// Usar en lugar del contenido normal
NoConnectionScreen(
  onRetry: () async {
    // Reintentar operación
    await checkConnection();
  },
)
```

## 🔧 Configuración Avanzada

### Personalizar intervalo de verificación

Edita `connectivity_service.dart` si necesitas cambiar la frecuencia de verificación:

```dart
// internet_connection_checker_plus verifica cada 10 segundos por defecto
// Para cambiar:
final _internetChecker = InternetConnection.createInstance(
  checkInterval: const Duration(seconds: 5), // Más frecuente
);
```

### Cambiar URLs de verificación

```dart
// Por defecto verifica contra Google, Cloudflare, etc.
// Para personalizar:
final _internetChecker = InternetConnection.createInstance(
  customCheckOptions: [
    InternetCheckOption(uri: Uri.parse('https://tuapi.com/health')),
  ],
);
```

## 📱 Permisos Necesarios

Ya están configurados automáticamente por los paquetes, pero verifica:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

**iOS** - No requiere configuración adicional.

## 🐛 Debug

El servicio imprime logs útiles:
- ✅ Conexión online
- ⚠️ Conectado sin Internet
- ❌ Sin conexión
- 🔄 Cambios detectados

Para ver los logs:
```bash
flutter run
```

## 💡 Mejores Prácticas

1. **Siempre verifica antes de llamadas críticas al backend**
2. **Guarda datos localmente si no hay conexión**
3. **Implementa cola de sincronización para cuando vuelva la conexión**
4. **Muestra feedback claro al usuario sobre el estado de conexión**
5. **No bloquees la UI mientras verificas conexión**

## 🎯 Estado Actual

El sistema está **completamente configurado** y funcionando:
- ✅ Monitoreo global activo desde el inicio de la app
- ✅ Banner automático en toda la app
- ✅ Providers disponibles para uso en cualquier widget
- ✅ Helper para verificaciones antes de llamadas API
