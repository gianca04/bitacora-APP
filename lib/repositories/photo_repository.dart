import 'package:isar/isar.dart';
import '../models/photo.dart';
import '../services/isar_service.dart';

/// Repository for Photo CRUD operations following Flutter best practices
class PhotoRepository {
  final IsarService _isarService;

  PhotoRepository(this._isarService);

  /// Get all photos
  Future<List<Photo>> getAll() async {
    final isar = _isarService.instance;
    return await isar.photos.where().findAll();
  }

  /// Get photo by ID
  Future<Photo?> getById(Id id) async {
    final isar = _isarService.instance;
    return await isar.photos.get(id);
  }

  /// Get all photos for a specific work report
  Future<List<Photo>> getByWorkReportId(int workReportId) async {
    final isar = _isarService.instance;
    return await isar.photos
        .filter()
        .workReportIdEqualTo(workReportId)
        .findAll();
  }

  /// Get photos with before-work images only
  Future<List<Photo>> getWithBeforeWorkPhotos() async {
    final isar = _isarService.instance;
    return await isar.photos
        .filter()
        .beforeWorkPhotoPathIsNotNull()
        .findAll();
  }

  /// Create a new photo
  Future<Id> create(Photo photo) async {
    final isar = _isarService.instance;
    return await isar.writeTxn(() async {
      return await isar.photos.put(photo);
    });
  }

  /// Update an existing photo
  Future<void> update(Photo photo) async {
    final isar = _isarService.instance;
    photo.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.photos.put(photo);
    });
  }

  /// Delete a photo
  Future<bool> delete(Id id) async {
    final isar = _isarService.instance;
    return await isar.writeTxn(() async {
      return await isar.photos.delete(id);
    });
  }

  /// Delete all photos for a specific work report
  Future<int> deleteByWorkReportId(int workReportId) async {
    final isar = _isarService.instance;
    return await isar.writeTxn(() async {
      final photos = await isar.photos
          .filter()
          .workReportIdEqualTo(workReportId)
          .findAll();
      final ids = photos.map((p) => p.id).toList();
      return await isar.photos.deleteAll(ids);
    });
  }

  /// Watch all photos (reactive)
  Stream<List<Photo>> watchAll() {
    final isar = _isarService.instance;
    return isar.photos.where().watch(fireImmediately: true);
  }

  /// Watch photos for a specific work report (reactive)
  Stream<List<Photo>> watchByWorkReportId(int workReportId) {
    final isar = _isarService.instance;
    return isar.photos
        .filter()
        .workReportIdEqualTo(workReportId)
        .watch(fireImmediately: true);
  }
}
