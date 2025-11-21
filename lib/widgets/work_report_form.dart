import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../models/work_report.dart';
import '../models/photo.dart';
import '../config/app_colors.dart';
import 'before_after_photo_card.dart';
import 'signature_pad_widget.dart';
import 'inputs/modern_text_field.dart';
import 'modern_date_picker.dart';
import 'inputs/rich_text_preview_field.dart';

// =============================================================================
// PANTALLA INDEPENDIENTE DE EDICIÓN (Optimización Mayor)
// =============================================================================
class RichTextEditorScreen extends StatefulWidget {
  final String label;
  final String initialContent;

  const RichTextEditorScreen({
    super.key,
    required this.label,
    required this.initialContent,
  });

  @override
  State<RichTextEditorScreen> createState() => _RichTextEditorScreenState();
}

class _RichTextEditorScreenState extends State<RichTextEditorScreen> {
  final HtmlEditorController controller = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar: ${widget.label}'),
        backgroundColor: AppColors.surfaceDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              final txt = await controller.getText();
              if (mounted) Navigator.pop(context, txt);
            },
          ),
        ],
      ),
      body: HtmlEditor(
        controller: controller,
        htmlEditorOptions: HtmlEditorOptions(
          hint: "Escriba aquí...",
          initialText: widget.initialContent,
          darkMode: true, // Asumo tema oscuro por tus colores
          adjustHeightForKeyboard: true,
        ),
        otherOptions: const OtherOptions(
          height: 500, // Altura fija o expandida
        ),
      ),
    );
  }
}

