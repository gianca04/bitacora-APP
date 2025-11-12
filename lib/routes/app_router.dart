import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../views/profile_page.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../providers/app_providers.dart';
import '../views/app_shell.dart';
import '../views/sign_in_page.dart';
import '../views/about_page.dart';
import '../views/contact_page.dart';
import '../views/settings_page.dart';
import '../views/work_report_list_page.dart';
import '../views/work_report_form_page.dart';
import '../views/work_report_detail_page.dart';
import '../models/work_report.dart';
import '../views/home_page.dart';
import '../views/loading_page.dart';

/// Notifier for GoRouter to listen to auth state changes
class _GoRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _initialized = false;

  _GoRouterNotifier(this._ref) {
    debugPrint('🔔 GoRouterNotifier: constructed');
    // Listen to auth state changes
    _ref.listen<AuthState>(
      authViewModelProvider,
      (previous, next) {
        debugPrint('🔔 GoRouterNotifier: Auth state changed from ${previous?.status} to ${next.status}');
        notifyListeners();
      },
    );
    
    // Listen to auth initialization
    _ref.listen<AsyncValue<bool>>(
      authInitProvider,
      (previous, next) {
        debugPrint('🔔 GoRouterNotifier: Auth init changed, loading: ${next.isLoading}, hasValue: ${next.hasValue}, error: ${next.hasError}');
        if (next.hasValue && !_initialized) {
          _initialized = true;
          notifyListeners();
        }
      },
    );
  }
}

/// Provides a GoRouter that reacts to authentication state via Riverpod.
/// The router is recreated whenever the auth state changes, ensuring
/// redirects are properly evaluated.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _GoRouterNotifier(ref);
  
  return GoRouter(
    // Use signin as initial location and redirect to /loading only while
    // auth initialization is in progress. This avoids getting stuck on
    // /loading if something prevents the redirect from running.
    initialLocation: '/signin',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    routes: [
      // ShellRoute provides a persistent AppShell (AppBar + Drawer)
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomePage(),
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
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
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
      // Lightweight loading page shown while authInitProvider is resolving
      GoRoute(
        path: '/loading',
        name: 'loading',
        builder: (context, state) => const LoadingPage(),
      ),
    ],
    redirect: (context, state) {
      final authInit = ref.read(authInitProvider);
      final authState = ref.read(authViewModelProvider);
      final isSignInPage = state.matchedLocation == '/signin';
      final isLoadingPage = state.matchedLocation == '/loading';

      debugPrint('🔀 Router redirect: location=${state.matchedLocation}, authInit=${authInit.asData?.value}, authStatus=${authState.status}, isSignInPage=$isSignInPage');

      // While authInitProvider is resolving, show the loading page
      if (authInit.isLoading) {
        debugPrint('🔀 Router: Auth init loading, redirecting to /loading');
        return isLoadingPage ? null : '/loading';
      }

      // If initialization failed, go to signin
      if (authInit.hasError) {
        debugPrint('🔀 Router: Auth initialization error, redirecting to signin');
        return isSignInPage ? null : '/signin';
      }

      // Check authentication status
      final isAuthenticated = authState.status == AuthStatus.authenticated;

      debugPrint('🔀 Router: isAuthenticated=$isAuthenticated');

      // Authenticated users should not see signin or loading pages
      if (isAuthenticated && (isSignInPage || isLoadingPage)) {
        debugPrint('🔀 Router: ✅ Authenticated user on signin/loading page, redirecting to home');
        return '/';
      }

      // Unauthenticated users should go to signin once initialization finished
      if (!isAuthenticated && !isSignInPage) {
        debugPrint('🔀 Router: ❌ Unauthenticated user trying to access protected route, redirecting to signin');
        return '/signin';
      }

      // Allow access
      debugPrint('🔀 Router: ✓ Allowing access to ${state.matchedLocation}');
      return null;
    },
  );
});

