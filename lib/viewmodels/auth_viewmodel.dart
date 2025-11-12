import 'package:flutter/material.dart';
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
  bool _isInitialized = false;

  AuthViewModel({required this.repository}) : super(const AuthState.initial());

  /// Check for stored authentication on app start
  /// Returns true if valid stored auth was found, false otherwise
  /// Only runs once to avoid multiple initializations
  Future<bool> checkAuthStatus() async {
    // Prevent multiple initializations
    if (_isInitialized) {
      debugPrint('🔐 AuthViewModel: Ya inicializado, retornando estado actual');
      return state.isAuthenticated;
    }

    debugPrint('🔐 AuthViewModel: Iniciando checkAuthStatus');
    
    try {
      debugPrint('🔐 AuthViewModel: Llamando a repository.checkStoredAuth()');
      final storedAuth = await repository.checkStoredAuth();

      if (storedAuth != null && storedAuth.isValid) {
        debugPrint('🔐 AuthViewModel: Token válido encontrado, actualizando estado a authenticated');
        state = AuthState.authenticated(storedAuth);
        _isInitialized = true;
        return true;
      } else {
        debugPrint('🔐 AuthViewModel: No se encontró token válido, estado inicial');
        state = const AuthState.initial();
        _isInitialized = true;
        return false;
      }
    } catch (e) {
      debugPrint('❌ AuthViewModel: Error checking auth status: $e');
      state = const AuthState.initial();
      _isInitialized = true;
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
    debugPrint('🔄 AuthViewModel: Cambiando estado a loading');
    state = const AuthState.loading();
    
    try {
      debugPrint('🔄 AuthViewModel: Llamando a repository.signIn()');
      final loginResponse = await repository.signIn(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      
      debugPrint('🔄 AuthViewModel: Respuesta recibida, success: ${loginResponse.success}');
      
      // Check if login was successful
      if (!loginResponse.success) {
        debugPrint('❌ AuthViewModel: Login no exitoso - ${loginResponse.message}');
        state = AuthState.error(loginResponse.message);
        return false;
      }
      
      // Validate that we have all required data
      if (!loginResponse.isValid) {
        debugPrint('❌ AuthViewModel: Respuesta inválida del servidor');
        state = const AuthState.error('Respuesta incompleta del servidor');
        return false;
      }
      
      debugPrint('🔄 AuthViewModel: Login exitoso, actualizando estado a authenticated');
      state = AuthState.authenticated(loginResponse);
      debugPrint('✅ AuthViewModel: Estado actualizado exitosamente');
      return true;
    } on AuthException catch (e) {
      // Handle authentication-specific errors
      debugPrint('❌ AuthViewModel: AuthException - ${e.message}');
      state = AuthState.error(e.message);
      return false;
    } catch (e) {
      // Handle any other errors
      debugPrint('❌ AuthViewModel: Error inesperado - ${e.toString()}');
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
      debugPrint('Error during signOut: $e');
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