import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import '../models/work_report.dart';
import '../models/photo.dart';
import '../config/app_colors.dart';
import 'before_after_photo_card.dart';
import 'signature_pad_widget.dart';
import 'inputs/modern_text_field.dart';
import 'inputs/modern_date_picker.dart';
import 'time_range_picker.dart';

// =============================================================================
// CLASES AUXILIARES
// =============================================================================

class _PhotoTaskDraft {
  String? beforePhoto;
  String? afterPhoto;
  String beforeDescription;
  String afterDescription;
  final String? originalBeforePhoto;
  final String? originalAfterPhoto;

  _PhotoTaskDraft({
    this.beforePhoto,
    this.afterPhoto,
    this.beforeDescription = '',
    this.afterDescription = '',
    this.originalBeforePhoto,
    this.originalAfterPhoto,
  });

  factory _PhotoTaskDraft.fromPhoto(Photo photo) {
    return _PhotoTaskDraft(
      beforePhoto: photo.beforeWorkPhotoPath,
      afterPhoto: photo.photoPath,
      beforeDescription: photo.beforeWorkDescripcion ?? '',
      afterDescription: photo.descripcion ?? '',
      originalBeforePhoto: photo.beforeWorkPhotoPath,
      originalAfterPhoto: photo.photoPath,
    );
  }

  bool get photosChanged =>
      beforePhoto != originalBeforePhoto || afterPhoto != originalAfterPhoto;
  bool get isValid =>
      (beforePhoto?.isNotEmpty ?? false) || (afterPhoto?.isNotEmpty ?? false);
}

