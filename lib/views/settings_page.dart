import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/connectivity_indicator.dart';
import '../providers/connectivity_preferences_provider.dart';
import '../models/connectivity_preferences.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar StateNotifier en lugar de Stream para carga instantánea
    final preferences = ref.watch(connectivityPreferencesNotifierProvider);
    
    // AppShell provides the app bar and drawer; return only content.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        Text(
          'Configuración',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gestiona la configuración de tu aplicación',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 32),
        
        // Sección de Conectividad
        Text(
          'Estado de Conexión',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        const ConnectivityDetailCard(),
        
        const SizedBox(height: 24),
        
        // Configuración del Indicador
        Text(
          'Configuración del Indicador',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        
        // Directamente renderizar sin loading ya que StateNotifier carga instantáneamente
        _buildConnectivitySettings(context, ref, preferences),
        
        const SizedBox(height: 32),
        
        // Sección de General (ejemplo)
        Text(
          'General',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notificaciones'),
                subtitle: const Text('Gestionar notificaciones de la app'),
                trailing: CupertinoSwitch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implementar cambio de preferencia
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Idioma'),
                subtitle: const Text('Español'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Abrir selector de idioma
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Tema oscuro'),
                subtitle: const Text('Activado'),
                trailing: CupertinoSwitch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implementar cambio de tema
                  },
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Sección de Información
        Text(
          'Información',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Versión'),
                subtitle: Text('0.1.1'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Términos y condiciones'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Abrir términos
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Política de privacidad'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Abrir política
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildConnectivitySettings(
    BuildContext context,
    WidgetRef ref,
    ConnectivityPreferences preferences,
  ) {
    final notifier = ref.read(connectivityPreferencesNotifierProvider.notifier);
    
    return Card(
      child: Column(
        children: [
          // Habilitar/Deshabilitar indicador
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Mostrar indicador'),
            subtitle: const Text('Muestra el estado de conexión en el navbar'),
            trailing: CupertinoSwitch(
              value: preferences.isEnabled,
              onChanged: (value) async {
                await notifier.updatePreference(isEnabled: value);
              },
            ),
          ),
          
          const Divider(height: 1),
          
          // Selector de modo de visualización
          ListTile(
            leading: Icon(
              Icons.palette_outlined,
              color: preferences.isEnabled ? null : Colors.grey,
            ),
            title: Text(
              'Estilo de visualización',
              style: TextStyle(
                color: preferences.isEnabled ? null : Colors.grey,
              ),
            ),
            subtitle: Text(
              preferences.displayModeName,
              style: TextStyle(
                color: preferences.isEnabled ? null : Colors.grey,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: preferences.isEnabled
                ? () {
                    _showDisplayModeDialog(context, ref, preferences, notifier);
                  }
                : null,
          ),
          
          const Divider(height: 1),
          
          // Mostrar cuando está online
          ListTile(
            leading: Icon(
              Icons.wifi,
              color: preferences.isEnabled ? null : Colors.grey,
            ),
            title: Text(
              'Mostrar cuando hay conexión',
              style: TextStyle(
                color: preferences.isEnabled ? null : Colors.grey,
              ),
            ),
            subtitle: Text(
              'Mostrar indicador incluso con buena conexión',
              style: TextStyle(
                color: preferences.isEnabled ? null : Colors.grey,
              ),
            ),
            trailing: CupertinoSwitch(
              value: preferences.showWhenOnline,
              onChanged: preferences.isEnabled
                  ? (value) async {
                      await notifier.updatePreference(showWhenOnline: value);
                    }
                  : null,
            ),
          ),
          
          const Divider(height: 1),
          
          // Notificaciones
          ListTile(
            leading: Icon(
              Icons.notifications_outlined,
              color: preferences.isEnabled ? null : Colors.grey,
            ),
            title: Text(
              'Notificaciones de conexión',
              style: TextStyle(
                color: preferences.isEnabled ? null : Colors.grey,
              ),
            ),
            subtitle: Text(
              'Alertas cuando cambia el estado',
              style: TextStyle(
                color: preferences.isEnabled ? null : Colors.grey,
              ),
            ),
            trailing: CupertinoSwitch(
              value: preferences.showNotifications,
              onChanged: preferences.isEnabled
                  ? (value) async {
                      await notifier.updatePreference(showNotifications: value);
                    }
                  : null,
            ),
          ),
          
          const Divider(height: 1),
          
          // Vibración
          ListTile(
            leading: Icon(
              Icons.vibration,
              color: preferences.isEnabled ? null : Colors.grey,
            ),
            title: Text(
              'Vibrar al desconectar',
              style: TextStyle(
                color: preferences.isEnabled ? null : Colors.grey,
              ),
            ),
            subtitle: Text(
              'Feedback háptico al perder conexión',
              style: TextStyle(
                color: preferences.isEnabled ? null : Colors.grey,
              ),
            ),
            trailing: CupertinoSwitch(
              value: preferences.vibrateOnDisconnect,
              onChanged: preferences.isEnabled
                  ? (value) async {
                      await notifier.updatePreference(vibrateOnDisconnect: value);
                    }
                  : null,
            ),
          ),
          
          const Divider(height: 1),
          
          // Sonido
          ListTile(
            leading: Icon(
              Icons.volume_up_outlined,
              color: preferences.isEnabled ? null : Colors.grey,
            ),
            title: Text(
              'Sonido de cambio',
              style: TextStyle(
                color: preferences.isEnabled ? null : Colors.grey,
              ),
            ),
            subtitle: Text(
              'Reproducir sonido al cambiar estado',
              style: TextStyle(
                color: preferences.isEnabled ? null : Colors.grey,
              ),
            ),
            trailing: CupertinoSwitch(
              value: preferences.playSoundOnChange,
              onChanged: preferences.isEnabled
                  ? (value) async {
                      await notifier.updatePreference(playSoundOnChange: value);
                    }
                  : null,
            ),
          ),
          
          const Divider(height: 1),
          
          // Botón de resetear
          ListTile(
            leading: Icon(Icons.restore, color: Colors.orange.shade700),
            title: Text(
              'Restablecer valores predeterminados',
              style: TextStyle(color: Colors.orange.shade700),
            ),
            onTap: () async {
              final confirmed = await showCupertinoDialog<bool>(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Restablecer configuración'),
                  content: const Text(
                    '¿Deseas restablecer todas las preferencias del indicador de conectividad a sus valores predeterminados?',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Restablecer'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true) {
                await notifier.resetToDefaults();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuración restablecida'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDisplayModeDialog(
    BuildContext context,
    WidgetRef ref,
    ConnectivityPreferences preferences,
    ConnectivityPreferencesNotifier notifier,
  ) {
    final modes = [
      {'value': 0, 'name': 'Solo icono', 'icon': Icons.circle},
      {'value': 1, 'name': 'Icono con texto', 'icon': Icons.label},
      {'value': 2, 'name': 'Punto de color', 'icon': Icons.fiber_manual_record},
      {'value': 3, 'name': 'Badge', 'icon': Icons.badge},
    ];

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Estilo de visualización'),
        message: const Text('Selecciona cómo quieres ver el indicador de conexión'),
        actions: modes.map((mode) {
          final isSelected = preferences.displayMode == mode['value'];
          return CupertinoActionSheetAction(
            onPressed: () async {
              await notifier.updatePreference(displayMode: mode['value'] as int);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            isDefaultAction: isSelected,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(mode['icon'] as IconData, size: 20),
                const SizedBox(width: 12),
                Text(mode['name'] as String),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: CupertinoColors.activeBlue, size: 20),
                ],
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: false,
          child: const Text('Cancelar'),
        ),
      ),
    );
  }
}
