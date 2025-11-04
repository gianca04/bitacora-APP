# 🧪 Guía Rápida de Testing - Fotos y Firmas

## 🚀 Inicio Rápido

### 1. Verificar Instalación

```bash
# Verificar dependencias
flutter pub get

# Verificar que no hay errores de compilación
flutter analyze
```

### 2. Ejecutar en Dispositivo

#### Android
```bash
# Conectar dispositivo via USB con depuración habilitada
# O iniciar emulador Android

flutter devices  # Ver dispositivos disponibles
flutter run      # Ejecutar app
```

#### iOS
```bash
# Conectar dispositivo iOS
# O iniciar simulador iOS

flutter devices  # Ver dispositivos disponibles
flutter run      # Ejecutar app
```

---

## ✅ Checklist de Testing

### Formulario de Reporte

- [ ] **Abrir formulario**
  - Navegar a "Reports" desde el menú
  - Tocar el botón flotante (+)
  - El formulario debe abrir correctamente

- [ ] **Llenar campos básicos**
  - Report Name: "Test Reporte"
  - Description: "Prueba de funcionalidad"
  - Employee ID: 1
  - Project ID: 1
  - Verificar validación de campos requeridos

- [ ] **Seleccionar fechas/horas**
  - Tocar campo "Report Date" → Seleccionar fecha
  - Tocar "Start Time" → Seleccionar hora
  - Tocar "End Time" → Seleccionar hora
  - Verificar que las fechas se muestran correctamente

---

### Captura de Fotos

#### Test 1: Foto desde Cámara

- [ ] **Agregar primera tarea**
  - Tocar "Agregar Nueva Tarea"
  - Debe aparecer card "TAREA 1"

- [ ] **Foto ANTES desde cámara**
  - Tocar "Tomar Foto Antes"
  - Seleccionar "📷 Cámara"
  - Tomar foto
  - ✅ La foto debe aparecer en preview
  - ✅ Botón "Recapturar" debe estar visible

- [ ] **Foto DESPUÉS desde cámara**
  - Tocar "Tomar Foto Después"
  - Seleccionar "📷 Cámara"
  - Tomar foto
  - ✅ La foto debe aparecer en preview
  - ✅ Botón "Recapturar" debe estar visible

- [ ] **Agregar descripciones**
  - Escribir en "Descripción del estado inicial"
  - Escribir en "Descripción del trabajo final"
  - ✅ El texto debe persistir

#### Test 2: Foto desde Galería

- [ ] **Agregar segunda tarea**
  - Tocar "Agregar Nueva Tarea" nuevamente
  - Debe aparecer card "TAREA 2"

- [ ] **Foto desde galería**
  - Tocar "Tomar Foto Antes"
  - Seleccionar "🖼️ Galería"
  - Elegir foto existente
  - ✅ La foto debe aparecer en preview

#### Test 3: Recapturar Foto

- [ ] **Recapturar foto ANTES**
  - Tocar botón "Recapturar" en preview de foto ANTES
  - Seleccionar cámara o galería
  - Tomar/seleccionar nueva foto
  - ✅ La foto anterior debe ser reemplazada

#### Test 4: Eliminar Tarea

- [ ] **Eliminar tarea**
  - Tocar icono de basura en esquina superior derecha de una tarea
  - ✅ La tarea debe desaparecer
  - ✅ La numeración de tareas restantes debe ajustarse

---

### Firmas Digitales

#### Test 5: Firma del Supervisor

- [ ] **Firmar con dedo/stylus**
  - Scrollear hasta "Firmas de Aprobación"
  - Firmar en el canvas "Firma del Supervisor"
  - ✅ El trazo debe ser visible
  - ✅ Botones Limpiar y Guardar deben activarse

- [ ] **Limpiar firma**
  - Tocar "Limpiar"
  - ✅ El canvas debe quedar limpio
  - ✅ Los botones deben desactivarse

- [ ] **Guardar firma**
  - Firmar nuevamente
  - Tocar "Guardar"
  - ✅ Debe aparecer SnackBar verde: "Firma guardada correctamente"

#### Test 6: Firma del Gerente

- [ ] **Firmar gerente**
  - Firmar en el canvas "Firma del Gerente"
  - Tocar "Guardar"
  - ✅ Debe aparecer confirmación

---

### Guardado del Reporte

#### Test 7: Validación

- [ ] **Submit sin campos requeridos**
  - Dejar campos vacíos
  - Tocar "Create Report"
  - ✅ Debe mostrar errores de validación

- [ ] **Submit completo**
  - Llenar todos los campos requeridos
  - Tener al menos 1 tarea con foto DESPUÉS
  - Tocar "Create Report"
  - ✅ Debe navegar a la lista
  - ✅ Debe mostrar SnackBar de éxito
  - ✅ El nuevo reporte debe aparecer en la lista

---

### Visualización de Reportes

#### Test 8: Lista de Reportes

- [ ] **Ver lista**
  - Navegar a "Reports"
  - ✅ Deben aparecer reportes guardados
  - ✅ Cada card debe mostrar:
    - Nombre del reporte
    - Duración
    - Fecha
    - Employee ID
    - Project ID

- [ ] **Pull to refresh**
  - Arrastrar hacia abajo en la lista
  - ✅ Debe recargar los reportes

#### Test 9: Editar Reporte (Futuro)

- [ ] **Tocar reporte existente**
  - ⚠️ Actualmente no implementado
  - Próxima mejora: Cargar datos en formulario

#### Test 10: Eliminar Reporte

