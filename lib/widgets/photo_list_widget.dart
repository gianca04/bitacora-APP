import 'package:flutter/material.dart';
import '../models/photo.dart';
// Asumimos que este widget existe en tu proyecto, o usa un Image.network/file básico
import 'photo_display_widget.dart'; 
import '../config/app_colors.dart'; 

class PhotoListWidget extends StatelessWidget {
  final List<Photo> photos;
  final VoidCallback? onRefresh;
  final Function(Photo)? onPhotoTap;
  final bool isDarkTheme; // Opcional, para adaptar fondos

  const PhotoListWidget({
    super.key,
    required this.photos,
    this.onRefresh,
    this.onPhotoTap,
    this.isDarkTheme = true, // Asumiendo el tema oscuro por defecto de los anteriores
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return _buildEmptyState();
    }

    // Usamos un Column en lugar de ListView con shrinkWrap para mejor performance
    // si este widget ya está dentro de un scroll view padre.
    return Column(
      children: photos.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _EvidenceCard(
            photo: entry.value,
            index: entry.key,
            onTap: () => onPhotoTap?.call(entry.value),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hide_image_outlined, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Sin evidencia fotográfica',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No se han adjuntado fotos a este reporte.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget Privado: Tarjeta de Evidencia Individual
/// Encapsula la lógica de visualización de una tarea (Antes/Después)
class _EvidenceCard extends StatelessWidget {
  final Photo photo;
  final int index;
  final VoidCallback onTap;

  const _EvidenceCard({
    required this.photo,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasBefore = photo.beforeWorkPhotoPath?.isNotEmpty ?? false;
    final hasAfter = photo.photoPath?.isNotEmpty ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Para que las imágenes respeten los bordes
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            // --- Header de la Tarjeta ---
            _buildHeader(),

            // --- Cuerpo de Imágenes ---
            if (hasBefore && hasAfter)
              // Si hay ambas, mostramos comparación Split
              _buildSplitComparison(photo.beforeWorkPhotoPath!, photo.photoPath!)
            else if (hasBefore)
               _buildSingleImage(photo.beforeWorkPhotoPath!, true)
            else if (hasAfter)
               _buildSingleImage(photo.photoPath!, false),

            // --- Footer con Descripciones ---
            if (hasBefore || hasAfter)
              _buildDescriptionFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                ),
                child: Text(
                  'TAREA #${index + 1}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (photo.createdAt != null)
                Text(
                  _formatDate(photo.createdAt!),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  // Layout para cuando hay ANTES y DESPUÉS (Estilo "Split Screen")
  Widget _buildSplitComparison(String beforeCtx, String afterCtx) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: _buildImageSection(
              path: beforeCtx, 
              label: 'ANTES', 
              labelColor: Colors.amber,
              isLeft: true
            ),
          ),
          Container(width: 1, color: AppColors.backgroundDark), // Divisor delgado
          Expanded(
            child: _buildImageSection(
              path: afterCtx, 
              label: 'DESPUÉS', 
              labelColor: AppColors.secondary, // Verde azulado
              isLeft: false
            ),
          ),
        ],
      ),
    );
  }

  // Layout para una sola imagen (full width)
  Widget _buildSingleImage(String path, bool isBefore) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: _buildImageSection(
        path: path,
        label: isBefore ? 'ESTADO INICIAL' : 'RESULTADO FINAL',
        labelColor: isBefore ? Colors.amber : AppColors.secondary,
        isLeft: true, // No afecta en single mode
        isSingle: true,
      ),
    );
  }

  Widget _buildImageSection({
    required String path, 
    required String label, 
    required Color labelColor,
    required bool isLeft,
    bool isSingle = false,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. La Imagen
        PhotoDisplayWidget(
          photoPath: path,
          fit: BoxFit.cover,
          // height/width controlados por el padre
        ),
        
        // 2. Gradiente para legibilidad de etiqueta
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 3. Etiqueta (Badge)
        Positioned(
          top: 12,
          left: isSingle ? 16 : (isLeft ? 12 : null), // Ajuste fino de posición
          right: isSingle ? null : (isLeft ? null : 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: labelColor.withOpacity(0.8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: labelColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionFooter(BuildContext context) {
    final beforeDesc = photo.beforeWorkDescripcion;
    final afterDesc = photo.descripcion;
    final hasBoth = (beforeDesc?.isNotEmpty ?? false) && (afterDesc?.isNotEmpty ?? false);

    return Container(
      color: AppColors.backgroundDark.withOpacity(0.3), // Fondo sutil para texto
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (beforeDesc?.isNotEmpty ?? false)
            _buildRichDescription('Antes:', beforeDesc!, Colors.amber),
          
          if (hasBoth) const SizedBox(height: 8), // Separación si hay ambos

          if (afterDesc?.isNotEmpty ?? false)
            _buildRichDescription('Después:', afterDesc!, AppColors.secondary),
        ],
      ),
    );
  }

  Widget _buildRichDescription(String label, String text, Color color) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.white70), // Base style
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          TextSpan(text: text),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Lógica simplificada y limpia
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Hoy, ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}';
  }
}