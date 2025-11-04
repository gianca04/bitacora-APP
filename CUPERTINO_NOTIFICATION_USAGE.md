# Cupertino Notification Banner - Guía de Uso

## 🎨 Widget de Notificación con Cupertino Design

Widget elegante y versátil para mostrar notificaciones en la app siguiendo el diseño de iOS.

## ✨ Características

- **4 Tipos de notificación**: Success, Error, Warning, Info
- **Diseño Cupertino**: Colores y estilos nativos de iOS
- **Animaciones fluidas**: Entrada desde arriba con fade y slide
- **Auto-dismiss**: Se cierra automáticamente después de N segundos
- **Deslizable**: Arrastra hacia arriba para cerrar manualmente
- **Flexible**: Puede mostrar logo o icono
- **Overlay o Inline**: Usa como popup o parte del layout

## 📱 Tipos de Notificación

### Success (Verde)
```dart
CupertinoNotificationBanner.show(
  context,
  message: 'Operación completada exitosamente',
  type: NotificationType.success,
);
```
**Color**: `#34C759` (iOS Green)  
**Icono**: ✓ Check mark circle

### Error (Rojo)
```dart
CupertinoNotificationBanner.show(
  context,
  message: 'Error al procesar la solicitud',
  type: NotificationType.error,
);
```
**Color**: `#FF3B30` (iOS Red)  
**Icono**: ✗ X mark circle

### Warning (Naranja)
```dart
CupertinoNotificationBanner.show(
  context,
  message: 'Conectado sin acceso a Internet',
  type: NotificationType.warning,
);
```
**Color**: `#FF9500` (iOS Orange)  
**Icono**: ⚠ Exclamation triangle

### Info (Azul)
```dart
CupertinoNotificationBanner.show(
  context,
  message: 'Nueva actualización disponible',
  type: NotificationType.info,
);
```
**Color**: `#007AFF` (iOS Blue)  
**Icono**: ⓘ Info circle

## 🚀 Uso Básico

### Notificación Simple
```dart
// Desde cualquier parte de tu app con acceso a BuildContext
CupertinoNotificationBanner.show(
  context,
  message: '¡Hola mundo!',
  type: NotificationType.info,
);
```

### Con Logo de la Empresa
```dart
CupertinoNotificationBanner.show(
  context,
  message: 'Reporte guardado correctamente',
  type: NotificationType.success,
  showLogo: true, // ← Muestra el logo en lugar del icono
);
```

### Duración Personalizada
```dart
CupertinoNotificationBanner.show(
  context,
  message: 'Este mensaje durará 5 segundos',
  type: NotificationType.info,
  duration: const Duration(seconds: 5), // Por defecto: 3 segundos
);
```

### Con Acción al Tocar
```dart
CupertinoNotificationBanner.show(
  context,
  message: 'Toca para ver detalles',
  type: NotificationType.info,
  onTap: () {
    print('Usuario tocó la notificación');
    // Navegar a otra página, etc.
  },
);
```

## 🎯 Casos de Uso Comunes

### 1. Operaciones CRUD
```dart
// Después de guardar datos
void _saveData() async {
  try {
    await repository.save(data);
    CupertinoNotificationBanner.show(
      context,
      message: 'Datos guardados exitosamente',
      type: NotificationType.success,
      showLogo: true,
    );
  } catch (e) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Error al guardar: ${e.toString()}',
      type: NotificationType.error,
    );
  }
}
```

### 2. Validación de Formularios
```dart
void _validateForm() {
  if (nameController.text.isEmpty) {
    CupertinoNotificationBanner.show(
      context,
      message: 'El nombre es requerido',
      type: NotificationType.warning,
    );
    return;
  }
  // Continuar con validación...
}
```

### 3. Estado de Conectividad
```dart
void _handleConnectivityChange(ConnectionStatus status) {
  if (status == ConnectionStatus.online) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Conexión restaurada',
      type: NotificationType.success,
      showLogo: true,
    );
  } else {
    CupertinoNotificationBanner.show(
      context,
      message: 'Sin conexión a Internet',
      type: NotificationType.error,
      showLogo: true,
      duration: const Duration(seconds: 5),
    );
  }
}
```

### 4. Confirmaciones de Usuario
```dart
void _deleteItem() async {
  CupertinoNotificationBanner.show(
    context,
    message: 'Elemento eliminado',
    type: NotificationType.info,
  );
  
  await Future.delayed(const Duration(seconds: 2));
  // Realmente eliminar el elemento
}
```

### 5. Recordatorios y Avisos
```dart
void _showReminder() {
  CupertinoNotificationBanner.show(
    context,
    message: 'Tienes 3 tareas pendientes para hoy',
    type: NotificationType.info,
    showLogo: true,
    duration: const Duration(seconds: 4),
  );
}
```

## 📐 Notificaciones Inline

Para casos donde necesitas la notificación como parte del layout (no como overlay):

```dart
// Dentro de tu widget tree
Column(
  children: [
    if (hasError)
      CupertinoNotificationInline(
        message: 'Hubo un error al cargar los datos',
        type: NotificationType.error,
        onDismiss: () => setState(() => hasError = false),
      ),
    const SizedBox(height: 16),
    // Resto de tu contenido...
  ],
)
```

