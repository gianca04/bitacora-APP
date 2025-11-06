import 'package:flutter/widgets.dart';

class MenuItemModel {
  final String title;
  final Widget? icon;
  final String? route;

  const MenuItemModel(this.title, {this.icon, this.route});
}

enum ProfileMenuAction { account, settings, signOut }
