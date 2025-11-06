import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../models/menu_item_model.dart';

class MenuRepository {
  // In a real app this might call an API or database. Kept sync for simplicity.
  List<MenuItemModel> fetchMenuItems() {
    // Titles in Spanish and small heroicons for the drawer/navbar
    return [
      MenuItemModel(
        'Inicio',
        icon: const HeroIcon(HeroIcons.home, color: Colors.white70, size: 18),
        route: '/',
      ),
      MenuItemModel(
        'Reportes',
        icon: const HeroIcon(HeroIcons.chartBar, color: Colors.white70, size: 18),
        route: '/reports',
      ),
      MenuItemModel(
        'Acerca',
        icon: const HeroIcon(HeroIcons.informationCircle, color: Colors.white70, size: 18),
        route: '/about',
      ),
      MenuItemModel(
        'Contacto',
        icon: const HeroIcon(HeroIcons.phone, color: Colors.white70, size: 18),
        route: '/contact',
      ),
      MenuItemModel(
        'Ajustes',
        icon: const HeroIcon(HeroIcons.cog, color: Colors.white70, size: 18),
        route: '/settings',
      ),
      MenuItemModel(
        'Cerrar sesión',
        icon: const HeroIcon(HeroIcons.arrowLeftOnRectangle, color: Colors.white70, size: 18),
        route: '/signin',
      ),
    ];
  }
}
