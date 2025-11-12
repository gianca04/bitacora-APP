import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/token_response.dart';

/// Service for securely storing and retrieving authentication tokens
/// 
/// Uses flutter_secure_storage to encrypt token data on disk.
/// Keys are prefixed with 'auth_' for consistency.
class TokenStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Storage keys
  static const _keyAccessToken = 'auth_access_token';
  static const _keyTokenType = 'auth_token_type';
  static const _keyExpiresAt = 'auth_expires_at';
  static const _keyUserId = 'auth_user_id';
  static const _keyUserName = 'auth_user_name';
  static const _keyUserEmail = 'auth_user_email';
  static const _keyEmployeeId = 'auth_employee_id';

  /// Saves the token to secure storage
  Future<void> saveToken(TokenResponse token) async {
    debugPrint('💾 TokenStorage: Guardando token...');
    try {
      await Future.wait([
        _storage.write(key: _keyAccessToken, value: token.accessToken),
        _storage.write(key: _keyTokenType, value: token.tokenType),
        _storage.write(
          key: _keyExpiresAt,
          value: token.expiresAt.toIso8601String(),
        ),
      ]).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⏱️ TokenStorage: Timeout guardando token');
          throw TimeoutException('Timeout guardando token');
        },
      );
      debugPrint('✅ TokenStorage: Token guardado exitosamente');
    } catch (e) {
      debugPrint('❌ TokenStorage: Error guardando token - $e');
      rethrow;
    }
  }

  /// Saves user information to secure storage
  Future<void> saveUserInfo({
    required int userId,
    required String userName,
    required String userEmail,
    int? employeeId,
  }) async {
    debugPrint('💾 TokenStorage: Guardando información de usuario...');
    try {
      await Future.wait([
        _storage.write(key: _keyUserId, value: userId.toString()),
        _storage.write(key: _keyUserName, value: userName),
        _storage.write(key: _keyUserEmail, value: userEmail),
        if (employeeId != null)
          _storage.write(key: _keyEmployeeId, value: employeeId.toString()),
      ]).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⏱️ TokenStorage: Timeout guardando info de usuario');
          throw TimeoutException('Timeout guardando información de usuario');
        },
      );
      debugPrint('✅ TokenStorage: Información de usuario guardada exitosamente');
    } catch (e) {
      debugPrint('❌ TokenStorage: Error guardando info de usuario - $e');
      rethrow;
    }
  }

  /// Retrieves the token from secure storage
  /// 
  /// Returns null if no token is stored or if any required field is missing
  Future<TokenResponse?> getToken() async {
    try {
      final values = await Future.wait([
        _storage.read(key: _keyAccessToken),
        _storage.read(key: _keyTokenType),
        _storage.read(key: _keyExpiresAt),
      ]).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⏱️ TokenStorage: Timeout leyendo token');
          return [null, null, null];
        },
      );

      final accessToken = values[0];
      final tokenType = values[1];
      final expiresAtStr = values[2];

      if (accessToken == null || tokenType == null || expiresAtStr == null) {
        return null;
      }

      final expiresAt = DateTime.parse(expiresAtStr);

      return TokenResponse(
        accessToken: accessToken,
        tokenType: tokenType,
        expiresAt: expiresAt,
      );
    } catch (e) {
      // If parsing fails or any error occurs, return null
      debugPrint('❌ TokenStorage: Error obteniendo token - $e');
      return null;
    }
  }

  /// Retrieves stored user ID
  Future<int?> getUserId() async {
    try {
      final value = await _storage.read(key: _keyUserId).timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      return value != null ? int.tryParse(value) : null;
    } catch (e) {
      debugPrint('❌ TokenStorage: Error obteniendo userId - $e');
      return null;
    }
  }

  /// Retrieves stored user name
  Future<String?> getUserName() async {
    try {
      return await _storage.read(key: _keyUserName).timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
    } catch (e) {
      debugPrint('❌ TokenStorage: Error obteniendo userName - $e');
      return null;
    }
  }

  /// Retrieves stored user email
  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _keyUserEmail).timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
    } catch (e) {
      debugPrint('❌ TokenStorage: Error obteniendo userEmail - $e');
      return null;
    }
  }

  /// Retrieves stored employee ID
  Future<int?> getEmployeeId() async {
    try {
      final value = await _storage.read(key: _keyEmployeeId).timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      return value != null ? int.tryParse(value) : null;
    } catch (e) {
      debugPrint('❌ TokenStorage: Error obteniendo employeeId - $e');
      return null;
    }
  }

  /// Checks if a valid token exists in storage
  /// 
  /// A token is considered valid if it exists and has not expired
  Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && !token.isExpired;
  }

  /// Deletes all stored authentication data
  Future<void> deleteAll() async {
    try {
      debugPrint('🗑️ TokenStorage: Eliminando todos los datos de autenticación...');
      await Future.wait([
        _storage.delete(key: _keyAccessToken),
        _storage.delete(key: _keyTokenType),
        _storage.delete(key: _keyExpiresAt),
        _storage.delete(key: _keyUserId),
        _storage.delete(key: _keyUserName),
        _storage.delete(key: _keyUserEmail),
        _storage.delete(key: _keyEmployeeId),
      ]).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⏱️ TokenStorage: Timeout eliminando datos');
          return [];
        },
      );
      debugPrint('✅ TokenStorage: Datos eliminados exitosamente');
    } catch (e) {
      debugPrint('❌ TokenStorage: Error eliminando datos - $e');
      rethrow;
    }
  }

  /// Deletes only the token, keeping user info
  Future<void> deleteToken() async {
    try {
      await Future.wait([
        _storage.delete(key: _keyAccessToken),
        _storage.delete(key: _keyTokenType),
        _storage.delete(key: _keyExpiresAt),
      ]).timeout(
        const Duration(seconds: 5),
        onTimeout: () => [],
      );
    } catch (e) {
      debugPrint('❌ TokenStorage: Error eliminando token - $e');
      rethrow;
    }
  }
}
