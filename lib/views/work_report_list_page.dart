import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/work_report_viewmodel.dart';
import '../viewmodels/server_work_report_viewmodel.dart';
import '../providers/app_providers.dart';
import '../models/work_report.dart';
import '../models/work_report_api_models.dart';

/// Page that displays a list of work reports with local/server tabs
/// Single Responsibility: Display work reports from both sources and handle navigation
class WorkReportListPage extends ConsumerStatefulWidget {
  const WorkReportListPage({super.key});

  @override
  ConsumerState<WorkReportListPage> createState() => _WorkReportListPageState();
}

class _WorkReportListPageState extends ConsumerState<WorkReportListPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Load reports when page is created
    Future.microtask(() {
      ref.read(workReportViewModelProvider.notifier).loadAll();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadDataForCurrentTab();
    }
  }
  
  bool get _isServerTab => _tabController.index == 1;
  
  void _loadDataForCurrentTab() {
    if (_isServerTab) {
      _loadServerReports();
    } else {
      _loadLocalReports();
    }
  }
  
  void _loadLocalReports() {
    ref.read(workReportViewModelProvider.notifier).loadAll();
  }
  
  void _loadServerReports() {
    ref.read(serverWorkReportViewModelProvider.notifier).loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workReportViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Reports'),
        backgroundColor: const Color(0xFF2A8D8D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDataForCurrentTab,
            tooltip: 'Actualizar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.storage),
              text: 'Local',
            ),
            Tab(
              icon: Icon(Icons.cloud),
              text: 'Servidor',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDataSourceInfo(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLocalBody(state),
                _buildServerBody(state),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        backgroundColor: const Color(0xFF2A8D8D),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDataSourceInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _isServerTab ? Colors.blue.shade50 : Colors.grey.shade50,
      child: Row(
        children: [
          Icon(
            _isServerTab ? Icons.cloud : Icons.storage,
            size: 16,
            color: _isServerTab ? Colors.blue.shade600 : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isServerTab 
                ? 'Datos del servidor con información detallada'
                : 'Datos guardados localmente en el dispositivo',
              style: TextStyle(
                fontSize: 12,
                color: _isServerTab ? Colors.blue.shade700 : Colors.grey.shade700,
              ),
            ),
          ),
          if (_isServerTab)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'En desarrollo',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLocalBody(WorkReportState state) {
    return _buildBody(state, isLocal: true);
  }
  
  Widget _buildServerBody(WorkReportState localState) {
    final serverState = ref.watch(serverWorkReportViewModelProvider);
    
    switch (serverState.status) {
      case ServerWorkReportStatus.initial:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Presiona el botón para cargar datos del servidor',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
        
      case ServerWorkReportStatus.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando reportes del servidor...'),
            ],
          ),
        );
        
      case ServerWorkReportStatus.noConnection:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Sin conexión a Internet',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(serverWorkReportViewModelProvider.notifier)
                    .refresh(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
        
      case ServerWorkReportStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: ${serverState.errorMessage}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(serverWorkReportViewModelProvider.notifier)
                    .refresh(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
        
      case ServerWorkReportStatus.loaded:
        if (serverState.reports.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay reportes de trabajo en el servidor',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () => ref
              .read(serverWorkReportViewModelProvider.notifier)
              .refresh(),
          child: Column(
            children: [
              // Indicador de fuente de datos
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Datos del servidor (${serverState.reports.length} reportes)',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                    const Spacer(),
                    if (serverState.hasMorePages)
                      Text(
                        'Página ${serverState.pagination?.currentPage ?? 1}',
                        style: TextStyle(color: Colors.blue.shade600),
                      ),
                  ],
                ),
              ),
              // Lista de reportes
              Expanded(
                child: ListView.builder(
                  itemCount: serverState.reports.length + 
                             (serverState.hasMorePages ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Botón para cargar más si hay más páginas
                    if (index == serverState.reports.length && 
                        serverState.hasMorePages) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () => ref
                                .read(serverWorkReportViewModelProvider.notifier)
                                .loadMoreReports(),
                            child: const Text('Cargar más reportes'),
                          ),
                        ),
                      );
                    }
                    
                    final report = serverState.reports[index];
                    return _buildServerReportCard(report);
                  },
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildBody(WorkReportState state, {bool isLocal = true}) {
    switch (state.status) {
      case WorkReportStatus.initial:
      case WorkReportStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case WorkReportStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'An error occurred',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(workReportViewModelProvider.notifier).loadAll();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );

      case WorkReportStatus.loaded:
        if (state.reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No work reports yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the + button to create one',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(workReportViewModelProvider.notifier).loadAll();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.reports.length,
            itemBuilder: (context, index) {
              final report = state.reports[index];
              return _buildReportCard(report, isLocal: !_isServerTab);
            },
          ),
        );
    }
  }

  Widget _buildReportCard(WorkReport report, {bool isLocal = true}) {
    final duration = report.endTime.difference(report.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(context, report),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Data source indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isLocal ? Colors.grey.shade200 : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isLocal ? 'Local' : 'Servidor',
                      style: TextStyle(
                        fontSize: 10,
                        color: isLocal ? Colors.grey.shade700 : Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF2A8D8D)),
                    onPressed: () => _navigateToEdit(context, report),
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(report),
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.calendar_today,
                    label: _formatDate(report.reportDate),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.access_time,
                    label: '${hours}h ${minutes}m',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.person,
                    label: 'Employee: ${report.employeeId}',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.work,
                    label: 'Project: ${report.projectId}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildServerReportCard(WorkReportData report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          ref
              .read(serverWorkReportViewModelProvider.notifier)
              .selectReport(report);
          _showServerReportDetails(report);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y fecha
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      report.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      report.reportDate,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Descripción
              Text(
                report.description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Información del proyecto y empleado
              Row(
                children: [
                  Icon(
                    Icons.business,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 3,
                    child: Text(
                      report.project.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 2,
                    child: Text(
                      report.employee.fullName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Información adicional (horario, fotos, firmas)
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${report.startTime} - ${report.endTime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  if (report.summary.hasPhotos)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_camera,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${report.summary.photosCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (report.summary.hasSignatures)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.draw,
                          size: 16,
                          color: Colors.purple.shade600,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Firmado',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServerReportDetails(WorkReportData report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Fecha:', report.reportDate),
              _buildDetailRow('Horario:', '${report.startTime} - ${report.endTime}'),
              _buildDetailRow('Proyecto:', report.project.name),
              _buildDetailRow('Empleado:', report.employee.fullName),
              _buildDetailRow('Posición:', report.employee.position.name),
              const SizedBox(height: 8),
              const Text(
                'Descripción:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(report.description),
              if (report.suggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Sugerencias:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(report.suggestions),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // Navegar a la página de creación de nuevo reporte
  void _navigateToForm(BuildContext context) {
    context.pushNamed('new-report').then((_) {
      // Recargar lista al volver
      ref.read(workReportViewModelProvider.notifier).loadAll();
    });
  }

  // Navegar a la página de detalle del reporte
  void _navigateToDetail(BuildContext context, WorkReport report) {
    context.pushNamed(
      'report-detail',
      pathParameters: {'id': report.id.toString()},
      extra: report,
    );
  }

  // Navegar a la página de edición
  void _navigateToEdit(BuildContext context, WorkReport report) {
    context.pushNamed(
      'edit-report',
      pathParameters: {'id': report.id.toString()},
      extra: report,
    ).then((_) {
      // Recargar lista al volver
      ref.read(workReportViewModelProvider.notifier).loadAll();
    });
  }

  Future<void> _confirmDelete(WorkReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "${report.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // First delete all photos associated with the report (including physical files)
      await ref.read(photoViewModelProvider.notifier).deleteByWorkReportIdWithFiles(report.id);
      
      // Then delete the report itself
      await ref.read(workReportViewModelProvider.notifier).deleteReport(report.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Report and photos deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
  
}
