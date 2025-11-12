import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';

import '../models/menu_item_model.dart';
import '../viewmodels/menu_viewmodel.dart';
import '../controllers/menu_controller.dart' as app_menu;
import '../providers/app_providers.dart';
import '../widgets/logo_to_connectivity_transition.dart';
import '../widgets/connectivity_indicator.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;
    final state = ref.watch(menuViewModelProvider);
    final app_menu.MenuController controller = ref.read(menuControllerProvider);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leadingWidth: 72,
          leading: _AppBarLeading(
            isLargeScreen: isLargeScreen,
            scaffoldKey: scaffoldKey,
          ),
          centerTitle: true,
          title: _AppBarTitle(
            isLargeScreen: isLargeScreen,
            state: state,
            controller: controller,
            ref: ref,
          ),
          actions: [
            SizedBox(
              width: 72,
              child: _AppBarActions(),
            ),
          ],
        ),
        drawer: isLargeScreen ? null : _drawer(context, ref, state, controller, scaffoldKey),
        body: child,
      ),
    );
  }

  Widget _drawer(
    BuildContext context,
    WidgetRef ref,
    MenuViewState state,
    app_menu.MenuController controller,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) => Drawer(
        child: Column(
          children: [
            // Header with SVG logo
            SizedBox(
              height: 100,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/svg/logo.svg', height: 20),
                    const SizedBox(width: 30),
                    const ConnectivityIndicator(),
                  ],
                ),
              ),
            ),
            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: state.items
                    .asMap()
                    .entries
                    .map(
                      (entry) => ListTile(
                        leading: entry.value.icon,
                        selected: entry.key == state.selectedIndex,
                        onTap: () {
                          scaffoldKey.currentState?.closeDrawer();
                          final route = entry.value.route;
                          if (route != null) {
                            if (route == '/signin') {
                              controller.selectMenu(entry.key);
                              ref.read(authControllerProvider).signOut(context);
                              context.go(route);
                            } else {
                              context.go(route);
                            }
                            return;
                          }

                          // Fallback navigation
                          switch (entry.value.title.toLowerCase()) {
                            case 'home':
                              context.go('/');
                              break;
                            case 'reports':
                              context.go('/reports');
                              break;
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
                              ref.read(authControllerProvider).signOut(context);
                              context.go('/signin');
                              break;
                            default:
                              controller.selectMenu(entry.key);
                          }
                        },
                        title: Text(entry.value.title),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
}

// Separated AppBar components for better responsibility separation

/// Leading section of AppBar - handles menu button for mobile
class _AppBarLeading extends StatelessWidget {
  final bool isLargeScreen;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _AppBarLeading({
    required this.isLargeScreen,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    if (isLargeScreen) {
      return const SizedBox(width: 72);
    }

    return SizedBox(
      width: 72,
      child: IconButton(
        icon: const Icon(Icons.menu, size: 24),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }
}

/// Title section of AppBar - contains logo and navigation items
class _AppBarTitle extends ConsumerWidget {
  final bool isLargeScreen;
  final MenuViewState state;
  final app_menu.MenuController controller;
  final WidgetRef ref;

  const _AppBarTitle({
    required this.isLargeScreen,
    required this.state,
    required this.controller,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const LogoToConnectivityTransition(),
        if (isLargeScreen) ...[
          const SizedBox(width: 24),
          Expanded(
            child: _NavBarItems(
              state: state,
              controller: controller,
              ref: ref,
            ),
          ),
        ],
      ],
    );
  }
}

/// Actions section of AppBar - contains profile avatar
class _AppBarActions extends ConsumerWidget {
  const _AppBarActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(menuControllerProvider);
    final authState = ref.watch(authViewModelProvider);

    // Extract user info
    String displayName = '';
    String usernameLocal = '';
    if (authState.user != null) {
      try {
        final dyn = authState.user as dynamic;
        final dn = dyn.displayName;
        if (dn is String && dn.isNotEmpty) displayName = dn;
      } catch (_) {}

      final email = authState.user!.email;
      if (email.isNotEmpty) usernameLocal = email.split('@').first;
    }

    final popupLabel = displayName.isNotEmpty ? displayName : (usernameLocal.isNotEmpty ? usernameLocal : 'Usuario');
    final avatarLabel = popupLabel.isNotEmpty ? popupLabel.substring(0, 1).toUpperCase() : 'U';

    return Center(
      child: PopupMenuButton<ProfileMenuAction>(
        icon: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[900],
          child: Text(
            avatarLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        offset: const Offset(0, 56),
        onSelected: (item) => controller.onProfileAction(item, context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: ProfileMenuAction.account,
            child: Row(
              children: [
                HeroIcon(HeroIcons.userCircle, color: Colors.white70, size: 20),
                const SizedBox(width: 6),
                Flexible(child: Text(popupLabel)),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: ProfileMenuAction.settings,
            child: Row(
              children: [
                HeroIcon(HeroIcons.cog, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                const Flexible(child: Text('Configuración')),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: ProfileMenuAction.signOut,
            child: Row(
              children: [
                HeroIcon(HeroIcons.arrowLeftOnRectangle, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                const Flexible(child: Text('Cerrar sesión')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation items for large screens (desktop/tablet)
class _NavBarItems extends ConsumerWidget {
  final MenuViewState state;
  final app_menu.MenuController controller;
  final WidgetRef ref;

  const _NavBarItems({
    required this.state,
    required this.controller,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: state.items
          .asMap()
          .entries
          .map(
            (entry) => InkWell(
              onTap: () => _handleNavItemTap(context, entry, controller, ref),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (entry.value.icon != null) ...[
                      entry.value.icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      entry.value.title,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  void _handleNavItemTap(
    BuildContext context,
    MapEntry<int, MenuItemModel> entry,
    app_menu.MenuController controller,
    WidgetRef ref,
  ) {
    final route = entry.value.route;
    if (route != null) {
      if (route == '/signin') {
        controller.selectMenu(entry.key);
        ref.read(authControllerProvider).signOut(context);
        context.go(route);
      } else {
        context.go(route);
      }
      return;
    }

    switch (entry.value.title.toLowerCase()) {
      case 'home':
        context.go('/');
        break;
      case 'reports':
        context.go('/reports');
        break;
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
        ref.read(authControllerProvider).signOut(context);
        context.go('/signin');
        break;
      default:
        controller.selectMenu(entry.key);
    }
  }
}
