import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/photo.dart';
import '../repositories/photo_repository.dart';
import '../services/photo_storage_service.dart';

/// Possible states for Photo operations
enum PhotoStatus { initial, loading, loaded, error }

/// State class holding Photo data and status
class PhotoState {
  final PhotoStatus status;
  final List<Photo> photos;
  final Photo? selectedPhoto;
  final String? errorMessage;

  const PhotoState._({
    required this.status,
    required this.photos,
    this.selectedPhoto,
    this.errorMessage,
  });

  PhotoState.initial() : this._(status: PhotoStatus.initial, photos: []);

  PhotoState.loading() : this._(status: PhotoStatus.loading, photos: []);

  PhotoState.loaded(List<Photo> photos)
      : this._(status: PhotoStatus.loaded, photos: photos);

  PhotoState.error(String message)
      : this._(status: PhotoStatus.error, photos: [], errorMessage: message);

  PhotoState copyWith({
    PhotoStatus? status,
    List<Photo>? photos,
    Photo? selectedPhoto,
    String? errorMessage,
  }) {
    return PhotoState._(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      selectedPhoto: selectedPhoto ?? this.selectedPhoto,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// ViewModel for Photo operations
/// Manages Photo state and coordinates with PhotoRepository
class PhotoViewModel extends StateNotifier<PhotoState> {
  final PhotoRepository repository;
  final PhotoStorageService storageService;

  PhotoViewModel({
    required this.repository,
    required this.storageService,
  }) : super(PhotoState.initial());

  /// Load all photos
  Future<void> loadAll() async {
    state = PhotoState.loading();
    try {
      final photos = await repository.getAll();
      state = PhotoState.loaded(photos);
    } catch (e) {
      state = PhotoState.error(e.toString());
    }
  }

  /// Load photos for a specific work report
  Future<void> loadByWorkReportId(int workReportId) async {
    state = PhotoState.loading();
    try {
      final photos = await repository.getByWorkReportId(workReportId);
      state = PhotoState.loaded(photos);
    } catch (e) {
      state = PhotoState.error(e.toString());
    }
  }

  /// Load photos with before-work images
  Future<void> loadWithBeforeWorkPhotos() async {
    state = PhotoState.loading();
    try {
      final photos = await repository.getWithBeforeWorkPhotos();
      state = PhotoState.loaded(photos);
    } catch (e) {
      state = PhotoState.error(e.toString());
    }
  }

  /// Create a new photo
  Future<Id?> createPhoto(Photo photo) async {
    try {
      final id = await repository.create(photo);
      await loadAll();
      return id;
    } catch (e) {
      state = PhotoState.error(e.toString());
      return null;
    }
  }

  /// Update an existing photo
  Future<bool> updatePhoto(Photo photo) async {
    try {
      await repository.update(photo);
      await loadAll();
      return true;
    } catch (e) {
      state = PhotoState.error(e.toString());
      return false;
    }
  }

  /// Delete a photo
  Future<bool> deletePhoto(Id id) async {
    try {
      // Get photo before deleting to clean up files
      final photos = state.photos.where((p) => p.id == id).toList();
      
      final success = await repository.delete(id);
      if (success && photos.isNotEmpty) {
        final photo = photos.first;
        // Delete photo files from storage
        if (photo.photoPath.isNotEmpty) {
          await storageService.deletePhoto(photo.photoPath);
        }
        if (photo.beforeWorkPhotoPath != null && photo.beforeWorkPhotoPath!.isNotEmpty) {
          await storageService.deletePhoto(photo.beforeWorkPhotoPath!);
        }
        await loadAll();
      }
      return success;
    } catch (e) {
      state = PhotoState.error(e.toString());
      return false;
    }
  }

  /// Delete all photos for a work report
  Future<int> deleteByWorkReportId(int workReportId) async {
    try {
      // Get photos before deleting to clean up files
      final photos = await repository.getByWorkReportId(workReportId);
      
      final count = await repository.deleteByWorkReportId(workReportId);
      
      // Delete photo files from storage
      for (final photo in photos) {
        if (photo.photoPath.isNotEmpty) {
          await storageService.deletePhoto(photo.photoPath);
        }
        if (photo.beforeWorkPhotoPath != null && photo.beforeWorkPhotoPath!.isNotEmpty) {
          await storageService.deletePhoto(photo.beforeWorkPhotoPath!);
        }
      }
      
      await loadAll();
      return count;
    } catch (e) {
      state = PhotoState.error(e.toString());
      return 0;
    }
  }

  /// Select a specific photo
  void selectPhoto(Photo photo) {
    state = state.copyWith(selectedPhoto: photo);
  }

  /// Clear the selected photo
  void clearSelection() {
    state = state.copyWith(selectedPhoto: null);
  }

  /// Reset to initial state
  void reset() {
    state = PhotoState.initial();
  }
}
