import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/work_report_viewmodel.dart';
import '../providers/app_providers.dart';
import '../models/work_report.dart';

/// Page that displays a list of all work reports
/// Single Responsibility: Display work reports and handle navigation
class WorkReportListPage extends ConsumerStatefulWidget {
  const WorkReportListPage({super.key});

  @override
  ConsumerState<WorkReportListPage> createState() => _WorkReportListPageState();
}

class _WorkReportListPageState extends ConsumerState<WorkReportListPage> {
  @override
  void initState() {
    super.initState();
    // Load reports when page is created
    Future.microtask(() {
      ref.read(workReportViewModelProvider.notifier).loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workReportViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Reports'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        backgroundColor: const Color(0xFF2A8D8D),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(WorkReportState state) {
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
              return _buildReportCard(report);
            },
          ),
        );
    }
  }

  Widget _buildReportCard(WorkReport report) {
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
