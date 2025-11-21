import 'package:flutter/material.dart';

/// Paleta de colores de la aplicación Bitácora
/// Esta clase centraliza todos los colores usados en la app
/// para mantener consistencia visual y facilitar cambios de tema.
class AppColors {
  // Constructor privado para prevenir instanciación
  AppColors._();
  
  // --- COLORES PRIMARIOS ---
  static const Color primary = Color(0xFF005A9C);
  static const Color secondary = Color(0xFF004070);
  
  // --- COLORES DE FONDO ---
  static const Color backgroundLight = Color(0xFFF0F2F5);
  static const Color backgroundDark = Color(0xFF101922);
  
  // --- COLORES DE SUPERFICIE ---
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B); // Slate-800
  
  // --- COLORES DE BORDE ---
  static const Color borderLight = Color(0xFFE2E8F0); // Slate-200
  static const Color borderDark = Color(0xFF334155); // Slate-700
  
  // --- COLORES DE TEXTO ---
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8); // Slate-400
  static const Color textLight = Color(0xFF1E293B);
  
  // --- COLORES DE ESTADO ---
  static const Color error = Colors.redAccent;
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // --- GRADIENTES ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // --- MÉTODOS HELPER ---
  
  /// Retorna un color con opacidad específica
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Colores para estados de conectividad
  static Color get connected => success;
  static Color get disconnected => error;
  static Color get connecting => warning;
}
