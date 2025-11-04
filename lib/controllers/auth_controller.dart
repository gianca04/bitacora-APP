import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../providers/app_providers.dart';

/// Controller for authentication operations
/// Acts as a facade between UI and AuthViewModel
/// Note: In Riverpod best practices, controllers are optional.
/// You can work directly with ViewModels from the UI.
class AuthController {
  final Ref ref;

  AuthController(this.ref);

  /// Attempts sign in and returns the resulting AuthState.
  Future<AuthState> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await ref.read(authViewModelProvider.notifier).signIn(
          email: email,
          password: password,
          rememberMe: rememberMe,
        );
    return ref.read(authViewModelProvider);
  }

  void signOut() {
    ref.read(authViewModelProvider.notifier).signOut();
  }
}
