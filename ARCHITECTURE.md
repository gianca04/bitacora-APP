# Arquitectura del Proyecto

## 📋 Visión General

Este proyecto sigue las **mejores prácticas de Flutter y Riverpod** con una arquitectura en capas clara y mantenible.

## 🏗️ Estructura de Capas

```
UI Layer (Views)
       ↓
ViewModel Layer (StateNotifier)
       ↓
Repository Layer
       ↓
Service/Data Layer (Isar, APIs, etc.)
```

### 1. **Service Layer** (`lib/services/`)
- **Responsabilidad**: Acceso a datos externos (base de datos, APIs, almacenamiento local)
- **Ejemplo**: `IsarService` - Maneja la inicialización y acceso a la base de datos Isar
- **Patrón**: Singleton para servicios que deben tener una única instancia

### 2. **Repository Layer** (`lib/repositories/`)
- **Responsabilidad**: Abstrae el acceso a datos y lógica de negocio
- **Ejemplo**: `WorkReportRepository`, `PhotoRepository`, `AuthRepository`
- **Buenas Prácticas**:
  - Recibe servicios por inyección de dependencias
  - Retorna tipos de dominio (modelos)
  - Maneja errores y transforma datos

### 3. **ViewModel Layer** (`lib/viewmodels/`)
- **Responsabilidad**: Maneja el estado de la UI y coordina con repositories
- **Patrón**: `StateNotifier<T>` de Riverpod
- **Buenas Prácticas**:
  - Inmutable el estado (usar clases con constructores named)
  - Status enum para diferentes estados (initial, loading, loaded, error)
  - Métodos públicos para operaciones de la UI
  - No contiene lógica de negocio (eso va en repositories)

**Estructura de un ViewModel:**
```dart
enum MyStatus { initial, loading, loaded, error }

class MyState {
  final MyStatus status;
  final List<Model> items;
  final String? errorMessage;
  
  const MyState._({required this.status, required this.items, this.errorMessage});
  
  MyState.initial() : this._(status: MyStatus.initial, items: []);
  MyState.loading() : this._(status: MyStatus.loading, items: []);
  MyState.loaded(List<Model> items) : this._(status: MyStatus.loaded, items: items);
  MyState.error(String message) : this._(status: MyStatus.error, items: [], errorMessage: message);
}

class MyViewModel extends StateNotifier<MyState> {
  final MyRepository repository;
  
  MyViewModel({required this.repository}) : super(MyState.initial());
  
  Future<void> loadData() async {
    state = MyState.loading();
    try {
      final items = await repository.getAll();
      state = MyState.loaded(items);
    } catch (e) {
      state = MyState.error(e.toString());
    }
  }
}
```

### 4. **Provider Layer** (`lib/providers/`)
- **Responsabilidad**: Configurar la inyección de dependencias con Riverpod
- **Archivo Central**: `app_providers.dart` - Todos los providers en un solo lugar
- **Tipos de Providers**:
  - `Provider<T>` - Para servicios y repositories (inmutables)
  - `StateNotifierProvider<N, S>` - Para ViewModels (estado mutable)

### 5. **Controller Layer** (`lib/controllers/`) - **OPCIONAL**
- **Nota**: En Riverpod, los controllers son opcionales. Puedes trabajar directamente con ViewModels desde la UI.
- **Cuándo usar**: Solo si necesitas una capa adicional de abstracción para lógica compleja de coordinación
- **Alternativa recomendada**: Trabajar directamente con ViewModels usando `ref.read()` y `ref.watch()`

### 6. **View Layer** (`lib/views/`)
- **Responsabilidad**: UI y widgets
- **Tipos**:
  - `ConsumerWidget` - Para widgets sin estado interno (solo lee providers)
  - `ConsumerStatefulWidget` - Para widgets con estado interno + providers
- **Buenas Prácticas**:
  - Usa `ref.watch()` para observar cambios de estado
  - Usa `ref.read()` para ejecutar acciones (en callbacks)
  - Mantén los widgets pequeños y reutilizables

## 📦 Convenciones de Código

### Naming Conventions

#### Archivos
- **snake_case**: `work_report_viewmodel.dart`, `auth_repository.dart`
- **Sufijos**: 
  - `_service.dart` para servicios
  - `_repository.dart` para repositories
  - `_viewmodel.dart` para view models
  - `_controller.dart` para controllers (opcional)
  - `_page.dart` o `_view.dart` para vistas

#### Clases
- **PascalCase**: `WorkReportViewModel`, `AuthRepository`
- **State classes**: `<Feature>State` (ej: `AuthState`, `WorkReportState`)
- **ViewModels**: `<Feature>ViewModel` 
- **Repositories**: `<Feature>Repository`

#### Providers
- **camelCase** con sufijo `Provider`:
  - `authViewModelProvider`
  - `workReportRepositoryProvider`
  - `isarServiceProvider`

