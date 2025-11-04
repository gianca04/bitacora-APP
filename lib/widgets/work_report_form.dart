import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../models/work_report.dart';
import '../models/photo.dart';
import 'before_after_photo_card.dart';
import 'signature_pad_widget.dart';

/// Form widget for creating/editing work reports
/// Single Responsibility: Handle form state and validation
class WorkReportForm extends StatefulWidget {
  final WorkReport? workReport;
  final List<Photo>? existingPhotos;
  final Function(WorkReport report, List<Photo> photos, bool photosChanged) onSubmit;

  const WorkReportForm({
    super.key,
    this.workReport,
    this.existingPhotos,
    required this.onSubmit,
  });

  @override
  State<WorkReportForm> createState() => _WorkReportFormState();
}

class _WorkReportFormState extends State<WorkReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _projectIdController = TextEditingController();
  final _suggestionsController = TextEditingController();
  final _toolsController = TextEditingController();
  final _personnelController = TextEditingController();
  final _materialsController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now();
  DateTime _reportDate = DateTime.now();

  // Lista de tareas con fotos antes/después
  final List<Map<String, dynamic>> _photoTasks = [];
  
  // Track whether user modified photos (add/delete/replace)
  bool _photosModified = false;
  // Track which indices have sent their initial onChanged callback so we
  // don't mark that as a user modification.
  final Set<int> _initialNotifiedIndices = {};

  // Firmas digitales
  Uint8List? _supervisorSignature;
  Uint8List? _managerSignature;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadExistingPhotos();
  }

  void _initializeForm() {
    if (widget.workReport != null) {
      final report = widget.workReport!;
      _nameController.text = report.name;
      _descriptionController.text = report.description;
      _employeeIdController.text = report.employeeId.toString();
      _projectIdController.text = report.projectId.toString();
      _suggestionsController.text = report.suggestions ?? '';
      _toolsController.text = report.tools ?? '';
      _personnelController.text = report.personnel ?? '';
      _materialsController.text = report.materials ?? '';
      _startTime = report.startTime;
      _endTime = report.endTime;
      _reportDate = report.reportDate;
    }
  }

  void _loadExistingPhotos() {
    // Sincronizar el estado local con widget.existingPhotos
    // Esto permite que las fotos cargadas asincrónicamente actualicen el formulario
    debugPrint('📦 WorkReportForm._loadExistingPhotos called');
    debugPrint('   existingPhotos count: ${widget.existingPhotos?.length ?? 0}');
    
    // Don't clear if we're just reloading the same data
    final shouldReload = widget.existingPhotos != null && 
                         widget.existingPhotos!.isNotEmpty &&
                         (_photoTasks.isEmpty || 
                          _photoTasks.length != widget.existingPhotos!.length);
    
    if (!shouldReload && _photoTasks.isNotEmpty) {
      debugPrint('   ⏭️ Skipping reload - data unchanged');
      return;
    }
    
    _photoTasks.clear();
    _initialNotifiedIndices.clear();
    
    if (widget.existingPhotos != null && widget.existingPhotos!.isNotEmpty) {
      // Convertir fotos existentes a formato de _photoTasks
      for (final photo in widget.existingPhotos!) {
        debugPrint('   Loading photo: afterPath=${photo.photoPath}, beforePath=${photo.beforeWorkPhotoPath}');
        _photoTasks.add({
          'beforePhoto': photo.beforeWorkPhotoPath,
          'afterPhoto': photo.photoPath,
          'beforeDescription': photo.beforeWorkDescripcion ?? '',
          'afterDescription': photo.descripcion ?? '',
          // Store original paths to compare later
          'originalBeforePhoto': photo.beforeWorkPhotoPath,
          'originalAfterPhoto': photo.photoPath,
        });
      }
      debugPrint('   ✅ Loaded ${_photoTasks.length} photo tasks');
    } else {
      debugPrint('   ℹ️ No existing photos to load');
    }
  }

  @override
  void didUpdateWidget(covariant WorkReportForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Solo recargar si las fotos existentes realmente cambiaron
    if (widget.existingPhotos != oldWidget.existingPhotos) {
      final oldCount = oldWidget.existingPhotos?.length ?? 0;
      final newCount = widget.existingPhotos?.length ?? 0;
      
      debugPrint('WorkReportForm: existingPhotos changed from $oldCount to $newCount');
      
      // Only reload if counts are different or if we're going from null to data
      if (oldCount != newCount || (oldCount == 0 && newCount > 0)) {
        setState(() {
          _loadExistingPhotos();
        });
      } else {
        debugPrint('   ⏭️ Same count, skipping reload');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _employeeIdController.dispose();
    _projectIdController.dispose();
    _suggestionsController.dispose();
    _toolsController.dispose();
    _personnelController.dispose();
    _materialsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Basic Information Section
          _buildSectionTitle('Basic Information'),
          _buildTextField(
            controller: _nameController,
            label: 'Report Name',
            validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            maxLines: 3,
            validator: (value) => value?.isEmpty ?? true ? 'Description is required' : null,
          ),
          const SizedBox(height: 16),
          
          // Employee and Project Section
          _buildSectionTitle('Assignment'),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _employeeIdController,
                  label: 'Employee ID',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (int.tryParse(value!) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _projectIdController,
                  label: 'Project ID',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (int.tryParse(value!) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date and Time Section
          _buildSectionTitle('Schedule'),
          _buildDateTimePicker(
            label: 'Report Date',
            value: _reportDate,
            onChanged: (date) => setState(() => _reportDate = date),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  label: 'Start Time',
                  value: _startTime,
                  onChanged: (time) => setState(() => _startTime = time),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(
                  label: 'End Time',
                  value: _endTime,
                  onChanged: (time) => setState(() => _endTime = time),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Additional Details Section
          _buildSectionTitle('Additional Details'),
          _buildTextField(
            controller: _suggestionsController,
            label: 'Suggestions',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _toolsController,
            label: 'Tools Used',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _personnelController,
            label: 'Personnel',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _materialsController,
            label: 'Materials',
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          // Photos Section - Fotos antes/después de cada tarea
          _buildSectionTitle('Fotografías del Trabajo'),
          Text(
            'Agregue fotos del antes y después de cada tarea realizada',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de tareas con fotos
          for (var entry in _photoTasks.asMap().entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: BeforeAfterPhotoCard(
                // Pasamos entry.key (0-based). El widget muestra +1 internamente para UX.
                index: entry.key,
                beforePhotoPath: entry.value['beforePhoto'] as String?,
                afterPhotoPath: entry.value['afterPhoto'] as String?,
                beforeDescription: entry.value['beforeDescription'] as String?,
                afterDescription: entry.value['afterDescription'] as String?,
                onChanged: (before, after, beforeDesc, afterDesc) {
                  setState(() {
                    // Debug: verificar qué valores llegan
                    debugPrint('📸 Photo task ${entry.key} onChanged:');
                    debugPrint('  beforePhoto: $before');
                    debugPrint('  afterPhoto: $after');
                    debugPrint('  Original beforePhoto: ${_photoTasks[entry.key]['originalBeforePhoto']}');
                    debugPrint('  Original afterPhoto: ${_photoTasks[entry.key]['originalAfterPhoto']}');
                    
                    _photoTasks[entry.key]['beforePhoto'] = before;
                    _photoTasks[entry.key]['afterPhoto'] = after;
                    _photoTasks[entry.key]['beforeDescription'] = beforeDesc;
                    _photoTasks[entry.key]['afterDescription'] = afterDesc;

                    // Check if photo paths actually changed (not just descriptions)
                    final originalBefore = _photoTasks[entry.key]['originalBeforePhoto'] as String?;
                    final originalAfter = _photoTasks[entry.key]['originalAfterPhoto'] as String?;
                    
                    // If this index has already sent its initial onChanged, check if
                    // the actual photo paths changed (indicating a photo replacement)
                    if (_initialNotifiedIndices.contains(entry.key)) {
                      // Mark as modified only if photo paths changed
                      if (before != originalBefore || after != originalAfter) {
                        debugPrint('  🔄 Photos modified detected!');
                        _photosModified = true;
                      } else {
                        debugPrint('  ✅ Only descriptions changed, photos preserved');
                      }
                    } else {
                      debugPrint('  📥 Initial notification');
                      _initialNotifiedIndices.add(entry.key);
                    }
                  });
                },
              ),
            ),

          // Botón para agregar nueva tarea
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _photoTasks.add({
                  'beforePhoto': null,
                  'afterPhoto': null,
                  'beforeDescription': '',
                  'afterDescription': '',
                  // New tasks have no original paths
                  'originalBeforePhoto': null,
                  'originalAfterPhoto': null,
                });
                // User explicitly added a new task => photos modified
                _photosModified = true;
              });
            },
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Agregar Nueva Tarea'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF2A8D8D), width: 2),
              foregroundColor: const Color(0xFF2A8D8D),
            ),
          ),
          const SizedBox(height: 32),

          // Signatures Section - Firmas digitales
          _buildSectionTitle('Firmas de Aprobación'),
          Text(
            'Las firmas digitales validan la aprobación del reporte',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          
          // Firma del Supervisor
          SignaturePadWidget(
            label: 'Firma del Supervisor',
            color: const Color(0xFF2A8D8D),
            onSignatureChanged: (signature) {
              setState(() {
                _supervisorSignature = signature;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Firma del Gerente
          SignaturePadWidget(
            label: 'Firma del Gerente',
            color: const Color(0xFF1F6B6B),
            onSignatureChanged: (signature) {
              setState(() {
                _managerSignature = signature;
              });
            },
          ),
          const SizedBox(height: 32),

          // Submit Button
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A8D8D),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.workReport == null ? 'Create Report' : 'Update Report',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2A8D8D),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          onChanged(DateTime(
            date.year,
            date.month,
            date.day,
            value.hour,
            value.minute,
          ));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
        );
        if (time != null) {
          onChanged(DateTime(
            value.year,
            value.month,
            value.day,
            time.hour,
            time.minute,
          ));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Convertir firmas a base64 si existen
      final supervisorSig = _supervisorSignature != null 
          ? base64Encode(_supervisorSignature!) 
          : null;
      final managerSig = _managerSignature != null 
          ? base64Encode(_managerSignature!) 
          : null;

      final report = WorkReport(
        id: widget.workReport?.id ?? Isar.autoIncrement,
        name: _nameController.text,
        description: _descriptionController.text,
        employeeId: int.parse(_employeeIdController.text),
        projectId: int.parse(_projectIdController.text),
        startTime: _startTime,
        endTime: _endTime,
        reportDate: _reportDate,
        suggestions: _suggestionsController.text.isEmpty ? null : _suggestionsController.text,
        tools: _toolsController.text.isEmpty ? null : _toolsController.text,
        personnel: _personnelController.text.isEmpty ? null : _personnelController.text,
        materials: _materialsController.text.isEmpty ? null : _materialsController.text,
        supervisorSignature: supervisorSig,
        managerSignature: managerSig,
      );

      // Convertir photoTasks a lista de Photo objetos
      final photos = <Photo>[];
      debugPrint('🔍 Converting photoTasks to Photo objects:');
      debugPrint('  Total photoTasks: ${_photoTasks.length}');
      debugPrint('  photosModified flag: $_photosModified');
      
      for (var i = 0; i < _photoTasks.length; i++) {
        final task = _photoTasks[i];
        final beforePath = task['beforePhoto'] as String?;
        final afterPath = task['afterPhoto'] as String?;
        final originalBeforePath = task['originalBeforePhoto'] as String?;
        final originalAfterPath = task['originalAfterPhoto'] as String?;
        final beforeDesc = task['beforeDescription'] as String?;
        final afterDesc = task['afterDescription'] as String?;

        // Use original paths if current are null (safety fallback)
        final finalBeforePath = beforePath ?? originalBeforePath;
        final finalAfterPath = afterPath ?? originalAfterPath;

        debugPrint('  Task $i:');
        debugPrint('    currentBefore=$beforePath, currentAfter=$afterPath');
        debugPrint('    originalBefore=$originalBeforePath, originalAfter=$originalAfterPath');
        debugPrint('    finalBefore=$finalBeforePath, finalAfter=$finalAfterPath');

        // Create Photo if at least ONE photo exists (before OR after)
        // Both fields are optional, supporting flexible workflows
        if (finalBeforePath != null && finalBeforePath.isNotEmpty ||
            finalAfterPath != null && finalAfterPath.isNotEmpty) {
          
          final photo = Photo(
            id: Isar.autoIncrement,
            workReportId: 0, // Will be assigned after report creation
            beforeWorkPhotoPath: (finalBeforePath?.isNotEmpty ?? false) ? finalBeforePath : null,
            photoPath: (finalAfterPath?.isNotEmpty ?? false) ? finalAfterPath : null,
            beforeWorkDescripcion: (beforeDesc?.isNotEmpty ?? false) ? beforeDesc : null,
            descripcion: (afterDesc?.isNotEmpty ?? false) ? afterDesc : null,
          );
          
          photos.add(photo);
          debugPrint('    ✅ Photo created (hasValidPhotos: ${photo.hasValidPhotos})');
        } else {
          debugPrint('    ⚠️ Skipped - no photo paths available');
        }
      }
      
      debugPrint('📊 Total valid photos: ${photos.length}');

      widget.onSubmit(report, photos, _photosModified);
    }
  }
}
