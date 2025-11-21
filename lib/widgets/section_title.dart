import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Reusable section title with icon and styled text
/// 
/// Displays a consistent header for form sections with an icon,
/// uppercase text, and primary color styling.
/// 
/// Example:
/// ```dart
/// SectionTitle(
///   title: 'Detalles Generales',
///   icon: Icons.dashboard_customize,
/// )
/// ```
class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Color? textColor;
  final double iconSize;
  final double fontSize;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.textColor,
    this.iconSize = 20,
    this.fontSize = 14,
    this.spacing = 12,
    this.padding = const EdgeInsets.only(bottom: 16, left: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: iconSize,
          ),
          SizedBox(width: spacing),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: textColor ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
