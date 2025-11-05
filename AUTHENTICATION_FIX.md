# Fix de Autenticación Persistente

## Problema Identificado

Al iniciar sesión y salir de la aplicación, al volver a abrirla se mostraba brevemente la pantalla del menú pero inmediatamente saltaba al login, aunque el token estuviera almacenado correctamente.

### Causa Raíz

El router de GoRouter intentaba hacer redirecciones **antes** de que se completara la verificación del token almacenado en `flutter_secure_storage`. Esto causaba una condición de carrera:

1. App se inicia
2. Router se construye y ejecuta la lógica de redirección
3. El estado de autenticación aún está en `loading` o `initial`
4. Router redirige al usuario al login
5. La verificación del token se completa (demasiado tarde)
6. Usuario ve un flash del menú antes de ser redirigido al login

## Solución Implementada

### 1. Nuevo `authInitProvider` (FutureProvider)

**Archivo**: `lib/providers/app_providers.dart`

```dart
final authInitProvider = FutureProvider<bool>((ref) async {
  final authViewModel = ref.watch(authViewModelProvider.notifier);
  print('🔐 authInitProvider: Checking stored authentication...');
  final hasAuth = await authViewModel.checkAuthStatus();
  print('🔐 authInitProvider: Auth check completed. Has auth: $hasAuth');
  return hasAuth;
});
```

Este provider:
- Se ejecuta cuando la app inicia
- Llama a `checkAuthStatus()` de forma asíncrona
- Espera a que la verificación se complete
- Devuelve `true` si hay autenticación válida, `false` si no

### 2. Router actualizado para esperar inicialización

**Archivo**: `lib/routes/app_router.dart`

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authInit = ref.watch(authInitProvider);
  final authState = ref.watch(authViewModelProvider);
  
  return GoRouter(
    // ... routes
    redirect: (context, state) {
      final authInit = ref.read(authInitProvider);
      
      // Esperar a que la inicialización termine
      if (authInit.isLoading) {
        return null; // No redirigir aún
      }
      
      // Resto de la lógica de redirección...
    },
  );
});
```

Cambios clave:
- El router observa tanto `authInitProvider` como `authViewModelProvider`
- La lógica de redirección espera a que `authInit.isLoading` sea `false`
- Esto garantiza que el token se verifique ANTES de cualquier redirección

### 3. Checkbox "Recordarme" marcado por defecto

**Archivo**: `lib/views/sign_in_page.dart`

```dart
bool _rememberMe = true; // Cambiado de false a true
```

Mejor experiencia de usuario - la mayoría de usuarios querrán mantener su sesión.

## Flujo de Autenticación Completo

### Al Iniciar la App

```
1. main() → ProviderScope inicia
2. authInitProvider se crea
   ├── Llama a checkAuthStatus()
   ├── Lee token de flutter_secure_storage
   └── Actualiza authState a:
       ├── authenticated (si token válido)
       └── initial (si no hay token o está expirado)
3. routerProvider se construye
   └── Espera a authInit.isLoading == false
4. Router ejecuta lógica de redirección
   ├── authenticated → Redirige a '/' (menú)
   └── initial → Redirige a '/signin' (login)
```

### Al Hacer Login

```
1. Usuario ingresa credenciales
2. AuthController.signIn() se ejecuta
   └── rememberMe = true (por defecto)
3. AuthViewModel.signIn()
   └── AuthRepository.signIn()
       ├── Llama a API
       ├── Recibe LoginResponse con token
       └── Si rememberMe: Guarda en flutter_secure_storage
           ├── Token
           ├── User ID
           ├── User Name
           └── User Email
4. authState cambia a authenticated
5. Router detecta cambio
6. Redirige automáticamente a '/' (menú)
```

### Al Volver a Abrir la App

```
1. App inicia
2. authInitProvider ejecuta checkAuthStatus()
3. AuthRepository.checkStoredAuth()
   ├── Lee token de storage
   ├── Verifica si está expirado
   └── Si válido: Reconstruye LoginResponse
4. authState = authenticated
5. Router redirige a '/' (menú)
6. ✅ Usuario entra directo al menú (sin login)
```

### Al Cerrar Sesión

```
1. Usuario presiona "Cerrar Sesión"
2. AuthController.signOut()
3. AuthRepository.signOut()
   ├── Llama a API logout
   └── Elimina todo de flutter_secure_storage
4. authState cambia a initial
5. Router redirige a '/signin'
```

## Verificación de Token

El token se considera válido si:
- Existe en storage
- No está expirado (`token.expiresAt > DateTime.now()`)
- Los datos de usuario están completos

Si cualquiera de estas condiciones falla:
- Se eliminan todos los datos de storage
- Se establece authState como initial
- Usuario debe hacer login nuevamente

## Debugging

Los logs en consola ayudan a seguir el flujo:

```
🔐 authInitProvider: Checking stored authentication...
🔐 AuthRepository: Verificando token almacenado...
🔐 AuthRepository: Token válido encontrado, recuperando datos de usuario...
🔐 AuthRepository: ✅ Autenticación restaurada para usuario: Juan Pérez (juan@example.com)
🔐 authInitProvider: Auth check completed. Has auth: true
🔄 Router: Creating router with auth init: true, auth status: authenticated
🔀 Router redirect: location=/, authInit=true, authStatus=authenticated
🔀 Router: User is authenticated
🔀 Router: Allowing access to /
```

## Dependencias Utilizadas

- `flutter_secure_storage: ^9.0.0` - Almacenamiento seguro del token
- `go_router: ^14.6.2` - Navegación y redirecciones
- `flutter_riverpod: ^2.3.6` - Gestión de estado

## Archivos Modificados

1. `lib/providers/app_providers.dart`
   - Agregado `authInitProvider`
   - Removido `Future.microtask()` del authViewModelProvider

2. `lib/routes/app_router.dart`
   - Router observa `authInitProvider`
   - Lógica de redirección espera a inicialización

3. `lib/views/sign_in_page.dart`
   - `_rememberMe = true` por defecto

## Testing

Para probar que funciona correctamente:

1. **Primera vez (sin token)**:
   - Abrir app → Debe mostrar login
   - Hacer login con "Recordarme" marcado
   - Debe redirigir al menú

2. **Volver a abrir app**:
   - Cerrar completamente la app
   - Volver a abrir
   - ✅ Debe ir directo al menú (sin mostrar login)

3. **Cerrar sesión**:
   - Presionar "Cerrar Sesión"
   - Debe redirigir al login
   - Token debe eliminarse de storage

4. **Token expirado**:
   - Esperar a que expire el token
   - Volver a abrir app
   - Debe mostrar login (token se limpia automáticamente)

## Notas Adicionales

- El token se almacena **solo** si el checkbox "Recordarme" está marcado
- El token se verifica automáticamente en cada inicio de app
- La verificación incluye validación de expiración
- Si el token es inválido, se limpia automáticamente todo el storage
- No se requiere intervención manual del usuario
