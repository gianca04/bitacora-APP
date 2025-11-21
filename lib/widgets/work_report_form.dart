import 'dart:convert';
import 'dart:typed_data';
import 'package:bitacora/widgets/inputs/CustomRichEditor.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

// Asumimos que estos imports existen en tu proyecto
import '../models/work_report.dart';
import '../models/photo.dart';
import '../config/app_colors.dart';
import 'before_after_photo_card.dart';
import 'signature_pad_widget.dart';
import 'section_title.dart';
import 'add_button.dart';
import 'inputs/modern_text_field.dart';
import 'inputs/modern_date_picker.dart';
import 'time_range_picker.dart';
import 'package:html_editor_enhanced/html_editor.dart'; // <--- Nuevo import
import 'custom_floating_tab_bar.dart';


// --- LOGIC HELPERS (Sin cambios, tu lógica es sólida) ---
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

// --- MAIN WIDGET ---
class WorkReportForm extends StatefulWidget {
  final WorkReport? workReport;
  final List<Photo>? existingPhotos;
  final Function(WorkReport report, List<Photo> photos, bool photosChanged)
  onSubmit;

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

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _employeeIdController;
  late final TextEditingController _projectIdController;

  // --- 1. CAMBIO: Nuevos Controladores HTML ---
  late final HtmlEditorController _suggestionsController;
  late final HtmlEditorController _toolsController;
  late final HtmlEditorController _personnelController;
  late final HtmlEditorController _materialsController;

  // --- 2. CAMBIO: Variables para Texto Inicial ---
  // Necesitamos guardar el texto inicial en variables string para pasarlas al widget
  String? _initialSuggestions;
  String? _initialTools;
  String? _initialPersonnel;
  String? _initialMaterials;

  // State
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

    // --- 3. CAMBIO: Instanciación simple ---
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

    // --- 4. CAMBIO: Asignar a variables Strings (Asumiendo que tu BD ya guarda HTML o String) ---
    // Si tu BD tiene JSON de Quill, esto se verá "feo" la primera vez hasta que guardes como HTML.
    _initialSuggestions = report.suggestions;
    _initialTools = report.tools;
    _initialPersonnel = report.personnel;
    _initialMaterials = report.materials;

    _startTime = report.startTime;
    _endTime = report.endTime;
    _reportDate = report.reportDate;
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

  // --- UI BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    // UI/UX Tip: GestureDetector oculta el teclado al tocar fuera
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            _buildHeaderInfo(),
            const SizedBox(height: 24),
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

  // --- SECCIONES MEJORADAS ---

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.workReport == null ? 'Nuevo Reporte' : 'Editar Reporte',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Asumiendo fondo oscuro
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete la información detallada del servicio realizado.',
          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return SectionTitle(title: title, icon: icon);
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        ModernTextField(
          controller: _nameController,
          label: 'Título del Reporte',
          hint: 'Ej: Mantenimiento Preventivo Torre A',
          icon: Icons.title,
          validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _descriptionController,
          label: 'Descripción',
          hint: 'Resumen ejecutivo de las actividades...',
          icon: Icons.short_text,
          maxLines: 3,
          validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ModernTextField(
                controller: _employeeIdController,
                label: 'ID Empleado',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                validator: _validateInteger,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ModernTextField(
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
          ModernDatePicker(
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
                      colorScheme: ColorScheme.dark(primary: AppColors.primary),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) setState(() => _reportDate = date);
            },
          ),
          const SizedBox(height: 16),
          TimeRangePicker(
            startTime: _startTime,
            endTime: _endTime,
            onStartTimeChanged: (time) => setState(() {
              _startTime = time;
              _timeError = null;
            }),
            onEndTimeChanged: (time) => setState(() {
              _endTime = time;
              _timeError = null;
            }),
            errorText: _timeError,
          ),
        ],
      ),
    );
  }

  Widget _buildRichTextDetails() {
    // Usamos un Layout Grid conceptual
    return Column(
      children: [
        CustomRichEditor(
          controller: _suggestionsController,
          label: 'Sugerencias',
          initialText: _initialSuggestions, // Pasamos el texto aquí
          hintText: 'Ingrese sugerencias...',
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        CustomRichEditor(
          controller: _toolsController,
          label: 'Herramientas',
          initialText: _initialTools,
          hintText: 'Listado de herramientas...',
        ),
        const SizedBox(height: 16),
        CustomRichEditor(
          controller: _personnelController,
          label: 'Personal Involucrado',
          initialText: _initialPersonnel,
          hintText: 'Nombres del equipo...',
        ),
        const SizedBox(height: 16),
        CustomRichEditor(
          controller: _materialsController,
          label: 'Materiales',
          initialText: _initialMaterials,
          hintText: 'Materiales utilizados...',
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

        AddButton(
          label: 'Agregar Nueva Evidencia',
          icon: Icons.add_a_photo,
          onPressed: () {
            setState(() {
              _photoTasks.add(_PhotoTaskDraft());
              _userManuallyAddedTask = true;
            });
          },
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
            onSignatureChanged: (sig) =>
                setState(() => _supervisorSignature = sig),
          ),
          const SizedBox(height: 24),
          SignaturePadWidget(
            label: 'Firma del Gerente',
            color: AppColors.secondary,
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
      height: 60, // Altura ergonómica
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

  // --- VALIDACIÓN Y LOGIC ---
  String? _validateInteger(String? value) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) return 'Solo números';
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor corrija los errores en el formulario'),
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

    final String suggestionsHtml = await _suggestionsController.getText();
    final String toolsHtml = await _toolsController.getText();
    final String personnelHtml = await _personnelController.getText();
    final String materialsHtml = await _materialsController.getText();

    setState(() {
      _timeError = null;
      _reportDateError = null;
    });

    final report = WorkReport(
      id: widget.workReport?.id ?? Isar.autoIncrement,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      employeeId: int.tryParse(_employeeIdController.text.trim()),
      projectId: int.tryParse(_projectIdController.text.trim()),
      startTime: _startTime,
      endTime: _endTime,
      reportDate: _reportDate,

      // --- Usamos los valores HTML obtenidos ---
      suggestions: suggestionsHtml,
      tools: toolsHtml,
      personnel: personnelHtml,
      materials: materialsHtml,
      supervisorSignature: _supervisorSignature != null
          ? base64Encode(_supervisorSignature!)
          : null,
      managerSignature: _managerSignature != null
          ? base64Encode(_managerSignature!)
          : null,
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