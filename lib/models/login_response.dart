import 'token_response.dart';
import 'auth_user.dart';
import 'auth_employee.dart';

/// Complete login response from the API
class LoginResponse {
  final bool success;
  final String message;
  final TokenResponse? token;
  final AuthUser? user;
  final AuthEmployee? employee;
  final Map<String, dynamic>? meta;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.employee,
    this.meta,
  });

  /// Create LoginResponse from JSON
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: data != null && data.containsKey('token')
          ? TokenResponse.fromJson(data['token'] as Map<String, dynamic>)
          : null,
      user: data != null && data.containsKey('user')
          ? AuthUser.fromJson(data['user'] as Map<String, dynamic>)
          : null,
      employee: data != null && data.containsKey('employee')
          ? AuthEmployee.fromJson(data['employee'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  /// Convert LoginResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        if (token != null) 'token': token!.toJson(),
        if (user != null) 'user': user!.toJson(),
        if (employee != null) 'employee': employee!.toJson(),
      },
      if (meta != null) 'meta': meta,
    };
  }

  /// Check if login was successful and has all required data
  bool get isValid => success && token != null && user != null;

  /// Check if this is an error response
  bool get isError => !success;

  @override
  String toString() {
    return 'LoginResponse(success: $success, message: $message, '
        'hasToken: ${token != null}, hasUser: ${user != null}, '
        'hasEmployee: ${employee != null})';
  }
}
