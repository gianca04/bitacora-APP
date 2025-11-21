import 'package:flutter/material.dart';
import 'package:bitacora/models/work_report.dart';
import 'package:bitacora/models/work_report_api_models.dart';
import '../config/app_colors.dart';

// [SocialImageGrid SE MANTIENE IGUAL, NO ES NECESARIO CAMBIARLO]
// ... (Copia la clase SocialImageGrid del código anterior aquí) ...
class SocialImageGrid extends StatelessWidget {
  final List<String> imageUrls;

  const SocialImageGrid({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    final displayCount = imageUrls.length > 4 ? 4 : imageUrls.length;
    final displayImages = imageUrls.sublist(0, displayCount);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildGrid(displayImages, imageUrls.length),
    );
  }

  Widget _buildGrid(List<String> images, int totalCount) {
    if (images.length == 1) {
      return _buildImage(images[0], isFull: true);
    } else if (images.length == 2) {
      return Row(children: [Expanded(child: _buildImage(images[0])), const SizedBox(width: 2), Expanded(child: _buildImage(images[1]))]);
    } else if (images.length == 3) {
      return Row(children: [
        Expanded(child: _buildImage(images[0], isFull: true)),
        const SizedBox(width: 2),
        Expanded(child: Column(children: [Expanded(child: _buildImage(images[1])), const SizedBox(height: 2), Expanded(child: _buildImage(images[2]))]))
      ]);
    } else {
      return Column(children: [
        Expanded(child: Row(children: [Expanded(child: _buildImage(images[0])), const SizedBox(width: 2), Expanded(child: _buildImage(images[1]))])),
        const SizedBox(height: 2),
        Expanded(child: Row(children: [Expanded(child: _buildImage(images[2])), const SizedBox(width: 2), Expanded(child: _buildImage(images[3], remaining: totalCount > 4 ? totalCount - 4 : 0))]))
      ]);
    }
  }

  Widget _buildImage(String url, {bool isFull = false, int remaining = 0}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url, fit: BoxFit.cover,
          loadingBuilder: (ctx, child, prog) => prog == null ? child : Container(color: Colors.grey[900]),
          errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[850], child: const Icon(Icons.broken_image, color: Colors.grey)),
        ),
        if (remaining > 0) Container(color: Colors.black54, child: Center(child: Text('+$remaining', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
      ],
    );
  }
}

// =============================================================================
// 2. WIDGET BASE: TARJETA SOCIAL MEJORADA (Más Info)
// =============================================================================
class _SocialFeedCard extends StatelessWidget {
  final String avatarLetter;
  final String authorName;
  final String date;
  final String projectName; // NUEVO: Campo explícito para el proyecto
  final String reportTitle; // NUEVO: Campo explícito para el título del reporte
  final String description;
  final List<String> images;
  final bool isLocal;
  final VoidCallback onTap;
  final Widget? actionButtons;

  const _SocialFeedCard({
    required this.avatarLetter,
    required this.authorName,
    required this.date,
    required this.projectName,
    required this.reportTitle,
    required this.description,
    required this.images,
    required this.isLocal,
    required this.onTap,
    this.actionButtons,
  });

  String _stripHtml(String htmlString) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').replaceAll('&nbsp;', ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16), // Un poco más de padding general
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderDark.withOpacity(0.5), width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AVATAR ---
            CircleAvatar(
              radius: 22,
              backgroundColor: isLocal ? AppColors.primary.withOpacity(0.2) : Colors.blueGrey.withOpacity(0.2),
              child: Text(
                avatarLetter,
                style: TextStyle(
                  color: isLocal ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // --- CONTENIDO ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. METADATA SUPERIOR: Autor y Fecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(fontSize: 15, color: Colors.white),
                            children: [
                              TextSpan(
                                text: authorName,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: ' · $date',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isLocal)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: const Text(
                            "Borrador",
                            style: TextStyle(fontSize: 10, color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // 2. CONTEXTO: Nombre del Proyecto (Badge estilo etiqueta)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.folder_open_rounded, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            projectName,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 3. TÍTULO DEL REPORTE (Bien definido)
                  Text(
                    reportTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Título en blanco brillante
                      height: 1.2,
                    ),
                  ),

                  // 4. DESCRIPCIÓN (Si existe)
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _stripHtml(description),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400, // Descripción un poco más apagada
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // 5. MEDIA
                  SocialImageGrid(imageUrls: images),

                  // 6. ACCIONES (Footer)
                  if (actionButtons != null) ...[
                    const SizedBox(height: 12),
                    actionButtons!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 3. IMPLEMENTACIÓN: TARJETA DE SERVIDOR
// =============================================================================
class ServerReportCard extends StatelessWidget {
  final WorkReportData report;
  final VoidCallback onTap;

  const ServerReportCard({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Extraer imágenes
    List<String> extractImages() {
      final List<String> urls = [];
      if (report.photos != null) {
        for (var photo in report.photos!) {
          if (photo.beforeWork?.photoUrl != null) urls.add(photo.beforeWork!.photoUrl!);
          if (photo.afterWork?.photoUrl != null) urls.add(photo.afterWork!.photoUrl!);
        }
      }
      return urls;
    }

    return _SocialFeedCard(
      avatarLetter: report.employee.fullName.isNotEmpty ? report.employee.fullName[0] : 'U',
      authorName: report.employee.fullName, // Autor
      date: _formatDate(report.reportDate), // Fecha formateada
      projectName: report.project.name, // Proyecto (Contexto)
      reportTitle: report.name, // Título del reporte (Destacado)
      description: report.description ?? "", // Cuerpo
      images: extractImages(),
      isLocal: false,
      onTap: onTap,
      actionButtons: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icono tipo "Comentario" o "Ver más" para indicar interacción
          Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textSecondary),
          Icon(Icons.share_outlined, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
      // Formato: 18 nov 2025
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (_) {
      return dateString;
    }
  }
}

// =============================================================================
// 4. IMPLEMENTACIÓN: TARJETA LOCAL
// =============================================================================
class LocalReportCard extends StatelessWidget {
  final WorkReport report;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LocalReportCard({
    super.key,
    required this.report,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _SocialFeedCard(
      avatarLetter: 'T',
      authorName: "Tú",
      date: "${report.reportDate.day}/${report.reportDate.month}/${report.reportDate.year}",
      projectName: "Proyecto ID: ${report.projectId}", // Info disponible en local
      reportTitle: report.name,
      description: report.description,
      images: const [], // Opcional: Manejo de archivos locales
      isLocal: true,
      onTap: onTap,
      actionButtons: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _ActionButton(
            icon: Icons.edit_outlined,
            label: "Editar",
            color: AppColors.primary,
            onTap: onEdit,
          ),
          const SizedBox(width: 16),
          _ActionButton(
            icon: Icons.delete_outline,
            label: "Borrar",
            color: AppColors.error,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

// Botón de acción pequeño con texto opcional
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(label!, style: TextStyle(fontSize: 12, color: color)),
          ],
        ],
      ),
    );
  }
}