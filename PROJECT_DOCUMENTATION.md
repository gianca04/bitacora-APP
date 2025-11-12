# Bitácora Mobile App - Documentación Técnica Completa

[![Flutter](https://img.shields.io/badge/Flutter-3.9+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Private-red.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-green.svg)](pubspec.yaml)

## 📋 Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Stack Tecnológico](#-stack-tecnológico)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Instalación y Configuración](#-instalación-y-configuración)
- [Características Principales](#-características-principales)
- [Patrones de Diseño](#-patrones-de-diseño)
- [Base de Datos](#-base-de-datos)
- [API Reference](#-api-reference)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Contribución](#-contribución)
- [Mantenimiento](#-mantenimiento)

## 🏗️ Descripción General

**Bitácora** es una aplicación móvil multiplataforma desarrollada en Flutter que permite la gestión integral de reportes de trabajo, empleados, usuarios y documentación fotográfica. La aplicación está diseñada con una arquitectura limpia (Clean Architecture) y patrones modernos de desarrollo para garantizar escalabilidad, mantenibilidad y testabilidad.

### Propósito

La aplicación facilita la creación, gestión y seguimiento de reportes de trabajo en tiempo real, incluyendo:

- Creación y edición de reportes de trabajo detallados
- Gestión completa de usuarios y empleados
- Captura y almacenamiento de evidencia fotográfica (antes/después)
- Firmas digitales para supervisores y gerentes
- Funcionamiento offline-first con sincronización automática
- Sistema de autenticación robusto

### Objetivos

- **Productividad**: Reducir el tiempo de creación de reportes
- **Precisión**: Minimizar errores mediante validaciones automáticas
- **Trazabilidad**: Mantener un historial completo de actividades
- **Accesibilidad**: Interfaz intuitiva para usuarios de diferentes niveles técnicos

## 🏛️ Arquitectura del Sistema

### Patrón Arquitectónico

La aplicación implementa **Clean Architecture** combinada con **MVVM (Model-View-ViewModel)** utilizando Riverpod como sistema de gestión de estado.

```
┌─────────────────────────────────────────────────────┐
│                Presentation Layer                    │
│  Views │ Widgets │ Navigation │ State Management     │
└─────────────────────┬──────────────────────────────┘
                      │ ref.watch() / ref.read()
┌─────────────────────▼─────────────────────────────────┐
│               Business Logic Layer                    │
│    ViewModels │ Controllers │ Providers               │
└─────────────────────┬─────────────────────────────────┘
                      │ Dependency Injection
┌─────────────────────▼─────────────────────────────────┐
│                 Domain Layer                          │
│      Repositories │ Models │ Business Rules           │
└─────────────────────┬─────────────────────────────────┘
                      │ Data Abstraction
┌─────────────────────▼─────────────────────────────────┐
│              Data & Service Layer                     │
│   Isar DB │ APIs │ Storage │ Configuration            │
└───────────────────────────────────────────────────────┘
```

### Principios SOLID Aplicados

- **SRP**: Cada capa tiene una responsabilidad específica
- **OCP**: Extensible sin modificar código existente
- **LSP**: Las abstracciones son intercambiables
- **ISP**: Interfaces segregadas por funcionalidad
- **DIP**: Las dependencias apuntan hacia abstracciones

## 🔧 Stack Tecnológico

### Framework y Lenguajes

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Flutter** | 3.9+ | Framework de UI multiplataforma |
| **Dart** | 3.9+ | Lenguaje de programación |

### Librerías Principales

#### Estado y Navegación
- **flutter_riverpod** `^2.3.6` - Gestión de estado reactiva
- **go_router** `^14.6.2` - Navegación declarativa con guards

#### Base de Datos y Persistencia
- **isar** `^3.1.0+1` - Base de datos NoSQL local
- **isar_flutter_libs** `^3.1.0+1` - Librerías nativas para Isar
- **flutter_secure_storage** `^9.0.0` - Almacenamiento seguro
- **path_provider** `^2.1.0` - Rutas del sistema

#### Networking y APIs
- **dio** `^5.9.0` - Cliente HTTP avanzado
- **connectivity_plus** `^6.1.2` - Monitoreo de conectividad
- **internet_connection_checker_plus** `^2.5.2` - Verificación de conexión

#### UI y Media
- **flutter_svg** `^2.1.1` - Soporte para SVG
- **heroicons** `^0.11.0` - Biblioteca de iconos
- **image_picker** `^1.0.4` - Captura de imágenes
- **signature** `^5.4.0` - Firmas digitales
- **flutter_quill** `^11.0.0` - Editor de texto enriquecido
- **cupertino_icons** `^1.0.8` - Iconos iOS

#### Desarrollo
- **build_runner** `^2.4.0` - Generación de código
- **isar_generator** `^3.1.0+1` - Generador de esquemas Isar
- **flutter_lints** `^5.0.0` - Análisis estático de código

### Herramientas de Desarrollo

- **VS Code** - IDE principal
- **Android Studio** - Emulación y debugging
- **FlutterFire CLI** - Configuración de Firebase (futuro)
- **Git** - Control de versiones

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── config/                     # Configuraciones globales
│   └── dio_config.dart         # Configuración HTTP cliente
├── controllers/                # Capa de fachada opcional (MVVM)
│   ├── auth_controller.dart
│   ├── employee_controller.dart
│   ├── photo_controller.dart
│   ├── user_controller.dart
│   └── work_report_controller.dart
├── models/                     # Entidades del dominio
│   ├── auth_employee.dart      # Autenticación empleado
│   ├── auth_user.dart          # Autenticación usuario
│   ├── connectivity_preferences.dart
│   ├── employee.dart           # Modelo principal empleado
│   ├── login_response.dart     # Respuesta de login
│   ├── menu_item_model.dart    # Elementos de menú
│   ├── photo.dart              # Modelo de fotografías
│   ├── token_response.dart     # Respuesta de tokens
│   ├── user.dart               # Modelo principal usuario
│   └── work_report.dart        # Modelo principal reporte
├── providers/                  # Inyección de dependencias (Riverpod)
│   └── app_providers.dart      # Providers centralizados
├── repositories/               # Capa de acceso a datos
│   ├── auth_repository.dart    # Autenticación
│   ├── employee_repository.dart # Gestión empleados
│   ├── menu_repository.dart    # Gestión menú
│   ├── photo_repository.dart   # Gestión fotografías
│   ├── user_repository.dart    # Gestión usuarios
│   └── work_report_repository.dart # Gestión reportes
├── routes/                     # Configuración de navegación
│   └── app_router.dart         # Router principal con guards
├── services/                   # Servicios de infraestructura
│   ├── api_call_helper.dart    # Helper para APIs
│   ├── auth_api_service.dart   # API de autenticación
│   ├── connectivity_preferences_service.dart
│   ├── connectivity_service.dart # Monitoreo conexión
│   ├── employee_service.dart   # Lógica negocio empleados
│   ├── isar_service.dart       # Servicio base de datos
│   ├── photo_storage_service.dart # Almacenamiento fotos
│   ├── storage_service.dart    # Almacenamiento general
│   ├── token_storage_service.dart # Gestión tokens
│   └── user_service.dart       # Lógica negocio usuarios
├── viewmodels/                 # Gestión de estado (MVVM)
│   ├── auth_viewmodel.dart     # Estado autenticación
│   ├── employee_viewmodel.dart # Estado empleados
│   ├── menu_viewmodel.dart     # Estado menú
│   ├── photo_viewmodel.dart    # Estado fotografías
│   ├── user_viewmodel.dart     # Estado usuarios
│   └── work_report_viewmodel.dart # Estado reportes
├── views/                      # Interfaz de usuario
│   ├── about_page.dart         # Página acerca de
│   ├── app_shell.dart          # Shell principal
│   ├── contact_page.dart       # Página contacto
│   ├── home_page.dart          # Página inicio
│   ├── notification_demo_page.dart
│   ├── profile_page.dart       # Perfil usuario
│   ├── responsive_navbar_page.dart
│   ├── settings_page.dart      # Configuraciones
│   ├── sign_in_page.dart       # Página login
│   ├── work_report_detail_page.dart # Detalle reporte
│   ├── work_report_form_page.dart # Formulario reporte
│   └── work_report_list_page.dart # Lista reportes
└── widgets/                    # Componentes reutilizables
    ├── before_after_photo_card.dart
    ├── no_connection_banner.dart
    ├── photo_list_widget.dart
    ├── signature_pad_widget.dart
    └── work_report_form.dart
```

### Assets

```
assets/
├── images/
│   ├── png/
│   │   └── auth_background.png  # Fondo autenticación
│   └── svg/
│       └── logo.svg             # Logo de la aplicación
```

## 🚀 Instalación y Configuración

### Prerequisitos

1. **Flutter SDK** (3.9 o superior)
2. **Dart SDK** (3.9 o superior)
3. **Android Studio** o **VS Code** con extensiones Flutter
4. **Git** para control de versiones

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/gianca04/bitacora-APP.git
cd bitacora-APP

# Instalar dependencias
flutter pub get

# Generar código Isar
dart run build_runner build

# Verificar configuración
flutter doctor

# Ejecutar en modo desarrollo
flutter run
```

### Configuración de Base de Datos

La aplicación utiliza Isar como base de datos local NoSQL. La inicialización es automática:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización automática de Isar
  await IsarService().initialize();
  
  // Inicialización del servicio de conectividad
  await ConnectivityService().initialize();
  
  runApp(const ProviderScope(child: MyApp()));
}
```

### Variables de Entorno

Crear archivo `.env` en la raíz del proyecto (no incluido en Git):

```env
# API Configuration
API_BASE_URL=https://api.bitacora.com
API_TIMEOUT=30000

# Storage
MAX_PHOTO_SIZE=5242880  # 5MB
PHOTOS_DIRECTORY=bitacora_photos

# Features
ENABLE_OFFLINE_MODE=true
ENABLE_DEBUG_LOGGING=true
```

## ⚡ Características Principales

### 1. Gestión de Reportes de Trabajo

#### Funcionalidades Core
- **Creación de reportes** con formularios detallados
- **Campos dinámicos** usando Flutter Quill para texto enriquecido
- **Validación en tiempo real** de datos obligatorios
- **Guardado automático** como borrador
- **Modo offline** completo con sincronización posterior

#### Campos del Reporte
- Información básica (nombre, descripción, fechas)
- Empleado responsable y proyecto asociado
- Horarios de trabajo (inicio/fin)
- Herramientas utilizadas
- Personal involucrado
- Materiales empleados
- Sugerencias y observaciones
- Firmas digitales (supervisor/gerente)

### 2. Sistema de Fotografías

#### Captura y Gestión
- **Fotos antes/después** del trabajo realizado
- **Compresión automática** para optimizar almacenamiento
- **Descripciones individuales** para cada fotografía
- **Almacenamiento permanente** en dispositivo
- **Sincronización** con registros de base de datos

#### Características Técnicas
```dart
class Photo {
  Id id = Isar.autoIncrement;
  int workReportId;
  String? beforeWorkPhotoPath;
  String? photoPath;
  String? beforeWorkDescripcion;
  String? descripcion;
  bool get hasValidPhotos => 
    (beforeWorkPhotoPath?.isNotEmpty ?? false) || 
    (photoPath?.isNotEmpty ?? false);
}
```

### 3. Gestión de Usuarios y Empleados

#### Modelo de Usuario
```dart
class User {
  Id id = Isar.autoIncrement;
  @Index() late int? employeeId;
  @Index() late String email;
  late String passwordHash;
  @Index() late bool isActive;
  late bool isEmailVerified;
  late DateTime createdAt;
  late DateTime updatedAt;
}
```

#### Modelo de Empleado
```dart
class Employee {
  Id id = Isar.autoIncrement;
  @Enumerated(EnumType.name) late DocumentType documentType;
  @Index() late String documentNumber;
  late String firstName;
  late String lastName;
  late String address;
  late DateTime dateContract;
  late DateTime dateBirth;
  @Enumerated(EnumType.name) late Sex sex;
  int? positionId;
  @Index() late bool active;
  
  // Computed properties
  String get fullName => '$firstName $lastName';
  int get age => DateTime.now().difference(dateBirth).inDays ~/ 365;
}
```

### 4. Autenticación y Seguridad

#### Características de Seguridad
- **JWT Tokens** para autenticación stateless
- **Almacenamiento seguro** de credenciales
- **Guards de navegación** basados en estado de autenticación
- **Renovación automática** de tokens
- **Logout automático** en caso de token expirado

#### Estados de Autenticación
```dart
enum AuthStatus { initial, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
}
```

### 5. Conectividad y Modo Offline

#### Características
- **Monitoreo en tiempo real** de conectividad
- **Banner de estado** global de conexión
- **Cola de sincronización** para acciones offline
- **Resolución de conflictos** automática
- **Respaldo local** completo de datos

## 🎯 Patrones de Diseño

### 1. Repository Pattern

Abstrae el acceso a datos y centraliza la lógica de negocio:

```dart
abstract class WorkReportRepository {
  Future<List<WorkReport>> getAll();
  Future<WorkReport?> getById(Id id);
  Future<Id> create(WorkReport report);
  Future<bool> update(WorkReport report);
  Future<bool> delete(Id id);
  Stream<List<WorkReport>> watchAll();
}
```

### 2. Service Layer Pattern

Encapsula lógica de negocio compleja:

```dart
class UserService {
  final UserRepository _repository;
  
  Future<AuthUser?> authenticate(String email, String password) async {
    // Validación, hash de contraseña, lógica de autenticación
  }
  
  Future<UserStats> getUserStats() async {
    // Cálculos estadísticos complejos
  }
}
```

### 3. State Management (MVVM)

ViewModels reactivos con StateNotifier:

```dart
class WorkReportViewModel extends StateNotifier<WorkReportState> {
  final WorkReportRepository _repository;
  
  WorkReportViewModel({required WorkReportRepository repository})
      : _repository = repository,
        super(WorkReportState.initial());
  
  Future<void> loadReports() async {
    state = WorkReportState.loading();
    try {
      final reports = await _repository.getAll();
      state = WorkReportState.loaded(reports);
    } catch (e) {
      state = WorkReportState.error(e.toString());
    }
  }
}
```

### 4. Dependency Injection

Centralización con Riverpod:

```dart
// Providers hierarchy
final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

final workReportRepositoryProvider = Provider<WorkReportRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return WorkReportRepository(isarService);
});

final workReportViewModelProvider = 
    StateNotifierProvider<WorkReportViewModel, WorkReportState>((ref) {
  final repository = ref.watch(workReportRepositoryProvider);
  return WorkReportViewModel(repository: repository);
});
```

### 5. Factory Pattern

Constructores nombrados para estados:

```dart
class WorkReportState {
  final WorkReportStatus status;
  final List<WorkReport> reports;
  final String? errorMessage;
  
  const WorkReportState._({
    required this.status, 
    required this.reports, 
    this.errorMessage
  });
  
  WorkReportState.initial() : this._(status: WorkReportStatus.initial, reports: []);
  WorkReportState.loading() : this._(status: WorkReportStatus.loading, reports: []);
  WorkReportState.loaded(List<WorkReport> reports) : 
    this._(status: WorkReportStatus.loaded, reports: reports);
  WorkReportState.error(String message) : 
    this._(status: WorkReportStatus.error, reports: [], errorMessage: message);
}
```

## 🗄️ Base de Datos

### Tecnología: Isar NoSQL

**Isar** es una base de datos NoSQL de alto rendimiento diseñada específicamente para Flutter:

#### Características
- **NoSQL Document Database** - Esquemas flexibles
- **Offline-first** - Funciona completamente sin internet
- **ACID Transactions** - Integridad de datos garantizada
- **Auto-generated schemas** - Tipos seguros en tiempo de compilación
- **Multi-isolate support** - Concurrencia real
- **Encryption ready** - Soporte para cifrado

### Esquema de Base de Datos

#### Colecciones Principales

```dart
// Configuración Isar
@collection
class WorkReport {
  Id id = Isar.autoIncrement;
  @Index() late String name;
  late String description;
  @Index() late int employeeId;
  @Index() late int projectId;
  @Index() late DateTime createdAt;
  // ... más campos
}

@collection 
class Photo {
  Id id = Isar.autoIncrement;
  @Index() late int workReportId;
  String? beforeWorkPhotoPath;
  String? photoPath;
  @Index() late DateTime createdAt;
}

@collection
class User {
  Id id = Isar.autoIncrement;
  @Index() late String email;
  @Index() late bool isActive;
  @Index() late DateTime createdAt;
}

@collection
class Employee {
  Id id = Isar.autoIncrement;
  @Index() late String documentNumber;
  @Index() late bool active;
  @Enumerated(EnumType.name) late DocumentType documentType;
}
```

#### Índices Optimizados

Los índices están estratégicamente ubicados en:
- **Campos de búsqueda frecuente** (email, documentNumber)
- **Campos de filtrado** (isActive, active, employeeId)
- **Campos de ordenamiento** (createdAt, updatedAt)
- **Claves foráneas** (workReportId, employeeId)

### Operaciones de Base de Datos

#### Transacciones ACID
```dart
Future<Id> createWorkReportWithPhotos(WorkReport report, List<Photo> photos) async {
  final isar = _isarService.instance;
  
  return await isar.writeTxn(() async {
    // 1. Crear reporte
    final reportId = await isar.workReports.put(report);
    
    // 2. Asociar fotos al reporte
    for (final photo in photos) {
      photo.workReportId = reportId;
      await isar.photos.put(photo);
    }
    
    return reportId;
  });
}
```

#### Consultas Reactivas
```dart
Stream<List<WorkReport>> watchActiveReports() {
  return _isarService.instance.workReports
    .filter()
    .createdAtGreaterThan(DateTime.now().subtract(Duration(days: 30)))
    .sortByCreatedAtDesc()
    .watch(fireImmediately: true);
}
```

## 📡 API Reference

### Endpoints Principales

#### Autenticación
```http
POST /auth/login
Content-Type: application/json

{
  "email": "usuario@ejemplo.com",
  "password": "password123"
}

Response:
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_here",
    "user": {
      "id": 1,
      "email": "usuario@ejemplo.com",
      "isActive": true
    }
  }
}
```

#### Gestión de Reportes
```http
GET /work-reports
Authorization: Bearer {token}

Response:
{
  "data": [
    {
      "id": 1,
      "name": "Reporte Ejemplo",
      "description": "Descripción del trabajo",
      "employeeId": 123,
      "projectId": 456,
      "createdAt": "2024-11-12T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

#### Upload de Fotografías
```http
POST /photos/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data

Form Data:
- file: [archivo_imagen]
- workReportId: 123
- description: "Foto antes del trabajo"

Response:
{
  "success": true,
  "data": {
    "id": 789,
    "url": "https://storage.ejemplo.com/photos/789.jpg",
    "workReportId": 123
  }
}
```

### Configuración HTTP Cliente

```dart
// dio_config.dart
class DioConfig {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: Environment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Interceptores
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(LoggingInterceptor());
    
    return dio;
  }
}
```

## 🧪 Testing

### Estrategia de Testing

La aplicación está diseñada para ser completamente testeable siguiendo la pirámide de testing:

```
    /\
   /  \     E2E Tests (10%)
  /____\    Integration Tests (20%)
 /______\   Unit Tests (70%)
```

### Unit Tests

#### Testing de Repositories
```dart
// test/repositories/work_report_repository_test.dart
void main() {
  group('WorkReportRepository', () {
    late WorkReportRepository repository;
    late MockIsarService mockIsarService;
    
    setUp(() {
      mockIsarService = MockIsarService();
      repository = WorkReportRepository(mockIsarService);
    });
    
    test('should create work report successfully', () async {
      // Given
      final report = WorkReport(name: 'Test Report');
      when(mockIsarService.instance.workReports.put(report))
          .thenAnswer((_) async => 1);
      
      // When
      final id = await repository.create(report);
      
      // Then
      expect(id, equals(1));
      verify(mockIsarService.instance.workReports.put(report)).called(1);
    });
  });
}
```

#### Testing de ViewModels
```dart
// test/viewmodels/work_report_viewmodel_test.dart
void main() {
  group('WorkReportViewModel', () {
    late WorkReportViewModel viewModel;
    late MockWorkReportRepository mockRepository;
    
    setUp(() {
      mockRepository = MockWorkReportRepository();
      viewModel = WorkReportViewModel(repository: mockRepository);
    });
    
    test('should load reports successfully', () async {
      // Given
      final reports = [WorkReport(name: 'Test')];
      when(mockRepository.getAll()).thenAnswer((_) async => reports);
      
      // When
      await viewModel.loadReports();
      
      // Then
      expect(viewModel.state.status, equals(WorkReportStatus.loaded));
      expect(viewModel.state.reports, equals(reports));
    });
  });
}
```

### Widget Tests

```dart
// test/widgets/work_report_form_test.dart
void main() {
  testWidgets('WorkReportForm should validate required fields', (tester) async {
    // Given
    var submitted = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkReportForm(
            onSubmit: (report, photos, changed) => submitted = true,
          ),
        ),
      ),
    );
    
    // When
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    
    // Then
    expect(find.text('Este campo es obligatorio'), findsAtLeast(1));
    expect(submitted, isFalse);
  });
}
```

### Integration Tests

```dart
// integration_test/app_test.dart
void main() {
  group('App Integration Tests', () {
    testWidgets('complete work report flow', (tester) async {
      // Setup app
      app.main();
      await tester.pumpAndSettle();
      
      // Login
      await tester.enterText(find.byKey(Key('email_field')), 'test@test.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password');
      await tester.tap(find.text('Iniciar Sesión'));
      await tester.pumpAndSettle();
      
      // Navigate to work reports
      await tester.tap(find.text('Reportes'));
      await tester.pumpAndSettle();
      
      // Create new report
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Fill form
      await tester.enterText(find.byKey(Key('name_field')), 'Test Report');
      await tester.enterText(find.byKey(Key('description_field')), 'Test Description');
      
      // Submit
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      
      // Verify
      expect(find.text('Test Report'), findsOneWidget);
    });
  });
}
```

### Configuración de Testing

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  integration_test:
    sdk: flutter
```

### Comandos de Testing

```bash
# Unit tests
flutter test

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Integration tests
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

# Widget tests específicos
flutter test test/widgets/

# Tests con watch mode
flutter test --reporter expanded --watch
```

## 🚀 Deployment

### Build Commands

#### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Release App Bundle (Google Play)
flutter build appbundle --release

# Con ofuscación
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

#### iOS
```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release

# Con ofuscación
flutter build ios --release --obfuscate --split-debug-info=./debug-info
```

#### Web
```bash
# Release web
flutter build web --release

# Con PWA support
flutter build web --pwa-strategy=offline-first
```

### Pipeline CI/CD

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.0'
    
    - run: flutter pub get
    - run: flutter test
    - run: flutter analyze
    
  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.0'
    
    - run: flutter pub get
    - run: flutter build apk --release
    
    - uses: actions/upload-artifact@v3
      with:
        name: android-release
        path: build/app/outputs/flutter-apk/app-release.apk
```

### Variables de Entorno por Ambiente

```dart
// lib/config/environment.dart
class Environment {
  static const String _environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isProduction => _environment == 'production';
  
  static String get apiBaseUrl {
    switch (_environment) {
      case 'production':
        return 'https://api.bitacora.com';
      case 'staging':
        return 'https://staging-api.bitacora.com';
      default:
        return 'http://localhost:3000';
    }
  }
}
```

### Build Flavors

```bash
# Comandos con flavors
flutter run --flavor development --dart-define=ENVIRONMENT=development
flutter build apk --flavor production --dart-define=ENVIRONMENT=production
```

## 🤝 Contribución

### Workflow de Desarrollo

1. **Fork** del repositorio
2. Crear **feature branch**: `git checkout -b feature/nueva-funcionalidad`
3. **Commit** cambios: `git commit -m 'feat: agregar nueva funcionalidad'`
4. **Push** a branch: `git push origin feature/nueva-funcionalidad`
5. Crear **Pull Request**

### Convenciones de Código

#### Naming Conventions

```dart
// Clases - PascalCase
class WorkReportViewModel {}

// Variables y métodos - camelCase
void loadWorkReports() {}
String employeeFullName = '';

// Constantes - UPPER_SNAKE_CASE
static const int MAX_PHOTO_SIZE = 5242880;

// Archivos - snake_case
work_report_repository.dart
photo_storage_service.dart
```

#### Estructura de Commits

Seguimos [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Tipos válidos:
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Documentación
- `style`: Formateo, puntos y comas faltantes
- `refactor`: Refactoring de código
- `test`: Tests
- `chore`: Mantenimiento

Ejemplos:
```
feat(auth): agregar autenticación con JWT
fix(photos): corregir compresión de imágenes
docs(readme): actualizar guía de instalación
refactor(repositories): simplificar queries Isar
```

### Code Review Guidelines

#### Checklist para PR

- [ ] **Funcionalidad** - ¿La función cumple los requerimientos?
- [ ] **Tests** - ¿Están incluidos los tests apropiados?
- [ ] **Documentación** - ¿Está documentado el código complejo?
- [ ] **Performance** - ¿No hay problemas de rendimiento?
- [ ] **Seguridad** - ¿No hay vulnerabilidades introducidas?
- [ ] **UI/UX** - ¿La interfaz es consistente?
- [ ] **Accesibilidad** - ¿Es accesible para usuarios con discapacidades?

#### Criterios de Aprobación

- ✅ Al menos 2 revisiones aprobadas
- ✅ Todos los tests pasan
- ✅ Coverage mínimo 80%
- ✅ No hay conflictos de merge
- ✅ Documentación actualizada

## 🔧 Mantenimiento

### Monitoreo y Logging

#### Configuración de Logs
```dart
// lib/utils/logger.dart
class AppLogger {
  static final Logger _logger = Logger('BitacoraApp');
  
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
    // También enviar a servicio de monitoreo externo
  }
}
```

#### Crash Reporting
```dart
// Integración con Firebase Crashlytics (futuro)
void main() async {
  await Firebase.initializeApp();
  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(MyApp());
}
```

### Performance Monitoring

#### Métricas Clave
- **App startup time** < 3 segundos
- **Database query time** < 100ms promedio
- **Photo compression time** < 2 segundos
- **Memory usage** < 100MB baseline
- **Battery usage** optimizado para trabajos largos

#### Tools de Profiling
```bash
# Flutter performance tools
flutter run --profile
flutter run --trace-startup

# Memory profiling
flutter run --profile --enable-software-rendering
```

### Backup y Recuperación

#### Estrategia de Backup
```dart
// lib/services/backup_service.dart
class BackupService {
  static Future<void> createBackup() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupData = {
      'work_reports': await _exportWorkReports(),
      'photos': await _exportPhotos(),
      'users': await _exportUsers(),
      'metadata': {
        'version': '1.0.0',
        'timestamp': timestamp,
      }
    };
    
    await _saveToSecureStorage('backup_$timestamp', jsonEncode(backupData));
  }
}
```

### Actualizaciones y Versionado

#### Semantic Versioning
- **MAJOR**: Cambios incompatibles de API
- **MINOR**: Nuevas funcionalidades compatibles
- **PATCH**: Correcciones de bugs

#### Migration Strategy
```dart
// lib/services/migration_service.dart
class MigrationService {
  static Future<void> migrateDatabase(int fromVersion, int toVersion) async {
    for (int version = fromVersion + 1; version <= toVersion; version++) {
      await _runMigration(version);
    }
  }
  
  static Future<void> _runMigration(int version) async {
    switch (version) {
      case 2:
        await _addEmployeeTable();
        break;
      case 3:
        await _addPhotoCompressionField();
        break;
    }
  }
}
```

### Security Updates

#### Dependencias de Seguridad
```bash
# Auditoría de seguridad
flutter pub deps --style=compact
flutter pub audit

# Actualización de dependencias
flutter pub upgrade --major-versions
```

#### Checklist de Seguridad
- [ ] **Datos sensibles** - No hardcoded en el código
- [ ] **API Keys** - Almacenadas en variables de entorno
- [ ] **Storage** - Datos sensibles en almacenamiento seguro
- [ ] **Network** - Todas las comunicaciones HTTPS
- [ ] **Authentication** - Tokens con expiración apropiada
- [ ] **Input Validation** - Validación en frontend y backend

---

## 📞 Soporte y Contacto

### Equipo de Desarrollo
- **Lead Developer**: [Tu Nombre]
- **Email**: desarrollo@bitacora.com
- **Documentation**: [Este archivo]

### Enlaces Útiles
- [Repository](https://github.com/gianca04/bitacora-APP)
- [Issue Tracker](https://github.com/gianca04/bitacora-APP/issues)
- [Wiki](https://github.com/gianca04/bitacora-APP/wiki)
- [Releases](https://github.com/gianca04/bitacora-APP/releases)

### Licencia

Este proyecto es propietario y confidencial. Todos los derechos reservados.

---

**Última actualización**: Noviembre 12, 2025  
**Versión de la documentación**: 1.0.0  
**Versión de la aplicación**: 1.0.0+1