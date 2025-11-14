import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/work_report_api_models.dart';
import '../config/dio_config.dart';
import 'api_call_helper.dart';

class WorkReportApiService {
  final Dio _dio;
  static const String baseUrl = '/work-reports';

  WorkReportApiService({Dio? dio}) 
      : _dio = dio ?? DioConfig.createDio(withAuthInterceptor: true);

  /// 1. Obtener lista de Work Reports con paginación
  Future<WorkReportApiResponse?> getWorkReports({
    int? projectId,
    int perPage = 10,
    int page = 1,
  }) async {
    return await ApiCallHelper.execute<WorkReportApiResponse?>(
      apiCall: () async {
        try {
          final queryParams = <String, dynamic>{
            'per_page': perPage,
            'page': page,
          };
          
          if (projectId != null) {
            queryParams['project_id'] = projectId;
          }

          debugPrint('🌐 [WorkReportAPI] Llamando GET $baseUrl con parámetros: $queryParams');
          
          final response = await _dio.get(
            baseUrl,
            queryParameters: queryParams,
          );

          debugPrint('🌐 [WorkReportAPI] Respuesta recibida - Status: ${response.statusCode}');
          debugPrint('🌐 [WorkReportAPI] Datos: ${response.data?.toString().substring(0, 200) ?? 'null'}...');

          if (response.statusCode == 200 && response.data != null) {
            final result = WorkReportApiResponse.fromJson(response.data);
            debugPrint('🌐 [WorkReportAPI] ✅ Datos parseados exitosamente: ${result.data.length} reportes');
            return result;
          }
          debugPrint('🌐 [WorkReportAPI] ❌ Respuesta vacía o status code incorrecto');
          return null;
        } on DioException catch (e) {
          debugPrint('🌐 [WorkReportAPI] ❌ DioException: ${e.response?.statusCode} - ${e.message}');
          debugPrint('🌐 [WorkReportAPI] ❌ Error data: ${e.response?.data}');
          throw Exception(parseError(e));
        } catch (e) {
          debugPrint('🌐 [WorkReportAPI] ❌ Error inesperado: $e');
          throw Exception('Error inesperado: $e');
        }
      },
    );
  }

  /// 2. Búsqueda avanzada de Work Reports
  Future<WorkReportApiResponse?> searchWorkReports(
    WorkReportSearchParams params,
  ) async {
    return await ApiCallHelper.execute<WorkReportApiResponse?>(
      apiCall: () async {
        try {
          final response = await _dio.get(
            '$baseUrl/search',
            queryParameters: params.toQueryParams(),
          );

          if (response.statusCode == 200 && response.data != null) {
            return WorkReportApiResponse.fromJson(response.data);
          }
          return null;
        } on DioException catch (e) {
          throw Exception(parseError(e));
        }
      },
    );
  }

  /// 3. Obtener Work Report por ID
  Future<WorkReportSingleApiResponse?> getWorkReportById(int id) async {
    return await ApiCallHelper.execute<WorkReportSingleApiResponse?>(
      apiCall: () async {
        try {
          final response = await _dio.get('$baseUrl/$id');

          if (response.statusCode == 200 && response.data != null) {
            return WorkReportSingleApiResponse.fromJson(response.data);
          }
          return null;
        } on DioException catch (e) {
          throw Exception(parseError(e));
        }
      },
    );
  }

  /// 4. Obtener Work Reports por Proyecto
  Future<WorkReportSingleApiResponse?> getWorkReportsByProject(
    int projectId,
  ) async {
    return await ApiCallHelper.execute<WorkReportSingleApiResponse?>(
      apiCall: () async {
        try {
          final response = await _dio.get('$baseUrl/project/$projectId');

          if (response.statusCode == 200 && response.data != null) {
            return WorkReportSingleApiResponse.fromJson(response.data);
          }
          return null;
        } on DioException catch (e) {
          throw Exception(parseError(e));
        }
      },
    );
  }

  /// 5. Obtener Work Reports por Empleado
  Future<WorkReportSingleApiResponse?> getWorkReportsByEmployee(
    int employeeId,
  ) async {
    return await ApiCallHelper.execute<WorkReportSingleApiResponse?>(
      apiCall: () async {
        try {
          final response = await _dio.get('$baseUrl/employee/$employeeId');

          if (response.statusCode == 200 && response.data != null) {
            return WorkReportSingleApiResponse.fromJson(response.data);
          }
          return null;
        } on DioException catch (e) {
          throw Exception(parseError(e));
        }
      },
    );
  }

  /// Método auxiliar para manejar errores de validación
  String parseValidationErrors(DioException e) {
    if (e.response?.statusCode == 422 && e.response?.data != null) {
      final data = e.response!.data;
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final errorMessages = <String>[];
        
        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(messages.cast<String>());
          }
        });
        
        return errorMessages.join('\n');
      }
    }
    return 'Error en la validación de datos';
  }

  /// Método auxiliar para manejar errores generales
  String parseError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return 'No autorizado. Verifica tu token de acceso.';
      case 403:
        return 'No tienes permisos para realizar esta acción.';
      case 404:
        return 'Recurso no encontrado.';
      case 422:
        return parseValidationErrors(e);
      case 500:
        return 'Error interno del servidor. Intenta más tarde.';
      default:
        return e.message ?? 'Error de conexión';
    }
  }
}