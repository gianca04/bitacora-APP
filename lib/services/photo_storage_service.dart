import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

/// Service for managing photo persistence
/// Responsibilities:
/// - Save photos to app directory
/// - Load photos from storage
/// - Delete photos
/// - Compress and optimize images
class PhotoStorageService {
  static const String _photoDirectory = 'work_report_photos';
  
  /// Save photo to permanent storage
  /// Returns the permanent file path
  Future<String> savePhoto(String tempPhotoPath) async {
    try {
      final File tempFile = File(tempPhotoPath);
      if (!await tempFile.exists()) {
        throw Exception('Photo file does not exist: $tempPhotoPath');
      }

      // Get app documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory photoDir = Directory(path.join(appDocDir.path, _photoDirectory));
      
      // Create directory if it doesn't exist
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }

      // Generate unique filename with timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(tempPhotoPath);
      final String fileName = 'photo_$timestamp$extension';
      final String permanentPath = path.join(photoDir.path, fileName);

      // Read and compress image
      final bytes = await tempFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image != null) {
        // Resize if too large (max 1920px width)
        img.Image resized = image;
        if (image.width > 1920) {
          resized = img.copyResize(image, width: 1920);
        }
        
        // Compress and save
        final compressed = img.encodeJpg(resized, quality: 85);
        final File permanentFile = File(permanentPath);
        await permanentFile.writeAsBytes(compressed);
        
        return permanentPath;
      } else {
        // If decoding fails, just copy the file
        await tempFile.copy(permanentPath);
        return permanentPath;
      }
    } catch (e) {
      throw Exception('Error saving photo: $e');
    }
  }

  /// Delete photo from storage
  Future<void> deletePhoto(String photoPath) async {
    try {
      final File file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Log error but don't throw - deletion failure shouldn't block other operations
      debugPrint('Error deleting photo: $e');
    }
  }

  /// Check if photo exists
  Future<bool> photoExists(String photoPath) async {
    try {
      final File file = File(photoPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get photo file
  File? getPhotoFile(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) {
      return null;
    }
    return File(photoPath);
  }

  /// Delete all photos in a list
  Future<void> deletePhotos(List<String> photoPaths) async {
    for (final photoPath in photoPaths) {
      await deletePhoto(photoPath);
    }
  }

  /// Clean up orphaned photos (photos not referenced in database)
  /// This should be called periodically or during app maintenance
  Future<void> cleanupOrphanedPhotos(List<String> referencedPhotoPaths) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory photoDir = Directory(path.join(appDocDir.path, _photoDirectory));
      
      if (!await photoDir.exists()) {
        return;
      }

      // Get all photo files
      final List<FileSystemEntity> files = photoDir.listSync();
      
      // Delete files not in referenced list
      for (final file in files) {
        if (file is File) {
          final filePath = file.path;
          if (!referencedPhotoPaths.contains(filePath)) {
            await file.delete();
            debugPrint('Deleted orphaned photo: $filePath');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up orphaned photos: $e');
    }
  }

  /// Get total size of all stored photos
  Future<int> getTotalPhotoSize() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory photoDir = Directory(path.join(appDocDir.path, _photoDirectory));
      
      if (!await photoDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      final List<FileSystemEntity> files = photoDir.listSync();
      
      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Format bytes to human readable string
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
