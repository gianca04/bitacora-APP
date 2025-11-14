import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/work_report_api_models.dart';
import '../services/work_report_api_service.dart';

/// Estados posibles para las operaciones de Work Reports del servidor
enum ServerWorkReportStatus { initial, loading, loaded, error, noConnection }

/// Estado que contiene los datos de Work Reports del servidor
class ServerWorkReportState {
  final ServerWorkReportStatus status;
  final List<WorkReportData> reports;
  final WorkReportData? selectedReport;
  final Pagination? pagination;
  final String? errorMessage;
  final bool hasMorePages;

  const ServerWorkReportState._({
    required this.status,
    required this.reports,
    this.selectedReport,
    this.pagination,
    this.errorMessage,
    this.hasMorePages = false,
  });

  ServerWorkReportState.initial()
      : this._(status: ServerWorkReportStatus.initial, reports: []);

  ServerWorkReportState.loading()
      : this._(status: ServerWorkReportStatus.loading, reports: []);

  ServerWorkReportState.loaded({
    required List<WorkReportData> reports,
    Pagination? pagination,
  }) : this._(
          status: ServerWorkReportStatus.loaded,
          reports: reports,
          pagination: pagination,
          hasMorePages: pagination?.hasMorePages ?? false,
        );

  ServerWorkReportState.error(String message)
      : this._(
          status: ServerWorkReportStatus.error,
          reports: [],
          errorMessage: message,
        );

  ServerWorkReportState.noConnection()
      : this._(
          status: ServerWorkReportStatus.noConnection,
          reports: [],
          errorMessage: 'Sin conexión a Internet',
        );

