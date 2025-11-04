# Work Report Form - Guía de Uso

## 📋 Descripción

El formulario de Work Report permite crear y editar reportes de trabajo con sus fotos asociadas. Sigue las mejores prácticas de Flutter con separación de responsabilidades.

## 🏗️ Arquitectura del Formulario

### Componentes Creados:

#### 1. **WorkReportFormPage** (`lib/views/work_report_form_page.dart`)
- **Responsabilidad**: Página contenedora y manejo de navegación
- **Características**:
  - Escucha cambios de estado del ViewModel
  - Muestra indicadores de carga
  - Maneja navegación después de guardar
  - Coordina guardado de WorkReport y Photos

#### 2. **WorkReportForm** (`lib/widgets/work_report_form.dart`)
- **Responsabilidad**: Widget del formulario con estado y validación
- **Características**:
  - Gestión de controllers para cada campo
  - Validación de formulario
  - Selección de fechas y horas
  - Integración con PhotoFormSection
  - Inicialización de datos para edición

#### 3. **PhotoFormSection** (`lib/widgets/photo_form_section.dart`)
- **Responsabilidad**: Gestión de lista de fotos
- **Características**:
  - Agregar fotos con diálogo modal
  - Mostrar lista de fotos
  - Eliminar fotos
  - Soporte para fotos "antes" y "después" del trabajo
  - Preview de información de fotos

#### 4. **WorkReportListPage** (`lib/views/work_report_list_page.dart`)
- **Responsabilidad**: Lista de todos los reportes
- **Características**:
  - Carga inicial de reportes
  - Pull-to-refresh
  - Navegación a formulario de creación/edición
  - Confirmación de eliminación
  - Estados: loading, error, empty, loaded

## 📁 Estructura de Archivos

```
lib/
├── views/
│   ├── work_report_form_page.dart    # Página del formulario
│   └── work_report_list_page.dart    # Página de lista
├── widgets/
│   ├── work_report_form.dart         # Widget del formulario
│   └── photo_form_section.dart       # Widget de fotos
└── routes/
    └── app_router.dart               # Ruta: /reports
```

## 🎯 Principios Aplicados

### 1. **Single Responsibility Principle (SRP)**
- **WorkReportFormPage**: Solo maneja navegación y coordinación
- **WorkReportForm**: Solo maneja estado del formulario
- **PhotoFormSection**: Solo maneja lista de fotos

### 2. **Separation of Concerns**
- **UI** (Page): Muestra loading, errores, navegación
- **Form Widget**: Maneja estado y validación
- **Section Widget**: Maneja una parte específica (fotos)

### 3. **State Management**
- Usa ViewModels para operaciones de base de datos
- Estado local para el formulario (TextEditingControllers)
- Ref.listen para efectos secundarios (SnackBars, navegación)

## 🚀 Uso

### Acceder a la Lista de Reportes

```dart
// Desde el menú lateral o AppBar
// Navegar a: /reports
context.go('/reports');
```

### Crear un Nuevo Reporte

1. Desde WorkReportListPage, tap en el botón flotante (+)
2. Llenar los campos requeridos:
   - Report Name *
   - Description *
   - Employee ID *
   - Project ID *
3. Seleccionar fechas y horas
4. (Opcional) Agregar detalles adicionales
5. (Opcional) Agregar fotos
6. Tap "Create Report"

### Editar un Reporte Existente

1. Desde WorkReportListPage, tap en una tarjeta de reporte
2. Modificar los campos necesarios
3. Tap "Update Report"

### Agregar Fotos

1. En el formulario, scroll hasta la sección "Photos"
2. Tap "Add Photo"
3. Ingresar ruta de la foto *
4. (Opcional) Agregar descripción
5. (Opcional) Marcar "Include Before-Work Photo" y llenar datos
6. Tap "Add"

### Eliminar un Reporte

1. Desde WorkReportListPage, tap el icono de eliminar (🗑️)
2. Confirmar en el diálogo

## 📊 Campos del Formulario

