import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auth_viewmodel.dart';

class AuthController {
  final Ref ref;

  AuthController(this.ref);

  /// Attempts sign in and returns the resulting AuthState.
  Future<AuthState> signIn({required String email, required String password, required bool rememberMe}) async {
    await ref.read(authViewModelProvider.notifier).signIn(email: email, password: password, rememberMe: rememberMe);
    return ref.read(authViewModelProvider);
  }

  void signOut() {
    ref.read(authViewModelProvider.notifier).signOut();
  }
}

final authControllerProvider = Provider<AuthController>((ref) => AuthController(ref));
