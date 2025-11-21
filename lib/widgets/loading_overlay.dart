import 'package:flutter/material.dart';

/// Reusable loading overlay with centered progress indicator and optional message
/// 
/// Displays a centered loading spinner with an optional text message below it.
/// Commonly used to show loading state while fetching data.
/// 
/// Example:
/// ```dart
/// LoadingOverlay(message: 'Cargando fotos...')
/// ```
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? messageColor;
  final Color? progressColor;
  final double spacing;

  const LoadingOverlay({
    super.key,
    this.message,
    this.messageColor,
    this.progressColor,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: progressColor,
          ),
          if (message != null) ...[
            SizedBox(height: spacing),
            Text(
              message!,
              style: TextStyle(
                color: messageColor ?? Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
