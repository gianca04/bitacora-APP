import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/cupertino_notification_banner.dart';

/// Página de demostración de las notificaciones Cupertino
/// 
/// Muestra ejemplos de todos los tipos y configuraciones disponibles
class NotificationDemoPage extends StatelessWidget {
  const NotificationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        title: const Text('Notificaciones Cupertino'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            const Text(
              'Tipos de Notificación',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toca cualquier botón para ver la notificación en acción',
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 24),

            // Success Examples
            _buildSection(
              title: '✓ Success (Éxito)',
              color: const Color(0xFF34C759),
              children: [
                _buildButton(
                  context,
                  label: 'Guardado exitoso',
                  onPressed: () => _showSuccess(context),
                ),
                _buildButton(
                  context,
                  label: 'Con logo de empresa',
                  onPressed: () => _showSuccessWithLogo(context),
                ),
                _buildButton(
                  context,
                  label: 'Conexión restaurada',
                  onPressed: () => _showConnectionRestored(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Error Examples
            _buildSection(
              title: '✗ Error',
              color: const Color(0xFFFF3B30),
              children: [
                _buildButton(
                  context,
                  label: 'Error de red',
                  onPressed: () => _showError(context),
                ),
                _buildButton(
                  context,
                  label: 'Sin conexión',
                  onPressed: () => _showNoConnection(context),
                ),
                _buildButton(
                  context,
                  label: 'Error con detalles',
                  onPressed: () => _showDetailedError(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Warning Examples
            _buildSection(
              title: '⚠ Warning (Advertencia)',
              color: const Color(0xFFFF9500),
              children: [
                _buildButton(
                  context,
                  label: 'Conexión limitada',
                  onPressed: () => _showWarning(context),
                ),
                _buildButton(
                  context,
                  label: 'Batería baja',
                  onPressed: () => _showBatteryWarning(context),
                ),
                _buildButton(
                  context,
                  label: 'Espacio limitado',
                  onPressed: () => _showStorageWarning(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Info Examples
            _buildSection(
              title: 'ⓘ Info (Información)',
              color: const Color(0xFF007AFF),
              children: [
                _buildButton(
                  context,
                  label: 'Actualización disponible',
                  onPressed: () => _showInfo(context),
                ),
                _buildButton(
                  context,
                  label: 'Nuevo mensaje',
                  onPressed: () => _showNewMessage(context),
                ),
                _buildButton(
                  context,
                  label: 'Consejo del día',
                  onPressed: () => _showTip(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Special Examples
            _buildSection(
              title: '🎨 Configuraciones Especiales',
              color: CupertinoColors.systemPurple,
              children: [
                _buildButton(
                  context,
                  label: 'Notificación rápida (1.5s)',
                  onPressed: () => _showQuick(context),
                ),
                _buildButton(
                  context,
                  label: 'Notificación larga (8s)',
                  onPressed: () => _showLong(context),
                ),
                _buildButton(
                  context,
                  label: 'Con acción personalizada',
                  onPressed: () => _showWithAction(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Inline Examples
            const Text(
              'Notificaciones Inline',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Estas notificaciones son parte del layout:',
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 16),
            
            const CupertinoNotificationInline(
              message: 'Esta es una notificación inline de éxito',
              type: NotificationType.success,
            ),
            const SizedBox(height: 12),
            
            const CupertinoNotificationInline(
              message: 'Notificación inline de error',
              type: NotificationType.error,
            ),
            const SizedBox(height: 12),
            
            const CupertinoNotificationInline(
              message: 'Advertencia inline con logo',
              type: NotificationType.warning,
              showLogo: true,
            ),
            const SizedBox(height: 12),
            
            const CupertinoNotificationInline(
              message: 'Información inline',
              type: NotificationType.info,
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          color: CupertinoColors.systemGrey5,
          padding: const EdgeInsets.symmetric(vertical: 12),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.label,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  // Success Examples
  void _showSuccess(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Datos guardados exitosamente',
      type: NotificationType.success,
    );
  }

  void _showSuccessWithLogo(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Reporte enviado correctamente',
      type: NotificationType.success,
      showLogo: true,
    );
  }

  void _showConnectionRestored(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Conexión a Internet restaurada',
      type: NotificationType.success,
      showLogo: true,
      duration: const Duration(seconds: 2),
    );
  }

  // Error Examples
  void _showError(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Error al procesar la solicitud',
      type: NotificationType.error,
    );
  }

  void _showNoConnection(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Sin conexión a la red',
      type: NotificationType.error,
      showLogo: true,
      duration: const Duration(seconds: 4),
    );
  }

  void _showDetailedError(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'No se pudo cargar los datos del servidor',
      type: NotificationType.error,
    );
  }

  // Warning Examples
  void _showWarning(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Conectado sin acceso a Internet',
      type: NotificationType.warning,
      showLogo: true,
    );
  }

  void _showBatteryWarning(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Batería baja - Considera cargar tu dispositivo',
      type: NotificationType.warning,
    );
  }

  void _showStorageWarning(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Espacio de almacenamiento casi lleno',
      type: NotificationType.warning,
    );
  }

  // Info Examples
  void _showInfo(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Nueva actualización disponible',
      type: NotificationType.info,
    );
  }

  void _showNewMessage(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Tienes 3 mensajes nuevos',
      type: NotificationType.info,
      showLogo: true,
    );
  }

  void _showTip(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Desliza hacia arriba para cerrar notificaciones',
      type: NotificationType.info,
      duration: const Duration(seconds: 5),
    );
  }

  // Special Examples
  void _showQuick(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: '¡Guardado!',
      type: NotificationType.success,
      duration: const Duration(milliseconds: 1500),
    );
  }

  void _showLong(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Esta notificación permanecerá por 8 segundos',
      type: NotificationType.info,
      duration: const Duration(seconds: 8),
    );
  }

  void _showWithAction(BuildContext context) {
    CupertinoNotificationBanner.show(
      context,
      message: 'Toca para ver más detalles',
      type: NotificationType.info,
      onTap: () {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('¡Acción personalizada!'),
            content: const Text('Tocaste la notificación'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
