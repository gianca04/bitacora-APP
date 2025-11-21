import 'package:flutter/material.dart';
import '../config/app_colors.dart'; // Tu archivo de colores

class ModernTabItem extends StatelessWidget {
  final String title;
  final int count;
  final bool isSelected; // Opcional: para cambiar estilos si está activo

  const ModernTabItem({
    super.key,
    required this.title,
    required this.count,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Tab de Flutter impone altura, usamos Center para asegurar alineación
    return Tab(
      height: 46, // Altura estándar cómoda
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Importante para que el InkWell del Tab no se rompa
        children: [
          // Título del Tab
          Text(
            title,
            style: TextStyle(
              // El TabBar padre suele controlar el color, pero podemos forzar peso
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          
          // Badge de Contador (Solo se muestra si count > 0)
          // Usamos AnimatedScale para una entrada suave
          if (count > 0) ...[
            const SizedBox(width: 8),
            _buildBadge(),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge() {
    // Formato: 9, 99, 99+
    final String displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // Usamos el color secundario para resaltar (ej. turquesa/verde)
        // o un color de "error" suave si es algo pendiente.
        color: AppColors.secondary, 
        borderRadius: BorderRadius.circular(12), // Forma de píldora/cápsula
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        displayCount,
        style: const TextStyle(
          color: Colors.white, // Texto blanco para contraste sobre color fuerte
          fontSize: 10,
          fontWeight: FontWeight.w900, // Extra bold para legibilidad pequeña
        ),
      ),
    );
  }
}