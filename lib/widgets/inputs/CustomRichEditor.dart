import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class CustomRichEditor extends StatelessWidget {
  final String label;
  final HtmlEditorController controller;
  final double height;
  final String hintText;
  final String? initialText;
  
  final Function(String?)? onChanged;
  final VoidCallback? onInit; // 🔧 NUEVO: Callback cuando el editor se inicializa
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
    this.onInit, // 🔧 NUEVO
    this.backgroundColor = const Color(0xFF1E1E1E), 
    this.toolbarColor = const Color(0xFF2C2C2C),
    this.labelColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    final String bgHex = '#${backgroundColor.value.toRadixString(16).substring(2)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: HtmlEditor(
            controller: controller,
            
            htmlEditorOptions: HtmlEditorOptions(
              hint: hintText,
              initialText: initialText,
              darkMode: true,
              customOptions: "summernote.options.modules.editor.background = '$bgHex';",
              shouldEnsureVisible: true,
              adjustHeightForKeyboard: false,
              autoAdjustHeight: false,
            ),

            callbacks: Callbacks(
              onChangeContent: (String? changed) {
                if (onChanged != null) {
                  onChanged!(changed);
                }
              },
              onInit: () {
                // 🔧 NUEVO: Llamar al callback externo cuando se inicializa
                if (onInit != null) {
                  onInit!();
                }
              },
            ),

            htmlToolbarOptions: HtmlToolbarOptions(
              toolbarPosition: ToolbarPosition.aboveEditor,
              toolbarType: ToolbarType.nativeScrollable,
              
              buttonColor: labelColor,
              buttonFocusColor: Colors.white,
              buttonFillColor: Colors.transparent,
              dropdownBackgroundColor: toolbarColor,
              textStyle: const TextStyle(color: Colors.white, fontSize: 16),
              
              defaultToolbarButtons: [
                const StyleButtons(),
                const FontButtons(clearAll: false, superscript: false, subscript: false),
                const ColorButtons(),
                const ListButtons(listStyles: false),
                const ParagraphButtons(textDirection: false, lineHeight: false, caseConverter: false),
                const InsertButtons(audio: false, video: false, otherFile: false, table: true, picture: true), 
              ],
              initiallyExpanded: true,
            ),

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