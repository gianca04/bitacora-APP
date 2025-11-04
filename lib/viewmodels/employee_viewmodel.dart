import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/employee.dart';
import '../repositories/employee_repository.dart';

/// Possible states for Employee operations
enum EmployeeStatus { initial, loading, loaded, error }

/// State class holding Employee data and status
class EmployeeState {
  final EmployeeStatus status;
  final List<Employee> employees;
  final Employee? selectedEmployee;
  final String? errorMessage;

  const EmployeeState._({
    required this.status,
    required this.employees,
    this.selectedEmployee,
    this.errorMessage,
  });

  EmployeeState.initial()
      : this._(status: EmployeeStatus.initial, employees: []);

  EmployeeState.loading()
      : this._(status: EmployeeStatus.loading, employees: []);

  EmployeeState.loaded(List<Employee> employees)
      : this._(status: EmployeeStatus.loaded, employees: employees);

  EmployeeState.error(String message)
      : this._(
          status: EmployeeStatus.error,
          employees: [],
          errorMessage: message,
        );

  // Copy with method for partial updates
  EmployeeState copyWith({
    EmployeeStatus? status,
    List<Employee>? employees,
    Employee? selectedEmployee,
    String? errorMessage,
  }) {
    return EmployeeState._(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// ViewModel for Employee operations
/// Manages Employee state and coordinates with EmployeeRepository
class EmployeeViewModel extends StateNotifier<EmployeeState> {
  final EmployeeRepository repository;

  EmployeeViewModel({required this.repository})
      : super(EmployeeState.initial());

  /// Load all employees
  Future<void> loadAll() async {
    state = EmployeeState.loading();
    try {
      final employees = await repository.getAll();
      state = EmployeeState.loaded(employees);
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Load active employees only
  Future<void> loadActiveEmployees() async {
    state = EmployeeState.loading();
    try {
      final employees = await repository.getActiveEmployees();
      state = EmployeeState.loaded(employees);
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Load inactive employees only
  Future<void> loadInactiveEmployees() async {
    state = EmployeeState.loading();
    try {
      final employees = await repository.getInactiveEmployees();
      state = EmployeeState.loaded(employees);
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Load employees by position ID
  Future<void> loadByPositionId(String positionId) async {
    state = EmployeeState.loading();
    try {
      final employees = await repository.getByPositionId(positionId);
      state = EmployeeState.loaded(employees);
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Load employees by document type
  Future<void> loadByDocumentType(DocumentType documentType) async {
    state = EmployeeState.loading();
    try {
      final employees = await repository.getByDocumentType(documentType);
      state = EmployeeState.loaded(employees);
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Load employees by sex
  Future<void> loadBySex(Sex sex) async {
    state = EmployeeState.loading();
    try {
      final employees = await repository.getBySex(sex);
      state = EmployeeState.loaded(employees);
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Search employees by name
  Future<void> searchByName(String query) async {
    state = EmployeeState.loading();
    try {
      final employees = await repository.searchByName(query);
      state = EmployeeState.loaded(employees);
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Load employees hired in a specific year
  Future<void> loadByContractYear(int year) async {
    state = EmployeeState.loading();
    try {
      final employees = await repository.getByContractYear(year);
      state = EmployeeState.loaded(employees);
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Get employee by ID
  Future<void> loadById(Id id) async {
    state = state.copyWith(status: EmployeeStatus.loading);
    try {
      final employee = await repository.getById(id);
      if (employee != null) {
        state = state.copyWith(
          status: EmployeeStatus.loaded,
          selectedEmployee: employee,
        );
      } else {
        state = state.copyWith(
          status: EmployeeStatus.error,
          errorMessage: 'Employee not found',
        );
      }
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Get employee by document number
  Future<void> loadByDocumentNumber(String documentNumber) async {
    state = state.copyWith(status: EmployeeStatus.loading);
    try {
      final employee = await repository.getByDocumentNumber(documentNumber);
      if (employee != null) {
        state = state.copyWith(
          status: EmployeeStatus.loaded,
          selectedEmployee: employee,
        );
      } else {
        state = state.copyWith(
          status: EmployeeStatus.error,
          errorMessage: 'Employee not found',
        );
      }
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Create a new employee
  Future<Id?> createEmployee(Employee employee) async {
    state = state.copyWith(status: EmployeeStatus.loading);
    try {
      final id = await repository.create(employee);
      await loadAll(); // Reload all employees
      return id;
    } catch (e) {
      state = EmployeeState.error(e.toString());
      return null;
    }
  }

  /// Update an existing employee
  Future<bool> updateEmployee(Employee employee) async {
    state = state.copyWith(status: EmployeeStatus.loading);
    try {
      await repository.update(employee);
      await loadAll(); // Reload all employees
      return true;
    } catch (e) {
      state = EmployeeState.error(e.toString());
      return false;
    }
  }

  /// Delete an employee
  Future<bool> deleteEmployee(Id id) async {
    state = state.copyWith(status: EmployeeStatus.loading);
    try {
      final success = await repository.delete(id);
      if (success) {
        await loadAll(); // Reload all employees
      }
      return success;
    } catch (e) {
      state = EmployeeState.error(e.toString());
      return false;
    }
  }

  /// Activate an employee
  Future<void> activateEmployee(Id id) async {
    try {
      await repository.activate(id);
      await loadAll(); // Reload all employees
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Deactivate an employee
  Future<void> deactivateEmployee(Id id) async {
    try {
      await repository.deactivate(id);
      await loadAll(); // Reload all employees
    } catch (e) {
      state = EmployeeState.error(e.toString());
    }
  }

  /// Check if document number exists
  Future<bool> documentNumberExists(String documentNumber) async {
    try {
      return await repository.documentNumberExists(documentNumber);
    } catch (e) {
      state = EmployeeState.error(e.toString());
      return false;
    }
  }

  /// Get count of active employees
  Future<int> getActiveCount() async {
    try {
      return await repository.getActiveCount();
    } catch (e) {
      state = EmployeeState.error(e.toString());
      return 0;
    }
  }

  /// Get count of employees by position
  Future<int> getCountByPosition(String positionId) async {
    try {
      return await repository.getCountByPosition(positionId);
    } catch (e) {
      state = EmployeeState.error(e.toString());
      return 0;
    }
  }

  /// Clear selected employee
  void clearSelected() {
    state = state.copyWith(selectedEmployee: null);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(
      status: EmployeeStatus.initial,
      errorMessage: null,
    );
  }
}
