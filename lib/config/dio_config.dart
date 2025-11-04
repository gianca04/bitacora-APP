import 'package:dio/dio.dart';

import '../services/token_storage_service.dart';

/// Configuration class for Dio HTTP client
/// Centralizes all HTTP request configurations and error handling
class DioConfig {
  static const String baseUrl = 'https://monitor.sat-industriales.pe/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Create and configure Dio instance
  /// 
  /// If [withAuthInterceptor] is true, adds automatic token injection
  static Dio createDio({bool withAuthInterceptor = false}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) {
          // Consider all status codes as valid to handle them manually
          return status != null && status < 500;
        },
      ),
    );

    // Add logging interceptor
    dio.interceptors.add(_createLoggingInterceptor());

    // Add auth interceptor if requested
    if (withAuthInterceptor) {
      dio.interceptors.add(_createAuthInterceptor());
    }

    return dio;
  }

  /// Create interceptor for automatic token injection
  static Interceptor _createAuthInterceptor() {
    final tokenStorage = TokenStorageService();

    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip token injection for auth endpoints
        if (options.path.contains('/login') || 
            options.path.contains('/register') ||
            options.path.contains('/refresh')) {
          return handler.next(options);
        }

        try {
          final token = await tokenStorage.getToken();

          if (token != null && !token.isExpired) {
            // Inject token
            options.headers['Authorization'] = token.authorizationHeader;
          } else if (token != null && token.isExpired) {
            // Token expired - could implement refresh here
            // For now, just log and continue
            print('⚠️ Token expired, consider implementing refresh');
          }
        } catch (e) {
          print('⚠️ Error retrieving token: $e');
        }

        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 errors (unauthorized)
        if (error.response?.statusCode == 401) {
          // Token might be invalid, clear storage
          try {
            await tokenStorage.deleteAll();
            print('🗑️ Cleared invalid token from storage');
          } catch (e) {
            print('⚠️ Error clearing token: $e');
          }
        }
        return handler.next(error);
      },
    );
  }

  /// Create interceptor for logging
  static Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Log request
        print('🚀 REQUEST[${options.method}] => ${options.uri}');
        if (options.data != null) {
          print('📤 Data: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response
        print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
        print('📥 Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        // Log error
        print('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
        print('📛 Message: ${error.message}');
        if (error.response?.data != null) {
          print('📛 Data: ${error.response?.data}');
        }
        return handler.next(error);
      },
    );
  }

  /// Add authorization token to Dio instance
  static void addAuthToken(Dio dio, String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authorization token from Dio instance
  static void removeAuthToken(Dio dio) {
    dio.options.headers.remove('Authorization');
  }

  /// Handle HTTP errors and convert them to user-friendly messages
  static String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de conexión agotado. Verifica tu conexión a Internet.';
      
      case DioExceptionType.sendTimeout:
        return 'Tiempo de envío agotado. Intenta nuevamente.';
      
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de recepción agotado. El servidor tardó demasiado en responder.';
      
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      
      case DioExceptionType.cancel:
        return 'Solicitud cancelada.';
      
      case DioExceptionType.connectionError:
        return 'Error de conexión. Verifica tu conexión a Internet.';
      
      case DioExceptionType.unknown:
        return 'Error desconocido. Intenta nuevamente.';
      
      default:
        return 'Error en la solicitud. Intenta nuevamente.';
    }
  }

  /// Handle bad response status codes
  static String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Try to extract message from response
    if (responseData != null && responseData is Map<String, dynamic>) {
      if (responseData.containsKey('message')) {
        return responseData['message'] as String;
      }
    }

    // Default messages based on status code
    switch (statusCode) {
      case 400:
        return 'Solicitud incorrecta. Verifica los datos enviados.';
      case 401:
        return 'No autorizado. Inicia sesión nuevamente.';
      case 403:
        return 'Acceso prohibido. No tienes permisos suficientes.';
      case 404:
        return 'Recurso no encontrado.';
      case 422:
        return 'Error de validación. Verifica los datos enviados.';
      case 429:
        return 'Demasiadas solicitudes. Intenta más tarde.';
      case 500:
        return 'Error del servidor. Intenta más tarde.';
      case 503:
        return 'Servicio no disponible. Intenta más tarde.';
      default:
        return 'Error en el servidor (código: $statusCode).';
    }
  }

  /// Check if response is successful based on the API format
  static bool isSuccessResponse(Map<String, dynamic> response) {
    return response.containsKey('success') && response['success'] == true;
  }

  /// Extract error message from API response
  static String extractErrorMessage(Map<String, dynamic> response) {
    if (response.containsKey('message')) {
      return response['message'] as String;
    }
    return 'Error desconocido en la respuesta del servidor.';
  }
}
