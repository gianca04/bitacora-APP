import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/work_report.dart';
import '../models/photo.dart';
import '../viewmodels/photo_viewmodel.dart';
import '../providers/app_providers.dart';
import '../widgets/photo_list_widget.dart';

/// Página para mostrar los detalles de un reporte de trabajo
/// Versión simplificada sin diseño UI (Raw)
class WorkReportDetailPage extends ConsumerStatefulWidget {
  final WorkReport workReport;

  const WorkReportDetailPage({
    super.key,
    required this.workReport,
  });

  @override
  ConsumerState<WorkReportDetailPage> createState() => _WorkReportDetailPageState();
}

class _WorkReportDetailPageState extends ConsumerState<WorkReportDetailPage> {
  late WorkReport _report;
  
  @override
  void initState() {
    super.initState();
    // Inicializar reporte mutable y cargar fotos
    _report = widget.workReport;
    
    // 🔍 LOG DETALLADO: Mantengo tu lógica de logs intacta
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('📄 WORK REPORT DETAIL PAGE - initState');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('WorkReport ID: ${_report.id}');
    debugPrint('Name: ${_report.name}');
    // ... (resto de tus logs originales)
    debugPrint('Updated At: ${_report.updatedAt}');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('📥 Loading photos for WorkReport ID: ${_report.id}');
      ref.read(photoViewModelProvider.notifier).loadByWorkReportId(_report.id).then((_) {
        final photoState = ref.read(photoViewModelProvider);
        // Mantengo logs de fotos
        debugPrint('Total photos: ${photoState.photos.length}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final photoState = ref.watch(photoViewModelProvider);
    final photos = photoState.photos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        // Eliminado background color
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Lógica de navegación intacta
              context.pushNamed(
                'edit-report',
                pathParameters: {'id': _report.id.toString()},
                extra: _report,
              ).then((value) {
                if (value is WorkReport) {
                  setState(() {
                    _report = value;
                  });
                }
                // Recargar fotos
                ref.read(photoViewModelProvider.notifier)
                  .loadByWorkReportId(_report.id);
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(photoViewModelProvider.notifier).loadByWorkReportId(widget.workReport.id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- INFORMACIÓN BÁSICA ---
              const Text('INFORMACIÓN GENERAL', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('ID: ${_report.id}'),
              Text('Nombre: ${_report.name}'),
              Text('Descripción: ${_report.description}'),
              Text('Empleado ID: ${_report.employeeId}'),
              Text('Proyecto ID: ${_report.projectId}'),
              
              const Divider(height: 30),

              // --- HORARIO ---
              const Text('HORARIO', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Fecha: ${_formatDate(widget.workReport.reportDate)}'),
              Text('Inicio: ${_formatTime(widget.workReport.startTime)}'),
              Text('Fin: ${_formatTime(widget.workReport.endTime)}'),
              Text('Duración: ${_calculateDuration()}'),

              const Divider(height: 30),

              // --- DETALLES ADICIONALES ---
              if (_hasAdditionalDetails()) ...[
                 const Text('DETALLES ADICIONALES', style: TextStyle(fontWeight: FontWeight.bold)),
                 const SizedBox(height: 10),
                 if (_report.suggestions?.isNotEmpty ?? false) 
                   Text('Sugerencias: ${_report.suggestions}'),
                 if (_report.tools?.isNotEmpty ?? false) 
                   Text('Herramientas: ${_report.tools}'),
                 if (_report.personnel?.isNotEmpty ?? false) 
                   Text('Personal: ${_report.personnel}'),
                 if (_report.materials?.isNotEmpty ?? false) 
                   Text('Materiales: ${_report.materials}'),
                 
                 const Divider(height: 30),
              ],

              // --- FOTOS ---
              Text('FOTOGRAFÍAS (${photos.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              _buildPhotosState(photos, photoState.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosState(List<Photo> photos, PhotoStatus status) {
    if (status == PhotoStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (status == PhotoStatus.error) {
      return Column(
        children: [
          const Text('Error al cargar fotos', style: TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: () {
              ref.read(photoViewModelProvider.notifier).loadByWorkReportId(widget.workReport.id);
            },
            child: const Text('Reintentar'),
          ),
        ],
      );
    } else {
      return PhotoListWidget(
        photos: photos,
        onRefresh: () {
          ref.read(photoViewModelProvider.notifier).loadByWorkReportId(widget.workReport.id);
        },
        onPhotoTap: (photo) {
          // TODO: Mostrar foto en pantalla completa
        },
      );
    }
  }

  // --- HELPERS SIMPLIFICADOS ---
  // Solo devuelven Strings, sin widgets de UI

  bool _hasAdditionalDetails() {
    return (widget.workReport.suggestions?.isNotEmpty ?? false) ||
           (widget.workReport.tools?.isNotEmpty ?? false) ||
           (widget.workReport.personnel?.isNotEmpty ?? false) ||
           (widget.workReport.materials?.isNotEmpty ?? false);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration() {
    final duration = widget.workReport.endTime.difference(widget.workReport.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}