import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/photo.dart';
import '../viewmodels/photo_viewmodel.dart';
import '../providers/app_providers.dart';

/// Controller for Photo operations
/// Acts as a facade between UI and PhotoViewModel
/// Note: In Riverpod best practices, controllers are optional.
/// You can work directly with ViewModels from the UI.
class PhotoController {
  final Ref ref;

  PhotoController(this.ref);

  /// Load all photos
  Future<PhotoState> loadAll() async {
    await ref.read(photoViewModelProvider.notifier).loadAll();
    return ref.read(photoViewModelProvider);
  }

  /// Load photos for a specific work report
  Future<PhotoState> loadByWorkReportId(int workReportId) async {
    await ref
        .read(photoViewModelProvider.notifier)
        .loadByWorkReportId(workReportId);
    return ref.read(photoViewModelProvider);
  }

  /// Load photos with before-work images
  Future<PhotoState> loadWithBeforeWorkPhotos() async {
    await ref
        .read(photoViewModelProvider.notifier)
        .loadWithBeforeWorkPhotos();
    return ref.read(photoViewModelProvider);
  }

  /// Create a new photo
  Future<Id?> createPhoto(Photo photo) async {
    return await ref.read(photoViewModelProvider.notifier).createPhoto(photo);
  }

  /// Update an existing photo
  Future<bool> updatePhoto(Photo photo) async {
    return await ref.read(photoViewModelProvider.notifier).updatePhoto(photo);
  }

  /// Delete a photo
  Future<bool> deletePhoto(Id id) async {
    return await ref.read(photoViewModelProvider.notifier).deletePhoto(id);
  }

  /// Delete all photos for a work report
  Future<int> deleteByWorkReportId(int workReportId) async {
    return await ref
        .read(photoViewModelProvider.notifier)
        .deleteByWorkReportId(workReportId);
  }

  /// Select a specific photo for viewing/editing
  void selectPhoto(Photo photo) {
    ref.read(photoViewModelProvider.notifier).selectPhoto(photo);
  }

  /// Clear the selected photo
  void clearSelection() {
    ref.read(photoViewModelProvider.notifier).clearSelection();
  }

  /// Reset to initial state
  void reset() {
    ref.read(photoViewModelProvider.notifier).reset();
  }
}
