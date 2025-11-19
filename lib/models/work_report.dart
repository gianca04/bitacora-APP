import 'package:isar/isar.dart';

part 'work_report.g.dart';

@collection
class WorkReport {
  Id id = Isar.autoIncrement;

  // Employee and project references
  // Employee and project references (nullable to allow server-only records)
  int? employeeId;
  int? projectId;

  // Basic information
  late String name;
  late String description;

  // Signatures (stored as paths or base64 strings)
  String? supervisorSignature;
  String? managerSignature;

  // Additional details
  String? suggestions;
  String? tools;
  String? personnel;
  String? materials;

  // Date and time fields
  late DateTime startTime;
  late DateTime endTime;
  late DateTime reportDate;

  // Timestamps for record management
  @Index()
  DateTime? createdAt;
  DateTime? updatedAt;

  WorkReport({
    this.id = Isar.autoIncrement,
    this.employeeId,
    this.projectId,
    required this.name,
    required this.description,
    this.supervisorSignature,
    this.managerSignature,
    this.suggestions,
    this.tools,
    this.personnel,
    this.materials,
    required this.startTime,
    required this.endTime,
    required this.reportDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}
