import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/work_report.dart';
import '../repositories/work_report_repository.dart';

/// Possible states for WorkReport operations
enum WorkReportStatus { initial, loading, loaded, error }

/// State class holding WorkReport data and status
class WorkReportState {
  final WorkReportStatus status;
  final List<WorkReport> reports;
  final WorkReport? selectedReport;
  final String? errorMessage;

  const WorkReportState._({
    required this.status,
    required this.reports,
    this.selectedReport,
    this.errorMessage,
  });

  WorkReportState.initial()
      : this._(status: WorkReportStatus.initial, reports: []);

  WorkReportState.loading()
      : this._(status: WorkReportStatus.loading, reports: []);

  WorkReportState.loaded(List<WorkReport> reports)
      : this._(status: WorkReportStatus.loaded, reports: reports);

  WorkReportState.error(String message)
      : this._(status: WorkReportStatus.error, reports: [], errorMessage: message);

  // Copy with method for partial updates
  WorkReportState copyWith({
    WorkReportStatus? status,
    List<WorkReport>? reports,
    WorkReport? selectedReport,
    String? errorMessage,
  }) {
    return WorkReportState._(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      selectedReport: selectedReport ?? this.selectedReport,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// ViewModel for WorkReport operations
/// Manages WorkReport state and coordinates with WorkReportRepository
class WorkReportViewModel extends StateNotifier<WorkReportState> {
  final WorkReportRepository repository;

  WorkReportViewModel({required this.repository})
      : super(WorkReportState.initial());

  /// Load all work reports
  Future<void> loadAll() async {
    state = WorkReportState.loading();
    try {
      final reports = await repository.getAll();
      state = WorkReportState.loaded(reports);
    } catch (e) {
      state = WorkReportState.error(e.toString());
    }
  }

  /// Load work reports by employee ID
  Future<void> loadByEmployeeId(int employeeId) async {
    state = WorkReportState.loading();
    try {
      final reports = await repository.getByEmployeeId(employeeId);
      state = WorkReportState.loaded(reports);
    } catch (e) {
      state = WorkReportState.error(e.toString());
    }
  }

  /// Load work reports by project ID
  Future<void> loadByProjectId(int projectId) async {
    state = WorkReportState.loading();
    try {
      final reports = await repository.getByProjectId(projectId);
      state = WorkReportState.loaded(reports);
    } catch (e) {
      state = WorkReportState.error(e.toString());
    }
  }

  /// Load work reports by date range
  Future<void> loadByDateRange(DateTime startDate, DateTime endDate) async {
    state = WorkReportState.loading();
    try {
      final reports = await repository.getByDateRange(startDate, endDate);
      state = WorkReportState.loaded(reports);
    } catch (e) {
      state = WorkReportState.error(e.toString());
    }
  }

  /// Create a new work report
  Future<Id?> createReport(WorkReport report) async {
    try {
      final id = await repository.create(report);
      // Reload reports after creation
      await loadAll();
      return id;
    } catch (e) {
      state = WorkReportState.error(e.toString());
      return null;
    }
  }

  /// Update an existing work report
  Future<bool> updateReport(WorkReport report) async {
    try {
      await repository.update(report);
      // Reload reports after update
      await loadAll();
      return true;
    } catch (e) {
      state = WorkReportState.error(e.toString());
      return false;
    }
  }

  /// Delete a work report
  Future<bool> deleteReport(Id id) async {
    try {
      final success = await repository.delete(id);
      if (success) {
        // Reload reports after deletion
        await loadAll();
      }
      return success;
    } catch (e) {
      state = WorkReportState.error(e.toString());
      return false;
    }
  }

  /// Select a specific report (useful for detail views)
  void selectReport(WorkReport report) {
    state = state.copyWith(selectedReport: report);
  }

  /// Clear the selected report
  void clearSelection() {
    state = state.copyWith(selectedReport: null);
  }

  /// Reset to initial state
  void reset() {
    state = WorkReportState.initial();
  }
}
