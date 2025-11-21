// Este componente encapsula el diseño "Premium" que creamos. Si mañana quieres cambiar el color de los tabs, solo tocas este archivo.
import 'package:flutter/material.dart';
import '../config/app_colors.dart'; // Asegúrate de importar tus colores
import 'tab_item.dart'; // Tu ModernTabItem

class CustomFloatingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isEditing;
  
  // Definimos los tabs aquí o los recibimos por parámetro si son dinámicos
  final List<Widget> tabs;

  const CustomFloatingAppBar({
    super.key,
    required this.title,
    required this.isEditing,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black, // Fondo negro puro
      iconTheme: const IconThemeData(color: Colors.white),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          height: 50,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B), // Tu Surface Dark
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.all(4),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            
            // Estilos
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade500,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            
            // Indicador Visual
            indicator: BoxDecoration(
              color: AppColors.primary, 
              borderRadius: BorderRadius.circular(21),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            
            // Los Tabs que pasamos
            tabs: tabs,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 70);
}