import 'package:flutter/material.dart';
import '../config/app_colors.dart'; // Tu archivo de colores

class ModernDatePicker extends StatelessWidget {
  final String label;
  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isTime;
  final String? errorText;

  const ModernDatePicker({
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color:
                  AppColors.backgroundDark, // Asegúrate que este color exista
              borderRadius: BorderRadius.circular(16),
              border: errorText != null
                  ? Border.all(color: AppColors.error)
                  : null,
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
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
