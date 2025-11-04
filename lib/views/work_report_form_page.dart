import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    
    // 🔍 LOG DETALLADO: WorkReport recibido al inicializar el formulario
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('📝 WORK REPORT FORM PAGE - initState');
    debugPrint('═══════════════════════════════════════════════════════════');
    if (widget.workReport != null) {
      final report = widget.workReport!;
      debugPrint('MODE: EDIT');
      debugPrint('WorkReport ID: ${report.id}');
      debugPrint('Name: ${report.name}');
      debugPrint('Description: ${report.description}');
      debugPrint('Employee ID: ${report.employeeId}');
      debugPrint('Project ID: ${report.projectId}');
      debugPrint('Start Time: ${report.startTime}');
      debugPrint('End Time: ${report.endTime}');
      debugPrint('Report Date: ${report.reportDate}');
      debugPrint('Suggestions: ${report.suggestions}');
      debugPrint('Tools: ${report.tools}');
      debugPrint('Personnel: ${report.personnel}');
      debugPrint('Materials: ${report.materials}');
      debugPrint('Has Supervisor Signature: ${report.supervisorSignature != null}');
      debugPrint('Has Manager Signature: ${report.managerSignature != null}');
      debugPrint('Created At: ${report.createdAt}');
      debugPrint('Updated At: ${report.updatedAt}');
    } else {
      debugPrint('MODE: CREATE NEW');
    }
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('');
    
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
    
    debugPrint('');
    debugPrint('───────────────────────────────────────────────────────────');
    debugPrint('📥 LOADING EXISTING PHOTOS');
    debugPrint('───────────────────────────────────────────────────────────');
    debugPrint('WorkReport ID: ${widget.workReport!.id}');
    
    setState(() {
      _isLoadingPhotos = true;
    });

    try {
      await ref.read(photoViewModelProvider.notifier)
        .loadByWorkReportId(widget.workReport!.id);
      
      if (!mounted) return;
      
      final photoState = ref.read(photoViewModelProvider);
      debugPrint('✅ Loaded ${photoState.photos.length} existing photos from database');
      
      for (var i = 0; i < photoState.photos.length; i++) {
        final photo = photoState.photos[i];
        debugPrint('');
        debugPrint('   📸 Photo $i:');
        debugPrint('      ID: ${photo.id}');
        debugPrint('      WorkReport ID: ${photo.workReportId}');
        debugPrint('      Before Photo: ${photo.beforeWorkPhotoPath ?? "null"}');
        debugPrint('      After Photo: ${photo.photoPath ?? "null"}');
        debugPrint('      Before Description: ${photo.beforeWorkDescripcion ?? "null"}');
        debugPrint('      After Description: ${photo.descripcion ?? "null"}');
        debugPrint('      Created At: ${photo.createdAt}');
        debugPrint('      Updated At: ${photo.updatedAt}');
      }
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('');
      
      setState(() {
        _existingPhotos = photoState.photos;
        _isLoadingPhotos = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading photos: $e');
      debugPrint('───────────────────────────────────────────────────────────');
      debugPrint('');
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
    // 🔍 LOG DETALLADO: Datos recibidos del formulario
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('💾 HANDLE SUBMIT - Data from form');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('WorkReport received:');
    debugPrint('   ID: ${report.id}');
    debugPrint('   Name: ${report.name}');
    debugPrint('   Description: ${report.description}');
    debugPrint('   Employee ID: ${report.employeeId}');
    debugPrint('   Project ID: ${report.projectId}');
    debugPrint('   Start Time: ${report.startTime}');
    debugPrint('   End Time: ${report.endTime}');
    debugPrint('   Report Date: ${report.reportDate}');
    debugPrint('   Suggestions: ${report.suggestions}');
    debugPrint('   Tools: ${report.tools}');
    debugPrint('   Personnel: ${report.personnel}');
    debugPrint('   Materials: ${report.materials}');
    debugPrint('   Has Supervisor Signature: ${report.supervisorSignature != null}');
    debugPrint('   Has Manager Signature: ${report.managerSignature != null}');
    debugPrint('');
    debugPrint('Photos: ${photos.length} photos');
    debugPrint('Photos Changed: $photosChanged');
    debugPrint('Mode: ${widget.workReport == null ? "CREATE" : "UPDATE"}');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('');
    
    try {
      final viewModel = ref.read(workReportViewModelProvider.notifier);

      if (widget.workReport == null) {
        // Create new report
        debugPrint('📝 Creating new report...');
        // store the submitted report so we can return it later
        _submittedReport = report;
        final reportId = await viewModel.createReport(report);
        
        // Create associated photos if report was created successfully
        if (reportId != null) {
          debugPrint('✅ Report created with ID: $reportId');
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
            } else {
              debugPrint('⚠️ Skipping photo without valid paths');
            }
          }
        }
      } else {
        // Update existing report
        debugPrint('✏️ Updating existing report...');
        _submittedReport = report;
        await viewModel.updateReport(report);
        debugPrint('✅ Report updated in database');

        // Para actualización: si las fotos fueron modificadas por el usuario,
        // comparamos las rutas antiguas con las nuevas y eliminamos solo las fotos
        // físicas que cambiaron. Luego actualizamos los registros en la BD.
        if (photosChanged) {
          debugPrint('🔄 Photos changed - updating photo records');
          final photoViewModel = ref.read(photoViewModelProvider.notifier);
          
          // Cargar fotos existentes ANTES de actualizar
          await photoViewModel.loadByWorkReportId(report.id);
          final existingPhotos = ref.read(photoViewModelProvider).photos;
          
          debugPrint('   Existing photos count: ${existingPhotos.length}');
          debugPrint('   New photos count: ${photos.length}');
          
          // Comparar y eliminar solo las fotos físicas que cambiaron
          for (int i = 0; i < photos.length && i < existingPhotos.length; i++) {
            final newPhoto = photos[i];
            final oldPhoto = existingPhotos[i];
            
            debugPrint('   📸 Comparing photo $i:');
            debugPrint('      Old beforePath: ${oldPhoto.beforeWorkPhotoPath}');
            debugPrint('      New beforePath: ${newPhoto.beforeWorkPhotoPath}');
            debugPrint('      Old afterPath: ${oldPhoto.photoPath}');
            debugPrint('      New afterPath: ${newPhoto.photoPath}');
            
            // Comparar beforeWorkPhotoPath
            if (oldPhoto.beforeWorkPhotoPath != null && 
                oldPhoto.beforeWorkPhotoPath != newPhoto.beforeWorkPhotoPath) {
              debugPrint('      🗑️ Deleting old BEFORE photo: ${oldPhoto.beforeWorkPhotoPath}');
              try {
                await photoViewModel.storageService.deletePhoto(oldPhoto.beforeWorkPhotoPath!);
                debugPrint('      ✅ Old BEFORE photo deleted');
              } catch (e) {
                debugPrint('      ⚠️ Error deleting old BEFORE photo: $e');
              }
            }
            
            // Comparar photoPath (after)
            if (oldPhoto.photoPath != null && 
                oldPhoto.photoPath != newPhoto.photoPath) {
              debugPrint('      🗑️ Deleting old AFTER photo: ${oldPhoto.photoPath}');
              try {
                await photoViewModel.storageService.deletePhoto(oldPhoto.photoPath!);
                debugPrint('      ✅ Old AFTER photo deleted');
              } catch (e) {
                debugPrint('      ⚠️ Error deleting old AFTER photo: $e');
              }
            }
          }
          
          // Ahora eliminar todos los registros de BD
          await photoViewModel.deleteByWorkReportId(report.id);
          debugPrint('   🗑️ Old photo records deleted from DB');

          // Crear nuevos registros con las rutas actuales
          for (final photo in photos) {
            if (photo.hasValidPhotos) {
              debugPrint('   Creating photo: beforePath=${photo.beforeWorkPhotoPath}, afterPath=${photo.photoPath}');
              await photoViewModel.createPhoto(
                Photo(
                  workReportId: report.id,
                  beforeWorkPhotoPath: photo.beforeWorkPhotoPath,
                  photoPath: photo.photoPath,
                  beforeWorkDescripcion: photo.beforeWorkDescripcion,
                  descripcion: photo.descripcion,
                ),
              );
              debugPrint('   ✅ Photo created in DB');
            } else {
              debugPrint('   ⚠️ Skipping photo without valid paths');
            }
          }
          debugPrint('   ✅ All photo records updated');
        } else {
          // Si no hubo cambios en las fotos (rutas), pero puede haber cambios
          // en las descripciones. Actualizamos las descripciones manteniendo las rutas.
          debugPrint('📝 Photos unchanged - checking descriptions');
          final photoViewModel = ref.read(photoViewModelProvider.notifier);
          
          // Cargar fotos existentes del reporte
          await photoViewModel.loadByWorkReportId(report.id);
          final existingPhotos = ref.read(photoViewModelProvider).photos;
          
          debugPrint('   Existing photos: ${existingPhotos.length}');
          debugPrint('   Form photos: ${photos.length}');
          
          // Actualizar descripciones si cambiaron
          if (photos.isNotEmpty && existingPhotos.isNotEmpty) {
            for (int i = 0; i < photos.length && i < existingPhotos.length; i++) {
              final formPhoto = photos[i];
              final existingPhoto = existingPhotos[i];
              
              // Solo actualizar si las descripciones cambiaron
              if (formPhoto.descripcion != existingPhoto.descripcion ||
                  formPhoto.beforeWorkDescripcion != existingPhoto.beforeWorkDescripcion) {
                debugPrint('   Updating descriptions for photo $i');
                final updatedPhoto = Photo(
                  id: existingPhoto.id,
                  workReportId: report.id,
                  beforeWorkPhotoPath: existingPhoto.beforeWorkPhotoPath, // Preserve original
                  photoPath: existingPhoto.photoPath, // Preserve original
                  beforeWorkDescripcion: formPhoto.beforeWorkDescripcion,
                  descripcion: formPhoto.descripcion,
                  createdAt: existingPhoto.createdAt,
                  updatedAt: DateTime.now(),
                );
                await photoViewModel.updatePhoto(updatedPhoto);
              }
            }
            debugPrint('   ✅ Descriptions updated');
          } else {
            debugPrint('   ℹ️ No description updates needed');
          }
        }
      }
      
      // ✅ All async operations complete - NOW we can navigate back safely
      if (context.mounted) {
        debugPrint('');
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('✅ ALL OPERATIONS COMPLETE - Returning to previous page');
        debugPrint('═══════════════════════════════════════════════════════════');
        if (_submittedReport != null) {
          debugPrint('Returning WorkReport:');
          debugPrint('   ID: ${_submittedReport!.id}');
          debugPrint('   Name: ${_submittedReport!.name}');
          debugPrint('   Description: ${_submittedReport!.description}');
          debugPrint('   Employee ID: ${_submittedReport!.employeeId}');
          debugPrint('   Project ID: ${_submittedReport!.projectId}');
          debugPrint('   Updated At: ${_submittedReport!.updatedAt}');
        } else {
          debugPrint('⚠️ _submittedReport is null!');
        }
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.workReport != null ? 'Report updated successfully' : 'Report created successfully'),
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
