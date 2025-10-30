import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/menu_item_model.dart';
import '../viewmodels/menu_viewmodel.dart';

class MenuController {
  final Ref ref;

  MenuController(this.ref);

  void selectMenu(int index) {
    ref.read(menuViewModelProvider.notifier).select(index);
  }

  void onProfileAction(ProfileMenuAction action, BuildContext context) {
    // Handle profile actions (navigate, show dialog, logout, etc.)
    switch (action) {
      case ProfileMenuAction.account:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account')));
        break;
      case ProfileMenuAction.settings:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings')));
        break;
      case ProfileMenuAction.signOut:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign Out')));
        break;
    }
  }
}

final menuControllerProvider = Provider<MenuController>((ref) => MenuController(ref));