### Información Básica
- **Report Name*** (requerido): Nombre del reporte
- **Description*** (requerido): Descripción del trabajo

### Asignación
- **Employee ID*** (requerido): ID numérico del empleado
- **Project ID*** (requerido): ID numérico del proyecto

### Horario
- **Report Date** (requerido): Fecha del reporte
- **Start Time** (requerido): Hora de inicio
- **End Time** (requerido): Hora de fin

### Detalles Adicionales (opcionales)
- **Suggestions**: Sugerencias
- **Tools Used**: Herramientas utilizadas
- **Personnel**: Personal involucrado
- **Materials**: Materiales usados

### Fotos (opcional)
- **Photo Path***: Ruta a la imagen
- **Description**: Descripción de la foto
- **Before Photo Path**: Ruta a imagen "antes del trabajo"
- **Before Description**: Descripción de la foto "antes"

## 🎨 Diseño Simple

El diseño sigue un enfoque minimalista:
- TextField estándar de Flutter con OutlinedBorder
- Secciones claramente divididas con títulos
- Botones con color del tema (#2A8D8D)
- Cards para lista de reportes
- Chips informativos para metadatos

## 🔄 Flujo de Datos

### Crear Reporte
```
UI → onSubmit() → Page → ViewModel → Repository → Isar
                         ↓
                    Photos ViewModel → Repository → Isar
```

### Listar Reportes
```
UI → initState → ViewModel.loadAll() → Repository → Isar
                         ↓
                    UI actualizada automáticamente
```

### Actualizar Reporte
```
UI → onSubmit() → Page → ViewModel.updateReport() → Repository → Isar
```

## 🧪 Testing (Próximamente)

La arquitectura permite testing fácil:

```dart
// Unit test del Form
testWidgets('validates required fields', (tester) async {
  await tester.pumpWidget(WorkReportForm(onSubmit: (_, __) {}));
  // Tap submit sin llenar campos
  // Verificar errores de validación
});

// Integration test
testWidgets('creates work report end-to-end', (tester) async {
  // Navegar a formulario
  // Llenar campos
  // Submit
  // Verificar que aparece en la lista
});
```

## 📝 Notas Importantes

1. **Photo Paths**: Por ahora son strings simples. En producción:
   - Usar image_picker para seleccionar fotos
   - Guardar en almacenamiento local con path_provider
   - Almacenar rutas relativas en la BD

2. **Validación**: Solo campos básicos. Considerar agregar:
   - Validación de fechas (end > start)
   - Validación de IDs contra base de datos
   - Formato de rutas de fotos

3. **Photos Update**: Al editar un reporte, las fotos se agregan pero no se eliminan las antiguas. Implementar:
   - Cargar fotos existentes del reporte
   - Opción de eliminar fotos individuales
   - Actualización de fotos existentes

4. **Signatures**: Los campos de firma existen en el modelo pero no en el formulario. Considerar:
   - Widget de firma con signature package
   - Guardar como base64 o imagen

## 🚀 Próximas Mejoras

- [ ] Integrar image_picker para seleccionar fotos
- [ ] Preview de imágenes en el formulario
- [ ] Edición de fotos existentes
- [ ] Widget de firma digital
- [ ] Validaciones más robustas
- [ ] Filtros en la lista de reportes
- [ ] Búsqueda de reportes
- [ ] Exportar reportes a PDF
- [ ] Modo offline con sincronización

## 🎓 Buenas Prácticas Aplicadas

✅ **Separación de responsabilidades**: Cada widget tiene un propósito único
✅ **Estado inmutable**: ViewModels con StateNotifier
✅ **Validación de formularios**: FormKey y validators
✅ **Manejo de errores**: Try-catch con mensajes al usuario
✅ **Feedback visual**: SnackBars, loading indicators
✅ **Navegación declarativa**: GoRouter con nombres de rutas
✅ **Dispose de recursos**: Controllers se limpian en dispose()
✅ **Código legible**: Nombres descriptivos y comentarios
✅ **Widgets reutilizables**: PhotoFormSection separado
✅ **Consistent styling**: Colores del tema aplicados
