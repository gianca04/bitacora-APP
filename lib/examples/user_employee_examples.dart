/// Example usage of User and Employee models
/// This file demonstrates how to use the CRUD operations
/// 
/// This is for documentation purposes and should not be executed directly.
/// Copy the relevant code snippets into your actual implementation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/user.dart';
import '../models/employee.dart';
import '../services/user_service.dart';
import '../services/employee_service.dart';
import '../providers/app_providers.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/employee_viewmodel.dart';

// ============================================================================
// EXAMPLE 1: Create and manage employees
// ============================================================================

Future<void> employeeExample(WidgetRef ref) async {
  // Get the employee controller
  final employeeController = ref.read(employeeControllerProvider);

  // 1. Create a new employee
  final newEmployee = Employee(
    documentType: DocumentType.dni,
    documentNumber: '12345678',
    firstName: 'Juan',
    lastName: 'Pérez',
    address: 'Av. Principal 123, Lima',
    dateContract: DateTime(2024, 1, 15),
    dateBirth: DateTime(1990, 5, 20),
    sex: Sex.male,
    positionId: 'POS001',
    active: true,
  );

  final employeeId = await employeeController.createEmployee(newEmployee);
  print('Employee created with ID: $employeeId');

  // 2. Search employees by name
  await employeeController.searchByName('Juan');
  final searchState = employeeController.state;
  print('Found ${searchState.employees.length} employees');

  // 3. Load all active employees
  await employeeController.loadActiveEmployees();
  final activeState = employeeController.state;
  print('Active employees: ${activeState.employees.length}');

  // 4. Update employee information
  if (employeeId != null) {
    await employeeController.loadById(employeeId);
    final employee = employeeController.state.selectedEmployee;
    
    if (employee != null) {
      final updatedEmployee = employee.copyWith(
        address: 'Nueva Dirección 456, Lima',
        positionId: 'POS002',
      );
      await employeeController.updateEmployee(updatedEmployee);
      print('Employee updated successfully');
    }
  }

  // 5. Get employee statistics
  final employeeRepo = ref.read(employeeRepositoryProvider);
  final employeeService = EmployeeService(employeeRepo);
  final stats = await employeeService.getEmployeeStats();
  
  print('Employee Statistics:');
  print('Total: ${stats.total}');
  print('Active: ${stats.active} (${stats.activePercentage.toStringAsFixed(1)}%)');
  print('Male: ${stats.male} (${stats.malePercentage.toStringAsFixed(1)}%)');
  print('Female: ${stats.female} (${stats.femalePercentage.toStringAsFixed(1)}%)');
  print('With Contract: ${stats.withContract}');
}

// ============================================================================
// EXAMPLE 2: Create and manage users
// ============================================================================

Future<void> userExample(WidgetRef ref) async {
  // Get the user controller
  final userController = ref.read(userControllerProvider);

  // 1. Create a new user linked to an employee
  final newUser = User(
    name: 'Juan Pérez',
    email: 'juan.perez@example.com',
    employeeId: 1, // Link to employee
    isActive: true,
  );

  final userId = await userController.createUser(newUser);
  print('User created with ID: $userId');

  // 2. Verify user email
  if (userId != null) {
    await userController.verifyEmail(userId);
    print('Email verified for user $userId');
  }

  // 3. Load user by email
  await userController.loadByEmail('juan.perez@example.com');
  final userState = userController.state;
  
  if (userState.selectedUser != null) {
    print('User found: ${userState.selectedUser!.name}');
    print('Email verified: ${userState.selectedUser!.isEmailVerified}');
  }

  // 4. Get user by email (using service)
  final userRepo = ref.read(userRepositoryProvider);
  final userService = UserService(userRepo);
  
  final foundUser = await userService.getUserByEmail('juan.perez@example.com');
  
  if (foundUser != null) {
    print('User found: ${foundUser.name}');
    userController.setCurrentUser(foundUser);
  } else {
    print('User not found or inactive');
  }

  // 5. Get user statistics
  final stats = await userService.getUserStats();
  print('User Statistics:');
  print('Total: ${stats.total}');
  print('Active: ${stats.active} (${stats.activePercentage.toStringAsFixed(1)}%)');
  print('Verified: ${stats.verified} (${stats.verifiedPercentage.toStringAsFixed(1)}%)');
  print('Unverified: ${stats.unverified}');

  // 6. Logout
  userController.logout();
  print('User logged out');
}