### Organización de Imports

```dart
// 1. Dart/Flutter core
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 2. Packages de terceros
import 'package:isar/isar.dart';
import 'package:go_router/go_router.dart';

// 3. Imports locales (relativos)
import '../models/my_model.dart';
import '../providers/app_providers.dart';
```

## 🔄 Flujo de Datos

### Lectura de Datos (UI → ViewModel → Repository)
```dart
// En la UI
final state = ref.watch(workReportViewModelProvider);

// Cuando el widget se construye, el ViewModel:
// 1. Lee del Repository
// 2. Transforma los datos
// 3. Actualiza el estado
// 4. La UI se reconstruye automáticamente
```

### Escritura de Datos (UI → ViewModel → Repository → Service)
```dart
// En la UI (callback de botón)
onPressed: () {
  ref.read(workReportViewModelProvider.notifier).createReport(report);
}

// El ViewModel:
// 1. Cambia estado a loading
// 2. Llama al Repository
// 3. El Repository llama al Service
// 4. Actualiza estado a loaded/error
```

## 🎯 Principios SOLID Aplicados

### Single Responsibility Principle (SRP)
- Cada capa tiene una única responsabilidad
- Services: Acceso a datos
- Repositories: Lógica de negocio
- ViewModels: Gestión de estado UI
- Views: Presentación

### Dependency Inversion Principle (DIP)
- Las capas superiores no dependen de implementaciones concretas
- Todo se inyecta via Riverpod providers
- Ejemplo: `WorkReportViewModel` recibe `WorkReportRepository` abstracto

### Open/Closed Principle (OCP)
- Los ViewModels son extensibles sin modificar código existente
- Nuevas funcionalidades = nuevos métodos

## 🚀 Mejores Prácticas de Riverpod

### 1. **Usa `ref.watch()` para observar**
```dart
// En build method - se reconstruye cuando cambia
final state = ref.watch(myViewModelProvider);
```

### 2. **Usa `ref.read()` para acciones**
```dart
// En callbacks - no se reconstruye
onPressed: () {
  ref.read(myViewModelProvider.notifier).doSomething();
}
```

### 3. **Usa `ref.listen()` para efectos secundarios**
```dart
// Para mostrar snackbars, navegar, etc.
ref.listen(authViewModelProvider, (previous, next) {
  if (next.status == AuthStatus.error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next.errorMessage ?? 'Error')),
    );
  }
});
```

### 4. **Centraliza los Providers**
- Todos los providers en `lib/providers/app_providers.dart`
- Facilita el mantenimiento y evita dependencias circulares

### 5. **Estado Inmutable**
- Usa constructores named para diferentes estados
- Usa `copyWith()` para actualizaciones parciales
- Nunca mutes directamente el estado

## 📱 Patrón de Estado para ViewModels

```dart
// ✅ CORRECTO - Estado inmutable con constructores named
class MyState {
  final Status status;
  final List<Item> items;
  final String? errorMessage;
  
  const MyState._({required this.status, required this.items, this.errorMessage});
  
  MyState.initial() : this._(status: Status.initial, items: []);
  MyState.loading() : this._(status: Status.loading, items: []);
  MyState.loaded(List<Item> items) : this._(status: Status.loaded, items: items);
  MyState.error(String msg) : this._(status: Status.error, items: [], errorMessage: msg);
  
  MyState copyWith({Status? status, List<Item>? items, String? errorMessage}) {
    return MyState._(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ❌ INCORRECTO - Estado mutable
class MyState {
  Status status = Status.initial;
  List<Item> items = [];
  String? errorMessage;
}
```

## 🗄️ Base de Datos con Isar

### Inicialización
```dart
// En main.dart ANTES de runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService().initialize();
  runApp(const ProviderScope(child: MyApp()));
}
```

### Modelos
```dart
@collection
class MyModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late DateTime createdAt;
  
  late String name;
}
```

### Repositories con Isar
```dart
class MyRepository {
  final IsarService _isarService;
  
  MyRepository(this._isarService);
  
  Future<List<MyModel>> getAll() async {
    final isar = _isarService.instance;
    return await isar.myModels.where().findAll();
  }
  
  Future<Id> create(MyModel model) async {
    final isar = _isarService.instance;
    return await isar.writeTxn(() async {
      return await isar.myModels.put(model);
    });
  }
}
```

## 🧪 Testing (Próximos Pasos)

La arquitectura está diseñada para ser fácilmente testeable:

1. **Unit Tests para Repositories**: Mock services
2. **Unit Tests para ViewModels**: Mock repositories  
3. **Widget Tests para Views**: Usa `ProviderScope` con overrides
4. **Integration Tests**: Prueba el flujo completo

## 📚 Recursos Adicionales

- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Isar Database](https://isar.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
