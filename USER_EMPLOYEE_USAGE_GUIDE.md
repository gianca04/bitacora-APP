# User & Employee Database Models - Usage Guide

Este documento proporciona una guía completa sobre cómo usar los modelos `User` y `Employee` implementados en la base de datos Isar.

## 📋 Tabla de Contenidos

1. [Estructura de las Tablas](#estructura-de-las-tablas)
2. [Modelos](#modelos)
3. [Repositorios](#repositorios)
4. [Servicios](#servicios)
5. [ViewModels](#viewmodels)
6. [Controllers](#controllers)
7. [Ejemplos de Uso](#ejemplos-de-uso)

## 🗂️ Estructura de las Tablas

### Tabla Users

La tabla `users` almacena información de usuarios del sistema:

```dart
- id: Id (auto-incremental)
- employeeId: int? (referencia a Employee)
- name: String?
- email: String? (indexado)
- emailVerifiedAt: DateTime?
- password: String? (debe ser hasheado)
- isActive: bool (default: true, indexado)
- rememberToken: String?
- createdAt: DateTime? (indexado)
- updatedAt: DateTime?
```

### Tabla Employees

La tabla `employees` almacena información de empleados:

```dart
- id: Id (auto-incremental)
- documentType: DocumentType (enum: dni, pasaporte, carnetExtranjeria)
- documentNumber: String (indexado)
- firstName: String
- lastName: String
- address: String?
- dateContract: DateTime?
- dateBirth: DateTime?
- sex: Sex? (enum: male, female, other)
- positionId: int? (indexado)
- active: bool (default: true, indexado)
- createdAt: DateTime? (indexado)
- updatedAt: DateTime?
```

## 📦 Modelos

### User Model

**Ubicación:** `lib/models/user.dart`

```dart
// Crear un nuevo usuario
final user = User(
  name: 'Juan Pérez',
  email: 'juan@example.com',
  password: 'hashed_password', // Debe ser hasheado
  employeeId: 1,
  isActive: true,
);

// Métodos útiles
user.isEmailVerified; // Verifica si el email está verificado
user.copyWith(name: 'Nuevo Nombre'); // Crea una copia con cambios
```

### Employee Model

**Ubicación:** `lib/models/employee.dart`

```dart
// Crear un nuevo empleado
final employee = Employee(
  documentType: DocumentType.dni,
  documentNumber: '12345678',
  firstName: 'María',
  lastName: 'García',
  address: 'Av. Principal 123',
  dateContract: DateTime(2024, 1, 15),
  dateBirth: DateTime(1990, 5, 20),
  sex: Sex.female,
  positionId: 1,
  active: true,
);

// Métodos útiles
employee.fullName; // Retorna "María García"
employee.age; // Calcula la edad si dateBirth está definida
employee.hasContract; // Verifica si tiene fecha de contrato
employee.copyWith(address: 'Nueva Dirección'); // Crea una copia con cambios
```

## 🗄️ Repositorios

Los repositorios proporcionan operaciones CRUD básicas.

### UserRepository

**Ubicación:** `lib/repositories/user_repository.dart`

```dart
// Obtener instancia a través de Riverpod
final userRepo = ref.read(userRepositoryProvider);

// Operaciones CRUD
await userRepo.create(user); // Crear
await userRepo.update(user); // Actualizar
await userRepo.delete(id); // Eliminar
await userRepo.getById(id); // Obtener por ID

// Consultas específicas
await userRepo.getByEmail('juan@example.com');
await userRepo.getByEmployeeId(1);
await userRepo.getActiveUsers();
await userRepo.getVerifiedUsers();
await userRepo.emailExists('juan@example.com');

// Operaciones de estado
await userRepo.activate(id);
await userRepo.deactivate(id);
await userRepo.verifyEmail(id);

// Streams reactivos
userRepo.watchAll(); // Stream de todos los usuarios
userRepo.watchUser(id); // Stream de un usuario específico
userRepo.watchActiveUsers(); // Stream de usuarios activos
```

### EmployeeRepository

**Ubicación:** `lib/repositories/employee_repository.dart`

```dart
// Obtener instancia a través de Riverpod
final employeeRepo = ref.read(employeeRepositoryProvider);

// Operaciones CRUD
await employeeRepo.create(employee); // Crear
await employeeRepo.update(employee); // Actualizar
await employeeRepo.delete(id); // Eliminar
await employeeRepo.getById(id); // Obtener por ID

// Consultas específicas
await employeeRepo.getByDocumentNumber('12345678');
await employeeRepo.getActiveEmployees();
await employeeRepo.getByPositionId(1);
await employeeRepo.getByDocumentType(DocumentType.dni);
await employeeRepo.getBySex(Sex.female);
await employeeRepo.searchByName('María');
await employeeRepo.getByContractYear(2024);

// Operaciones de estado
await employeeRepo.activate(id);
await employeeRepo.deactivate(id);

// Estadísticas
await employeeRepo.getActiveCount();
await employeeRepo.getCountByPosition(positionId);

// Streams reactivos
employeeRepo.watchAll(); // Stream de todos los empleados
employeeRepo.watchEmployee(id); // Stream de un empleado específico
employeeRepo.watchActiveEmployees(); // Stream de empleados activos
employeeRepo.watchByPosition(positionId); // Stream por posición
```

## 🔧 Servicios

Los servicios proporcionan lógica de negocio de nivel superior.

### UserService

**Ubicación:** `lib/services/user_service.dart`

```dart
final userService = UserService(userRepo);

// Autenticación
final user = await userService.authenticate('email@example.com', 'password');

// Registro
final userId = await userService.register(
  email: 'nuevo@example.com',
  password: 'secure_password',
  name: 'Nombre Usuario',
  employeeId: 1,
);

// Gestión de contraseñas
await userService.updatePassword(userId, 'new_password');

// Vinculación con empleados
await userService.linkEmployee(userId, employeeId);
await userService.unlinkEmployee(userId);

// Verificación de email
await userService.sendEmailVerification(userId);

// Estadísticas
final stats = await userService.getUserStats();
print('Total: ${stats.total}');
print('Activos: ${stats.active}');
print('Verificados: ${stats.verified}');
print('Porcentaje activos: ${stats.activePercentage}%');

// Operaciones en lote
await userService.bulkActivate([id1, id2, id3]);
await userService.bulkDeactivate([id4, id5]);
```

### EmployeeService

**Ubicación:** `lib/services/employee_service.dart`

```dart
final employeeService = EmployeeService(employeeRepo);

// Validación de documentos
final isValid = employeeService.validateDocumentNumber(
  DocumentType.dni,
  '12345678',
);

// Crear empleado con validación
final employeeId = await employeeService.createEmployee(
  documentType: DocumentType.dni,
  documentNumber: '12345678',
  firstName: 'Juan',
  lastName: 'Pérez',
  address: 'Dirección 123',
  dateContract: DateTime.now(),
  dateBirth: DateTime(1990, 1, 1),
  sex: Sex.male,
  positionId: 1,
);

// Actualizar con validación
await employeeService.updateEmployee(employee);

// Gestión de posiciones
await employeeService.assignPosition(employeeId, positionId);
await employeeService.removePosition(employeeId);

// Consultas avanzadas
final youngEmployees = await employeeService.getEmployeesByAgeRange(20, 30);
final recentHires = await employeeService.getRecentHires(30); // Últimos 30 días

final byContract = await employeeService.getEmployeesByContractStatus();
print('Con contrato: ${byContract.withContract.length}');
print('Sin contrato: ${byContract.withoutContract.length}');

// Estadísticas
final stats = await employeeService.getEmployeeStats();
print('Total: ${stats.total}');
print('Activos: ${stats.active}');
print('Hombres: ${stats.male}');
print('Mujeres: ${stats.female}');
print('Con contrato: ${stats.withContract}');

// Búsqueda avanzada
final results = await employeeService.advancedSearch(
  nameQuery: 'Juan',
  documentType: DocumentType.dni,
  sex: Sex.male,
  positionId: 1,
  active: true,
);

// Importación en lote
final ids = await employeeService.bulkImportEmployees([employee1, employee2]);
```

## 🎯 ViewModels

Los ViewModels gestionan el estado de la UI usando StateNotifier de Riverpod.

### UserViewModel

**Ubicación:** `lib/viewmodels/user_viewmodel.dart`

```dart
// En un Widget con ConsumerWidget
class UserListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userViewModelProvider);
    
    // Cargar usuarios al iniciar
    ref.read(userViewModelProvider.notifier).loadActiveUsers();
    
    return switch (userState.status) {
      UserStatus.loading => CircularProgressIndicator(),
      UserStatus.error => Text('Error: ${userState.errorMessage}'),
      UserStatus.loaded => ListView.builder(
        itemCount: userState.users.length,
        itemBuilder: (context, index) {
          final user = userState.users[index];
          return ListTile(
            title: Text(user.name ?? 'Sin nombre'),
            subtitle: Text(user.email ?? ''),
          );
        },
      ),
      _ => Text('No hay datos'),
    };
  }
}

// Operaciones desde el ViewModel
final notifier = ref.read(userViewModelProvider.notifier);

await notifier.loadAll();
await notifier.loadActiveUsers();
await notifier.loadByEmail('email@example.com');
await notifier.createUser(user);
await notifier.updateUser(user);
await notifier.deleteUser(id);
await notifier.activateUser(id);
await notifier.verifyEmail(id);
notifier.setCurrentUser(user);
notifier.logout();
```

### EmployeeViewModel

**Ubicación:** `lib/viewmodels/employee_viewmodel.dart`

```dart
// En un Widget con ConsumerWidget
class EmployeeListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeState = ref.watch(employeeViewModelProvider);
    
    // Cargar empleados al iniciar
    ref.read(employeeViewModelProvider.notifier).loadActiveEmployees();
    
    return switch (employeeState.status) {
      EmployeeStatus.loading => CircularProgressIndicator(),
      EmployeeStatus.error => Text('Error: ${employeeState.errorMessage}'),
      EmployeeStatus.loaded => ListView.builder(
        itemCount: employeeState.employees.length,
        itemBuilder: (context, index) {
          final employee = employeeState.employees[index];
          return ListTile(
            title: Text(employee.fullName),
            subtitle: Text(employee.documentNumber),
          );
        },
      ),
      _ => Text('No hay datos'),
    };
  }
}

// Operaciones desde el ViewModel
final notifier = ref.read(employeeViewModelProvider.notifier);

await notifier.loadAll();
await notifier.loadActiveEmployees();
await notifier.searchByName('Juan');
await notifier.loadByDocumentNumber('12345678');
await notifier.createEmployee(employee);
await notifier.updateEmployee(employee);
await notifier.deleteEmployee(id);
await notifier.activateEmployee(id);
```

## 🎮 Controllers

Los controllers actúan como fachadas opcionales entre la UI y los ViewModels.

### UserController

**Ubicación:** `lib/controllers/user_controller.dart`

```dart
// Obtener instancia
final userController = ref.read(userControllerProvider);

// Usar operaciones
final state = await userController.loadAll();
await userController.createUser(user);
await userController.updateUser(user);
await userController.deleteUser(id);
await userController.activateUser(id);
userController.setCurrentUser(user);
userController.logout();
```

### EmployeeController

**Ubicación:** `lib/controllers/employee_controller.dart`

```dart
// Obtener instancia
final employeeController = ref.read(employeeControllerProvider);

// Usar operaciones
final state = await employeeController.loadAll();
await employeeController.createEmployee(employee);
await employeeController.updateEmployee(employee);
await employeeController.deleteEmployee(id);
await employeeController.activateEmployee(id);
await employeeController.searchByName('Juan');
```

## 💡 Ejemplos de Uso

### Ejemplo 1: Crear y listar usuarios

```dart
class CreateUserExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final controller = ref.read(userControllerProvider);
            
            final newUser = User(
              name: 'Juan Pérez',
              email: 'juan@example.com',
              password: 'hashed_password',
              isActive: true,
            );
            
            final id = await controller.createUser(newUser);
            if (id != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Usuario creado: $id')),
              );
            }
          },
          child: Text('Crear Usuario'),
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final userState = ref.watch(userViewModelProvider);
              
              if (userState.status == UserStatus.loading) {
                return CircularProgressIndicator();
              }
              
              return ListView.builder(
                itemCount: userState.users.length,
                itemBuilder: (context, index) {
                  final user = userState.users[index];
                  return ListTile(
                    title: Text(user.name ?? 'Sin nombre'),
                    subtitle: Text(user.email ?? ''),
                    trailing: Switch(
                      value: user.isActive,
                      onChanged: (value) async {
                        final controller = ref.read(userControllerProvider);
                        if (value) {
                          await controller.activateUser(user.id);
                        } else {
                          await controller.deactivateUser(user.id);
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
```

### Ejemplo 2: Búsqueda de empleados

```dart
class EmployeeSearchExample extends ConsumerStatefulWidget {
  @override
  ConsumerState<EmployeeSearchExample> createState() => _EmployeeSearchExampleState();
}

class _EmployeeSearchExampleState extends ConsumerState<EmployeeSearchExample> {
  final _searchController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeViewModelProvider);
    
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Buscar empleado',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                ref
                    .read(employeeViewModelProvider.notifier)
                    .searchByName(_searchController.text);
              },
            ),
          ),
        ),
        Expanded(
          child: employeeState.status == EmployeeStatus.loading
              ? CircularProgressIndicator()
              : ListView.builder(
                  itemCount: employeeState.employees.length,
                  itemBuilder: (context, index) {
                    final employee = employeeState.employees[index];
                    return Card(
                      child: ListTile(
                        title: Text(employee.fullName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Doc: ${employee.documentNumber}'),
                            Text('Edad: ${employee.age ?? "N/A"} años'),
                            if (employee.positionId != null)
                              Text('Posición: ${employee.positionId}'),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(employee.active ? 'Activo' : 'Inactivo'),
                          backgroundColor:
                              employee.active ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
```

### Ejemplo 3: Estadísticas de empleados

```dart
class EmployeeStatsExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: _loadStats(ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        
        final stats = snapshot.data as EmployeeStats;
        
        return GridView.count(
          crossAxisCount: 2,
          children: [
            _StatCard('Total', '${stats.total}'),
            _StatCard('Activos', '${stats.active}'),
            _StatCard('Hombres', '${stats.male}'),
            _StatCard('Mujeres', '${stats.female}'),
            _StatCard('Con Contrato', '${stats.withContract}'),
            _StatCard('% Activos', '${stats.activePercentage.toStringAsFixed(1)}%'),
          ],
        );
      },
    );
  }
  
  Future<EmployeeStats> _loadStats(WidgetRef ref) async {
    final repo = ref.read(employeeRepositoryProvider);
    final service = EmployeeService(repo);
    return await service.getEmployeeStats();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  
  const _StatCard(this.title, this.value);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔐 Notas de Seguridad

### Hashing de Contraseñas

⚠️ **IMPORTANTE:** El campo `password` en el modelo `User` debe ser hasheado antes de almacenarse. Los ejemplos actuales usan texto plano solo para desarrollo.

Para producción, usa paquetes como:
- `crypto` para SHA-256
- `bcrypt` para hashing seguro
- `argon2` para máxima seguridad

```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}
```

## 📚 Referencias

- [Isar Database Documentation](https://isar.dev/)
- [Flutter Riverpod Documentation](https://riverpod.dev/)
- Archivo: `ARCHITECTURE.md` - Arquitectura general del proyecto
- Archivo: `TESTING_GUIDE.md` - Guía de testing

## ✅ Checklist de Implementación

- [x] Modelos User y Employee creados
- [x] Repositorios implementados con operaciones CRUD
- [x] Servicios con lógica de negocio
- [x] ViewModels con StateNotifier
- [x] Controllers como fachadas opcionales
- [x] Providers configurados en app_providers.dart
- [x] IsarService actualizado con nuevos schemas
- [x] Build runner ejecutado exitosamente
- [ ] Tests unitarios (pendiente)
- [ ] Vistas de UI (pendiente según requerimiento)
