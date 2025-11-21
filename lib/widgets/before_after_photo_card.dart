import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/app_providers.dart';

class BeforeAfterPhotoCard extends ConsumerStatefulWidget {
  final String? beforePhotoPath;
  final String? afterPhotoPath;
  final String? beforeDescription;
  final String? afterDescription;
  final Function(String? before, String? after, String? beforeDesc, String? afterDesc) onChanged;
  final int index;

  const BeforeAfterPhotoCard({
    super.key,
    this.beforePhotoPath,
    this.afterPhotoPath,
    this.beforeDescription,
    this.afterDescription,
    required this.onChanged,
    required this.index,
  });

  @override
  ConsumerState<BeforeAfterPhotoCard> createState() => _BeforeAfterPhotoCardState();
}

class _BeforeAfterPhotoCardState extends ConsumerState<BeforeAfterPhotoCard> {
  final ImagePicker _picker = ImagePicker();
  
  String? _beforePath;
  String? _afterPath;
  String? _beforeDesc;
  String? _afterDesc;
  
  String? _originalBeforePath;
  String? _originalAfterPath;
  
  bool _hasNotifiedInitialState = false;

  @override
  void initState() {
    super.initState();
    _beforePath = widget.beforePhotoPath;
    _afterPath = widget.afterPhotoPath;
    _beforeDesc = widget.beforeDescription ?? '';
    _afterDesc = widget.afterDescription ?? '';
    
    _originalBeforePath = widget.beforePhotoPath;
    _originalAfterPath = widget.afterPhotoPath;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasNotifiedInitialState) {
        _hasNotifiedInitialState = true;
        widget.onChanged(_beforePath, _afterPath, _beforeDesc, _afterDesc);
      }
    });
  }
  
  @override
  void didUpdateWidget(BeforeAfterPhotoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.beforePhotoPath != _beforePath || 
        widget.afterPhotoPath != _afterPath ||
        widget.beforeDescription != _beforeDesc ||
        widget.afterDescription != _afterDesc) {
      
      setState(() {
        if (widget.beforePhotoPath != oldWidget.beforePhotoPath) {
          _beforePath = widget.beforePhotoPath;
          _originalBeforePath = widget.beforePhotoPath;
        }
        if (widget.afterPhotoPath != oldWidget.afterPhotoPath) {
          _afterPath = widget.afterPhotoPath;
          _originalAfterPath = widget.afterPhotoPath;
        }
        
        _beforeDesc = widget.beforeDescription ?? '';
        _afterDesc = widget.afterDescription ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se eliminó Card, elevation, margin y shape
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header simple sin decoración
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tarea ${widget.index + 1}'),
            IconButton(
              icon: const Icon(Icons.delete), // Sin color rojo explícito
              onPressed: () {
                widget.onChanged(null, null, null, null);
              },
              tooltip: 'Eliminar tarea',
            ),
          ],
        ),
        
        // Foto ANTES
        _buildPhotoSection(
          title: 'Foto ANTES', // Sin emojis ni colores
          photoPath: _beforePath,
          description: _beforeDesc,
          onTakePhoto: () => _takePhoto(isBeforePhoto: true),
          onDescriptionChanged: (desc) {
            setState(() => _beforeDesc = desc);
            _notifyChange();
          },
        ),

        const Divider(), // Separador nativo simple

        // Foto DESPUÉS
        _buildPhotoSection(
          title: 'Foto DESPUÉS',
          photoPath: _afterPath,
          description: _afterDesc,
          onTakePhoto: () => _takePhoto(isBeforePhoto: false),
          onDescriptionChanged: (desc) {
            setState(() => _afterDesc = desc);
            _notifyChange();
          },
        ),
        
        const SizedBox(height: 20), // Espacio final
      ],
    );
  }

  Widget _buildPhotoSection({
    required String title,
    required String? photoPath,
    required String? description,
    required VoidCallback onTakePhoto,
    required Function(String) onDescriptionChanged,
  }) {
    final String path = photoPath ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título simple
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),

        // Lógica de visualización: Botón o Imagen
        if (path.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen sin bordes redondeados ni sombras
              Image.file(
                File(path),
                key: ValueKey(path), // Mantiene la key para refresco
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  const Text('Error al cargar imagen'),
              ),
              // Botón simple para recapturar
              TextButton.icon(
                onPressed: onTakePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cambiar foto'),
              ),
              // Ruta en texto simple para debug/verificación
              Text(path, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        else
          // Botón estándar para tomar foto (sin contenedor decorado)
          ElevatedButton.icon(
            onPressed: onTakePhoto,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Tomar foto'),
          ),

        const SizedBox(height: 8),

        // TextField sin OutlineInputBorder decorativo
        TextField(
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'Detalles del trabajo...',
          ),
          maxLines: 2,
          controller: TextEditingController(text: description),
          onChanged: onDescriptionChanged,
        ),
      ],
    );
  }

  Future<void> _takePhoto({required bool isBeforePhoto}) async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Procesando foto...')), // Sin colores ni loaders complejos
        );
      }

      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (photo != null) {
        final photoStorageService = ref.read(photoStorageServiceProvider);
        final String permanentPath = await photoStorageService.savePhoto(photo.path);
        
        // Lógica de borrado de foto anterior (Mantenida exacta)
        if (isBeforePhoto) {
          if (_beforePath != null && _beforePath != _originalBeforePath) {
            await photoStorageService.deletePhoto(_beforePath!);
          }
        } else {
          if (_afterPath != null && _afterPath != _originalAfterPath) {
            await photoStorageService.deletePhoto(_afterPath!);
          }
        }
        
        setState(() {
          if (isBeforePhoto) {
            _beforePath = permanentPath;
          } else {
            _afterPath = permanentPath;
          }
        });
        _notifyChange();
        
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          // SnackBar simple de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto guardada')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // SnackBar simple de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _notifyChange() {
    widget.onChanged(_beforePath, _afterPath, _beforeDesc, _afterDesc);
  }
}