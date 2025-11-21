import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart'; // Tu archivo de colores
import 'package:bitacora/widgets/custom_floating_tab_bar.dart';
import '../models/work_report.dart';
import '../models/photo.dart';
import '../viewmodels/work_report_viewmodel.dart';
import '../providers/app_providers.dart';
import '../widgets/work_report_form.dart';
import '../widgets/tab_item.dart';
import '../widgets/loading_overlay.dart';

/// Page for creating or editing a work report
class WorkReportFormPage extends ConsumerStatefulWidget {
  final WorkReport? workReport;

  const WorkReportFormPage({super.key, this.workReport});

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
      await ref
          .read(photoViewModelProvider.notifier)
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

    // Listen to state changes for ERROR handling only
    ref.listen<WorkReportState>(workReportViewModelProvider, (previous, next) {
      if (next.status == WorkReportStatus.error) {
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CustomFloatingAppBar(
          title: isEditing ? 'Editar Reporte' : 'Crear nuevo Reporte',
          isEditing: isEditing,
          tabs: const [
            ModernTabItem(title: 'General', count: 0),
            ModernTabItem(title: 'Fotografías', count: 0),
            ModernTabItem(title: 'Firmas', count: 0),
          ],
        ),
        body: Container(
          color: Colors.black,
          child: TabBarView(
            children: [
              // Información general: contenido existente del formulario
              Stack(
                children: [
                  _isLoadingPhotos
                      ? const LoadingOverlay(message: 'Cargando fotos...')
                      : state.status == WorkReportStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : WorkReportForm(
                          workReport: widget.workReport,
                          existingPhotos: _existingPhotos,
                          onSubmit: (report, photos, photosChanged) =>
                              _handleSubmit(
                                report,
                                photos,
                                photosChanged,
                                context,
                              ),
                        ),
                ],
              ),
              // Descripción
              const Center(
                child: Text(
                  'Descripción',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const Center(
                child: Text(
                  'Descripción',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
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
        _submittedReport = report;
        final reportId = await viewModel.createReport(report);

        // Create associated photos if report was created successfully
        if (reportId != null) {
          // Update submitted report id
          _submittedReport?.id = reportId;
          final photoViewModel = ref.read(photoViewModelProvider.notifier);

          // Photos have already been saved to permanent storage by BeforeAfterPhotoCard
          // using PhotoStorageService. We only need to create DB records.
          // Only save photos that have valid paths
          for (final photo in photos) {
            if (photo.hasValidPhotos) {
              await photoViewModel.createPhoto(
                Photo(
                  workReportId: reportId,
                  beforeWorkPhotoPath: photo.beforeWorkPhotoPath,
                  photoPath: photo.photoPath,
                  beforeWorkDescripcion: photo.beforeWorkDescripcion,
                  descripcion: photo.descripcion,
                ),
              );
            }
          }
        }
      } else {
        // Update existing report
        _submittedReport = report;
        await viewModel.updateReport(report);

        // Para actualización: si las fotos fueron modificadas por el usuario,
        // comparamos las rutas antiguas con las nuevas y eliminamos solo las fotos
        // físicas que cambiaron. Luego actualizamos los registros en la BD.
        if (photosChanged) {
          final photoViewModel = ref.read(photoViewModelProvider.notifier);

          // Cargar fotos existentes ANTES de actualizar
          await photoViewModel.loadByWorkReportId(report.id);
          final existingPhotos = ref.read(photoViewModelProvider).photos;

          // Comparar y eliminar solo las fotos físicas que cambiaron
          for (int i = 0; i < photos.length && i < existingPhotos.length; i++) {
            final newPhoto = photos[i];
            final oldPhoto = existingPhotos[i];

            // Comparar beforeWorkPhotoPath
            if (oldPhoto.beforeWorkPhotoPath != null &&
                oldPhoto.beforeWorkPhotoPath != newPhoto.beforeWorkPhotoPath) {
              try {
                await photoViewModel.storageService.deletePhoto(
                  oldPhoto.beforeWorkPhotoPath!,
                );
              } catch (e) {}
            }

            // Comparar photoPath (after)
            if (oldPhoto.photoPath != null &&
                oldPhoto.photoPath != newPhoto.photoPath) {
              try {
                await photoViewModel.storageService.deletePhoto(
                  oldPhoto.photoPath!,
                );
              } catch (e) {}
            }
          }

          // Ahora eliminar todos los registros de BD
          await photoViewModel.deleteByWorkReportId(report.id);

          // Crear nuevos registros con las rutas actuales
          for (final photo in photos) {
            if (photo.hasValidPhotos) {
              await photoViewModel.createPhoto(
                Photo(
                  workReportId: report.id,
                  beforeWorkPhotoPath: photo.beforeWorkPhotoPath,
                  photoPath: photo.photoPath,
                  beforeWorkDescripcion: photo.beforeWorkDescripcion,
                  descripcion: photo.descripcion,
                ),
              );
            }
          }
        } else {
          // Si no hubo cambios en las fotos (rutas), pero puede haber cambios
          // en las descripciones. Actualizamos las descripciones manteniendo las rutas.
          final photoViewModel = ref.read(photoViewModelProvider.notifier);

          // Cargar fotos existentes del reporte
          await photoViewModel.loadByWorkReportId(report.id);
          final existingPhotos = ref.read(photoViewModelProvider).photos;

          // Actualizar descripciones si cambiaron
          if (photos.isNotEmpty && existingPhotos.isNotEmpty) {
            for (
              int i = 0;
              i < photos.length && i < existingPhotos.length;
              i++
            ) {
              final formPhoto = photos[i];
              final existingPhoto = existingPhotos[i];

              // Solo actualizar si las descripciones cambiaron
              if (formPhoto.descripcion != existingPhoto.descripcion ||
                  formPhoto.beforeWorkDescripcion !=
                      existingPhoto.beforeWorkDescripcion) {
                final updatedPhoto = Photo(
                  id: existingPhoto.id,
                  workReportId: report.id,
                  beforeWorkPhotoPath:
                      existingPhoto.beforeWorkPhotoPath, // Preserve original
                  photoPath: existingPhoto.photoPath, // Preserve original
                  beforeWorkDescripcion: formPhoto.beforeWorkDescripcion,
                  descripcion: formPhoto.descripcion,
                  createdAt: existingPhoto.createdAt,
                  updatedAt: DateTime.now(),
                );
                await photoViewModel.updatePhoto(updatedPhoto);
              }
            }
          }
        }
      }

      // ✅ All async operations complete - NOW we can navigate back safely
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.workReport != null
                  ? 'Report updated successfully'
                  : 'Report created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(_submittedReport);
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