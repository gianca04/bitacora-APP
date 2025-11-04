import '../models/employee.dart';
import '../repositories/employee_repository.dart';
import 'package:isar/isar.dart';

/// Service for Employee-specific business logic
/// Provides higher-level operations beyond simple CRUD
class EmployeeService {
  final EmployeeRepository _repository;

  EmployeeService(this._repository);

  /// Validate document number format based on document type
  bool validateDocumentNumber(DocumentType type, String number) {
    switch (type) {
      case DocumentType.dni:
        // DNI in Peru is 8 digits
        return RegExp(r'^\d{8}$').hasMatch(number);
      case DocumentType.pasaporte:
        // Passport can be alphanumeric, typically 9-12 characters
        return RegExp(r'^[A-Z0-9]{9,12}$').hasMatch(number);
      case DocumentType.carnetExtranjeria:
        // Carnet de Extranjeria is typically 12 characters
        return RegExp(r'^[A-Z0-9]{12}$').hasMatch(number);
    }
  }

  /// Create employee with validation
  Future<Id?> createEmployee({
    required DocumentType documentType,
    required String documentNumber,
    required String firstName,
    required String lastName,
    String? address,
    DateTime? dateContract,
    DateTime? dateBirth,
    Sex? sex,
    String? positionId,
  }) async {
    // Validate document number format
    if (!validateDocumentNumber(documentType, documentNumber)) {
      return null;
    }

    // Check if document number already exists
    final exists = await _repository.documentNumberExists(documentNumber);
    if (exists) {
      return null;
    }

    final employee = Employee(
      documentType: documentType,
      documentNumber: documentNumber,
      firstName: firstName,
      lastName: lastName,
      address: address,
      dateContract: dateContract,
      dateBirth: dateBirth,
      sex: sex,
      positionId: positionId,
      active: true,
    );

    return await _repository.create(employee);
  }

  /// Update employee information
  Future<bool> updateEmployee(Employee employee) async {
    // Validate document number format
    if (!validateDocumentNumber(employee.documentType, employee.documentNumber)) {
      return false;
    }

    await _repository.update(employee);
    return true;
  }

  /// Assign position to employee
  Future<bool> assignPosition(Id employeeId, String positionId) async {
    final employee = await _repository.getById(employeeId);
    if (employee == null) {
      return false;
    }

    final updatedEmployee = employee.copyWith(positionId: positionId);
    await _repository.update(updatedEmployee);
    return true;
  }

  /// Remove position from employee
  Future<bool> removePosition(Id employeeId) async {
    final employee = await _repository.getById(employeeId);
    if (employee == null) {
      return false;
    }

    final updatedEmployee = employee.copyWith(positionId: null);
    await _repository.update(updatedEmployee);
    return true;
  }

  /// Get employees by age range
  Future<List<Employee>> getEmployeesByAgeRange(int minAge, int maxAge) async {
    final allEmployees = await _repository.getAll();
    
    return allEmployees.where((employee) {
      final age = employee.age;
      if (age == null) return false;
      return age >= minAge && age <= maxAge;
    }).toList();
  }

  /// Get employees hired in the last N days
  Future<List<Employee>> getRecentHires(int days) async {
    final allEmployees = await _repository.getAll();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    return allEmployees.where((employee) {
      final contractDate = employee.dateContract;
      if (contractDate == null) return false;
      return contractDate.isAfter(cutoffDate);
    }).toList();
  }

  /// Get employees by contract status
  Future<EmployeesByContract> getEmployeesByContractStatus() async {
    final allEmployees = await _repository.getAll();
    
    final withContract = allEmployees
        .where((e) => e.dateContract != null)
        .toList();
    final withoutContract = allEmployees
        .where((e) => e.dateContract == null)
        .toList();

    return EmployeesByContract(
      withContract: withContract,
      withoutContract: withoutContract,
    );
  }

  /// Get employee statistics
  Future<EmployeeStats> getEmployeeStats() async {
    final allEmployees = await _repository.getAll();
    final activeEmployees = await _repository.getActiveEmployees();
    
    final maleCount = allEmployees.where((e) => e.sex == Sex.male).length;
    final femaleCount = allEmployees.where((e) => e.sex == Sex.female).length;
    final otherCount = allEmployees.where((e) => e.sex == Sex.other).length;
    final unspecifiedCount = allEmployees.where((e) => e.sex == null).length;
    
    final withContract = allEmployees.where((e) => e.hasContract).length;

    return EmployeeStats(
      total: allEmployees.length,
      active: activeEmployees.length,
      inactive: allEmployees.length - activeEmployees.length,
      male: maleCount,
      female: femaleCount,
      other: otherCount,
      unspecifiedSex: unspecifiedCount,
      withContract: withContract,
      withoutContract: allEmployees.length - withContract,
    );
  }

  /// Bulk import employees (useful for initial data setup)
  Future<List<Id>> bulkImportEmployees(List<Employee> employees) async {
    final ids = <Id>[];
    
    for (final employee in employees) {
      // Skip if document number already exists
      final exists = await _repository.documentNumberExists(employee.documentNumber);
      if (!exists) {
        final id = await _repository.create(employee);
        ids.add(id);
      }
    }
    
    return ids;
  }

  /// Search employees by multiple criteria
  Future<List<Employee>> advancedSearch({
    String? nameQuery,
    DocumentType? documentType,
    Sex? sex,
    String? positionId,
    bool? active,
  }) async {
    var employees = await _repository.getAll();

    if (nameQuery != null && nameQuery.isNotEmpty) {
      final query = nameQuery.toLowerCase();
      employees = employees.where((e) =>
          e.firstName.toLowerCase().contains(query) ||
          e.lastName.toLowerCase().contains(query)).toList();
    }

    if (documentType != null) {
      employees = employees.where((e) => e.documentType == documentType).toList();
    }

    if (sex != null) {
      employees = employees.where((e) => e.sex == sex).toList();
    }

    if (positionId != null) {
      employees = employees.where((e) => e.positionId == positionId).toList();
    }

    if (active != null) {
      employees = employees.where((e) => e.active == active).toList();
    }

    return employees;
  }
}

/// Employee statistics data class
class EmployeeStats {
  final int total;
  final int active;
  final int inactive;
  final int male;
  final int female;
  final int other;
  final int unspecifiedSex;
  final int withContract;
  final int withoutContract;

  EmployeeStats({
    required this.total,
    required this.active,
    required this.inactive,
    required this.male,
    required this.female,
    required this.other,
    required this.unspecifiedSex,
    required this.withContract,
    required this.withoutContract,
  });

  double get activePercentage => total > 0 ? (active / total) * 100 : 0;
  double get malePercentage => total > 0 ? (male / total) * 100 : 0;
  double get femalePercentage => total > 0 ? (female / total) * 100 : 0;
  double get contractPercentage => total > 0 ? (withContract / total) * 100 : 0;
}

/// Data class for employees grouped by contract status
class EmployeesByContract {
  final List<Employee> withContract;
  final List<Employee> withoutContract;

  EmployeesByContract({
    required this.withContract,
    required this.withoutContract,
  });
}
