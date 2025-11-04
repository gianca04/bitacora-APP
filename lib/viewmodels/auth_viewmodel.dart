import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  const AuthState._({required this.status, this.user, this.errorMessage});

  const AuthState.initial() : this._(status: AuthStatus.initial);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated(AuthUser user) : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.error(String message) : this._(status: AuthStatus.error, errorMessage: message);
}

/// ViewModel for authentication operations
/// Manages authentication state and coordinates with AuthRepository
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthViewModel({required this.repository}) : super(const AuthState.initial());

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await repository.signIn(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign out the current user
  void signOut() {
    state = const AuthState.initial();
  }
}
