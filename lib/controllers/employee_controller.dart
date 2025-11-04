import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/employee.dart';
import '../viewmodels/employee_viewmodel.dart';
import '../providers/app_providers.dart';

/// Controller for Employee operations
/// Acts as a facade between UI and EmployeeViewModel
/// Note: In Riverpod best practices, controllers are optional.
/// You can work directly with ViewModels from the UI.
class EmployeeController {
  final Ref ref;

  EmployeeController(this.ref);

  /// Load all employees
  Future<EmployeeState> loadAll() async {
    await ref.read(employeeViewModelProvider.notifier).loadAll();
    return ref.read(employeeViewModelProvider);
  }

  /// Load active employees only
  Future<EmployeeState> loadActiveEmployees() async {
    await ref.read(employeeViewModelProvider.notifier).loadActiveEmployees();
    return ref.read(employeeViewModelProvider);
  }

  /// Load inactive employees only
  Future<EmployeeState> loadInactiveEmployees() async {
    await ref.read(employeeViewModelProvider.notifier).loadInactiveEmployees();
    return ref.read(employeeViewModelProvider);
  }

  /// Load employees by position ID
  Future<EmployeeState> loadByPositionId(String positionId) async {
    await ref
        .read(employeeViewModelProvider.notifier)
        .loadByPositionId(positionId);
    return ref.read(employeeViewModelProvider);
  }

  /// Load employees by document type
  Future<EmployeeState> loadByDocumentType(DocumentType documentType) async {
    await ref
        .read(employeeViewModelProvider.notifier)
        .loadByDocumentType(documentType);
    return ref.read(employeeViewModelProvider);
  }

  /// Load employees by sex
  Future<EmployeeState> loadBySex(Sex sex) async {
    await ref.read(employeeViewModelProvider.notifier).loadBySex(sex);
    return ref.read(employeeViewModelProvider);
  }

  /// Search employees by name
  Future<EmployeeState> searchByName(String query) async {
    await ref.read(employeeViewModelProvider.notifier).searchByName(query);
    return ref.read(employeeViewModelProvider);
  }

  /// Load employees hired in a specific year
  Future<EmployeeState> loadByContractYear(int year) async {
    await ref
        .read(employeeViewModelProvider.notifier)
        .loadByContractYear(year);
    return ref.read(employeeViewModelProvider);
  }

  /// Load employee by ID
  Future<EmployeeState> loadById(Id id) async {
    await ref.read(employeeViewModelProvider.notifier).loadById(id);
    return ref.read(employeeViewModelProvider);
  }

  /// Load employee by document number
  Future<EmployeeState> loadByDocumentNumber(String documentNumber) async {
    await ref
        .read(employeeViewModelProvider.notifier)
        .loadByDocumentNumber(documentNumber);
    return ref.read(employeeViewModelProvider);
  }

  /// Create a new employee
  Future<Id?> createEmployee(Employee employee) async {
    return await ref
        .read(employeeViewModelProvider.notifier)
        .createEmployee(employee);
  }

  /// Update an existing employee
  Future<bool> updateEmployee(Employee employee) async {
    return await ref
        .read(employeeViewModelProvider.notifier)
        .updateEmployee(employee);
  }

  /// Delete an employee
  Future<bool> deleteEmployee(Id id) async {
    return await ref
        .read(employeeViewModelProvider.notifier)
        .deleteEmployee(id);
  }

  /// Activate an employee
  Future<void> activateEmployee(Id id) async {
    await ref.read(employeeViewModelProvider.notifier).activateEmployee(id);
  }

  /// Deactivate an employee
  Future<void> deactivateEmployee(Id id) async {
    await ref.read(employeeViewModelProvider.notifier).deactivateEmployee(id);
  }

  /// Check if document number exists
  Future<bool> documentNumberExists(String documentNumber) async {
    return await ref
        .read(employeeViewModelProvider.notifier)
        .documentNumberExists(documentNumber);
  }

  /// Get count of active employees
  Future<int> getActiveCount() async {
    return await ref.read(employeeViewModelProvider.notifier).getActiveCount();
  }

  /// Get count of employees by position
  Future<int> getCountByPosition(String positionId) async {
    return await ref
        .read(employeeViewModelProvider.notifier)
        .getCountByPosition(positionId);
  }

  /// Clear selected employee
  void clearSelected() {
    ref.read(employeeViewModelProvider.notifier).clearSelected();
  }

  /// Clear error message
  void clearError() {
    ref.read(employeeViewModelProvider.notifier).clearError();
  }

  /// Get current state
  EmployeeState get state => ref.read(employeeViewModelProvider);
}
