import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/app_providers.dart';

/// Widget para capturar foto de "antes y después" del trabajo
/// UX intuitiva: muestra preview, permite recapturar, agregar descripción
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

  @override
  void initState() {
    super.initState();
    _beforePath = widget.beforePhotoPath;
    _afterPath = widget.afterPhotoPath;
    _beforeDesc = widget.beforeDescription;
    _afterDesc = widget.afterDescription;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A8D8D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Tarea ${widget.index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    // Notificar eliminación
                    widget.onChanged(null, null, null, null);
                  },
                  tooltip: 'Eliminar tarea',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Foto ANTES
            _buildPhotoSection(
              title: '📸 Foto ANTES del trabajo',
              photoPath: _beforePath,
              description: _beforeDesc,
              onTakePhoto: () => _takePhoto(isBeforePhoto: true),
              onDescriptionChanged: (desc) {
                setState(() => _beforeDesc = desc);
                _notifyChange();
              },
              color: Colors.orange,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Foto DESPUÉS
            _buildPhotoSection(
              title: '✅ Foto DESPUÉS del trabajo',
              photoPath: _afterPath,
              description: _afterDesc,
              onTakePhoto: () => _takePhoto(isBeforePhoto: false),
              onDescriptionChanged: (desc) {
                setState(() => _afterDesc = desc);
                _notifyChange();
              },
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection({
    required String title,
    required String? photoPath,
    required String? description,
    required VoidCallback onTakePhoto,
    required Function(String) onDescriptionChanged,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Preview de la foto o botón para tomar
        if (photoPath != null && photoPath.isNotEmpty)
          Stack(
            children: [
              // Preview de la imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(photoPath),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
                ),
              ),
              // Botón para recapturar
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: onTakePhoto,
                    tooltip: 'Tomar otra foto',
                  ),
                ),
              ),
            ],
          )
        else
          // Botón para tomar foto inicial
          InkWell(
            onTap: onTakePhoto,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
                color: color.withValues(alpha: 0.05),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 48, color: color),
                  const SizedBox(height: 8),
                  Text(
                    'Toca para tomar foto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Campo de descripción
        TextField(
          decoration: InputDecoration(
            labelText: 'Descripción del trabajo realizado',
            hintText: 'Ej: Instalación de tubería, pintura de pared...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.description_outlined),
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
      // Mostrar opciones: cámara o galería
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Procesando foto...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );
      }

      // Capturar foto temporal
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (photo != null) {
        // Guardar foto permanentemente usando el servicio
        final photoStorageService = ref.read(photoStorageServiceProvider);
        final String permanentPath = await photoStorageService.savePhoto(photo.path);
        
        // Eliminar la foto anterior si existe
        if (isBeforePhoto && _beforePath != null) {
          await photoStorageService.deletePhoto(_beforePath!);
        } else if (!isBeforePhoto && _afterPath != null) {
          await photoStorageService.deletePhoto(_afterPath!);
        }
        
        setState(() {
          if (isBeforePhoto) {
            _beforePath = permanentPath;
          } else {
            _afterPath = permanentPath;
          }
        });
        _notifyChange();
        
        // Ocultar indicador de carga y mostrar éxito
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Foto guardada correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Usuario canceló
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar foto: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _notifyChange() {
    widget.onChanged(_beforePath, _afterPath, _beforeDesc, _afterDesc);
  }
}