// =============================================================================
// WIDGET PRINCIPAL
// =============================================================================

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

  // --- Controllers Nativos ---
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _employeeIdController;
  late final TextEditingController _projectIdController;

  // --- Controllers HTML ---
  late final HtmlEditorController _suggestionsController;
  late final HtmlEditorController _toolsController;
  late final HtmlEditorController _personnelController;
  late final HtmlEditorController _materialsController;

  // --- VARIABLES DE ESTADO PARA TEXTO HTML ---
  String _suggestionsContent = '';
  String _toolsContent = '';
  String _personnelContent = '';
  String _materialsContent = '';

  // --- State General ---
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now();
  DateTime _reportDate = DateTime.now();

  String? _reportDateError;
  String? _timeError;

  final List<_PhotoTaskDraft> _photoTasks = [];
  bool _userManuallyAddedTask = false;

  // Firmas
  Uint8List? _supervisorSignature;
  Uint8List? _managerSignature;

  // 🔧 MEJORA 1: Flag para saber si los editores ya se inicializaron
  bool _editorsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadFormData();
    _loadExistingPhotos();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _employeeIdController = TextEditingController();
    _projectIdController = TextEditingController();

    _suggestionsController = HtmlEditorController();
    _toolsController = HtmlEditorController();
    _personnelController = HtmlEditorController();
    _materialsController = HtmlEditorController();
  }

  void _loadFormData() {
    if (widget.workReport == null) return;
    final report = widget.workReport!;
    
    _nameController.text = report.name;
    _descriptionController.text = report.description;
    _employeeIdController.text = report.employeeId?.toString() ?? '';
    _projectIdController.text = report.projectId?.toString() ?? '';

    // 🔧 MEJORA 2: Cargar valores INMEDIATAMENTE en las variables de estado
    // Esto garantiza que si el usuario no edita, se guarde el contenido original
    _suggestionsContent = report.suggestions ?? '';
    _toolsContent = report.tools ?? '';
    _personnelContent = report.personnel ?? '';
    _materialsContent = report.materials ?? '';

    _startTime = report.startTime;
    _endTime = report.endTime;
    _reportDate = report.reportDate;
    
    if (report.supervisorSignature != null) {
       try {
         _supervisorSignature = base64Decode(report.supervisorSignature!);
       } catch (_) {}
    }
    if (report.managerSignature != null) {
       try {
         _managerSignature = base64Decode(report.managerSignature!);
       } catch (_) {}
    }
  }

  @override
  void didUpdateWidget(covariant WorkReportForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingPhotos != oldWidget.existingPhotos) {
      final newLen = widget.existingPhotos?.length ?? 0;
      final oldLen = oldWidget.existingPhotos?.length ?? 0;
      if (newLen != oldLen || (oldLen == 0 && newLen > 0)) {
        setState(() => _loadExistingPhotos());
      }
    }
  }

  void _loadExistingPhotos() {
    final isInitialLoad = _photoTasks.isEmpty;
    final hasExternalChanges =
        (widget.existingPhotos?.length ?? 0) != _photoTasks.length;

    if (!isInitialLoad && !hasExternalChanges) return;

    _photoTasks.clear();
    if (widget.existingPhotos != null) {
      _photoTasks.addAll(
        widget.existingPhotos!.map((p) => _PhotoTaskDraft.fromPhoto(p)),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _employeeIdController.dispose();
    _projectIdController.dispose();
    super.dispose();
  }

  // 🔧 MEJORA 3: Callback para cuando el editor HTML termina de cargar
  void _onEditorInitialized(String fieldName, HtmlEditorController controller) {
    if (!_editorsInitialized && widget.workReport != null) {
      // Al inicializarse, sincronizamos el contenido del editor con la variable
      Future.delayed(const Duration(milliseconds: 100), () async {
        try {
          final content = await controller.getText();
          setState(() {
            switch (fieldName) {
              case 'suggestions':
                _suggestionsContent = content;
                break;
              case 'tools':
                _toolsContent = content;
                break;
              case 'personnel':
                _personnelContent = content;
                break;
              case 'materials':
                _materialsContent = content;
                break;
            }
          });
        } catch (e) {
          debugPrint('Error al inicializar $fieldName: $e');
        }
      });
    }
  }

  // --- UI BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            _buildSectionTitle('Detalles Generales', Icons.dashboard_customize),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Cronología', Icons.access_time_filled),
            _buildDateTimeSection(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Bitácora', Icons.menu_book),
            _buildRichTextDetails(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Evidencia Fotográfica', Icons.camera_alt),
            _buildPhotosSection(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Conformidad', Icons.verified_user),
            _buildSignaturesSection(),
            const SizedBox(height: 40),
            
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- SECCIONES ---

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _ModernTextField(
          controller: _nameController,
          label: 'Título del Reporte',
          hint: 'Ej: Mantenimiento Preventivo Torre A',
          icon: Icons.title,
          validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        _ModernTextField(
          controller: _descriptionController,
          label: 'Descripción',
          hint: 'Resumen ejecutivo...',
          icon: Icons.short_text,
          maxLines: 3,
          validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ModernTextField(
                controller: _employeeIdController,
                label: 'ID Empleado',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                validator: _validateInteger,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ModernTextField(
                controller: _projectIdController,
                label: 'ID Proyecto',
                icon: Icons.folder_open,
                keyboardType: TextInputType.number,
                validator: _validateInteger,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _ModernDatePicker(
            label: 'Fecha del Servicio',
            value: _reportDate,
            icon: Icons.calendar_month,
            errorText: _reportDateError,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _reportDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(primary: AppColors.primary),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) setState(() => _reportDate = date);
            },
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _ModernDatePicker(
                  label: 'Inicio', 
                  value: _startTime, 
                  icon: Icons.schedule,
                  isTime: true,
                  onTap: () => _selectTime(true)
                )
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernDatePicker(
                  label: 'Fin', 
                  value: _endTime, 
                  icon: Icons.timer_off,
                  isTime: true,
                  errorText: _timeError,
                  onTap: () => _selectTime(false)
                )
              ),
            ]
          )
        ],
      ),
    );
  }
  
  Future<void> _selectTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final time = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.fromDateTime(initial)
    );
    if(time != null) {
      final dt = DateTime(initial.year, initial.month, initial.day, time.hour, time.minute);
      setState(() {
        if(isStart) _startTime = dt; else _endTime = dt;
        _timeError = null;
      });
    }
  }

  Widget _buildRichTextDetails() {
    final report = widget.workReport;
    
    return Column(
      children: [
        _buildBasicHtmlEditor(
          label: 'Sugerencias',
          controller: _suggestionsController,
          initialText: report?.suggestions,
          hint: 'Ingrese sugerencias...',
          onChanged: (val) => _suggestionsContent = val ?? '',
          onInit: () => _onEditorInitialized('suggestions', _suggestionsController),
        ),
        const SizedBox(height: 16),
        _buildBasicHtmlEditor(
          label: 'Herramientas',
          controller: _toolsController,
          initialText: report?.tools,
          hint: 'Listado de herramientas...',
          onChanged: (val) => _toolsContent = val ?? '',
          onInit: () => _onEditorInitialized('tools', _toolsController),
        ),
        const SizedBox(height: 16),
        _buildBasicHtmlEditor(
          label: 'Personal Involucrado',
          controller: _personnelController,
          initialText: report?.personnel,
          hint: 'Nombres del equipo...',
          onChanged: (val) => _personnelContent = val ?? '',
          onInit: () => _onEditorInitialized('personnel', _personnelController),
        ),
        const SizedBox(height: 16),
        _buildBasicHtmlEditor(
          label: 'Materiales',
          controller: _materialsController,
          initialText: report?.materials,
          hint: 'Materiales utilizados...',
          onChanged: (val) => _materialsContent = val ?? '',
          onInit: () => _onEditorInitialized('materials', _materialsController),
        ),
      ],
    );
  }

  Widget _buildBasicHtmlEditor({
    required String label,
    required HtmlEditorController controller,
    String? initialText,
    required String hint,
    required Function(String?) onChanged,
    required VoidCallback onInit,
  }) {
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
        HtmlEditor(
          controller: controller,
          htmlEditorOptions: HtmlEditorOptions(
            hint: hint,
            initialText: initialText,
            darkMode: true,
          ),
          callbacks: Callbacks(
            onChangeContent: onChanged,
            onInit: onInit,
          ),
          otherOptions: OtherOptions(
            height: 200,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      children: [
        ..._photoTasks.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BeforeAfterPhotoCard(
              index: entry.key,
              beforePhotoPath: entry.value.beforePhoto,
              afterPhotoPath: entry.value.afterPhoto,
              beforeDescription: entry.value.beforeDescription,
              afterDescription: entry.value.afterDescription,
              onChanged: (before, after, beforeDesc, afterDesc) {
                setState(() {
                  entry.value.beforePhoto = before;
                  entry.value.afterPhoto = after;
                  entry.value.beforeDescription = beforeDesc ?? '';
                  entry.value.afterDescription = afterDesc ?? '';
                });
              },
            ),
          );
        }),
        
        InkWell(
          onTap: () {
            setState(() {
              _photoTasks.add(_PhotoTaskDraft());
              _userManuallyAddedTask = true;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(16),
              color: AppColors.primary.withOpacity(0.05),
            ),
            child: Column(
              children: [
                const Icon(Icons.add_a_photo, color: AppColors.primary, size: 32),
                const SizedBox(height: 8),
                const Text(
                  "Agregar Nueva Evidencia",
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignaturesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SignaturePadWidget(
            label: 'Firma del Supervisor',
            color: AppColors.primary,
            initialSignature: widget.workReport?.supervisorSignature,
            onSignatureChanged: (sig) =>
                setState(() => _supervisorSignature = sig),
          ),
          const SizedBox(height: 24),
          SignaturePadWidget(
            label: 'Firma del Gerente',
            color: AppColors.secondary,
            initialSignature: widget.workReport?.managerSignature,
            onSignatureChanged: (sig) =>
                setState(() => _managerSignature = sig),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.workReport == null
                  ? 'GUARDAR REPORTE'
                  : 'ACTUALIZAR REPORTE',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.save_alt),
          ],
        ),
      ),
    );
  }

  // --- VALIDACIÓN Y LÓGICA FINAL ---
  String? _validateInteger(String? value) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) return 'Solo números';
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor corrija los errores en el formulario'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_endTime.isAfter(_startTime)) {
      setState(() => _timeError = 'Hora fin inválida');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _timeError = null;
      _reportDateError = null;
    });

    // 🎯 Las variables ya tienen el contenido correcto
    final report = WorkReport(
      id: widget.workReport?.id ?? Isar.autoIncrement,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      employeeId: int.tryParse(_employeeIdController.text.trim()),
      projectId: int.tryParse(_projectIdController.text.trim()),
      startTime: _startTime,
      endTime: _endTime,
      reportDate: _reportDate,

      // ✅ Usamos directamente las variables de estado
      suggestions: _suggestionsContent,
      tools: _toolsContent,
      personnel: _personnelContent,
      materials: _materialsContent,

      supervisorSignature: _supervisorSignature != null
          ? base64Encode(_supervisorSignature!)
          : widget.workReport?.supervisorSignature,
      managerSignature: _managerSignature != null
          ? base64Encode(_managerSignature!)
          : widget.workReport?.managerSignature,
    );

    final photos = _photoTasks
        .where((task) => task.isValid)
        .map(
          (task) => Photo(
            id: Isar.autoIncrement,
            workReportId: 0,
            beforeWorkPhotoPath: task.beforePhoto,
            photoPath: task.afterPhoto,
            beforeWorkDescripcion: task.beforeDescription.isNotEmpty
                ? task.beforeDescription
                : null,
            descripcion: task.afterDescription.isNotEmpty
                ? task.afterDescription
                : null,
          ),
        )
        .toList();

    final bool hasPhotoChanges =
        _userManuallyAddedTask || _photoTasks.any((task) => task.photosChanged);

    widget.onSubmit(report, photos, hasPhotoChanges);
  }
}

// =============================================================================
// WIDGETS ATÓMICOS LOCALES
// =============================================================================

class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.error.withOpacity(0.5), width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}

class _ModernDatePicker extends StatelessWidget {
  final String label;
  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isTime;
  final String? errorText;

  const _ModernDatePicker({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.isTime = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = isTime
        ? '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
        : '${value.day}/${value.month}/${value.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(16),
              border: errorText != null 
                  ? Border.all(color: AppColors.error)
                  : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(errorText!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ),
      ],
    );
  }
}