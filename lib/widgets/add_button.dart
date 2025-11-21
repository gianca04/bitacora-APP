import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Reusable styled button for adding new items
/// 
/// Displays a prominent button with icon and text, commonly used to add
/// new photos, tasks, or other list items.
/// 
/// Example:
/// ```dart
/// AddButton(
///   label: 'Agregar Nueva Evidencia',
///   icon: Icons.add_a_photo,
///   onPressed: () {
///     // Add new item
///   },
/// )
/// ```
class AddButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? primaryColor;
  final double iconSize;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const AddButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primaryColor,
    this.iconSize = 32,
    this.borderWidth = 1.5,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 20),
  });

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? AppColors.primary;
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: padding,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: color,
            style: BorderStyle.solid,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
