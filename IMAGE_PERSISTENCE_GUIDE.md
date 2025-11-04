# 💾 Sistema de Persistencia de Imágenes

## 📋 Resumen

Se ha implementado un sistema robusto de persistencia de imágenes siguiendo las mejores prácticas de Flutter y la arquitectura del proyecto. El sistema garantiza que las fotos se almacenen permanentemente en el dispositivo y se eliminen correctamente cuando ya no se necesitan.

## 🏗️ Arquitectura

### Flujo de Datos

```
Usuario toma foto
      ↓
ImagePicker captura (archivo temporal)
      ↓
PhotoStorageService.savePhoto()
  ├─ Copia a directorio permanente
  ├─ Comprime imagen (max 1920px, 85% calidad)
  └─ Genera nombre único con timestamp
      ↓
Retorna ruta permanente
      ↓
BeforeAfterPhotoCard actualiza estado
      ↓
WorkReportForm guarda en Photo model
      ↓
Isar DB almacena ruta permanente
```

## 📦 Componentes del Sistema

### 1. PhotoStorageService

**Ubicación**: `lib/services/photo_storage_service.dart`

**Responsabilidades**:
- ✅ Guardar fotos en directorio permanente de la app
- ✅ Comprimir y optimizar imágenes
- ✅ Eliminar fotos cuando se borran registros
- ✅ Limpiar fotos huérfanas (sin referencias en DB)
- ✅ Verificar existencia de archivos
- ✅ Calcular tamaño total de almacenamiento

**Métodos principales**:

```dart
// Guarda foto temporal en almacenamiento permanente
Future<String> savePhoto(String tempPhotoPath)

// Elimina foto del almacenamiento
Future<void> deletePhoto(String photoPath)

// Verifica si foto existe
Future<bool> photoExists(String photoPath)

// Elimina fotos huérfanas
Future<void> cleanupOrphanedPhotos(List<String> referencedPhotoPaths)

// Obtiene tamaño total de fotos
Future<int> getTotalPhotoSize()
```

**Detalles de implementación**:

```dart
// Directorio de almacenamiento
static const String _photoDirectory = 'work_report_photos';
// Ubicación: /data/user/0/com.example.bitacora/documents/work_report_photos/

// Nombre de archivo con timestamp único
String fileName = 'photo_${timestamp}${extension}';
// Ejemplo: photo_1730745123456.jpg

// Compresión automática
- Si ancho > 1920px → redimensionar a 1920px
- Calidad JPEG: 85%
- Formato: JPEG optimizado
```

### 2. BeforeAfterPhotoCard (Actualizado)

**Ubicación**: `lib/widgets/before_after_photo_card.dart`

**Cambios**:
- ✅ Ahora es `ConsumerStatefulWidget` para acceder a providers
- ✅ Usa `PhotoStorageService` para persistencia
- ✅ Elimina foto anterior al recapturar
- ✅ Muestra indicadores de progreso
- ✅ Feedback visual con SnackBars

**Flujo de captura**:

```dart
1. Usuario toca "Tomar Foto"
2. Muestra bottom sheet (Cámara/Galería)
3. ImagePicker captura foto temporal
4. Muestra "Procesando foto..." (SnackBar)
5. PhotoStorageService.savePhoto()
   - Copia a directorio permanente
   - Comprime imagen
   - Retorna ruta permanente
6. Si existe foto anterior → eliminarla
7. Actualiza estado con nueva ruta
8. Muestra "✅ Foto guardada correctamente"
```

### 3. PhotoViewModel (Actualizado)

**Ubicación**: `lib/viewmodels/photo_viewmodel.dart`

**Cambios**:
- ✅ Recibe `PhotoStorageService` en constructor
- ✅ `deletePhoto()` ahora elimina archivos del almacenamiento
- ✅ `deleteByWorkReportId()` elimina todas las fotos de un reporte

**Método deletePhoto mejorado**:

```dart
Future<bool> deletePhoto(Id id) async {
  // 1. Obtener photo del estado
  final photos = state.photos.where((p) => p.id == id).toList();
  
  // 2. Eliminar de base de datos
  final success = await repository.delete(id);
  
  if (success && photos.isNotEmpty) {
    final photo = photos.first;
    
    // 3. Eliminar archivo "después"
    if (photo.photoPath.isNotEmpty) {
      await storageService.deletePhoto(photo.photoPath);
    }
    
    // 4. Eliminar archivo "antes" si existe
    if (photo.beforeWorkPhotoPath != null) {
      await storageService.deletePhoto(photo.beforeWorkPhotoPath!);
    }
    
    // 5. Recargar lista
    await loadAll();
  }
  
  return success;
}
```

**Método deleteByWorkReportId mejorado**:

```dart
Future<int> deleteByWorkReportId(int workReportId) async {
  // 1. Obtener todas las fotos del reporte
  final photos = await repository.getByWorkReportId(workReportId);
  
  // 2. Eliminar de base de datos
  final count = await repository.deleteByWorkReportId(workReportId);
  
  // 3. Eliminar todos los archivos
  for (final photo in photos) {
    await storageService.deletePhoto(photo.photoPath);
    if (photo.beforeWorkPhotoPath != null) {
      await storageService.deletePhoto(photo.beforeWorkPhotoPath!);
    }
  }
  
  return count;
}
```

### 4. WorkReportListPage (Actualizado)

**Ubicación**: `lib/views/work_report_list_page.dart`

**Cambio en _confirmDelete**:

```dart
if (confirmed == true && mounted) {
  // 1. Primero eliminar fotos (archivos + DB)
  await ref.read(photoViewModelProvider.notifier)
      .deleteByWorkReportId(report.id);
  
  // 2. Luego eliminar reporte
  await ref.read(workReportViewModelProvider.notifier)
      .deleteReport(report.id);
  
  // 3. Feedback visual
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('✅ Report and photos deleted')),
  );
}
```

### 5. Providers (Actualizado)

**Ubicación**: `lib/providers/app_providers.dart`

**Nuevo provider**:

```dart
/// Provider for photo storage service
final photoStorageServiceProvider = Provider<PhotoStorageService>((ref) {
  return PhotoStorageService();
});
```

**PhotoViewModel provider actualizado**:

```dart
final photoViewModelProvider =
    StateNotifierProvider<PhotoViewModel, PhotoState>((ref) {
  final repo = ref.watch(photoRepositoryProvider);
  final storageService = ref.watch(photoStorageServiceProvider);
  return PhotoViewModel(
    repository: repo,
    storageService: storageService,
  );
});
```

## 📁 Estructura de Almacenamiento

### Ubicación de Fotos

```
Android:
/data/user/0/com.example.bitacora/
  └── documents/
      └── work_report_photos/
          ├── photo_1730745123456.jpg
          ├── photo_1730745234567.jpg
          └── photo_1730745345678.jpg

iOS:
/var/mobile/Containers/Data/Application/<UUID>/
  └── Documents/
      └── work_report_photos/
          ├── photo_1730745123456.jpg
          └── photo_1730745234567.jpg
```

### Convención de Nombres

```
Patrón: photo_{timestamp}.{extension}

Ejemplos:
- photo_1730745123456.jpg
- photo_1730745234567.png
- photo_1730745345678.jpeg

Timestamp: milliseconds desde epoch
Extension: preservada del archivo original
```

## 🔄 Ciclo de Vida de una Foto

### 1. Creación

```
Usuario toma foto
  ↓
Archivo temporal: /data/user/0/.../cache/image_picker123.jpg
  ↓
PhotoStorageService.savePhoto()
  ↓
Archivo permanente: /data/user/0/.../documents/work_report_photos/photo_1730745123456.jpg
  ↓
Ruta guardada en DB: "/data/user/0/.../photo_1730745123456.jpg"
```

### 2. Recaptura

```
Usuario recaptura foto
  ↓
Nueva foto temporal capturada
  ↓
PhotoStorageService.savePhoto(nuevaFoto)
  ↓
Nueva foto permanente creada
  ↓
PhotoStorageService.deletePhoto(fotoAnterior)
  ↓
Foto anterior eliminada del almacenamiento
  ↓
Estado actualizado con nueva ruta
```

### 3. Eliminación de Reporte

```
Usuario elimina reporte
  ↓
PhotoViewModel.deleteByWorkReportId()
  ├─ Obtener todas las fotos del reporte
  ├─ Eliminar registros de DB
  └─ Para cada foto:
      ├─ Eliminar photo.photoPath
      └─ Eliminar photo.beforeWorkPhotoPath (si existe)
  ↓
WorkReportViewModel.deleteReport()
  ↓
Reporte y fotos completamente eliminados
```

## 🛡️ Manejo de Errores

### Escenarios Cubiertos

1. **Archivo temporal no existe**
   ```dart
   if (!await tempFile.exists()) {
     throw Exception('Photo file does not exist');
   }
   ```

2. **Error al comprimir imagen**
   ```dart
   if (image != null) {
     // Comprimir
   } else {
     // Copiar archivo directamente
     await tempFile.copy(permanentPath);
   }
   ```

3. **Error al eliminar foto**
   ```dart
   try {
     await file.delete();
   } catch (e) {
     print('Error deleting photo: $e');
     // No throw - no bloquear otras operaciones
   }
   ```

4. **Verificación de existencia**
   ```dart
   Future<bool> photoExists(String photoPath) async {
     try {
       final File file = File(photoPath);
       return await file.exists();
     } catch (e) {
       return false;
     }
   }
   ```

## 🔧 Optimizaciones Implementadas