// =============================================================================
// CLASES AUXILIARES (Mantenidas)
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

  // --- Controllers Nativos ---
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _employeeIdController;
  late final TextEditingController _projectIdController;

  // --- VARIABLES DE ESTADO (Sin Controllers HTML aquí) ---
  String _suggestionsContent = '';
  String _toolsContent = '';
  String _personnelContent = '';
  String _materialsContent = '';

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now();
  DateTime _reportDate = DateTime.now();

  String? _reportDateError;
  String? _timeError;

  final List<_PhotoTaskDraft> _photoTasks = [];
  bool _userManuallyAddedTask = false;

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
  }

  void _loadFormData() {
    if (widget.workReport == null) return;
    final report = widget.workReport!;

    _nameController.text = report.name;
    _descriptionController.text = report.description;
    _employeeIdController.text = report.employeeId?.toString() ?? '';
    _projectIdController.text = report.projectId?.toString() ?? '';

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
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _employeeIdController.dispose();
    _projectIdController.dispose();
    super.dispose();
  }

  // ... (El método didUpdateWidget y _loadExistingPhotos se mantienen igual)
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
  Widget build(BuildContext context) {
    // Usamos SingleChildScrollView en lugar de ListView para formularios complejos
    // donde queremos mantener el estado de los hijos.
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          physics: const ClampingScrollPhysics(), // Scroll más nativo
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                'Detalles Generales',
                Icons.dashboard_customize,
              ),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              _buildSectionTitle('Cronología', Icons.access_time_filled),
              _buildDateTimeSection(),
              const SizedBox(height: 24),

              _buildSectionTitle('Bitácora', Icons.menu_book),
              _buildRichTextDetails(), // AQUI ESTA LA OPTIMIZACION
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
      ),
    );
  }

  // --- SECCIONES ---

  // (Se mantiene igual pero añadiendo const donde es posible)
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
        ModernTextField(
          controller: _nameController,
          label: 'Título del Reporte',
          hint: 'Ej: Mantenimiento Torre A',
          icon: Icons.title,
          validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        ModernTextField(
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
    // (Se mantiene igual, código omitido por brevedad, usar el tuyo original aquí)
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
              );
              if (date != null) setState(() => _reportDate = date);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ModernDatePicker(
                  label: 'Inicio',
                  value: _startTime,
                  icon: Icons.schedule,
                  isTime: true,
                  onTap: () => _selectTime(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernDatePicker(
                  label: 'Fin',
                  value: _endTime,
                  icon: Icons.timer_off,
                  isTime: true,
                  errorText: _timeError,
                  onTap: () => _selectTime(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time != null) {
      final dt = DateTime(
        initial.year,
        initial.month,
        initial.day,
        time.hour,
        time.minute,
      );
      setState(() {
        if (isStart)
          _startTime = dt;
        else
          _endTime = dt;
        _timeError = null;
      });
    }
  }

  // 🚀 OPTIMIZACIÓN: Reemplazo de HtmlEditors pesados por Previews ligeros
  Widget _buildRichTextDetails() {
    return Column(
      children: [
        RichTextPreviewField(
          label: 'Sugerencias',
          content: _suggestionsContent,
          hint: 'Toque para añadir sugerencias...',
          onTap: () =>
              _openHtmlEditor('Sugerencias', _suggestionsContent, (val) {
                setState(() => _suggestionsContent = val);
              }),
        ),
        const SizedBox(height: 16),
        RichTextPreviewField(
          label: 'Herramientas',
          content: _toolsContent,
          hint: 'Toque para listar herramientas...',
          onTap: () => _openHtmlEditor('Herramientas', _toolsContent, (val) {
            setState(() => _toolsContent = val);
          }),
        ),
        const SizedBox(height: 16),
        RichTextPreviewField(
          label: 'Personal',
          content: _personnelContent,
          hint: 'Toque para añadir personal...',
          onTap: () => _openHtmlEditor('Personal', _personnelContent, (val) {
            setState(() => _personnelContent = val);
          }),
        ),
        const SizedBox(height: 16),
        RichTextPreviewField(
          label: 'Materiales',
          content: _materialsContent,
          hint: 'Toque para listar materiales...',
          onTap: () => _openHtmlEditor('Materiales', _materialsContent, (val) {
            setState(() => _materialsContent = val);
          }),
        ),
      ],
    );
  }

  // Lógica para abrir el editor en pantalla completa
  void _openHtmlEditor(
    String title,
    String currentContent,
    Function(String) onSave,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RichTextEditorScreen(label: title, initialContent: currentContent),
      ),
    );

    if (result != null && result is String) {
      onSave(result);
    }
  }

  // (El resto de las secciones _buildPhotosSection, _buildSignaturesSection, etc. se mantienen iguales)
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
                // No usamos setState para todo, solo actualizamos datos
                // Si necesitas refrescar UI, usa setState.
                // Aquí está bien, pero en apps grandes usaríamos Provider/Bloc
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
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(16),
              color: AppColors.primary.withOpacity(0.05),
            ),
            child: const Column(
              children: [
                Icon(Icons.add_a_photo, color: AppColors.primary, size: 32),
                SizedBox(height: 8),
                Text(
                  "Agregar Nueva Evidencia",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
            // CORRECCIÓN: Convertimos los bytes a Base64 String para que el widget lo entienda
            initialSignature: _supervisorSignature != null
                ? base64Encode(_supervisorSignature!)
                : null,
            onSignatureChanged: (sig) =>
                setState(() => _supervisorSignature = sig),
          ),
          const SizedBox(height: 24),
          SignaturePadWidget(
            label: 'Firma del Gerente',
            color: AppColors.secondary,
            // CORRECCIÓN: Lo mismo para la firma del gerente
            initialSignature: _managerSignature != null
                ? base64Encode(_managerSignature!)
                : null,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          widget.workReport == null ? 'GUARDAR REPORTE' : 'ACTUALIZAR REPORTE',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- LÓGICA DE SUBMIT (Optimizada) ---
  String? _validateInteger(String? value) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) return 'Solo números';
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Construcción del objeto (Igual que antes)
    final report = WorkReport(
      id: widget.workReport?.id ?? Isar.autoIncrement,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      employeeId: int.tryParse(_employeeIdController.text.trim()),
      projectId: int.tryParse(_projectIdController.text.trim()),
      startTime: _startTime,
      endTime: _endTime,
      reportDate: _reportDate,
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

    widget.onSubmit(
      report,
      photos,
      _userManuallyAddedTask || _photoTasks.any((task) => task.photosChanged),
    );
  }
}

// =============================================================================
// WIDGETS LOCALES (Componentes Atómicos)
// =============================================================================
