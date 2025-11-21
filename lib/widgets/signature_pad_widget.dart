import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../config/app_colors.dart'; // Asumiendo que tienes este archivo del paso anterior

class SignaturePadWidget extends StatefulWidget {
  final String label;
  final String? initialSignature; // Base64 string para modo edición
  final Function(Uint8List?) onSignatureChanged;
  final Color color;

  const SignaturePadWidget({
    super.key,
    required this.label,
    required this.onSignatureChanged,
    this.initialSignature,
    this.color = AppColors.primary, // Usamos el color del tema por defecto
  });

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  late SignatureController _controller;
  
  // Estado
  Uint8List? _savedSignatureBytes; // Para mostrar la firma ya guardada/inicial
  bool _isEditing = true; // Controla si mostramos el pad o la imagen estática

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black, // Siempre negro para contraste sobre papel blanco
      exportBackgroundColor: Colors.transparent,
    );

    // Lógica de Inicialización para modo Edición
    if (widget.initialSignature != null && widget.initialSignature!.isNotEmpty) {
      try {
        _savedSignatureBytes = base64Decode(widget.initialSignature!);
        _isEditing = false; // Iniciamos en modo "Lectura" si ya hay firma
      } catch (e) {
        debugPrint('Error decodificando firma inicial: $e');
      }
    }

    _controller.addListener(() {
      // Pequeña optimización: solo redibujar si el estado vacío cambia
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  void _clearSignature() {
    setState(() {
      _controller.clear();
      _savedSignatureBytes = null;
      _isEditing = true; // Volvemos a mostrar el pad
    });
    widget.onSignatureChanged(null);
  }

  Future<void> _confirmSignature() async {
    if (_controller.isEmpty) return;

    final signature = await _controller.toPngBytes();
    if (signature != null) {
      setState(() {
        _savedSignatureBytes = signature;
        _isEditing = false; // Bloqueamos el pad para mostrar lo guardado
      });
      widget.onSignatureChanged(signature);
    }
  }

  void _editAgain() {
    setState(() {
      _isEditing = true;
      // Nota: signature package no permite "recargar" trazos. 
      // Al editar de nuevo, se empieza en blanco (comportamiento estándar de seguridad).
      _controller.clear(); 
    });
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    final isSigned = _savedSignatureBytes != null && !_isEditing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(isSigned ? Icons.check_circle : Icons.draw, 
                  color: isSigned ? AppColors.secondary : widget.color, 
                  size: 20
              ),
              const SizedBox(width: 8),
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSigned ? AppColors.secondary : widget.color,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),

        // Main Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // Fondo papel siempre blanco para firmas
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              // Borde verde si está firmado, gris si no
              color: isSigned ? AppColors.secondary : Colors.grey.withOpacity(0.4),
              width: isSigned ? 2 : 1,
            ),
            boxShadow: [
              if (isSigned)
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Área de Firma
              SizedBox(
                height: 180,
                width: double.infinity,
                child: _isEditing 
                  ? _buildEditorCanvas() 
                  : _buildStaticImage(),
              ),
              
              // Barra de Herramientas Inferior
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50], // Fondo gris muy suave para la barra
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: _buildActionButtons(isSigned),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditorCanvas() {
    return Stack(
      children: [
        // 1. Background Guidelines (Marca de agua visual)
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Espacio para firmar",
                  style: TextStyle(color: Colors.grey[300], fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40), // Espacio para la línea
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 40,
          right: 40,
          child: Divider(color: Colors.grey[300], thickness: 2, indent: 20, endIndent: 20),
        ),
        Positioned(
          bottom: 55,
          left: 60,
          child: Text("x", style: TextStyle(color: Colors.grey[400], fontSize: 20)),
        ),

        // 2. The actual Signature Pad
        Signature(
          controller: _controller,
          backgroundColor: Colors.transparent, // Importante para ver el fondo
          height: 180,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildStaticImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(
          _savedSignatureBytes!,
          fit: BoxFit.contain,
        ),
        // Overlay sutil para indicar que está "bloqueado"
        Container(
          color: Colors.white.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isSigned) {
    if (isSigned) {
      // Estado: FIRMADO
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: AppColors.secondary, size: 18),
              const SizedBox(width: 8),
              Text(
                "Firma registrada",
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: _editAgain,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text("Cambiar"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          )
        ],
      );
    } else {
      // Estado: EDITANDO / VACÍO
      final bool hasStrokes = _controller.isNotEmpty;
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón Limpiar
          TextButton(
            onPressed: hasStrokes ? _clearSignature : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              disabledForegroundColor: Colors.grey[300],
            ),
            child: const Text("Limpiar"),
          ),
          
          // Botón Confirmar (Estilo "Pill" moderno)
          ElevatedButton.icon(
            onPressed: hasStrokes ? _confirmSignature : null,
            icon: const Icon(Icons.check, size: 16),
            label: const Text("Confirmar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      );
    }
  }
}