### Compresión Automática

```dart
// Redimensionar si es muy grande
if (image.width > 1920) {
  resized = img.copyResize(image, width: 1920);
}

// Comprimir JPEG
final compressed = img.encodeJpg(resized, quality: 85);
```

**Beneficios**:
- Foto 4000x3000 (8MB) → 1920x1440 (800KB)
- Ahorro de ~90% de espacio
- Sin pérdida visual significativa
- Carga más rápida en UI

### Nombres Únicos con Timestamp

```dart
String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
String fileName = 'photo_$timestamp$extension';
```

**Beneficios**:
- Evita colisiones de nombres
- Orden cronológico automático
- Fácil debugging (ver cuándo se creó)

### Eliminación Proactiva

```dart
// Al recapturar
if (isBeforePhoto && _beforePath != null) {
  await photoStorageService.deletePhoto(_beforePath!);
}
```

**Beneficios**:
- No acumula fotos viejas
- Ahorra espacio automáticamente
- Mantiene almacenamiento limpio

## 🧹 Mantenimiento

### Limpieza de Fotos Huérfanas

```dart
Future<void> cleanupOrphanedPhotos(List<String> referencedPhotoPaths)
```

**Uso recomendado**:
```dart
// En settings o mantenimiento
final photoViewModel = ref.read(photoViewModelProvider.notifier);
final storageService = ref.read(photoStorageServiceProvider);

// Obtener todas las rutas referenciadas en DB
await photoViewModel.loadAll();
final photos = photoViewModel.state.photos;
final referencedPaths = photos
    .map((p) => [p.photoPath, p.beforeWorkPhotoPath])
    .expand((x) => x)
    .where((path) => path != null && path.isNotEmpty)
    .toList();

// Limpiar fotos sin referencias
await storageService.cleanupOrphanedPhotos(referencedPaths);
```

**Cuándo ejecutar**:
- Mensualmente (tarea en background)
- Al inicio de app (si no se ha hecho en 30 días)
- Manualmente desde Settings

### Monitoreo de Espacio

```dart
// Obtener tamaño total
final totalBytes = await storageService.getTotalPhotoSize();
final readable = storageService.formatBytes(totalBytes);
print('Total photo storage: $readable');
```

**Output ejemplo**:
```
Total photo storage: 45.3 MB
```

## 📊 Métricas de Performance

### Tiempos Estimados

| Operación | Tiempo | Notas |
|-----------|--------|-------|
| Capturar foto | 1-2s | Depende de cámara |
| Guardar + comprimir | 0.5-1s | Foto 4000x3000 |
| Eliminar foto | <100ms | I/O simple |
| Cleanup huérfanas | 1-3s | Depende de cantidad |

### Uso de Espacio

| Escenario | Espacio por foto | Total (100 fotos) |
|-----------|------------------|-------------------|
| Sin compresión | ~8 MB | ~800 MB |
| Con compresión (85%) | ~800 KB | ~80 MB |
| **Ahorro** | **90%** | **720 MB** |

## 🔍 Debugging

### Ver fotos almacenadas

```dart
final storageService = ref.read(photoStorageServiceProvider);
final appDocDir = await getApplicationDocumentsDirectory();
final photoDir = Directory(path.join(appDocDir.path, 'work_report_photos'));

if (await photoDir.exists()) {
  final files = photoDir.listSync();
  for (final file in files) {
    print('Photo: ${file.path}');
  }
}
```

### Verificar integridad

```dart
// Verificar que todas las fotos en DB existen
final photos = await repository.getAll();
for (final photo in photos) {
  final exists = await storageService.photoExists(photo.photoPath);
  if (!exists) {
    print('⚠️ Missing photo: ${photo.photoPath}');
  }
}
```

## ✅ Checklist de Implementación

- [x] PhotoStorageService creado
- [x] Compresión de imágenes implementada
- [x] Nombres únicos con timestamp
- [x] BeforeAfterPhotoCard actualizado
- [x] PhotoViewModel actualizado con eliminación
- [x] WorkReportListPage elimina fotos al borrar
- [x] Providers configurados
- [x] Manejo de errores completo
- [x] Feedback visual con SnackBars
- [x] Documentación completa

## 🚀 Próximas Mejoras

1. **Sincronización con servidor**
   - Subir fotos a cloud storage
   - Mantener copia local + remota
   - Sincronizar cambios

2. **Caché de miniaturas**
   - Generar thumbnails pequeños
   - Cargar lista más rápido
   - Vista previa instantánea

3. **Backup automático**
   - Export a SD card
   - Backup periódico
   - Restauración desde backup

4. **Compresión avanzada**
   - WebP format (mejor compresión)
   - Compresión adaptativa por red
   - Lazy loading de imágenes

---

**Última actualización**: 2024  
**Estado**: ✅ Implementado y funcionando
