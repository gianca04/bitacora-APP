# Guía de Formularios con Captura de Fotos y Firmas Digitales

## 📋 Resumen

Se ha mejorado el sistema de reportes de trabajo con una interfaz intuitiva para trabajadores de campo que incluye:

- ✅ Captura de fotos antes/después con vista previa
- ✅ Firmas digitales del supervisor y gerente
- ✅ Descripciones para cada foto
- ✅ Interfaz visual clara con códigos de color
- ✅ Soporte para múltiples tareas en un mismo reporte

## 🎨 Componentes Principales

### 1. BeforeAfterPhotoCard

Widget para capturar fotos del antes y después de cada tarea realizada.

**Ubicación**: `lib/widgets/before_after_photo_card.dart`

**Características**:
- **Captura de fotos**: Cámara o galería mediante ImagePicker
- **Vista previa en tiempo real**: Muestra las fotos capturadas inmediatamente
- **Códigos de color**:
  - 🟠 Naranja: Sección "ANTES"
  - 🟢 Verde: Sección "DESPUÉS"
- **Recapturar**: Botón flotante sobre la imagen para tomar nueva foto
- **Descripciones**: Campo de texto para cada foto
- **Numeración**: Cada tarea tiene su número (Tarea 1, Tarea 2, etc.)
- **Compresión automática**: Reduce el tamaño de las imágenes (85% calidad, max 1920px)

**Uso**:
```dart
BeforeAfterPhotoCard(
  index: 1,
  beforePhotoPath: '/path/to/before.jpg',
  afterPhotoPath: '/path/to/after.jpg',
  beforeDescription: 'Descripción del estado inicial',
  afterDescription: 'Descripción del trabajo completado',
  onChanged: (before, after, beforeDesc, afterDesc) {
    // Manejar cambios
  },
)
```

**UX Flow**:
1. Usuario toca el botón "Tomar Foto Antes" o "Tomar Foto Después"
2. Se muestra bottom sheet con opciones: Cámara o Galería
3. Usuario selecciona fuente y toma/selecciona la foto
4. Vista previa aparece inmediatamente con botón "Recapturar"
5. Usuario puede agregar descripción en el campo de texto debajo

### 2. SignaturePadWidget

Widget para capturar firmas digitales del supervisor y gerente.

**Ubicación**: `lib/widgets/signature_pad_widget.dart`

**Características**:
- **Canvas de firma**: Área blanca para firmar con dedo o stylus
- **Botones de acción**:
  - 🔴 Limpiar: Borra la firma actual
  - ✅ Guardar: Guarda la firma como PNG
- **Feedback visual**: Mensajes de confirmación al guardar
- **Personalización**: Color del tema configurable
- **Exportación**: Convierte la firma a Uint8List (PNG bytes)

**Uso**:
```dart
SignaturePadWidget(
  label: 'Firma del Supervisor',
  color: Color(0xFF2A8D8D),
  onSignatureChanged: (Uint8List? signature) {
    // signature contiene los bytes PNG de la firma
    // Se puede convertir a base64 para guardar en DB
  },
)
```

**UX Flow**:
1. Usuario firma en el recuadro blanco
2. Los botones Limpiar y Guardar se activan automáticamente
3. Al tocar "Guardar", se captura la firma como imagen PNG
4. Se muestra SnackBar de confirmación verde
5. La firma se pasa al callback como Uint8List

### 3. WorkReportForm (Actualizado)

Formulario principal que integra ambos componentes.

**Ubicación**: `lib/widgets/work_report_form.dart`

**Nuevas características**:
- Lista dinámica de tareas con fotos antes/después
- Botón "Agregar Nueva Tarea" para múltiples trabajos
- Dos secciones de firma digital (supervisor y gerente)
- Conversión automática de firmas a base64
- Validación de que al menos la foto "después" esté presente

**Estructura de datos**:
```dart
// Estado interno para tareas con fotos
List<Map<String, dynamic>> _photoTasks = [
  {
    'beforePhoto': String?,      // Ruta de archivo
    'afterPhoto': String?,        // Ruta de archivo
    'beforeDescription': String?, // Texto descriptivo
    'afterDescription': String?,  // Texto descriptivo
  }
];

// Firmas digitales
Uint8List? _supervisorSignature;
Uint8List? _managerSignature;
```

