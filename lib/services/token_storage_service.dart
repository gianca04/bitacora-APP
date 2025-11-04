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
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: token.accessToken),
      _storage.write(key: _keyTokenType, value: token.tokenType),
      _storage.write(
        key: _keyExpiresAt,
        value: token.expiresAt.toIso8601String(),
      ),
    ]);
  }

  /// Saves user information to secure storage
  Future<void> saveUserInfo({
    required int userId,
    required String userName,
    required String userEmail,
    int? employeeId,
  }) async {
    await Future.wait([
      _storage.write(key: _keyUserId, value: userId.toString()),
      _storage.write(key: _keyUserName, value: userName),
      _storage.write(key: _keyUserEmail, value: userEmail),
      if (employeeId != null)
        _storage.write(key: _keyEmployeeId, value: employeeId.toString()),
    ]);
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
      ]);

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
      return null;
    }
  }

  /// Retrieves stored user ID
  Future<int?> getUserId() async {
    final value = await _storage.read(key: _keyUserId);
    return value != null ? int.tryParse(value) : null;
  }

  /// Retrieves stored user name
  Future<String?> getUserName() async {
    return _storage.read(key: _keyUserName);
  }

  /// Retrieves stored user email
  Future<String?> getUserEmail() async {
    return _storage.read(key: _keyUserEmail);
  }

  /// Retrieves stored employee ID
  Future<int?> getEmployeeId() async {
    final value = await _storage.read(key: _keyEmployeeId);
    return value != null ? int.tryParse(value) : null;
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
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyTokenType),
      _storage.delete(key: _keyExpiresAt),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyUserName),
      _storage.delete(key: _keyUserEmail),
      _storage.delete(key: _keyEmployeeId),
    ]);
  }

  /// Deletes only the token, keeping user info
  Future<void> deleteToken() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyTokenType),
      _storage.delete(key: _keyExpiresAt),
    ]);
  }
}
