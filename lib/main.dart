import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_router.dart';
import 'services/isar_service.dart';
import 'services/connectivity_service.dart';
import 'widgets/no_connection_banner.dart';

void main() async {
  // Ensure Flutter bindings are initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Inicializando base de datos Isar...');
  // Initialize Isar database before running the app
  await IsarService().initialize();
  print('✅ Base de datos Isar inicializada');
  
  print('🚀 Inicializando ConnectivityService...');
  // Initialize connectivity monitoring service
  await ConnectivityService().initialize();
  print('✅ ConnectivityService inicializado');
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Root widget uses MaterialApp.router wired to the GoRouter from provider
  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);

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