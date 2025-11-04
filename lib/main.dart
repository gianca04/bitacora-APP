import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_router.dart';
import 'services/isar_service.dart';
import 'services/connectivity_service.dart';
import 'widgets/no_connection_banner.dart';
import 'providers/app_providers.dart';

void main() async {
  // Ensure Flutter bindings are initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar database before running the app
  await IsarService().initialize();
  
  // Initialize connectivity monitoring service
  await ConnectivityService().initialize();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  /// Check if user has valid stored authentication on app start
  Future<void> _checkAuthenticationStatus() async {
    try {
      // Check for stored authentication token
      await ref.read(authControllerProvider).checkAuthStatus();
    } catch (e) {
      print('Error checking auth status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  // Root widget uses MaterialApp.router wired to the GoRouter from provider
  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);

    // Show splash screen while checking authentication
    if (_isCheckingAuth) {
      return MaterialApp(
        title: 'Bitácora',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const _SplashScreen(),
      );
    }

    return MaterialApp.router(
      title: 'Bitácora',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
      // Envolver con NoConnectionBanner para monitoreo global
      builder: (context, child) {
        return NoConnectionBanner(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Simple splash screen shown while checking authentication
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF18181B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can add your logo here
            Icon(
              Icons.verified_user,
              size: 80,
              color: Color(0xFF2A8D8D),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: Color(0xFF2A8D8D),
            ),
            SizedBox(height: 16),
            Text(
              'Verificando autenticación...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}