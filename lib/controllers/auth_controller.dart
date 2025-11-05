import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../providers/app_providers.dart';
import '../widgets/cupertino_notification_banner.dart';

/// Controller for authentication operations
/// Acts as a facade between UI and AuthViewModel
/// Handles UI feedback through notifications
class AuthController {
  final Ref ref;

  AuthController(this.ref);

  /// Check authentication status on app start
  /// Returns true if user is authenticated from stored token
  Future<bool> checkAuthStatus() async {
    return await ref.read(authViewModelProvider.notifier).checkAuthStatus();
  }

  /// Attempts sign in with visual feedback
  /// Returns true if successful, false otherwise
  /// Shows notification banner on success or error
  Future<bool> signIn({
    required BuildContext context,
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    print('🎮 AuthController: Iniciando signIn');
    
    final success = await ref.read(authViewModelProvider.notifier).signIn(
          email: email,
          password: password,
          rememberMe: rememberMe,
        );

    print('🎮 AuthController: signIn completado, success: $success');

    final state = ref.read(authViewModelProvider);

    // Use WidgetsBinding to ensure we show notification after frame
    if (success) {
      print('🎮 AuthController: Mostrando notificación de éxito');
      // Delay to ensure context is still valid
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          // Use a SnackBar instead of custom overlay to avoid potential overlay
          // related freezes during debugging. This is a temporary change.
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inicio de sesión exitoso'),
                backgroundColor: Color(0xFF34C759),
                duration: Duration(seconds: 2),
              ),
            );
          } catch (e, st) {
            print('❌ AuthController: Error mostrando SnackBar de éxito: $e\n$st');
          }

          // Navigate to home after successful sign in. Use GoRouter to ensure
          // navigation is performed within the router context. We schedule
          // it on the next frame so the banner can be shown reliably.
          try {
            context.go('/');
          } catch (e) {
            // If go() fails for any reason, fall back to Navigator
            print('⚠️ AuthController: go() failed, falling back to Navigator: $e');
            Navigator.of(context).pushReplacementNamed('/');
          }
        }
      });
      print('🎮 AuthController: Notificación programada');
    } else {
      print('🎮 AuthController: Mostrando notificación de error');
      // Show error notification immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error al iniciar sesión'),
                backgroundColor: const Color(0xFFFF3B30),
                duration: const Duration(seconds: 4),
              ),
            );
          } catch (e, st) {
            print('❌ AuthController: Error mostrando SnackBar de error: $e\n$st');
          }
        }
      });
    }

    print('🎮 AuthController: Retornando success: $success');
    return success;
  }

  /// Sign out with visual feedback
  Future<void> signOut(BuildContext context) async {
    await ref.read(authViewModelProvider.notifier).signOut();

    // Show logout notification
    CupertinoNotificationBanner.show(
      context,
      message: 'Sesión cerrada',
      type: NotificationType.info,
      showLogo: true,
      duration: const Duration(seconds: 2),
    );
  }

  /// Get current auth state
  AuthState get state => ref.read(authViewModelProvider);

  /// Watch auth state for reactive UI
  AuthState watch() => ref.watch(authViewModelProvider);
}