- [ ] **Eliminar reporte**
  - Tocar icono de basura en un reporte
  - Confirmar eliminación en el diálogo
  - ✅ El reporte debe desaparecer de la lista

---

## 🔍 Testing de Permisos

### Android

- [ ] **Primera ejecución**
  - Al tocar "Tomar Foto" por primera vez
  - ✅ Debe solicitar permiso de cámara
  - Otorgar permiso
  - ✅ La cámara debe abrir correctamente

- [ ] **Permiso denegado**
  - Denegar permiso de cámara
  - ✅ Debe mostrar mensaje de error
  - Ir a Settings → Permisos → Otorgar
  - ✅ Debe funcionar después

### iOS

- [ ] **Primera ejecución**
  - Al tocar "Tomar Foto" por primera vez
  - ✅ Debe aparecer diálogo con mensaje:
    "Esta app necesita acceso a la cámara para tomar fotografías del trabajo realizado"
  - Otorgar permiso
  - ✅ La cámara debe abrir

---

## 🐛 Tests de Edge Cases

### Casos Límite

- [ ] **Sin fotos**
  - Crear reporte sin agregar ninguna tarea
  - Tocar "Create Report"
  - ✅ Debe guardar correctamente (0 fotos)

- [ ] **Solo foto ANTES**
  - Agregar tarea con solo foto ANTES (sin foto DESPUÉS)
  - Tocar "Create Report"
  - ✅ No debe crear Photo object (solo se guardan tareas con foto DESPUÉS)

- [ ] **Múltiples tareas**
  - Agregar 5 tareas con fotos
  - ✅ Todas deben guardarse correctamente
  - ✅ La numeración debe ser correcta (1-5)

- [ ] **Sin firmas**
  - Crear reporte sin firmas
  - ✅ Debe permitir guardar (firmas opcionales)

- [ ] **Solo una firma**
  - Firmar solo supervisor (sin gerente)
  - ✅ Debe guardar correctamente

- [ ] **Descripción vacía**
  - No escribir descripciones en fotos
  - ✅ Debe guardar con descripciones null/vacías

---

## 📱 Tests de UI/UX

### Responsividad

- [ ] **Orientación horizontal**
  - Rotar dispositivo
  - ✅ El layout debe adaptarse
  - ✅ Las fotos deben verse correctamente

- [ ] **Scroll**
  - Con formulario largo (múltiples tareas)
  - ✅ Debe hacer scroll suavemente
  - ✅ Los campos deben permanecer accesibles

- [ ] **Teclado**
  - Tocar campo de texto
  - ✅ El teclado debe aparecer
  - ✅ No debe ocultar el campo activo

### Performance

- [ ] **Fotos grandes**
  - Tomar fotos de alta resolución
  - ✅ La compresión debe funcionar
  - ✅ El preview debe cargar rápido
  - ✅ No debe crashear la app

- [ ] **Múltiples fotos**
  - Agregar 10+ tareas con fotos
  - ✅ La app debe permanecer fluida
  - ✅ El guardado no debe tardar demasiado

---

## 📊 Resultados Esperados

### ✅ Success Criteria

| Funcionalidad | Criterio de Éxito |
|--------------|-------------------|
| Captura desde cámara | Foto visible en preview inmediatamente |
| Captura desde galería | Foto seleccionada cargada correctamente |
| Recapturar | Foto anterior reemplazada |
| Firmas | Trazo visible, guardado confirmado |
| Validación | Errores mostrados en campos requeridos |
| Guardado | SnackBar verde, navega a lista |
| Lista | Reportes visibles con datos correctos |
| Eliminación | Reporte removido de lista |

### ❌ Red Flags

- 🚫 Crash al abrir cámara
- 🚫 Foto no aparece en preview
- 🚫 Firma no se guarda
- 🚫 App lenta con múltiples fotos
- 🚫 Permisos no solicitados
- 🚫 Datos no persistidos
- 🚫 Memory leak con fotos grandes

---

## 🔧 Debugging

### Herramientas

```bash
# Ver logs en tiempo real
flutter logs

# Inspeccionar widgets
# Presionar el botón de debug en DevTools

# Ver base de datos Isar
# Instalar: https://github.com/isar/isar_inspector
flutter pub run isar_inspector
```

### Common Issues

| Issue | Solución |
|-------|----------|
| "Permission denied" | Verificar AndroidManifest.xml / Info.plist |
| "Image picker not found" | `flutter clean && flutter pub get` |
| "Signature not showing" | Verificar que hay al menos un trazo en canvas |
| "Photos not saving" | Revisar logs, verificar permisos de escritura |
| "Slow preview" | Reducir maxWidth en image_picker settings |

---

## 📝 Checklist Final

Antes de marcar como completo:

- [ ] ✅ Todos los tests básicos pasados
- [ ] ✅ Tests de edge cases verificados
- [ ] ✅ Performance aceptable con 10+ fotos
- [ ] ✅ Permisos funcionando en Android
- [ ] ✅ Permisos funcionando en iOS (si aplica)
- [ ] ✅ No hay memory leaks visibles
- [ ] ✅ UI responsiva en diferentes tamaños
- [ ] ✅ Firmas guardadas correctamente
- [ ] ✅ Datos persisten después de cerrar app

---

## 🎉 Testing Completado

Una vez completados todos los tests:

1. **Documentar issues encontrados**
2. **Reportar bugs si los hay**
3. **Sugerir mejoras de UX**
4. **Marcar como listo para producción**

---

**Tiempo estimado de testing**: 30-45 minutos

**Última actualización**: 2024