### Uso en ListView
```dart
ListView(
  children: [
    CupertinoNotificationInline(
      message: 'Nuevas actualizaciones disponibles',
      type: NotificationType.info,
      showLogo: true,
    ),
    // Otros items del list...
  ],
)
```

## 🎨 Personalización Avanzada

### Notificación Persistente (Sin Auto-Dismiss)
```dart
// Usa una duración muy larga
CupertinoNotificationBanner.show(
  context,
  message: 'Esta notificación permanecerá',
  type: NotificationType.warning,
  duration: const Duration(hours: 1), // Prácticamente permanente
);
```

### Notificación Rápida
```dart
CupertinoNotificationBanner.show(
  context,
  message: 'Guardado!',
  type: NotificationType.success,
  duration: const Duration(milliseconds: 1500), // 1.5 segundos
);
```

## 🔧 Integración con NoConnectionBanner

El widget ya está integrado en el sistema de conectividad:

```dart
// En lib/widgets/no_connection_banner.dart
class NoConnectionBanner extends ConsumerStatefulWidget {
  // Automáticamente muestra notificaciones cuando:
  // 1. Se pierde la conexión
  // 2. Se recupera la conexión
  // 3. Hay conexión pero sin Internet
}
```

Beneficios:
- ✅ Banner inline cuando no hay conexión (siempre visible)
- ✅ Notificación overlay cuando cambia el estado (temporal)
- ✅ Muestra logo de la empresa
- ✅ Colores según severidad (rojo para offline, naranja para sin internet)

## 🎭 Comportamiento de Animación

### Entrada (400ms)
1. **Slide**: Desde arriba (-1.5 offset → 0)
2. **Fade**: De transparente (0) a opaco (1)
3. **Curva**: `easeOutCubic` para efecto natural

### Salida (400ms)
1. Se invierte la animación
2. Puede ser disparada por:
   - Auto-dismiss (timer)
   - Tap del usuario
   - Swipe hacia arriba (velocity > -500)

## 📊 Comparación con el Banner Anterior

| Aspecto | Banner Anterior | Cupertino Notification |
|---------|----------------|------------------------|
| Diseño | Material Design | Cupertino (iOS) |
| Colores | `Colors.red.shade700` | `#FF3B30` (iOS Red) |
| Animación | AnimatedContainer | Slide + Fade |
| Interacción | Solo visual | Tap to dismiss, Swipe |
| Logo | No soportado | Soportado con `showLogo` |
| Tipos | 2 (offline/noInternet) | 4 (success/error/warning/info) |
| Overlay | No | Sí (Positioned overlay) |
| Auto-dismiss | No | Sí (configurable) |

## 🎯 Mejores Prácticas

### ✅ DO
```dart
// Usa tipos apropiados
CupertinoNotificationBanner.show(context, 
  message: 'Guardado', 
  type: NotificationType.success, // ✓ Tipo correcto
);

// Mensajes claros y concisos
message: 'Conexión restaurada' // ✓ Directo al punto

// Usa logo para mensajes de marca
showLogo: true // ✓ Cuando es de la app/empresa
```

### ❌ DON'T
```dart
// No uses tipo incorrecto
CupertinoNotificationBanner.show(context, 
  message: 'Error', 
  type: NotificationType.success, // ✗ Contradictorio
);

// No hagas mensajes muy largos
message: 'Esto es un mensaje muy largo que probablemente...' // ✗

// No abuses del logo
showLogo: true // ✗ En cada notificación trivial
```

## 🔍 Troubleshooting

### La notificación no se muestra
```dart
// Asegúrate de tener contexto válido
void _showNotification() {
  // ✗ Incorrecto: context fuera de build
  CupertinoNotificationBanner.show(context, message: 'Test');
  
  // ✓ Correcto: dentro de método con BuildContext
  WidgetsBinding.instance.addPostFrameCallback((_) {
    CupertinoNotificationBanner.show(context, message: 'Test');
  });
}
```

### Logo no se carga
```dart
// Verifica la ruta del asset
// En cupertino_notification_banner.dart línea ~80:
SvgPicture.asset(
  'assets/images/svg/logo_secundario.svg', // ← Verifica esta ruta
  fit: BoxFit.contain,
);

// Y que esté en pubspec.yaml:
// flutter:
//   assets:
//     - assets/images/svg/
```

### Notificaciones se solapan
```dart
// Espera a que termine la anterior
CupertinoNotificationBanner.show(context, message: 'Primera');
await Future.delayed(const Duration(seconds: 3));
CupertinoNotificationBanner.show(context, message: 'Segunda');
```

## 📝 Notas Técnicas

- **Overlay Layer**: Usa `Overlay.of(context)` para mostrar sobre todo el contenido
- **Safe Area**: Respeta `MediaQuery.of(context).padding.top` para notch/status bar
- **Memory Management**: OverlayEntry se remueve automáticamente después del dismiss
- **State Management**: No requiere gestión de estado global, es efímero por diseño
- **Performance**: Animaciones con `SingleTickerProviderStateMixin` para eficiencia

---

**¡Disfruta de notificaciones elegantes y funcionales! 🎉**
