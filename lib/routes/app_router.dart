import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../providers/app_providers.dart';
import '../views/app_shell.dart';
import '../views/responsive_navbar_page.dart';
import '../views/sign_in_page.dart';
import '../views/about_page.dart';
import '../views/contact_page.dart';
import '../views/settings_page.dart';

/// Provides a GoRouter that reacts to authentication state via Riverpod.
final routerProvider = Provider<GoRouter>((ref) {
  // Create a small ChangeNotifier that we can pass to GoRouter so it
  // re-evaluates redirects when the auth state changes.
  final refresh = _AuthChangeNotifier();

  // Listen to the Riverpod auth state and notify the ChangeNotifier when it
  // changes. This keeps a single GoRouter instance that responds to auth
  // updates (sign in / sign out) by re-running the `redirect` logic.
  ref.listen<AuthState>(
    authViewModelProvider,
    (previous, next) => refresh.notify(),
  );

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    routes: [
      // ShellRoute provides a persistent AppShell (AppBar + Drawer)
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const ResponsiveNavBarPage(),
          ),
          GoRoute(
            path: '/about',
            name: 'about',
            builder: (context, state) => const AboutPage(),
          ),
          GoRoute(
            path: '/contact',
            name: 'contact',
            builder: (context, state) => const ContactPage(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      // Standalone sign-in route (doesn't include the AppShell)
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const SignInPage(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authViewModelProvider);
      final loggingIn = state.location == '/signin';

      // If the user is not authenticated, send them to /signin unless
      // they're already on the sign-in page.
      if (authState.status != AuthStatus.authenticated && !loggingIn) {
        return '/signin';
      }

      // If the user is authenticated and tries to go to the sign-in page,
      // send them to the home page.
      if (authState.status == AuthStatus.authenticated && loggingIn) {
        return '/';
      }

      // No redirect
      return null;
    },
  );
});

/// Small ChangeNotifier used to tell GoRouter to re-run redirect logic when
/// the Riverpod auth state changes.
class _AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