**Flujo de guardado**:
1. Usuario completa campos del reporte
2. Agrega una o más tareas con fotos antes/después
3. Captura firmas del supervisor y gerente
4. Al tocar "Create Report":
   - Valida campos requeridos
   - Convierte firmas a base64
   - Crea objetos Photo para cada tarea con foto "después"
   - Llama al callback onSubmit con el reporte y las fotos

## 📱 Permisos Configurados

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<!-- Permisos para la cámara y almacenamiento -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32" />

<!-- Indicar que la app usa la cámara pero no es obligatoria -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<!-- Permisos para cámara y galería -->
<key>NSCameraUsageDescription</key>
<string>Esta app necesita acceso a la cámara para tomar fotografías del trabajo realizado</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Esta app necesita acceso a la galería para seleccionar fotografías del trabajo realizado</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Esta app necesita guardar fotografías en la galería</string>
```

## 📦 Dependencias

Agregadas en `pubspec.yaml`:

```yaml
dependencies:
  image_picker: ^1.0.4       # Captura de fotos desde cámara/galería
  signature: ^5.4.0          # Canvas para firmas digitales
  permission_handler: ^11.0.1 # Manejo de permisos (opcional)
```

**Instalación**:
```bash
flutter pub get
```

## 🎯 Flujo de Usuario Completo

### Caso de uso: Trabajador registra trabajo diario

1. **Abrir formulario**: Navega a "Reports" → FAB (+)

2. **Información básica**:
   - Nombre del reporte: "Instalación de tubería Sector A"
   - Descripción: "Instalación de 50m de tubería PVC"
   - Employee ID: 101
   - Project ID: 5

3. **Horario**:
   - Fecha: 2024-01-15
   - Hora inicio: 08:00
   - Hora fin: 17:00

4. **Primera tarea con fotos**:
   - Toca "Agregar Nueva Tarea"
   - Aparece Tarea 1
   - Toca "Tomar Foto Antes" → Cámara → Captura zanja vacía
   - Agrega descripción: "Zanja preparada para tubería"
   - Toca "Tomar Foto Después" → Cámara → Captura tubería instalada
   - Agrega descripción: "Tubería PVC instalada y nivelada"

5. **Segunda tarea con fotos**:
   - Toca "Agregar Nueva Tarea" nuevamente
   - Aparece Tarea 2
   - Repite el proceso para otra sección del trabajo

6. **Detalles adicionales**:
   - Suggestions: "Considerar tubería de mayor diámetro"
   - Tools: "Excavadora, nivel, cinta métrica"
   - Personnel: "Juan Pérez, María López"
   - Materials: "50m tubería PVC 4 pulgadas"

7. **Firmas de aprobación**:
   - **Supervisor**: Firma en el primer canvas
   - Toca "Guardar" → ✅ "Firma guardada correctamente"
   - **Gerente**: Firma en el segundo canvas
   - Toca "Guardar" → ✅ "Firma guardada correctamente"

8. **Enviar reporte**:
   - Toca "Create Report"
   - El sistema valida y guarda:
     - WorkReport con firmas en base64
     - 2 objetos Photo (uno por cada tarea)
   - Navega de vuelta a la lista
   - Muestra SnackBar de éxito

## 🔧 Consideraciones Técnicas

### Almacenamiento de Fotos

Las fotos se guardan como **rutas de archivo** (String):
```dart
Photo(
  photoPath: '/data/user/0/.../after.jpg',
  beforeWorkPhotoPath: '/data/user/0/.../before.jpg',
  descripcion: 'Trabajo completado',
  beforeWorkDescripcion: 'Estado inicial',
)
```

### Almacenamiento de Firmas

Las firmas se guardan como **base64** en el modelo WorkReport:
```dart
WorkReport(
  supervisorSignature: 'iVBORw0KGgoAAAANSUhEUgAA...',
  managerSignature: 'iVBORw0KGgoAAAANSUhEUgAA...',
)
```

Para mostrar una firma guardada:
```dart
// Convertir base64 a imagen
final bytes = base64Decode(report.supervisorSignature!);
Image.memory(bytes);
```

### Compresión de Imágenes

`BeforeAfterPhotoCard` comprime automáticamente las fotos:
```dart
await _picker.pickImage(
  source: source,
  imageQuality: 85,    // 85% de calidad
  maxWidth: 1920,      // Max ancho
);
```

Esto reduce el tamaño de archivo significativamente sin pérdida visual notable.

### Validación

El formulario valida:
- ✅ Campos requeridos (nombre, descripción, IDs, fechas)
- ✅ Formato de números (Employee ID, Project ID)
- ✅ Al menos una foto "después" por tarea (la foto "antes" es opcional)

**No valida**:
- ❌ Presencia de firmas (opcional para borradores)

## 🚀 Testing en Dispositivo

### Android

1. Conectar dispositivo vía USB con depuración habilitada
2. Ejecutar: `flutter run`
3. Otorgar permisos cuando la app lo solicite
4. Probar cámara y galería

### iOS

1. Conectar dispositivo iOS
2. Configurar Apple Developer account en Xcode
3. Ejecutar: `flutter run`
4. Otorgar permisos en la primera solicitud
5. Probar cámara y galería

### Emulador

⚠️ **Limitaciones**:
- **Android Emulator**: Cámara virtual funciona pero con baja calidad
- **iOS Simulator**: No tiene acceso a cámara real, solo a fotos de muestra

## 📊 Arquitectura de Datos

### Relación WorkReport ↔ Photos

```
WorkReport (1) ────── (N) Photos
     ↓                      ↓
  - id: 1              - id: 1, workReportId: 1
  - name              - photoPath: "after1.jpg"
  - supervisorSig     - beforeWorkPhotoPath: "before1.jpg"
  - managerSig        
                      - id: 2, workReportId: 1
                      - photoPath: "after2.jpg"
                      - beforeWorkPhotoPath: "before2.jpg"
