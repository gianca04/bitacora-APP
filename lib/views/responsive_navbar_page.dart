import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/menu_item_model.dart';
import '../viewmodels/menu_viewmodel.dart';
import '../controllers/menu_controller.dart' as menu_ctrl;
import '../controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';

class ResponsiveNavBarPage extends ConsumerWidget {
  const ResponsiveNavBarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;
    final state = ref.watch(menuViewModelProvider);
  final controller = ref.read(menu_ctrl.menuControllerProvider);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          leading: isLargeScreen
              ? null
              : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Logo",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLargeScreen) Expanded(child: _navBarItems(context, ref, state, controller)),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: _ProfileIcon()),
            ),
          ],
        ),
  drawer: isLargeScreen ? null : _drawer(context, ref, state, controller, scaffoldKey),
        body: Center(child: Text('Selected: ${state.selectedIndex}')),
      ),
    );
  }

  Widget _drawer(BuildContext context, WidgetRef ref, MenuViewState state, menu_ctrl.MenuController controller, GlobalKey<ScaffoldState> scaffoldKey) => Drawer(
        child: ListView(
          children: state.items
              .asMap()
              .entries
              .map(
                (entry) => ListTile(
                  selected: entry.key == state.selectedIndex,
                  onTap: () {
                    // navigate based on item title
                    switch (entry.value.title.toLowerCase()) {
                      case 'about':
                        scaffoldKey.currentState?.openEndDrawer();
                        context.go('/about');
                        break;
                      case 'contact':
                        scaffoldKey.currentState?.openEndDrawer();
                        context.go('/contact');
                        break;
                      case 'settings':
                        scaffoldKey.currentState?.openEndDrawer();
                        context.go('/settings');
                        break;
                      case 'sign out':
                        controller.selectMenu(entry.key);
                        ref.read(authControllerProvider).signOut();
                        scaffoldKey.currentState?.openEndDrawer();
                        context.go('/signin');
                        break;
                      default:
                        controller.selectMenu(entry.key);
                        scaffoldKey.currentState?.openEndDrawer();
                    }
                  },
                  title: Text(entry.value.title),
                ),
              )
              .toList(),
        ),
      );

  Widget _navBarItems(BuildContext context, WidgetRef ref, MenuViewState state, menu_ctrl.MenuController controller) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: state.items
            .asMap()
            .entries
            .map(
              (entry) => InkWell(
                onTap: () {
                  switch (entry.value.title.toLowerCase()) {
                    case 'about':
                      context.go('/about');
                      break;
                    case 'contact':
                      context.go('/contact');
                      break;
                    case 'settings':
                      context.go('/settings');
                      break;
                    case 'sign out':
                      controller.selectMenu(entry.key);
                      ref.read(authControllerProvider).signOut();
                      context.go('/signin');
                      break;
                    default:
                      controller.selectMenu(entry.key);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16,
                  ),
                  child: Text(entry.value.title, style: const TextStyle(fontSize: 18)),
                ),
              ),
            )
            .toList(),
      );
}

class _ProfileIcon extends ConsumerWidget {
  const _ProfileIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final controller = ref.read(menu_ctrl.menuControllerProvider);

    return PopupMenuButton<ProfileMenuAction>(
      icon: const Icon(Icons.person),
      offset: const Offset(0, 40),
      onSelected: (ProfileMenuAction item) => controller.onProfileAction(item, context),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ProfileMenuAction>>[
        const PopupMenuItem<ProfileMenuAction>(value: ProfileMenuAction.account, child: Text('Account')),
        const PopupMenuItem<ProfileMenuAction>(value: ProfileMenuAction.settings, child: Text('Settings')),
        const PopupMenuItem<ProfileMenuAction>(value: ProfileMenuAction.signOut, child: Text('Sign Out')),
      ],
    );
  }
}
