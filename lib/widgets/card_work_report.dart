import 'package:flutter/material.dart';
import 'package:bitacora/models/work_report.dart';
import 'package:bitacora/models/work_report_api_models.dart';
import '../config/app_colors.dart';

// =============================================================================
// 1. GRID DE IMÁGENES (Estilo Red Social)
// =============================================================================
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildGrid(displayImages, imageUrls.length),
    );
  }

  Widget _buildGrid(List<String> images, int totalCount) {
    if (images.length == 1) {
      return _buildImage(images[0], isFull: true);
    } else if (images.length == 2) {
      return Row(children: [
        Expanded(child: _buildImage(images[0])),
        const SizedBox(width: 2),
        Expanded(child: _buildImage(images[1]))
      ]);
    } else if (images.length == 3) {
      return Row(children: [
        Expanded(child: _buildImage(images[0], isFull: true)),
        const SizedBox(width: 2),
        Expanded(
            child: Column(children: [
          Expanded(child: _buildImage(images[1])),
          const SizedBox(height: 2),
          Expanded(child: _buildImage(images[2]))
        ]))
      ]);
    } else {
      return Column(children: [
        Expanded(
            child: Row(children: [
          Expanded(child: _buildImage(images[0])),
          const SizedBox(width: 2),
          Expanded(child: _buildImage(images[1]))
        ])),
        const SizedBox(height: 2),
        Expanded(
            child: Row(children: [
          Expanded(child: _buildImage(images[2])),
          const SizedBox(width: 2),
          Expanded(
              child: _buildImage(images[3],
                  remaining: totalCount > 4 ? totalCount - 4 : 0))
        ]))
      ]);
    }
  }

  Widget _buildImage(String url, {bool isFull = false, int remaining = 0}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, prog) =>
              prog == null ? child : Container(color: Colors.grey[900]),
          errorBuilder: (ctx, err, stack) => Container(
              color: Colors.grey[850],
              child: const Icon(Icons.broken_image, color: Colors.grey)),
        ),
        if (remaining > 0)
          Container(
              color: Colors.black54,
              child: Center(
                  child: Text('+$remaining',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)))),
      ],
    );
  }
}

// =============================================================================
// 2. WIDGET BASE: TARJETA SOCIAL PRO (Diseño Unificado)
// =============================================================================
class _SocialFeedCard extends StatelessWidget {
  final String avatarLetter;
  final String authorName;
  final String date;
  final String projectName;
  final String reportTitle;
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
    // Color para el chip del proyecto (Turquesa/Secundario para destacar)
    final projectColor = AppColors.secondary;

    return InkWell(
      onTap: onTap,
      // Eliminamos bordes redondeados externos para full look de Feed continuo
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: AppColors.borderDark.withOpacity(0.4), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AVATAR (Columna Izquierda) ---
            CircleAvatar(
              radius: 20,
              backgroundColor: isLocal
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.white10,
              child: Text(
                avatarLetter,
                style: TextStyle(
                  color: isLocal ? AppColors.primary : Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // --- CONTENIDO (Columna Derecha) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER: Autor · Fecha · Badge Borrador
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          authorName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '· $date',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      if (isLocal) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 0.5),
                          ),
                          child: const Text("Borrador",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ],
                  ),

                  const SizedBox(height: 6),

                  // 2. CHIP DE PROYECTO (Contexto profesional)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: projectColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: projectColor.withOpacity(0.3), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_outlined,
                            size: 12, color: projectColor),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            projectName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: projectColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 3. TÍTULO DEL REPORTE
                  Text(
                    reportTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),

                  // 4. DESCRIPCIÓN CORTA
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _stripHtml(description),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // 5. GRID DE IMÁGENES (Si existen)
                  SocialImageGrid(imageUrls: images),

                  // 6. BOTONES DE ACCIÓN
                  if (actionButtons != null) ...[
                    const SizedBox(height: 10),
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
// 3. IMPLEMENTACIÓN: TARJETA SERVIDOR (NUBE)
// =============================================================================
class ServerReportCard extends StatelessWidget {
  final WorkReportData report;
  final VoidCallback onTap;

  const ServerReportCard(
      {super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    List<String> extractImages() {
      final List<String> urls = [];
      if (report.photos != null) {
        for (var photo in report.photos!) {
          if (photo.beforeWork?.photoUrl != null)
            urls.add(photo.beforeWork!.photoUrl!);
          if (photo.afterWork?.photoUrl != null)
            urls.add(photo.afterWork!.photoUrl!);
        }
      }
      return urls;
    }

    return _SocialFeedCard(
      avatarLetter: report.employee.fullName.isNotEmpty
          ? report.employee.fullName[0]
          : 'U',
      authorName: report.employee.fullName,
      date: _formatDate(report.reportDate),
      projectName: report.project.name,
      reportTitle: report.name,
      description: report.description ?? "",
      images: extractImages(),
      isLocal: false,
      onTap: onTap,
      actionButtons: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const months = [
        'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
      ];
      return "${date.day} ${months[date.month - 1]}";
    } catch (_) {
      return dateString;
    }
  }
}

// =============================================================================
// 4. IMPLEMENTACIÓN: TARJETA LOCAL (BORRADOR)
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
    // NOTA: Aquí logramos que se vea idéntica a la de nube.
    // Usamos "Tú" como autor y el ID del proyecto en el chip si no tenemos el nombre.
    
    return _SocialFeedCard(
      avatarLetter: 'T', // "T" de Tú (Usuario actual)
      authorName: "Tu Reporte",
      date: "${report.reportDate.day}/${report.reportDate.month}",
      projectName: "PROYECTO #${report.projectId}", // Misma estética de Chip
      reportTitle: report.name,
      description: report.description,
      images: const [], // Localmente pasamos vacío por ahora, mantiene el diseño limpio
      isLocal: true,
      onTap: onTap,
      actionButtons: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _ActionButton(
              icon: Icons.edit_outlined,
              label: "Editar",
              color: AppColors.primary, // Azul/Primary para acción positiva
              onTap: onEdit),
          const SizedBox(width: 16),
          _ActionButton(
              icon: Icons.delete_outline,
              label: "Borrar",
              color: Colors.red.shade400, // Rojo suave para borrar
              onTap: onDelete),
        ],
      ),
    );
  }
}

// =============================================================================
// 5. WIDGETS AUXILIARES
// =============================================================================

// Botón de acción con texto (Usado en Local para Editar/Borrar)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon,
      this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(6.0), // Área táctil cómoda
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(label!,
                  style: TextStyle(
                      fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}

// Botón icono simple (Usado en Servidor para Like/Share)
class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final String? count;

  const _SocialIconButton({required this.icon, this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          if (count != null) ...[
            const SizedBox(width: 4),
            Text(count!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ]
        ],
      ),
    );
  }
}