  // Copy with method para actualizaciones parciales
  ServerWorkReportState copyWith({
    ServerWorkReportStatus? status,
    List<WorkReportData>? reports,
    WorkReportData? selectedReport,
    Pagination? pagination,
    String? errorMessage,
    bool? hasMorePages,
  }) {
    return ServerWorkReportState._(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      selectedReport: selectedReport ?? this.selectedReport,
      pagination: pagination ?? this.pagination,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}

/// ViewModel para operaciones de Work Reports del servidor
class ServerWorkReportViewModel extends StateNotifier<ServerWorkReportState> {
  final WorkReportApiService apiService;

  ServerWorkReportViewModel({required this.apiService})
      : super(ServerWorkReportState.initial());

  /// Cargar todos los work reports con paginación
  Future<void> loadReports({
    int? projectId,
    int perPage = 10,
    int page = 1,
    bool append = false,
  }) async {
    if (!append) {
      state = ServerWorkReportState.loading();
    }

    try {
      debugPrint('📊 [ServerWorkReportVM] Iniciando carga de reportes del servidor...');
      
      final response = await apiService.getWorkReports(
        projectId: projectId,
        perPage: perPage,
        page: page,
      );

      if (response == null) {
        debugPrint('📊 [ServerWorkReportVM] ❌ Sin conexión a internet');
        state = ServerWorkReportState.noConnection();
        return;
      }

      if (!response.success) {
        debugPrint('📊 [ServerWorkReportVM] ❌ API devolvió success=false: ${response.message}');
        state = ServerWorkReportState.error(response.message);
        return;
      }

      List<WorkReportData> reports = response.data;
      
      // Si estamos agregando más datos, combinamos con los existentes
      if (append && state.reports.isNotEmpty) {
        reports = [...state.reports, ...response.data];
      }

      debugPrint('📊 [ServerWorkReportVM] ✅ Carga exitosa: ${reports.length} reportes total');
      state = ServerWorkReportState.loaded(
        reports: reports,
        pagination: response.pagination,
      );
    } catch (e) {
      debugPrint('📊 [ServerWorkReportVM] ❌ Error en loadReports: $e');
      state = ServerWorkReportState.error(e.toString());
    }
  }

  /// Cargar más reportes (paginación)
  Future<void> loadMoreReports({
    int? projectId,
    int perPage = 10,
  }) async {
    final currentPage = state.pagination?.currentPage ?? 1;
    
    if (!state.hasMorePages) return;

    await loadReports(
      projectId: projectId,
      perPage: perPage,
      page: currentPage + 1,
      append: true,
    );
  }

  /// Búsqueda avanzada de work reports
  Future<void> searchReports(WorkReportSearchParams params) async {
    state = ServerWorkReportState.loading();

    try {
      final response = await apiService.searchWorkReports(params);

      if (response == null) {
        state = ServerWorkReportState.noConnection();
        return;
      }

      if (!response.success) {
        state = ServerWorkReportState.error(response.message);
        return;
      }

      state = ServerWorkReportState.loaded(
        reports: response.data,
        pagination: response.pagination,
      );
    } catch (e) {
      state = ServerWorkReportState.error(e.toString());
    }
  }

  /// Obtener work report por ID
  Future<void> getReportById(int id) async {
    state = ServerWorkReportState.loading();

    try {
      final response = await apiService.getWorkReportById(id);

      if (response == null) {
        state = ServerWorkReportState.noConnection();
        return;
      }

      if (!response.success) {
        state = ServerWorkReportState.error(response.message);
        return;
      }

      if (response.data != null) {
        state = state.copyWith(
          status: ServerWorkReportStatus.loaded,
          selectedReport: response.data,
        );
      } else {
        state = ServerWorkReportState.error('Work report no encontrado');
      }
    } catch (e) {
      state = ServerWorkReportState.error(e.toString());
    }
  }

  /// Obtener work reports por proyecto
  Future<void> getReportsByProject(int projectId) async {
    state = ServerWorkReportState.loading();

    try {
      final response = await apiService.getWorkReportsByProject(projectId);

      if (response == null) {
        state = ServerWorkReportState.noConnection();
        return;
      }

      if (!response.success) {
        state = ServerWorkReportState.error(response.message);
        return;
      }

      if (response.data != null) {
        // getWorkReportsByProject devuelve un array en data, pero en WorkReportSingleApiResponse
        // Necesitamos manejar esto correctamente
        state = ServerWorkReportState.loaded(
          reports: [response.data!], // Por ahora manejamos como un solo item
        );
      } else {
        state = ServerWorkReportState.loaded(reports: []);
      }
    } catch (e) {
      state = ServerWorkReportState.error(e.toString());
    }
  }

  /// Obtener work reports por empleado
  Future<void> getReportsByEmployee(int employeeId) async {
    state = ServerWorkReportState.loading();

    try {
      final response = await apiService.getWorkReportsByEmployee(employeeId);

      if (response == null) {
        state = ServerWorkReportState.noConnection();
        return;
      }

      if (!response.success) {
        state = ServerWorkReportState.error(response.message);
        return;
      }

      if (response.data != null) {
        state = ServerWorkReportState.loaded(
          reports: [response.data!], // Por ahora manejamos como un solo item
        );
      } else {
        state = ServerWorkReportState.loaded(reports: []);
      }
    } catch (e) {
      state = ServerWorkReportState.error(e.toString());
    }
  }

  /// Seleccionar un reporte específico
  void selectReport(WorkReportData report) {
    state = state.copyWith(selectedReport: report);
  }

  /// Limpiar la selección
  void clearSelection() {
    state = state.copyWith(selectedReport: null);
  }

  /// Resetear al estado inicial
  void reset() {
    state = ServerWorkReportState.initial();
  }

  /// Refrescar los datos
  Future<void> refresh({int? projectId}) async {
    await loadReports(projectId: projectId);
  }
}

/// Providers para Riverpod
final workReportApiServiceProvider = Provider<WorkReportApiService>((ref) {
  return WorkReportApiService();
});

final serverWorkReportViewModelProvider = 
    StateNotifierProvider<ServerWorkReportViewModel, ServerWorkReportState>((ref) {
  final apiService = ref.watch(workReportApiServiceProvider);
  return ServerWorkReportViewModel(apiService: apiService);
});