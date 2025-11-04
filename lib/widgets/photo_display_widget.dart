import 'dart:io';
import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar una foto desde el almacenamiento local
/// Responsabilidad: Mostrar una imagen con manejo de errores y estados de carga
class PhotoDisplayWidget extends StatelessWidget {
  final String photoPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? errorMessage;

  const PhotoDisplayWidget({
    super.key,
    required this.photoPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPath.isEmpty) {
      return _buildErrorWidget('No photo path provided');
    }

    final file = File(photoPath);

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
          return _buildErrorWidget(
            errorMessage ?? 'Photo not found',
          );
        }

        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget('Error loading image');
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