// ============================================================================
// EXAMPLE 3: Widget showing list of employees
// ============================================================================

class EmployeeListWidget extends ConsumerWidget {
  const EmployeeListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the employee state
    final employeeState = ref.watch(employeeViewModelProvider);

    // Load employees when widget builds
    ref.listen(employeeViewModelProvider, (previous, next) {
      if (next.status == EmployeeStatus.initial) {
        ref.read(employeeViewModelProvider.notifier).loadActiveEmployees();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(employeeViewModelProvider.notifier).loadAll();
            },
          ),
        ],
      ),
      body: _buildBody(context, ref, employeeState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, EmployeeState state) {
    return switch (state.status) {
      EmployeeStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
      EmployeeStatus.error => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${state.errorMessage}'),
              ElevatedButton(
                onPressed: () {
                  ref.read(employeeViewModelProvider.notifier).loadAll();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      EmployeeStatus.loaded => state.employees.isEmpty
          ? const Center(child: Text('No hay empleados'))
          : ListView.builder(
              itemCount: state.employees.length,
              itemBuilder: (context, index) {
                final employee = state.employees[index];
                return _buildEmployeeCard(context, ref, employee);
              },
            ),
      _ => const Center(child: Text('Iniciando...')),
    };
  }

  Widget _buildEmployeeCard(
    BuildContext context,
    WidgetRef ref,
    Employee employee,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(employee.firstName[0] + employee.lastName[0]),
        ),
        title: Text(employee.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${employee.documentType.name}: ${employee.documentNumber}'),
            if (employee.age != null) Text('Edad: ${employee.age} años'),
            if (employee.dateContract != null)
              Text(
                'Contrato: ${employee.dateContract!.day}/${employee.dateContract!.month}/${employee.dateContract!.year}',
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(employee.active ? 'Activo' : 'Inactivo'),
              backgroundColor: employee.active ? Colors.green : Colors.red,
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: const Text('Editar'),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    employee.active ? 'Desactivar' : 'Activar',
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: const Text('Eliminar'),
                ),
              ],
              onSelected: (value) {
                _handleMenuAction(context, ref, employee, value.toString());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    Employee employee,
    String action,
  ) async {
    final controller = ref.read(employeeControllerProvider);

    switch (action) {
      case 'toggle':
        if (employee.active) {
          await controller.deactivateEmployee(employee.id);
        } else {
          await controller.activateEmployee(employee.id);
        }
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Eliminar a ${employee.fullName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await controller.deleteEmployee(employee.id);
        }
        break;
      case 'edit':
        // Navigate to edit screen
        break;
    }
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    // Show dialog to create new employee
    // This is a placeholder - implement your own form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Empleado'),
        content: const Text('Implementar formulario aquí'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Create employee
              Navigator.pop(context);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Widget showing user profile
// ============================================================================

class UserProfileWidget extends ConsumerWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userViewModelProvider);

    if (userState.currentUser == null) {
      return const Center(child: Text('No hay usuario autenticado'));
    }

    final user = userState.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                user.name?.substring(0, 1) ?? 'U',
                style: const TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name ?? 'Sin nombre',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              user.email ?? 'Sin email',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Estado',
              user.isActive ? 'Activo' : 'Inactivo',
              user.isActive ? Colors.green : Colors.red,
            ),
            _buildInfoRow(
              'Email verificado',
              user.isEmailVerified ? 'Sí' : 'No',
              user.isEmailVerified ? Colors.green : Colors.orange,
            ),
            if (user.employeeId != null)
              _buildInfoRow('ID Empleado', '${user.employeeId}', Colors.blue),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(userControllerProvider).logout();
                  Navigator.pop(context);
                },
                child: const Text('Cerrar Sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Chip(
            label: Text(value),
            backgroundColor: color.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
