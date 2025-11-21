import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Modern styled text field with icon and customizable validation
/// 
/// A reusable text input field with consistent styling across the app,
/// featuring a prefix icon, custom colors, and validation support.
/// 
/// Example:
/// ```dart
/// ModernTextField(
///   controller: _nameController,
///   label: 'Título del Reporte',
///   hint: 'Ej: Mantenimiento Preventivo Torre A',
///   icon: Icons.title,
///   validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
/// )
/// ```
class ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextStyle? style;
  final Color? fillColor;
  final Color? iconColor;
  final double borderRadius;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.style,
    this.fillColor,
    this.iconColor,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: style ?? const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(
          icon,
          color: iconColor ?? AppColors.textSecondary,
        ),
        filled: true,
        fillColor: fillColor ?? AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.error.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}
