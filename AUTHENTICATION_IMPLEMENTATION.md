# Authentication Implementation Guide

## Overview
This document describes the authentication system implemented using Dio HTTP client to connect to the API at `https://monitor.sat-industriales.pe/api`.

## Architecture

### Layer Structure
```
Views (sign_in_page.dart, app_shell.dart)
    ↓
Controllers (auth_controller.dart)
    ↓
ViewModels (auth_viewmodel.dart)
    ↓
Repositories (auth_repository.dart)
    ↓
Services (auth_api_service.dart)
    ↓
Config (dio_config.dart)
    ↓
API (https://monitor.sat-industriales.pe/api)
```

## Components

### 1. Configuration Layer
**File**: `lib/config/dio_config.dart`
- Creates configured Dio HTTP client
- Base URL: `https://monitor.sat-industriales.pe/api`
- 30-second connection timeout
- 60-second receive timeout
- Automatic error handling with user-friendly messages
- Request/response logging for debugging

### 2. Model Layer

#### TokenResponse (`lib/models/token_response.dart`)
```dart
class TokenResponse {
  final String accessToken;
  final String tokenType;
  final DateTime expiresAt;
  
  // Computed properties
  bool get isExpired;
  String get authorizationHeader; // "Bearer {token}"
}
```

#### AuthUser (`lib/models/auth_user.dart`)
```dart
class AuthUser {
  final int id;
  final String name;
  final String email;
}
```

#### AuthEmployee (`lib/models/auth_employee.dart`)
```dart
class AuthEmployee {
  final int id;
  final String name;
  final String lastName;
  final String? dni;
  final String? phone;
  final String position;
  final int userId;
}
```

#### LoginResponse (`lib/models/login_response.dart`)
```dart
class LoginResponse {
  final bool success;
  final String? message;
  final TokenResponse? token;
  final AuthUser? user;
  final AuthEmployee? employee;
  
  bool get isValid; // Validates all required fields
}
```

### 3. Service Layer
**File**: `lib/services/auth_api_service.dart`
- Direct API communication
- `Future<LoginResponse> login(String email, String password)`
- Custom `AuthException` for error handling
- Endpoint: `POST /login`

### 4. Repository Layer
**File**: `lib/repositories/auth_repository.dart`
- Bridge between service and ViewModel
- `Future<LoginResponse> signIn(String email, String password)`
- `Future<void> signOut()`
- `Future<LoginResponse?> legacySignIn()` - For backward compatibility

### 5. ViewModel Layer
**File**: `lib/viewmodels/auth_viewmodel.dart`
- State management with Riverpod
- `AuthState` includes:
  - `AuthStatus status`
  - `String? errorMessage`
  - `LoginResponse? loginResponse`
  - `TokenResponse? token` (computed getter)
- `Future<bool> signIn(String email, String password, bool rememberMe)`
- `Future<void> signOut()`

### 6. Controller Layer
**File**: `lib/controllers/auth_controller.dart`
- UI facade with notification integration
- Shows `CupertinoNotificationBanner` on success/error
- Methods:
  - `Future<bool> signIn({BuildContext, email, password, rememberMe})`
  - `Future<void> signOut(BuildContext context)`
  - `Future<void> legacySignIn(BuildContext context)`

### 7. View Layer

#### SignIn Page (`lib/views/sign_in_page.dart`)
- Email and password input fields
- "Remember me" checkbox
- Calls `controller.signIn()` with context
- Automatic notification display via controller
- Loading state handled by button

#### App Shell (`lib/views/app_shell.dart`)
- Sign out menu items updated
- Calls `controller.signOut(context)` with context

## API Integration

### Login Endpoint
**URL**: `POST https://monitor.sat-industriales.pe/api/login`

**Request Body**:
```json
{
  "email": "string",
  "password": "string"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Login successful",
  "token": {
    "access_token": "eyJ0eXAi...",
    "token_type": "Bearer",
    "expires_at": "2024-01-20T10:30:00.000000Z"
  },
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "employee": {
    "id": 1,
    "name": "John",
    "last_name": "Doe",
    "dni": "12345678",
    "phone": "+51987654321",
    "position": "Developer",
    "user_id": 1
  }
}
```

**Error Response** (401 Unauthorized):
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

## Test Credentials
```
Email: sistemas@sat-industriales.pe
Password: admin1234
```

## User Experience

### Success Flow
1. User enters credentials and taps "Iniciar sesión"
2. Button shows loading state
3. API request is made
4. On success:
   - Green notification banner appears: "Inicio de sesión exitoso"
   - User/employee data stored in state
   - JWT token saved
   - Ready for navigation to home page

