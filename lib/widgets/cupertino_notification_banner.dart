import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Tipo de notificación que determina el color y el icono
enum NotificationType {
  success,
  error,
  warning,
  info,
}

/// Widget de notificación con Cupertino Design
/// 
/// Puede ser llamado desde cualquier parte de la app usando:
/// ```dart
/// CupertinoNotificationBanner.show(
///   context,
///   message: 'Mensaje aquí',
///   type: NotificationType.error,
/// );
/// ```
class CupertinoNotificationBanner extends StatelessWidget {
  final String message;
  final NotificationType type;
  final bool showLogo;
  final VoidCallback? onTap;
  final Duration duration;

  const CupertinoNotificationBanner({
    super.key,
    required this.message,
    this.type = NotificationType.info,
    this.showLogo = false,
    this.onTap,
    this.duration = const Duration(seconds: 3),
  });

  /// Muestra la notificación como un overlay en la parte superior de la pantalla
  static void show(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
    bool showLogo = false,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Buscar el Overlay de forma segura
    //final overlay = Overlay.maybeOf(context);
    
    // Si no hay Overlay disponible, no hacer nada
    //if (overlay == null) {
    //  debugPrint('Warning: No Overlay found in context. Cannot show notification.');
    //  return;
    //}
    
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        top: MediaQuery.of(overlayContext).padding.top + 8,
        left: 16,
        right: 16,
        child: _AnimatedNotification(
          message: message,
          type: type,
          showLogo: showLogo,
          onTap: onTap ?? () => overlayEntry.remove(),
          onDismiss: () => overlayEntry.remove(),
          duration: duration,
        ),
      ),
    );

    //overlay.insert(overlayEntry);
    debugPrint('🔔 CupertinoNotificationBanner: inserted overlayEntry');
  }

  @override
  Widget build(BuildContext context) {
    final config = _getNotificationConfig(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono o Logo
          if (showLogo) ...[
            _buildLogo(),
            const SizedBox(width: 12),
          ] else ...[
            Icon(
              config.icon,
              color: config.iconColor,
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          
          // Mensaje
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: config.textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ),
          
          // Botón de cerrar (opcional)
          if (onTap != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onTap,
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                color: config.iconColor.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(4),
      child: SvgPicture.asset(
        'assets/images/svg/logo_secundario.svg',
        fit: BoxFit.contain,
      ),
    );
  }

  _NotificationConfig _getNotificationConfig(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return _NotificationConfig(
          backgroundColor: const Color(0xFF34C759), // iOS Green
          iconColor: CupertinoColors.white,
          textColor: CupertinoColors.white,
          icon: CupertinoIcons.check_mark_circled_solid,
        );
      case NotificationType.error:
        return _NotificationConfig(
          backgroundColor: const Color(0xFFFF3B30), // iOS Red
          iconColor: CupertinoColors.white,
          textColor: CupertinoColors.white,
          icon: CupertinoIcons.xmark_circle_fill,
        );
      case NotificationType.warning:
        return _NotificationConfig(
          backgroundColor: const Color(0xFFFF9500), // iOS Orange
          iconColor: CupertinoColors.white,
          textColor: CupertinoColors.white,
          icon: CupertinoIcons.exclamationmark_triangle_fill,
        );
      case NotificationType.info:
        return _NotificationConfig(
          backgroundColor: const Color(0xFF007AFF), // iOS Blue
          iconColor: CupertinoColors.white,
          textColor: CupertinoColors.white,
          icon: CupertinoIcons.info_circle_fill,
        );
    }
  }
}

/// Widget interno con animación de entrada y salida
class _AnimatedNotification extends StatefulWidget {
  final String message;
  final NotificationType type;
  final bool showLogo;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final Duration duration;

  const _AnimatedNotification({
    required this.message,
    required this.type,
    required this.showLogo,
    required this.onTap,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Animación de entrada
    _controller.forward();

    // Auto-dismiss después de la duración especificada
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: _dismiss,
          onVerticalDragEnd: (details) {
            // Deslizar hacia arriba para cerrar
            if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
              _dismiss();
            }
          },
          child: CupertinoNotificationBanner(
            message: widget.message,
            type: widget.type,
            showLogo: widget.showLogo,
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}

/// Configuración interna para cada tipo de notificación
class _NotificationConfig {
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  _NotificationConfig({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}

/// Widget wrapper para mostrar notificaciones inline (sin overlay)
/// 
/// Útil para casos donde quieres la notificación como parte del layout
class CupertinoNotificationInline extends StatelessWidget {
  final String message;
  final NotificationType type;
  final bool showLogo;
  final VoidCallback? onDismiss;

  const CupertinoNotificationInline({
    super.key,
    required this.message,
    this.type = NotificationType.info,
    this.showLogo = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: CupertinoNotificationBanner(
        message: message,
        type: type,
        showLogo: showLogo,
        onTap: onDismiss,
      ),
    );
  }
}
