import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- IMPORTS ---
import '../viewmodels/work_report_viewmodel.dart';
import '../viewmodels/server_work_report_viewmodel.dart';
import '../providers/app_providers.dart';
import '../models/work_report.dart';
import '../widgets/card_work_report.dart';
import '../models/work_report_api_models.dart';
import '../config/app_colors.dart'; // Tu archivo de colores
import 'server_work_report_detail_page.dart';

/// Página principal de listado de reportes.
/// Diseño: Dark Theme Premium con Floating Tabs.
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
    
    // Carga inicial
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
    // Forzar rebuild para actualizar UI dependiente del tab
    setState(() {}); 
  }
  
  bool get _isServerTab => _tabController.index == 1;
  
  void _loadDataForCurrentTab() {
    if (_isServerTab) {
      ref.read(serverWorkReportViewModelProvider.notifier).loadReports();
    } else {
      ref.read(workReportViewModelProvider.notifier).loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localState = ref.watch(workReportViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Fondo base negro
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER PERSONALIZADO
            _buildCustomHeader(),

            // 2. TABS FLOTANTES (Estilo Cápsula)
            _buildFloatingTabBar(),

            // 3. CONTENIDO PRINCIPAL
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLocalBody(localState),
                  _buildServerBody(),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // 4. FAB CON GRADIENTE
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient, // Usamos tu gradiente
          boxShadow: [
            BoxShadow(color: AppColors.primary, blurRadius: 15, spreadRadius: -5)
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _navigateToForm(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // --- COMPONENTES DE UI ---

  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reportes de Trabajo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isServerTab ? 'Sincronizado con la nube' : 'Almacenamiento local',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _loadDataForCurrentTab,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(
              Icons.refresh, 
              color: _isServerTab ? AppColors.info : AppColors.success
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingTabBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: _isServerTab ? AppColors.info : AppColors.success, // Color dinámico según tab
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: (_isServerTab ? AppColors.info : AppColors.success).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.smartphone, size: 18),
                SizedBox(width: 8),
                Text('Dispositivo'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_queue, size: 18),
                SizedBox(width: 8),
                Text('Nube'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CUERPO LOCAL ---

  Widget _buildLocalBody(WorkReportState state) {
    if (state.status == WorkReportStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.success));
    }

    if (state.status == WorkReportStatus.error) {
      return _buildErrorState(state.errorMessage ?? 'Error desconocido', () {
        ref.read(workReportViewModelProvider.notifier).loadAll();
      });
    }

    if (state.reports.isEmpty) {
      return _buildEmptyState(
        'Sin reportes locales', 
        'Toca el botón + para crear tu primer reporte.',
        Icons.note_add_outlined
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.reports.length,
      itemBuilder: (context, index) {
        return LocalReportCard(
          report: state.reports[index],
          onTap: () => _navigateToDetail(context, state.reports[index]),
          onEdit: () => _navigateToEdit(context, state.reports[index]),
          onDelete: () => _confirmDelete(state.reports[index]),
        );
      },
    );
  }

  // --- CUERPO SERVIDOR ---

  Widget _buildServerBody() {
    final serverState = ref.watch(serverWorkReportViewModelProvider);

    if (serverState.status == ServerWorkReportStatus.loading && serverState.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.info));
    }

    if (serverState.status == ServerWorkReportStatus.error || 
        serverState.status == ServerWorkReportStatus.noConnection) {
      return _buildErrorState(
        serverState.errorMessage ?? 'Error de conexión', 
        () => ref.read(serverWorkReportViewModelProvider.notifier).refresh()
      );
    }

    if (serverState.status == ServerWorkReportStatus.loaded && serverState.reports.isEmpty) {
      return _buildEmptyState(
        'Nube vacía', 
        'No hay reportes sincronizados en el servidor.',
        Icons.cloud_off
      );
    }

    // Lista con paginación
    return RefreshIndicator(
      color: AppColors.info,
      backgroundColor: AppColors.surfaceDark,
      onRefresh: () => ref.read(serverWorkReportViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: serverState.reports.length + (serverState.hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == serverState.reports.length) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () => ref.read(serverWorkReportViewModelProvider.notifier).loadMoreReports(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceDark,
                    foregroundColor: AppColors.info,
                  ),
                  child: const Text('Cargar más antiguos'),
                ),
              ),
            );
          }
          
          return ServerReportCard(
            report: serverState.reports[index],
            onTap: () {
               Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ServerWorkReportDetailPage(report: serverState.reports[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- WIDGETS DE ESTADO ---

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // --- NAVEGACIÓN Y LÓGICA ---

  void _navigateToForm(BuildContext context) {
    context.pushNamed('new-report').then((_) => 
      ref.read(workReportViewModelProvider.notifier).loadAll()
    );
  }

  void _navigateToDetail(BuildContext context, WorkReport report) {
    context.pushNamed('report-detail', pathParameters: {'id': report.id.toString()}, extra: report);
  }

  void _navigateToEdit(BuildContext context, WorkReport report) {
    context.pushNamed('edit-report', pathParameters: {'id': report.id.toString()}, extra: report).then((_) =>
      ref.read(workReportViewModelProvider.notifier).loadAll()
    );
  }

  Future<void> _confirmDelete(WorkReport report) async {
    // Diálogo Dark Mode
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Eliminar Reporte', style: TextStyle(color: Colors.white)),
        content: Text('¿Estás seguro de eliminar "${report.name}" de forma permanente?', 
          style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(photoViewModelProvider.notifier).deleteByWorkReportIdWithFiles(report.id);
      await ref.read(workReportViewModelProvider.notifier).deleteReport(report.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte eliminado'), backgroundColor: AppColors.success),
        );
      }
    }
  }
}

// =============================================================================
// TARJETAS REUTILIZABLES (Diseño Consistente)
// =============================================================================

/// Tarjeta base para evitar código repetido entre Local y Server
