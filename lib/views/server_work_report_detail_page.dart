import 'package:flutter/material.dart';

import '../models/work_report_api_models.dart';

/// Page that displays complete details of a work report from the server
class ServerWorkReportDetailPage extends StatelessWidget {
  final WorkReportData report;

  const ServerWorkReportDetailPage({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Reporte'),
        backgroundColor: const Color(0xFF2A8D8D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with report name and date
            _buildHeader(),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information
                  _buildSection(
                    title: 'Información General',
                    icon: Icons.info_outline,
                    child: Column(
                      children: [
                        _buildInfoRow('Fecha del Reporte', report.reportDate, Icons.calendar_today),
                        _buildInfoRow('Horario', '${report.startTime} - ${report.endTime}', Icons.access_time),
                        _buildInfoRow('Estado', report.project.status, Icons.flag, 
                          valueColor: _getStatusColor(report.project.status)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Project Information
                  _buildSection(
                    title: 'Información del Proyecto',
                    icon: Icons.business,
                    child: Column(
                      children: [
                        _buildInfoRow('Proyecto', report.project.name, Icons.work),
                        _buildInfoRow('SubCliente', report.project.subClient.name, Icons.business_center),
                        if (report.project.client != null)
                          _buildInfoRow('Cliente', report.project.client!.name, Icons.account_circle),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Employee Information
                  _buildSection(
                    title: 'Información del Empleado',
                    icon: Icons.person,
                    child: Column(
                      children: [
                        _buildInfoRow('Nombre', report.employee.fullName, Icons.badge),
                        _buildInfoRow('Documento', report.employee.documentNumber, Icons.credit_card),
                        _buildInfoRow('Posición', report.employee.position.name, Icons.work_outline),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  _buildSection(
                    title: 'Descripción del Trabajo',
                    icon: Icons.description,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _stripHtmlTags(report.description),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Photos Section
                  if (report.summary.hasPhotos) ...[
                    _buildSection(
                      title: 'Fotografías (${report.summary.photosCount})',
                      icon: Icons.photo_library,
                      child: _buildPhotosGrid(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Signatures Status
                  if (report.summary.hasSignatures) ...[
                    _buildSection(
                      title: 'Firmas',
                      icon: Icons.draw,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Este reporte ha sido firmado',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Timestamps
                  _buildSection(
                    title: 'Registro',
                    icon: Icons.history,
                    child: Column(
                      children: [
                        if (report.timestamps.createdAt.isNotEmpty)
                          _buildInfoRow('Creado', _formatTimestamp(report.timestamps.createdAt), Icons.add_circle_outline),
                        if (report.timestamps.updatedAt.isNotEmpty)
                          _buildInfoRow('Última actualización', _formatTimestamp(report.timestamps.updatedAt), Icons.update),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A8D8D),
            const Color(0xFF2A8D8D).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Servidor',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tag, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'ID: ${report.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF2A8D8D)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A8D8D),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.grey.shade900,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid() {
    if (report.photos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay fotos disponibles'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: report.photos.length * 2, // Each photo has before and after
      itemBuilder: (context, index) {
        final photoIndex = index ~/ 2;
        final isAfter = index % 2 == 0;
        
        if (photoIndex >= report.photos.length) {
          return const SizedBox.shrink();
        }
        
        final photo = report.photos[photoIndex];
        final photoData = isAfter ? photo.afterWork : photo.beforeWork;
        
        if (!photoData.hasPhoto) {
          return const SizedBox.shrink();
        }

        return _buildPhotoCard(
          photoData.photoUrl!,
          isAfter ? 'Después' : 'Antes',
          photo.createdAt,
        );
      },
    );
  }

  Widget _buildPhotoCard(String imageUrl, String label, String? timestamp) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: label == 'Después' ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: label == 'Después' ? Colors.green.shade700 : Colors.orange.shade700,
              ),
            ),
          ),
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey.shade400, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'culminado':
      case 'completado':
      case 'finalizado':
        return Colors.green.shade700;
      case 'en progreso':
      case 'en proceso':
        return Colors.orange.shade700;
      case 'pendiente':
        return Colors.blue.shade700;
      case 'cancelado':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String _stripHtmlTags(String htmlString) {
    // Simple HTML tag remover
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString
        .replaceAll(exp, '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }
}
