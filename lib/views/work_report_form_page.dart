import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/work_report.dart';
import '../models/photo.dart';
import '../viewmodels/work_report_viewmodel.dart';
import '../providers/app_providers.dart';
import '../widgets/work_report_form.dart';

/// Page for creating or editing a work report
class WorkReportFormPage extends ConsumerStatefulWidget {
  final WorkReport? workReport;

  const WorkReportFormPage({
    super.key,
    this.workReport,
  });

  @override
  ConsumerState<WorkReportFormPage> createState() => _WorkReportFormPageState();
}

class _WorkReportFormPageState extends ConsumerState<WorkReportFormPage> {
  List<Photo>? _existingPhotos;
  bool _isLoadingPhotos = false;
  // Keep the last submitted report so we can return it to the caller when pop
  WorkReport? _submittedReport;

  @override
  void initState() {
    super.initState();
    // Cargar fotos existentes si estamos editando
    // Usar addPostFrameCallback para evitar modificar provider durante build
    if (widget.workReport != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingPhotos();
      });
    }
  }

  Future<void> _loadExistingPhotos() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingPhotos = true;
    });

    try {
      await ref.read(photoViewModelProvider.notifier)
        .loadByWorkReportId(widget.workReport!.id);
      
      if (!mounted) return;
      
      final photoState = ref.read(photoViewModelProvider);
      setState(() {
        _existingPhotos = photoState.photos;
        _isLoadingPhotos = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoadingPhotos = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar fotos: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workReportViewModelProvider);
    final isEditing = widget.workReport != null;

    // Listen to state changes for navigation and return the submitted report
    ref.listen<WorkReportState>(workReportViewModelProvider, (previous, next) {
      if (next.status == WorkReportStatus.loaded && previous?.status == WorkReportStatus.loading) {
        // Successfully saved, navigate back and return submitted report
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Report updated successfully' : 'Report created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(_submittedReport);
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
      body: _isLoadingPhotos
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando fotos...'),
                ],
              ),
            )
          : state.status == WorkReportStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : WorkReportForm(
                  workReport: widget.workReport,
                  existingPhotos: _existingPhotos,
                  onSubmit: (report, photos, photosChanged) => _handleSubmit(report, photos, photosChanged, context),
                ),
    );
  }

  Future<void> _handleSubmit(
    WorkReport report,
    List<Photo> photos,
    bool photosChanged,
    BuildContext context,
  ) async {
    try {
      final viewModel = ref.read(workReportViewModelProvider.notifier);

      if (widget.workReport == null) {
        // Create new report
        // store the submitted report so we can return it later
        _submittedReport = report;
        final reportId = await viewModel.createReport(report);
        
        // Create associated photos if report was created successfully
        if (reportId != null) {
          // Update submitted report id
          _submittedReport?.id = reportId;
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
        _submittedReport = report;
        await viewModel.updateReport(report);

        // Para actualización: si las fotos fueron modificadas por el usuario,
        // eliminamos las antiguas y creamos las nuevas. Si no hubo cambios de
        // fotos, preservamos las fotos existentes.
  if (photosChanged) {
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
