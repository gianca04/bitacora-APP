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
  
  // Store original paths to detect actual photo replacements
  String? _originalBeforePath;
  String? _originalAfterPath;
  
  // Track if we've sent the initial notification
  bool _hasNotifiedInitialState = false;

  @override
  void initState() {
    super.initState();
    _beforePath = widget.beforePhotoPath;
    _afterPath = widget.afterPhotoPath;
    _beforeDesc = widget.beforeDescription ?? '';
    _afterDesc = widget.afterDescription ?? '';
    
    // Remember original paths
    _originalBeforePath = widget.beforePhotoPath;
    _originalAfterPath = widget.afterPhotoPath;
    
    // Notify parent of initial values ONLY ONCE to sync state
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
    
    // If parent passes new paths (e.g., when loading), update our state
    // But only if they're actually different from current state
    if (widget.beforePhotoPath != _beforePath || 
        widget.afterPhotoPath != _afterPath ||
        widget.beforeDescription != _beforeDesc ||
        widget.afterDescription != _afterDesc) {
      
      setState(() {
        // Update paths if they changed externally
        if (widget.beforePhotoPath != oldWidget.beforePhotoPath) {
          _beforePath = widget.beforePhotoPath;
          _originalBeforePath = widget.beforePhotoPath;
        }
        if (widget.afterPhotoPath != oldWidget.afterPhotoPath) {
          _afterPath = widget.afterPhotoPath;
          _originalAfterPath = widget.afterPhotoPath;
        }
        
        // Update descriptions
        _beforeDesc = widget.beforeDescription ?? '';
        _afterDesc = widget.afterDescription ?? '';
      });
    }
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
    final String _path = photoPath ?? '';
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
        if (_path.isNotEmpty)
          Stack(
            children: [
              // Preview de la imagen con Key única para forzar refresh
              ClipRRect(
                key: ValueKey(_path), // ✨ Key única basada en la ruta
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_path),
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
              // Mostrar ruta de la imagen en una etiqueta inferior para verificación
              if (_path.isNotEmpty)
                Positioned(
                  left: 8,
                  bottom: 8,
                  right: 56,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _path,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
        
        debugPrint('');
        debugPrint('📷 PHOTO CAPTURED - BeforeAfterPhotoCard');
        debugPrint('   isBeforePhoto: $isBeforePhoto');
        debugPrint('   New photo path: $permanentPath');
        debugPrint('   Current ${isBeforePhoto ? "before" : "after"}Path: ${isBeforePhoto ? _beforePath : _afterPath}');
        debugPrint('   Original ${isBeforePhoto ? "before" : "after"}Path: ${isBeforePhoto ? _originalBeforePath : _originalAfterPath}');
        
        // Eliminar la foto anterior SOLO si es diferente de la original
        // (es decir, si ya había sido reemplazada antes en esta sesión)
        if (isBeforePhoto) {
          if (_beforePath != null && _beforePath != _originalBeforePath) {
            debugPrint('   🗑️ Deleting old before photo (not original): $_beforePath');
            await photoStorageService.deletePhoto(_beforePath!);
          } else {
            debugPrint('   ✅ Preserving before photo (is original or null)');
          }
        } else {
          if (_afterPath != null && _afterPath != _originalAfterPath) {
            debugPrint('   🗑️ Deleting old after photo (not original): $_afterPath');
            await photoStorageService.deletePhoto(_afterPath!);
          } else {
            debugPrint('   ✅ Preserving after photo (is original or null)');
          }
        }
        debugPrint('');
        
        setState(() {
          debugPrint('🔄 setState: Updating ${isBeforePhoto ? "BEFORE" : "AFTER"} photo');
          debugPrint('   Before setState:');
          debugPrint('      _beforePath: $_beforePath');
          debugPrint('      _afterPath: $_afterPath');
          
          if (isBeforePhoto) {
            _beforePath = permanentPath;
          } else {
            _afterPath = permanentPath;
          }
          
          debugPrint('   After setState:');
          debugPrint('      _beforePath: $_beforePath');
          debugPrint('      _afterPath: $_afterPath');
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
    debugPrint('🔔 BeforeAfterPhotoCard._notifyChange called');
    debugPrint('   Notifying parent with:');
    debugPrint('   beforePath: $_beforePath');
    debugPrint('   afterPath: $_afterPath');
    debugPrint('   beforeDesc: $_beforeDesc');
    debugPrint('   afterDesc: $_afterDesc');
    widget.onChanged(_beforePath, _afterPath, _beforeDesc, _afterDesc);
  }
}
