import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/work_report.dart';
import '../viewmodels/work_report_viewmodel.dart';
import '../providers/app_providers.dart';

/// Controller for WorkReport operations
/// Acts as a facade between UI and WorkReportViewModel
/// Note: In Riverpod best practices, controllers are optional.
/// You can work directly with ViewModels from the UI.
class WorkReportController {
  final Ref ref;

  WorkReportController(this.ref);

  /// Load all work reports
  Future<WorkReportState> loadAll() async {
    await ref.read(workReportViewModelProvider.notifier).loadAll();
    return ref.read(workReportViewModelProvider);
  }

  /// Load work reports by employee ID
  Future<WorkReportState> loadByEmployeeId(int employeeId) async {
    await ref
        .read(workReportViewModelProvider.notifier)
        .loadByEmployeeId(employeeId);
    return ref.read(workReportViewModelProvider);
  }

  /// Load work reports by project ID
  Future<WorkReportState> loadByProjectId(int projectId) async {
    await ref
        .read(workReportViewModelProvider.notifier)
        .loadByProjectId(projectId);
    return ref.read(workReportViewModelProvider);
  }

  /// Load work reports by date range
  Future<WorkReportState> loadByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await ref
        .read(workReportViewModelProvider.notifier)
        .loadByDateRange(startDate, endDate);
    return ref.read(workReportViewModelProvider);
  }

  /// Create a new work report and return the resulting state
  Future<Id?> createReport(WorkReport report) async {
    final id = await ref
        .read(workReportViewModelProvider.notifier)
        .createReport(report);
    return id;
  }

  /// Update an existing work report and return success status
  Future<bool> updateReport(WorkReport report) async {
    return await ref
        .read(workReportViewModelProvider.notifier)
        .updateReport(report);
  }

  /// Delete a work report and return success status
  Future<bool> deleteReport(Id id) async {
    return await ref
        .read(workReportViewModelProvider.notifier)
        .deleteReport(id);
  }

  /// Select a specific report for viewing/editing
  void selectReport(WorkReport report) {
    ref.read(workReportViewModelProvider.notifier).selectReport(report);
  }

  /// Clear the selected report
  void clearSelection() {
    ref.read(workReportViewModelProvider.notifier).clearSelection();
  }

  /// Reset to initial state
  void reset() {
    ref.read(workReportViewModelProvider.notifier).reset();
  }
}
