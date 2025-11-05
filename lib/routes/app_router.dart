import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../providers/app_providers.dart';
import '../views/app_shell.dart';
import '../views/responsive_navbar_page.dart';
import '../views/sign_in_page.dart';
import '../views/about_page.dart';
import '../views/contact_page.dart';
import '../views/settings_page.dart';
import '../views/work_report_list_page.dart';
import '../views/work_report_form_page.dart';
import '../views/work_report_detail_page.dart';
import '../models/work_report.dart';

/// Provides a GoRouter that reacts to authentication state via Riverpod.
/// The router is recreated whenever the auth state changes, ensuring
/// redirects are properly evaluated.
final routerProvider = Provider<GoRouter>((ref) {
  // Watch both the auth initialization and auth state
  final authInit = ref.watch(authInitProvider);
  final authState = ref.watch(authViewModelProvider);
  
  print('🔄 Router: Creating router with auth init: ${authInit.asData?.value}, auth status: ${authState.status}');

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
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
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const WorkReportListPage(),
            routes: [
              // Subruta para crear nuevo reporte
              GoRoute(
                path: 'new',
                name: 'new-report',
                builder: (context, state) => const WorkReportFormPage(),
              ),
              // Subruta para ver detalle de reporte
              GoRoute(
                path: ':id',
                name: 'report-detail',
                builder: (context, state) {
                  final report = state.extra as WorkReport;
                  return WorkReportDetailPage(workReport: report);
                },
              ),
              // Subruta para editar reporte
              GoRoute(
                path: ':id/edit',
                name: 'edit-report',
                builder: (context, state) {
                  final report = state.extra as WorkReport;
                  return WorkReportFormPage(workReport: report);
                },
              ),
            ],
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
      final authInit = ref.read(authInitProvider);
      final authState = ref.read(authViewModelProvider);
      final isSignInPage = state.matchedLocation == '/signin';

      print('🔀 Router redirect: location=${state.matchedLocation}, authInit=${authInit.asData?.value}, authStatus=${authState.status}, isSignInPage=$isSignInPage');

      // Wait for auth initialization to complete
      if (authInit.isLoading) {
        print('🔀 Router: Still initializing auth, waiting...');
        return null; // Don't redirect while checking stored auth
      }

      // During loading (checking stored auth), allow navigation to complete
      // Don't redirect yet, wait for auth check to finish
      if (authState.status == AuthStatus.loading) {
        print('🔀 Router: Loading state - checking stored auth...');
        return null; // Don't redirect, let the current navigation proceed
      }

      // During initial state (shouldn't happen anymore since we start with loading)
      if (authState.status == AuthStatus.initial) {
        print('🔀 Router: Initial state detected');
        final redirect = isSignInPage ? null : '/signin';
        print('🔀 Router: Redirecting to $redirect');
        return redirect;
      }

      // If user is authenticated
      if (authState.status == AuthStatus.authenticated) {
        print('🔀 Router: User is authenticated');
        // Redirect authenticated users away from signin page
        if (isSignInPage) {
          print('🔀 Router: On signin page, redirecting to home');
          return '/';
        }
        // Allow access to all other pages
        print('🔀 Router: Allowing access to ${state.matchedLocation}');
        return null;
      }

      // If user is not authenticated (error state or unauthenticated)
      if (!isSignInPage) {
        print('🔀 Router: Not authenticated, redirecting to signin');
        // Redirect to signin page
        return '/signin';
      }

      // Already on signin page and not authenticated - allow access
      print('🔀 Router: On signin page, not authenticated, allowing access');
      return null;
    },
  );
});

