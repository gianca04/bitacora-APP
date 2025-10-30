import 'dart:async';

import '../models/auth_user.dart';

class AuthRepository {
  /// Simulate a network login with artificial delay.
  /// Returns an AuthUser on success or throws on failure.
  Future<AuthUser> signIn({required String email, required String password, required bool rememberMe}) async {
    await Future.delayed(const Duration(seconds: 1));

    // Very simple validation emulation
    if (email == 'user@example.com' && password == 'password') {
      return AuthUser(id: 'uid-123', email: email);
    }

    throw Exception('Credenciales inválida');
  }
}
