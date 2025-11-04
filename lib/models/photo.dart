import 'package:isar/isar.dart';

part 'photo.g.dart';

@collection
class Photo {
  Id id = Isar.autoIncrement;

  // Reference to the work report
  @Index()
  late int workReportId;

  // Photo after work
  late String photoPath;
  String? descripcion;

  // Photo before work (optional)
  String? beforeWorkPhotoPath;
  String? beforeWorkDescripcion;

  // Timestamps for record management
  @Index()
  DateTime? createdAt;
  DateTime? updatedAt;

  Photo({
    this.id = Isar.autoIncrement,
    required this.workReportId,
    required this.photoPath,
    this.descripcion,
    this.beforeWorkPhotoPath,
    this.beforeWorkDescripcion,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
