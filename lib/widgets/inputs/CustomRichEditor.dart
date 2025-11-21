import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class CustomRichEditor extends StatelessWidget {
  final String label;
  final HtmlEditorController controller;
  final double height;
  final String hintText;
  final String? initialText;
  
  // Nuevas propiedades para mayor flexibilidad
  final Function(String?)? onChanged; // Callback vital para formularios
  final Color backgroundColor;
  final Color toolbarColor;
  final Color labelColor;

  const CustomRichEditor({
    super.key,
    required this.label,
    required this.controller,
    this.height = 350,
    this.hintText = 'Escribe aquí...',
    this.initialText,
    this.onChanged,
    // Colores por defecto (Tu paleta Dark)
    this.backgroundColor = const Color(0xFF1E1E1E), 
    this.toolbarColor = const Color(0xFF2C2C2C),
    this.labelColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    // Convertimos el color de Flutter a Hex String para CSS
    final String bgHex = '#${backgroundColor.value.toRadixString(16).substring(2)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LABEL ---
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),

        // --- EDITOR CONTAINER ---
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              // Sutil sombra para dar profundidad
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: HtmlEditor(
            controller: controller,
            
            // --- OPCIONES DEL EDITOR ---
            htmlEditorOptions: HtmlEditorOptions(
              hint: hintText,
              initialText: initialText,
              darkMode: true, // Mantiene el modo oscuro base
              
              // Inyección dinámica del color de fondo
              customOptions: "summernote.options.modules.editor.background = '$bgHex';",
              
              shouldEnsureVisible: true,
              adjustHeightForKeyboard: false, // A veces 'true' causa saltos en listas largas, probar según el caso
              autoAdjustHeight: false, // Importante para respetar tu 'height' fijo
            ),

            // --- CALLBACKS (La mejora clave) ---
            callbacks: Callbacks(
              onChangeContent: (String? changed) {
                if (onChanged != null) {
                  onChanged!(changed);
                }
              },
              onInit: () {
                // Opcional: Configurar el editor para que use la fuente del sistema si es necesario
                controller.setFullScreen(); // Ejemplo de acción al iniciar
              },
            ),

            // --- TOOLBAR ---
            htmlToolbarOptions: HtmlToolbarOptions(
              toolbarPosition: ToolbarPosition.aboveEditor,
              toolbarType: ToolbarType.nativeScrollable,
              
              // Estilos dinámicos
              buttonColor: labelColor,
              buttonFocusColor: Colors.white,
              buttonFillColor: Colors.transparent,
              dropdownBackgroundColor: toolbarColor,
              textStyle: const TextStyle(color: Colors.white, fontSize: 16),
              
              // Configuración optimizada de botones para móvil (menos desorden)
              defaultToolbarButtons: [
                const StyleButtons(),
                const FontButtons(clearAll: false, superscript: false, subscript: false), // Simplificado
                const ColorButtons(),
                const ListButtons(listStyles: false),
                const ParagraphButtons(textDirection: false, lineHeight: false, caseConverter: false),
                // Insertar imágenes/tablas puede ser pesado en móvil, valora si dejarlos
                const InsertButtons(audio: false, video: false, otherFile: false, table: true, picture: true), 
              ],
              initiallyExpanded: true,
            ),

            // --- OPCIONES ESTRUCTURALES ---
            otherOptions: OtherOptions(
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor, 
              ),
            ),
          ),
        ),
      ],
    );
  }
}