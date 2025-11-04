import 'package:isar/isar.dart';

part 'photo.g.dart';

@collection
class Photo {
  Id id = Isar.autoIncrement;

  // Reference to the work report
  @Index()
  late int workReportId;

  // Photo paths - at least one must be provided
  // Note: Both fields are optional to support flexible workflows
  String? beforeWorkPhotoPath;
  String? photoPath; // Photo after work

  // Optional descriptions
  String? beforeWorkDescripcion;
  String? descripcion;

  // Timestamps for record management
  @Index()
  DateTime? createdAt;
  DateTime? updatedAt;

  Photo({
    this.id = Isar.autoIncrement,
    required this.workReportId,
    this.beforeWorkPhotoPath,
    this.photoPath,
    this.beforeWorkDescripcion,
    this.descripcion,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Validates that at least one photo path is provided
  bool get hasValidPhotos => 
      (beforeWorkPhotoPath != null && beforeWorkPhotoPath!.isNotEmpty) ||
      (photoPath != null && photoPath!.isNotEmpty);
}
