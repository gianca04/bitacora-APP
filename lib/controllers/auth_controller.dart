import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    if (success) {
      print('🎮 AuthController: Mostrando notificación de éxito');
      // Show success notification
      CupertinoNotificationBanner.show(
        context,
        message: 'Inicio de sesión exitoso',
        type: NotificationType.success,
        showLogo: true,
        duration: const Duration(seconds: 2),
      );
      print('🎮 AuthController: Notificación mostrada');
    } else {
      print('🎮 AuthController: Mostrando notificación de error');
      // Show error notification
      CupertinoNotificationBanner.show(
        context,
        message: state.errorMessage ?? 'Error al iniciar sesión',
        type: NotificationType.error,
        showLogo: true,
        duration: const Duration(seconds: 4),
      );
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