### Error Flow
1. User enters credentials and taps "Iniciar sesión"
2. Button shows loading state
3. API request fails
4. On error:
   - Red notification banner appears with specific error message
   - Examples:
     - "Credenciales inválidas"
     - "Error de conexión. Verifica tu internet."
     - "El servidor no está disponible"

## Error Handling

### DioConfig Error Messages
- **DioExceptionType.connectionTimeout**: "Tiempo de conexión agotado. Verifica tu conexión a internet."
- **DioExceptionType.receiveTimeout**: "El servidor tardó demasiado en responder."
- **DioExceptionType.badResponse**:
  - 401: "Credenciales inválidas"
  - 403: "No tienes permiso para acceder"
  - 404: "Recurso no encontrado"
  - 500-599: "Error del servidor. Intenta más tarde."
- **DioExceptionType.cancel**: "Solicitud cancelada"
- **DioExceptionType.connectionError**: "Error de conexión. Verifica tu internet."
- **DioExceptionType.unknown**: "Error desconocido: {error}"

## Next Steps (TODO)

### 1. Token Persistence
Implement secure token storage using `flutter_secure_storage`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  
  Future<void> saveToken(TokenResponse token) async {
    await _storage.write(key: 'access_token', value: token.accessToken);
    await _storage.write(key: 'expires_at', value: token.expiresAt.toIso8601String());
  }
  
  Future<TokenResponse?> getToken() async {
    // Implement retrieval logic
  }
  
  Future<void> deleteToken() async {
    await _storage.deleteAll();
  }
}
```

### 2. Token Refresh
Add token refresh logic before expiration:
```dart
// In dio_config.dart interceptor
if (token.isExpired) {
  final newToken = await refreshToken();
  request.headers['Authorization'] = newToken.authorizationHeader;
}
```

### 3. Automatic Token Injection
Add interceptor to inject token in all requests:
```dart
// In dio_config.dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await tokenStorage.getToken();
    if (token != null && !token.isExpired) {
      options.headers['Authorization'] = token.authorizationHeader;
    }
    handler.next(options);
  },
));
```

### 4. Navigation After Login
Update sign_in_page.dart success handler:
```dart
if (success) {
  context.go('/home'); // or wherever you want to navigate
}
```

### 5. Sync to Local Database
After successful authentication, sync user and employee to Isar:
```dart
if (success) {
  final loginResponse = authState.loginResponse;
  if (loginResponse != null) {
    // Convert AuthUser to User (Isar model)
    // Convert AuthEmployee to Employee (Isar model)
    // Save to Isar database
  }
}
```

### 6. Protected Routes
Implement authentication guard in router:
```dart
redirect: (context, state) {
  final authState = ref.read(authViewModelProvider);
  final isAuthenticated = authState.status == AuthStatus.authenticated;
  final isGoingToSignIn = state.matchedLocation == '/signin';
  
  if (!isAuthenticated && !isGoingToSignIn) {
    return '/signin';
  }
  if (isAuthenticated && isGoingToSignIn) {
    return '/home';
  }
  return null;
}
```

## Files Modified/Created

### Created Files
- ✅ `lib/config/dio_config.dart`
- ✅ `lib/models/token_response.dart`
- ✅ `lib/models/auth_user.dart` (replaced)
- ✅ `lib/models/auth_employee.dart`
- ✅ `lib/models/login_response.dart`
- ✅ `lib/services/auth_api_service.dart`

### Modified Files
- ✅ `lib/repositories/auth_repository.dart` - Integrated API service
- ✅ `lib/viewmodels/auth_viewmodel.dart` - Updated state to include LoginResponse
- ✅ `lib/controllers/auth_controller.dart` - Added BuildContext and notifications
- ✅ `lib/views/sign_in_page.dart` - Updated button handler to use new controller
- ✅ `lib/views/app_shell.dart` - Updated signOut calls to include context

## Dependencies
```yaml
dependencies:
  dio: ^5.9.0                    # HTTP client
  flutter_riverpod: ^2.3.6       # State management
  # For future token storage:
  # flutter_secure_storage: ^9.0.0
```

## Testing
To test the authentication:
1. Run the app
2. Navigate to sign-in page
3. Enter test credentials:
   - Email: `sistemas@sat-industriales.pe`
   - Password: `admin1234`
4. Tap "Iniciar sesión"
5. Verify green notification appears on success
6. Check that token and user data are stored in state

## Architecture Benefits
✅ **Separation of Concerns**: Each layer has a single responsibility
✅ **Testability**: Each layer can be tested independently
✅ **Maintainability**: Easy to modify without affecting other layers
✅ **Error Handling**: Centralized error handling in DioConfig
✅ **User Feedback**: Visual notifications via CupertinoNotificationBanner
✅ **Type Safety**: Strong typing with custom models
✅ **Scalability**: Easy to add new endpoints and features
