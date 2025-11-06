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
                // Logo que transiciona a indicador de conectividad
                const LogoToConnectivityTransition(),
                const SizedBox(width: 12),
                if (isLargeScreen)
                  Expanded(
                    child: _navBarItems(context, ref, state, controller),
                  ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _ProfileIcon(),
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
                    const SizedBox(width: 12),
                    // Indicador de conectividad en el drawer (usa preferencias del usuario)
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
                        selected: entry.key == state.selectedIndex,
                        onTap: () {
                          // navigate based on item title
                          switch (entry.value.title.toLowerCase()) {
                            case 'home':
                              scaffoldKey.currentState?.openEndDrawer();
                              context.go('/');
                              break;
                            case 'reports':
                              scaffoldKey.currentState?.openEndDrawer();
                              context.go('/reports');
                              break;
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
                              ref.read(authControllerProvider).signOut(context);
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
            ),
          ],
        ),
      );

  Widget _navBarItems(
    BuildContext context,
    WidgetRef ref,
    MenuViewState state,
    app_menu.MenuController controller,
  ) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: state.items
            .asMap()
            .entries
            .map(
              (entry) => InkWell(
                onTap: () {
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16,
                  ),
                  child: Text(
                    entry.value.title,
                    style: const TextStyle(fontSize: 18),
                  ),
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
    final app_menu.MenuController controller = ref.read(menuControllerProvider);
    final authState = ref.watch(authViewModelProvider);

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

    final String popupLabel = displayName.isNotEmpty ? displayName : (usernameLocal.isNotEmpty ? usernameLocal : 'Usuario');
    final String avatarLabel = popupLabel;

    return PopupMenuButton<ProfileMenuAction>(
      icon: CircleAvatar(
        backgroundColor: Colors.grey[900],
        child: Text(
          avatarLabel,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      offset: const Offset(0, 30),
      onSelected: (ProfileMenuAction item) => controller.onProfileAction(item, context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ProfileMenuAction>>[
        PopupMenuItem<ProfileMenuAction>(
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
        PopupMenuItem<ProfileMenuAction>(
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
        PopupMenuItem<ProfileMenuAction>(
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
    );
  }
}
