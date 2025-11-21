import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

// Nuevo Widget Ligero para mostrar preview de HTML
class RichTextPreviewField extends StatelessWidget {
  final String label;
  final String content;
  final String hint;
  final VoidCallback onTap;

  const RichTextPreviewField({
    super.key, // Agregado super.key para buenas prácticas
    required this.label,
    required this.content,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Algunos editores guardan "<p></p>" o "<br>" cuando están "vacíos".
    // Limpiamos tags básicos para verificar si realmente hay texto visible.
    final hasContent = content
        .replaceAll(RegExp(r'<[^>]*>|&nbsp;|\s'), '')
        .isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 100),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: hasContent
                ? HtmlWidget(
                    content,
                    // Personalizamos el estilo base para que se vea bien en fondo oscuro
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4, // Mejor legibilidad
                    ),
                    // Personalización de estilos específicos si es necesario
                    customStylesBuilder: (element) {
                      if (element.localName == 'li') {
                        return {'margin-bottom': '4px'};
                      }
                      return null;
                    },
                    // Renderizar loading si hay imágenes remotas
                    onErrorBuilder: (context, element, error) =>
                        const Icon(Icons.broken_image, color: Colors.grey),
                    onLoadingBuilder: (context, element, loadingProgress) =>
                        const CircularProgressIndicator.adaptive(),
                  )
                : Text(
                    hint,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}