import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/work_report.dart';
import '../models/photo.dart';
import '../viewmodels/work_report_viewmodel.dart';
import '../providers/app_providers.dart';
import '../widgets/work_report_form.dart';

/// Page for creating or editing a work report
class WorkReportFormPage extends ConsumerWidget {
  final WorkReport? workReport;

  const WorkReportFormPage({
    super.key,
    this.workReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workReportViewModelProvider);
    final isEditing = workReport != null;

    // Listen to state changes for navigation
    ref.listen<WorkReportState>(workReportViewModelProvider, (previous, next) {
      if (next.status == WorkReportStatus.loaded && previous?.status == WorkReportStatus.loading) {
        // Successfully saved, navigate back
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Report updated successfully' : 'Report created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else if (next.status == WorkReportStatus.error) {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Work Report' : 'New Work Report'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: state.status == WorkReportStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : WorkReportForm(
              workReport: workReport,
              onSubmit: (report, photos) => _handleSubmit(ref, report, photos, context),
            ),
    );
  }

  Future<void> _handleSubmit(
    WidgetRef ref,
    WorkReport report,
    List<Photo> photos,
    BuildContext context,
  ) async {
    try {
      final viewModel = ref.read(workReportViewModelProvider.notifier);

      if (workReport == null) {
        // Create new report
        final reportId = await viewModel.createReport(report);
        
        // Create associated photos if report was created successfully
        if (reportId != null) {
          final photoViewModel = ref.read(photoViewModelProvider.notifier);
          
          // Las fotos ya fueron guardadas en almacenamiento permanente 
          // por BeforeAfterPhotoCard usando PhotoStorageService
          // Solo necesitamos crear los registros en la BD
          for (final photo in photos) {
            await photoViewModel.createPhoto(
              Photo(
                workReportId: reportId,
                photoPath: photo.photoPath,
                descripcion: photo.descripcion,
                beforeWorkPhotoPath: photo.beforeWorkPhotoPath,
                beforeWorkDescripcion: photo.beforeWorkDescripcion,
              ),
            );
          }
        }
      } else {
        // Update existing report
        await viewModel.updateReport(report);
        
        // Para actualización: eliminar fotos antiguas y crear nuevas
        final photoViewModel = ref.read(photoViewModelProvider.notifier);
        
        // Eliminar fotos antiguas del reporte
        await photoViewModel.deleteByWorkReportId(report.id);
        
        // Crear nuevas fotos
        for (final photo in photos) {
          await photoViewModel.createPhoto(
            Photo(
              workReportId: report.id,
              photoPath: photo.photoPath,
              descripcion: photo.descripcion,
              beforeWorkPhotoPath: photo.beforeWorkPhotoPath,
              beforeWorkDescripcion: photo.beforeWorkDescripcion,
            ),
          );
        }
      }
    } catch (e) {
      // Mostrar error si algo falla
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow;
    }
  }
}
