import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/work_report.dart';
import '../models/photo.dart';
import '../viewmodels/photo_viewmodel.dart';
import '../providers/app_providers.dart';
import '../widgets/photo_list_widget.dart';

/// Página para mostrar los detalles de un reporte de trabajo
/// Incluye información del reporte y galería de fotos
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
  @override
  void initState() {
    super.initState();
    // Cargar las fotos del reporte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(photoViewModelProvider.notifier).loadByWorkReportId(widget.workReport.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final photoState = ref.watch(photoViewModelProvider);
    final photos = photoState.photos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.pushNamed(
                'edit-report',
                pathParameters: {'id': widget.workReport.id.toString()},
                extra: widget.workReport,
              ).then((_) {
                // Recargar fotos después de editar
                ref.read(photoViewModelProvider.notifier)
                  .loadByWorkReportId(widget.workReport.id);
              });
            },
            tooltip: 'Editar reporte',
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
              // Información básica del reporte
              _buildInfoCard(),
              const SizedBox(height: 24),

              // Horario
              _buildScheduleCard(),
              const SizedBox(height: 24),

              // Detalles adicionales
              if (_hasAdditionalDetails()) ...[
                _buildAdditionalDetailsCard(),
                const SizedBox(height: 24),
              ],

              // Sección de fotografías
              _buildPhotosSection(photos, photoState.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A8D8D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Color(0xFF2A8D8D),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.workReport.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reporte #${widget.workReport.id}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow(
              icon: Icons.work_outline,
              label: 'Descripción',
              value: widget.workReport.description,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Empleado',
              value: 'ID: ${widget.workReport.employeeId}',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.folder_outlined,
              label: 'Proyecto',
              value: 'ID: ${widget.workReport.projectId}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFF2A8D8D)),
                SizedBox(width: 8),
                Text(
                  'Horario de Trabajo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Fecha del reporte',
              value: _formatDate(widget.workReport.reportDate),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimeChip(
                    label: 'Inicio',
                    time: _formatTime(widget.workReport.startTime),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeChip(
                    label: 'Fin',
                    time: _formatTime(widget.workReport.endTime),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Duración: ${_calculateDuration()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2A8D8D)),
                SizedBox(width: 8),
                Text(
                  'Detalles Adicionales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.workReport.suggestions != null && widget.workReport.suggestions!.isNotEmpty)
              _buildDetailSection('Sugerencias', widget.workReport.suggestions!),
            if (widget.workReport.tools != null && widget.workReport.tools!.isNotEmpty)
              _buildDetailSection('Herramientas', widget.workReport.tools!),
            if (widget.workReport.personnel != null && widget.workReport.personnel!.isNotEmpty)
              _buildDetailSection('Personal', widget.workReport.personnel!),
            if (widget.workReport.materials != null && widget.workReport.materials!.isNotEmpty)
              _buildDetailSection('Materiales', widget.workReport.materials!),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection(List<Photo> photos, PhotoStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_library, color: Color(0xFF2A8D8D)),
            const SizedBox(width: 8),
            const Text(
              'Fotografías del Trabajo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (photos.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A8D8D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${photos.length} ${photos.length == 1 ? 'foto' : 'fotos'}',
                  style: const TextStyle(
                    color: Color(0xFF2A8D8D),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (status == PhotoStatus.loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (status == PhotoStatus.error)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al cargar las fotos',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(photoViewModelProvider.notifier).loadByWorkReportId(widget.workReport.id);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        else
          PhotoListWidget(
            photos: photos,
            onRefresh: () {
              ref.read(photoViewModelProvider.notifier).loadByWorkReportId(widget.workReport.id);
            },
            onPhotoTap: (photo) {
              // TODO: Mostrar foto en pantalla completa
            },
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChip({
    required String label,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A8D8D),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAdditionalDetails() {
    return (widget.workReport.suggestions != null && widget.workReport.suggestions!.isNotEmpty) ||
           (widget.workReport.tools != null && widget.workReport.tools!.isNotEmpty) ||
           (widget.workReport.personnel != null && widget.workReport.personnel!.isNotEmpty) ||
           (widget.workReport.materials != null && widget.workReport.materials!.isNotEmpty);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration() {
    final duration = widget.workReport.endTime.difference(widget.workReport.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours == 0) {
      return '$minutes min';
    } else if (minutes == 0) {
      return '$hours ${hours == 1 ? 'hora' : 'horas'}';
    } else {
      return '$hours ${hours == 1 ? 'hora' : 'horas'} $minutes min';
    }
  }
}
