import 'package:dio/dio.dart';
import '../config/dio_config.dart';
import '../models/login_response.dart';

/// Authentication service for API login
/// Handles all authentication-related HTTP requests
class AuthApiService {
  final Dio _dio;

  AuthApiService({Dio? dio}) : _dio = dio ?? DioConfig.createDio();

  /// Login with email and password
  /// 
  /// Returns [LoginResponse] with user data and token if successful
  /// Throws [DioException] if request fails
  /// Throws [AuthException] if credentials are invalid
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Iniciando login para: $email');
      
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('🔐 Respuesta recibida, parseando...');
      
      // Parse response
      final loginResponse = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      print('🔐 LoginResponse parseado: $loginResponse');

      // Check if login was successful
      if (!loginResponse.success) {
        print('❌ Login no exitoso: ${loginResponse.message}');
        throw AuthException(loginResponse.message);
      }

      // Validate that we have all required data
      if (!loginResponse.isValid) {
        print('❌ Respuesta inválida del servidor');
        throw AuthException('Respuesta incompleta del servidor');
      }

      print('✅ Login exitoso, retornando respuesta');
      return loginResponse;
    } on DioException catch (e) {
      // Handle Dio errors
      print('❌ DioException en login: ${e.toString()}');
      final errorMessage = DioConfig.handleError(e);
      throw AuthException(errorMessage);
    } catch (e) {
      // Handle other errors
      print('❌ Error en login: ${e.toString()}');
      if (e is AuthException) rethrow;
      throw AuthException('Error al procesar la solicitud: ${e.toString()}');
    }
  }

  /// Logout (if API has logout endpoint)
  /// Currently not implemented as API doesn't specify logout endpoint
  Future<void> logout(String token) async {
    // TODO: Implement when API provides logout endpoint
    throw UnimplementedError('Logout endpoint not available yet');
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
