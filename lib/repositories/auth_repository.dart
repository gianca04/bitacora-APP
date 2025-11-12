import 'dart:async';

import 'package:flutter/material.dart';

import '../models/auth_user.dart';
import '../models/login_response.dart';
import '../services/auth_api_service.dart';
import '../services/token_storage_service.dart';

/// Repository for authentication operations
/// Acts as a bridge between the service layer and the API
class AuthRepository {
  final AuthApiService _authApiService;
  final TokenStorageService _tokenStorage;

  AuthRepository({
    AuthApiService? authApiService,
    TokenStorageService? tokenStorage,
  })  : _authApiService = authApiService ?? AuthApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  /// Sign in with email and password
  /// 
  /// Returns [LoginResponse] with complete authentication data
  /// Saves token and user info to secure storage if rememberMe is true
  /// Throws [AuthException] if credentials are invalid or request fails
  Future<LoginResponse> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      debugPrint('📦 AuthRepository: Llamando a AuthApiService.login()');
      final response = await _authApiService.login(
        email: email,
        password: password,
      );

      debugPrint('📦 AuthRepository: Respuesta recibida de API');

      // Save to secure storage if login successful and rememberMe is true
      if (response.isValid && rememberMe) {
        debugPrint('💾 Guardando datos de autenticación (rememberMe: true)');
        await _saveAuthData(response);
        debugPrint('✅ Datos de autenticación guardados');
      } else {
        debugPrint('⏭️ No guardando datos (rememberMe: $rememberMe, isValid: ${response.isValid})');
      }

      debugPrint('✅ AuthRepository: Retornando respuesta');
      return response;
    } catch (e) {
      debugPrint('❌ AuthRepository: Error en signIn - ${e.toString()}');
      // Re-throw to be handled by the ViewModel/Controller
      rethrow;
    }
  }

  /// Saves authentication data to secure storage
  Future<void> _saveAuthData(LoginResponse response) async {
    debugPrint('💾 _saveAuthData: Guardando token...');
    if (response.token != null) {
      await _tokenStorage.saveToken(response.token!);
      debugPrint('✅ Token guardado');
    }

    debugPrint('💾 _saveAuthData: Guardando información de usuario...');
    if (response.user != null) {
      await _tokenStorage.saveUserInfo(
        userId: response.user!.id,
        userName: response.user!.name,
        userEmail: response.user!.email,
        employeeId: response.employee?.id,
      );
      debugPrint('✅ Información de usuario guardada');
    }
  }

  /// Checks if there's a valid stored token and returns authentication data
  /// 
  /// Returns [LoginResponse] with stored data if token is valid
  /// Returns null if no valid token exists
  Future<LoginResponse?> checkStoredAuth() async {
    debugPrint('🔐 AuthRepository: Verificando token almacenado...');
    try {
      final token = await _tokenStorage.getToken();

      if (token == null || token.isExpired) {
        debugPrint('🔐 AuthRepository: Token no encontrado o expirado');
        // Clean up expired token
        await _tokenStorage.deleteAll();
        return null;
      }

      debugPrint('🔐 AuthRepository: Token válido encontrado, recuperando datos de usuario...');
      // Retrieve user info
      final userId = await _tokenStorage.getUserId();
      final userName = await _tokenStorage.getUserName();
      final userEmail = await _tokenStorage.getUserEmail();
      // Note: employeeId could be retrieved here if needed in the future
      // final employeeId = await _tokenStorage.getEmployeeId();

      if (userId == null || userName == null || userEmail == null) {
        debugPrint('🔐 AuthRepository: Datos de usuario incompletos, limpiando...');
        // Incomplete data, clean up
        await _tokenStorage.deleteAll();
        return null;
      }

      debugPrint('🔐 AuthRepository: ✅ Autenticación restaurada para usuario: $userName ($userEmail)');
      // Construct LoginResponse from stored data
      return LoginResponse(
        success: true,
        message: 'Autenticación restaurada',
        token: token,
        user: AuthUser(
          id: userId,
          name: userName,
          email: userEmail,
        ),
        employee: null, // Employee data can be fetched later if needed
      );
    } catch (e) {
      debugPrint('❌ AuthRepository: Error verificando token: $e');
      // If any error occurs, clean up and return null
      await _tokenStorage.deleteAll();
      return null;
    }
  }

  /// Get authenticated user (legacy method for compatibility)
  /// Returns only the AuthUser from the login response
  @Deprecated('Use signIn() instead which returns complete LoginResponse')
  Future<AuthUser> legacySignIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final response = await signIn(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    if (response.user == null) {
      throw Exception('No se pudo obtener la información del usuario');
    }

    return response.user!;
  }

  /// Sign out (logout)
  /// Deletes all stored authentication data
  Future<void> signOut(String? token) async {
    try {
      // Call API logout if token is available
      if (token != null) {
        await _authApiService.logout(token);
      }
    } catch (e) {
      // Ignore logout errors, still clear local storage
      debugPrint('Error during logout: $e');
    } finally {
      // Always delete stored authentication data
      await _tokenStorage.deleteAll();
    }
  }
}
