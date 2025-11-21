import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

/// Modern styled date/time picker button
/// 
/// A reusable button-style picker for selecting dates or times with
/// consistent styling and tap handling.
/// 
/// Example:
/// ```dart
/// ModernDatePicker(
///   label: 'Fecha del Servicio',
///   value: _reportDate,
///   icon: Icons.calendar_month,
///   onTap: () async {
///     final date = await showDatePicker(...);
///     if (date != null) setState(() => _reportDate = date);
///   },
/// )
/// ```
class ModernDatePicker extends StatelessWidget {
  final String label;
  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isTime;
  final String? errorText;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const ModernDatePicker({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.isTime = false,
    this.errorText,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = isTime
        ? '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
        : '${value.day}/${value.month}/${value.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(borderRadius),
              border: errorText != null
                  ? Border.all(color: AppColors.error)
                  : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              errorText!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}