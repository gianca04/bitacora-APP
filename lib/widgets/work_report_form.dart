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
  final Function(WorkReport report, List<Photo> photos) onSubmit;

  const WorkReportForm({
    super.key,
    this.workReport,
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
  
  // Firmas digitales
  Uint8List? _supervisorSignature;
  Uint8List? _managerSignature;

  @override
  void initState() {
    super.initState();
    _initializeForm();
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
                index: entry.key + 1,
                beforePhotoPath: entry.value['beforePhoto'] as String?,
                afterPhotoPath: entry.value['afterPhoto'] as String?,
                beforeDescription: entry.value['beforeDescription'] as String?,
                afterDescription: entry.value['afterDescription'] as String?,
                onChanged: (before, after, beforeDesc, afterDesc) {
                  setState(() {
                    _photoTasks[entry.key]['beforePhoto'] = before;
                    _photoTasks[entry.key]['afterPhoto'] = after;
                    _photoTasks[entry.key]['beforeDescription'] = beforeDesc;
                    _photoTasks[entry.key]['afterDescription'] = afterDesc;
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
                });
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
      for (var task in _photoTasks) {
        final beforePath = task['beforePhoto'] as String?;
        final afterPath = task['afterPhoto'] as String?;
        final beforeDesc = task['beforeDescription'] as String?;
        final afterDesc = task['afterDescription'] as String?;

        // Solo crear Photo si al menos una foto fue tomada
        if (afterPath != null) {
          photos.add(Photo(
            id: Isar.autoIncrement,
            workReportId: 0, // Se asignará después de crear el reporte
            photoPath: afterPath, // Foto principal (después)
            descripcion: afterDesc,
            beforeWorkPhotoPath: beforePath, // Foto antes (opcional)
            beforeWorkDescripcion: beforeDesc,
          ));
        }
      }

      widget.onSubmit(report, photos);
    }
  }
}