```

**Flujo de guardado**:
1. Se guarda el WorkReport → obtiene id generado
2. Se asigna workReportId a cada Photo
3. Se guardan todos los Photos asociados

## 🎨 Personalización Visual

### Colores Actuales

```dart
// Color principal (teal)
Color(0xFF2A8D8D)

// Color secundario (teal oscuro)
Color(0xFF1F6B6B)

// Antes (naranja)
Colors.orange[400]

// Después (verde)
Colors.green[600]
```

Para cambiar los colores, edita las constantes en cada widget.

## 📝 Próximas Mejoras

1. **Geolocalización**: Capturar ubicación GPS de cada foto
2. **Timestamp en foto**: Marca de agua con fecha/hora
3. **Múltiples fotos por sección**: Más de una foto "antes" o "después"
4. **Edición de reportes**: Cargar fotos y firmas existentes al editar
5. **Sincronización**: Subir fotos a servidor cloud
6. **Vista de galería**: Ver todas las fotos en modo galería
7. **Zoom de fotos**: Ampliar fotos para ver detalles
8. **Firma offline-first**: Guardar firma localmente y sincronizar después

## 🐛 Solución de Problemas

### Error: "Permission denied"

**Solución**: Verificar que los permisos estén en AndroidManifest.xml e Info.plist

### Error: "Image picker not working"

**Solución**: 
1. Verificar instalación: `flutter pub get`
2. Reiniciar app: `flutter run`
3. Limpiar build: `flutter clean && flutter pub get`

### Error: "Signature not saving"

**Solución**: Verificar que el botón "Guardar" esté habilitado (requiere al menos un trazo en el canvas)

### Fotos muy grandes

**Solución**: Ajustar compresión en `BeforeAfterPhotoCard`:
```dart
imageQuality: 70,  // Menor calidad = menor tamaño
maxWidth: 1280,    // Menor resolución
```

## 📚 Referencias

- [image_picker Package](https://pub.dev/packages/image_picker)
- [signature Package](https://pub.dev/packages/signature)
- [Flutter Camera Guide](https://docs.flutter.dev/cookbook/plugins/picture-using-camera)
- [Android Permissions](https://developer.android.com/guide/topics/permissions/overview)
- [iOS Permissions](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy)

---

**Última actualización**: 2024
**Versión de la guía**: 1.0
