import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/menu_item_model.dart';
import '../viewmodels/menu_viewmodel.dart';
import '../controllers/menu_controller.dart' as menu_ctrl;
import '../controllers/auth_controller.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroicons/heroicons.dart';

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
                // Small logo in the AppBar for branding
                SvgPicture.asset('assets/images/svg/logo.svg', height: 28),
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
        drawer: isLargeScreen
            ? null
            : _drawer(context, ref, state, controller, scaffoldKey),
        body: Center(child: Text('Selected: ${state.selectedIndex}')),
      ),
    );
  }

  Widget _drawer(
    BuildContext context,
    WidgetRef ref,
    MenuViewState state,
    menu_ctrl.MenuController controller,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) => Drawer(
    child: Column(
      children: [
        // Header with SVG logo
        _SidebarHeader(),
        // Navigation items
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: state.items
                .asMap()
                .entries
                .map(
                  (entry) => _SidebarItem(
                    title: entry.value.title,
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
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );

  // Sidebar header widget placed at top of the drawer. Kept private and in
  // the same file for locality (per your request).
  Widget _SidebarHeader() => SizedBox(
    height: 100,
    child: DrawerHeader(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [SvgPicture.asset('assets/images/svg/logo.svg', height: 35)],
      ),
    ),
  );

  // Small reusable widget for sidebar items. Keeps visual consistency and
  // makes the drawer mapping concise.
  Widget _SidebarItem({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) => ListTile(selected: selected, onTap: onTap, title: Text(title));

  Widget _navBarItems(
    BuildContext context,
    WidgetRef ref,
    MenuViewState state,
    menu_ctrl.MenuController controller,
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
    final controller = ref.read(menu_ctrl.menuControllerProvider);
    final authState = ref.watch(authViewModelProvider);

    // Prefer showing a displayName if it's provided on the user object.
    // Fallback to the email local-part (before @). If none available, use 'U'.
    String displayName = '';
    String usernameLocal = '';
    if (authState.user != null) {
      // Access displayName dynamically so this code works while the model
      // may or may not include a displayName field. If you add
      // `displayName` to `AuthUser`, the dynamic access will pick it up.
      try {
        final dyn = authState.user as dynamic;
        final dn = dyn.displayName;
        if (dn is String && dn.isNotEmpty) displayName = dn;
      } catch (_) {
        // ignore - no displayName present on the current model
      }

      final email = authState.user!.email;
      if (email.isNotEmpty) {
        usernameLocal = email.split('@').first;
      }
    }

    // Text to show in the popup menu (full display name or username local-part)
    final String popupLabel = displayName.isNotEmpty ? displayName : (usernameLocal.isNotEmpty ? usernameLocal : 'Usuario');

    // Show the full displayName or the email local-part as the avatar label.
    // This matches the popup label and gives the user a textual identifier.
    final String avatarLabel = popupLabel;

    return PopupMenuButton<ProfileMenuAction>(
      // Use a circular avatar showing the user's name (or local-part) as the
      // button content. If the text is long, it will be shown as-is; consider
      // trimming or styling if you want shorter avatars later.
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
      onSelected: (ProfileMenuAction item) =>
          controller.onProfileAction(item, context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
      ),
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<ProfileMenuAction>>[
            // Show the displayName if available, otherwise the username local-part.
            PopupMenuItem<ProfileMenuAction>(
              value: ProfileMenuAction.account,
              child: Row(
                children: [
                  // Heroicons user icon next to the username
                  HeroIcon(
                    HeroIcons.userCircle,
                    color: Colors.white70,
                    size: 20,
                  ),
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
                  HeroIcon(
                    HeroIcons.cog,
                    color: Colors.white70,
                    size: 18,
                  ),
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
                  HeroIcon(
                    HeroIcons.arrowLeftOnRectangle,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Flexible(child: Text('Cerrar sesión')),
                ],
              ),
            ),
          ],
    );
  }
}
