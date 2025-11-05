import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import '../models/login_response.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_api_service.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final LoginResponse? loginResponse;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.user,
    this.loginResponse,
    this.errorMessage,
  });

  const AuthState.initial() : this._(status: AuthStatus.initial);
  
  const AuthState.loading() : this._(status: AuthStatus.loading);
  
  AuthState.authenticated(LoginResponse response)
      : this._(
          status: AuthStatus.authenticated,
          user: response.user,
          loginResponse: response,
        );
  
  const AuthState.error(String message)
      : this._(status: AuthStatus.error, errorMessage: message);

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// Get token if available
  String? get token => loginResponse?.token?.accessToken;

  /// Get employee information if available
  get employee => loginResponse?.employee;
}

/// ViewModel for authentication operations
/// Manages authentication state and coordinates with AuthRepository
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthViewModel({required this.repository}) : super(const AuthState.loading());

  /// Check for stored authentication on app start
  /// Returns true if valid stored auth was found, false otherwise
  Future<bool> checkAuthStatus() async {
    print('🔐 AuthViewModel: Iniciando checkAuthStatus');
    state = const AuthState.loading();

    try {
      print('🔐 AuthViewModel: Llamando a repository.checkStoredAuth()');
      final storedAuth = await repository.checkStoredAuth();

      if (storedAuth != null && storedAuth.isValid) {
        print('🔐 AuthViewModel: Token válido encontrado, actualizando estado a authenticated');
        state = AuthState.authenticated(storedAuth);
        return true;
      } else {
        print('🔐 AuthViewModel: No se encontró token válido, estado inicial');
        state = const AuthState.initial();
        return false;
      }
    } catch (e) {
      print('❌ AuthViewModel: Error checking auth status: $e');
      state = const AuthState.initial();
      return false;
    }
  }

  /// Sign in with email and password
  /// Returns true if successful, false otherwise
  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    print('🔄 AuthViewModel: Cambiando estado a loading');
    state = const AuthState.loading();
    
    try {
      print('🔄 AuthViewModel: Llamando a repository.signIn()');
      final loginResponse = await repository.signIn(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      
      print('🔄 AuthViewModel: Respuesta recibida, actualizando estado a authenticated');
      state = AuthState.authenticated(loginResponse);
      print('✅ AuthViewModel: Estado actualizado exitosamente');
      return true;
    } on AuthException catch (e) {
      // Handle authentication-specific errors
      print('❌ AuthViewModel: AuthException - ${e.message}');
      state = AuthState.error(e.message);
      return false;
    } catch (e) {
      // Handle any other errors
      print('❌ AuthViewModel: Error inesperado - ${e.toString()}');
      state = AuthState.error('Error inesperado: ${e.toString()}');
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      // Pass token to repository for API logout
      await repository.signOut(state.token);
    } catch (e) {
      // Ignore logout errors, still clear local state
      print('Error during signOut: $e');
    } finally {
      // Always clear local state
      state = const AuthState.initial();
    }
  }

  /// Clear error message
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = const AuthState.initial();
    }
  }
}
