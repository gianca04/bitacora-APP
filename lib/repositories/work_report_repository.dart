import 'package:isar/isar.dart';
import '../models/work_report.dart';
import '../services/isar_service.dart';

/// Repository for WorkReport CRUD operations following Flutter best practices
class WorkReportRepository {
  final IsarService _isarService;

  WorkReportRepository(this._isarService);

  /// Get all work reports
  Future<List<WorkReport>> getAll() async {
    final isar = _isarService.instance;
    return await isar.workReports.where().findAll();
  }

  /// Get work report by ID
  Future<WorkReport?> getById(Id id) async {
    final isar = _isarService.instance;
    return await isar.workReports.get(id);
  }

  /// Get work reports by employee
  Future<List<WorkReport>> getByEmployeeId(int employeeId) async {
    final isar = _isarService.instance;
    return await isar.workReports
        .filter()
        .employeeIdEqualTo(employeeId)
        .findAll();
  }

  /// Get work reports by project
  Future<List<WorkReport>> getByProjectId(int projectId) async {
    final isar = _isarService.instance;
    return await isar.workReports
        .filter()
        .projectIdEqualTo(projectId)
        .findAll();
  }

  /// Get work reports by date range
  Future<List<WorkReport>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final isar = _isarService.instance;
    return await isar.workReports
        .filter()
        .reportDateBetween(startDate, endDate)
        .findAll();
  }

  /// Create a new work report
  Future<Id> create(WorkReport workReport) async {
    final isar = _isarService.instance;
    return await isar.writeTxn(() async {
      return await isar.workReports.put(workReport);
    });
  }

  /// Update an existing work report
  Future<void> update(WorkReport workReport) async {
    final isar = _isarService.instance;
    workReport.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.workReports.put(workReport);
    });
  }

  /// Delete a work report
  Future<bool> delete(Id id) async {
    final isar = _isarService.instance;
    return await isar.writeTxn(() async {
      return await isar.workReports.delete(id);
    });
  }

  /// Delete multiple work reports
  Future<int> deleteAll(List<Id> ids) async {
    final isar = _isarService.instance;
    return await isar.writeTxn(() async {
      return await isar.workReports.deleteAll(ids);
    });
  }

  /// Watch all work reports (reactive)
  Stream<List<WorkReport>> watchAll() {
    final isar = _isarService.instance;
    return isar.workReports.where().watch(fireImmediately: true);
  }

  /// Watch work reports by employee (reactive)
  Stream<List<WorkReport>> watchByEmployeeId(int employeeId) {
    final isar = _isarService.instance;
    return isar.workReports
        .filter()
        .employeeIdEqualTo(employeeId)
        .watch(fireImmediately: true);
  }
}
