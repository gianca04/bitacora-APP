import 'package:isar/isar.dart';
import '../models/employee.dart';
import '../services/isar_service.dart';

/// Repository for Employee CRUD operations following Flutter best practices
class EmployeeRepository {
  final IsarService _isarService;

  EmployeeRepository(this._isarService);

  /// Get all employees
  Future<List<Employee>> getAll() async {
    final isar = _isarService.instance;
    return await isar.employees.where().findAll();
  }

  /// Get employee by ID
  Future<Employee?> getById(Id id) async {
    final isar = _isarService.instance;
    return await isar.employees.get(id);
  }

  /// Get employee by document number
  Future<Employee?> getByDocumentNumber(String documentNumber) async {
    final isar = _isarService.instance;
    return await isar.employees
        .filter()
        .documentNumberEqualTo(documentNumber)
        .findFirst();
  }

  /// Get all active employees
  Future<List<Employee>> getActiveEmployees() async {
    final isar = _isarService.instance;
    return await isar.employees
        .filter()
        .activeEqualTo(true)
        .findAll();
  }

  /// Get all inactive employees
  Future<List<Employee>> getInactiveEmployees() async {
    final isar = _isarService.instance;
    return await isar.employees
        .filter()
        .activeEqualTo(false)
        .findAll();
  }

  /// Get employees by position ID
  Future<List<Employee>> getByPositionId(String positionId) async {
    final isar = _isarService.instance;
    return await isar.employees
        .filter()
        .positionIdEqualTo(positionId)
        .findAll();
  }

  /// Get employees by document type
  Future<List<Employee>> getByDocumentType(DocumentType documentType) async {
    final isar = _isarService.instance;
    return await isar.employees
        .filter()
        .documentTypeEqualTo(documentType)
        .findAll();
  }

  /// Get employees by sex
  Future<List<Employee>> getBySex(Sex sex) async {
    final isar = _isarService.instance;
    return await isar.employees
        .filter()
        .sexEqualTo(sex)
        .findAll();
  }

  /// Search employees by name (first or last name)
  Future<List<Employee>> searchByName(String query) async {
    final isar = _isarService.instance;
    final lowerQuery = query.toLowerCase();
    
    return await isar.employees
        .filter()
        .group((q) => q
            .firstNameContains(lowerQuery, caseSensitive: false)
            .or()
            .lastNameContains(lowerQuery, caseSensitive: false))
        .findAll();
  }

  /// Get employees hired in a specific year
  Future<List<Employee>> getByContractYear(int year) async {
    final isar = _isarService.instance;
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31, 23, 59, 59);
    
    return await isar.employees
        .filter()
        .dateContractBetween(startDate, endDate)
        .findAll();
  }

  /// Create a new employee
  Future<Id> create(Employee employee) async {
    final isar = _isarService.instance;
    return await isar.writeTxn(() async {
      return await isar.employees.put(employee);
    });
  }

  /// Update an existing employee
  Future<void> update(Employee employee) async {
    final isar = _isarService.instance;
    employee.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.employees.put(employee);
    });
  }

  /// Delete an employee
  Future<bool> delete(Id id) async {
    final isar = _isarService.instance;
    return await isar.writeTxn(() async {
      return await isar.employees.delete(id);
    });
  }

  /// Activate an employee
  Future<void> activate(Id id) async {
    final employee = await getById(id);
    if (employee != null) {
      final updatedEmployee = employee.copyWith(active: true);
      await update(updatedEmployee);
    }
  }

  /// Deactivate an employee
  Future<void> deactivate(Id id) async {
    final employee = await getById(id);
    if (employee != null) {
      final updatedEmployee = employee.copyWith(active: false);
      await update(updatedEmployee);
    }
  }

  /// Check if document number exists
  Future<bool> documentNumberExists(String documentNumber) async {
    final employee = await getByDocumentNumber(documentNumber);
    return employee != null;
  }

  /// Get count of active employees
  Future<int> getActiveCount() async {
    final isar = _isarService.instance;
    return await isar.employees
        .filter()
        .activeEqualTo(true)
        .count();
  }

  /// Get count of employees by position
  Future<int> getCountByPosition(String positionId) async {
    final isar = _isarService.instance;
    return await isar.employees
        .filter()
        .positionIdEqualTo(positionId)
        .count();
  }

  /// Watch all employees (reactive)
  Stream<List<Employee>> watchAll() {
    final isar = _isarService.instance;
    return isar.employees.where().watch(fireImmediately: true);
  }

  /// Watch a specific employee (reactive)
  Stream<Employee?> watchEmployee(Id id) {
    final isar = _isarService.instance;
    return isar.employees.watchObject(id, fireImmediately: true);
  }

  /// Watch active employees (reactive)
  Stream<List<Employee>> watchActiveEmployees() {
    final isar = _isarService.instance;
    return isar.employees
        .filter()
        .activeEqualTo(true)
        .watch(fireImmediately: true);
  }

  /// Watch employees by position (reactive)
  Stream<List<Employee>> watchByPosition(String positionId) {
    final isar = _isarService.instance;
    return isar.employees
        .filter()
        .positionIdEqualTo(positionId)
        .watch(fireImmediately: true);
  }
}
