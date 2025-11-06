import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/connectivity_provider.dart';
import '../providers/connectivity_preferences_provider.dart';
import '../services/connectivity_service.dart';
import 'connectivity_indicator.dart';

/// Widget que muestra el logo inicialmente y transiciona al indicador de conectividad
/// después de 2 segundos o cuando el estado de conexión cambia
/// 
/// Lógica:
/// - Muestra logo por 2 segundos o hasta que cambie el estado
/// - Después muestra el indicador si hay problema de conexión
/// - Si está online y showWhenOnline=false, vuelve a mostrar el logo
class LogoToConnectivityTransition extends ConsumerStatefulWidget {
  const LogoToConnectivityTransition({super.key});

  @override
  ConsumerState<LogoToConnectivityTransition> createState() =>
      _LogoToConnectivityTransitionState();
}

class _LogoToConnectivityTransitionState
    extends ConsumerState<LogoToConnectivityTransition> {
  bool _hasTransitioned = false;
  ConnectionStatus? _lastStatus;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Marcar transición después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_hasTransitioned) {
        setState(() {
          _hasTransitioned = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatusAsync = ref.watch(connectionStatusProvider);
    final preferences = ref.watch(connectivityPreferencesNotifierProvider);

    // Si las preferencias están deshabilitadas, siempre mostrar logo
    if (!preferences.isEnabled) {
      return _buildLogo();
    }

    return connectionStatusAsync.when(
      data: (status) {
        // Escuchar cambios de estado para activar transición inmediatamente
        if (_hasInitialized && _lastStatus != status && !_hasTransitioned) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasTransitioned = true;
              });
            }
          });
        }
        
        if (!_hasInitialized) {
          _lastStatus = status;
          _hasInitialized = true;
        } else {
          _lastStatus = status;
        }

        // Determinar qué mostrar
        final shouldShowIndicator = _hasTransitioned &&
            (status != ConnectionStatus.online || preferences.showWhenOnline);

        // Ajustar ancho del contenedor según el modo seleccionado del indicador.
        // Si el usuario eligió 'badge' o 'iconWithText', necesitamos más ancho
        // para que el texto sea legible en el navbar.
        final int mode = preferences.displayMode;
        double containerWidth;
        switch (mode) {
          case 3: // badge
            containerWidth = 100;
            break;
          case 1: // iconWithText
            containerWidth = 100;
            break;
          case 2: // dotOnly
          case 0: // iconOnly
          default:
            containerWidth = 40;
        }

        return SizedBox(
          width: containerWidth,
          height: 28,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: shouldShowIndicator
                ? SizedBox(
                    key: ValueKey('indicator-$status'),
                    // Allow the inner indicator to size itself up to the container
                    // width. Keep height small to fit the navbar.
                    width: containerWidth,
                    child: ConnectivityIndicator(
                      showWhenOnline: preferences.showWhenOnline,
                    ),
                  )
                : _buildLogo(),
          ),
        );
      },
      loading: () => _buildLogo(),
      error: (_, __) => _buildLogo(),
    );
  }

  Widget _buildLogo() {
    return Center(
      key: const ValueKey('logo'),
      child: SvgPicture.asset(
        'assets/images/svg/logo.svg',
        height: 20,
        fit: BoxFit.contain,
      ),
    );
  }
}
