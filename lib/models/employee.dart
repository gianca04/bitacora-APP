import 'package:isar/isar.dart';

part 'employee.g.dart';

/// Document type enumeration
enum DocumentType {
  dni,
  pasaporte,
  carnetExtranjeria,
}

/// Sex/Gender enumeration
enum Sex {
  male,
  female,
  other,
}

@collection
class Employee {
  Id id = Isar.autoIncrement;

  // Document information
  @Enumerated(EnumType.name)
  DocumentType documentType;
  
  @Index()
  late String documentNumber;

  // Personal information
  late String firstName;
  late String lastName;
  String? address;
  
  // Dates
  DateTime? dateContract;
  DateTime? dateBirth;
  
  // Gender
  @Enumerated(EnumType.name)
  Sex? sex;

  // Foreign key reference to position
  @Index()
  int? positionId;

  // Status
  @Index()
  bool active;

  // Timestamps for record management
  @Index()
  DateTime? createdAt;
  DateTime? updatedAt;

  Employee({
    this.id = Isar.autoIncrement,
    this.documentType = DocumentType.dni,
    required this.documentNumber,
    required this.firstName,
    required this.lastName,
    this.address,
    this.dateContract,
    this.dateBirth,
    this.sex,
    this.positionId,
    this.active = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Check if employee has a contract date
  bool get hasContract => dateContract != null;

  /// Calculate age if date of birth is provided
  int? get age {
    if (dateBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateBirth!.year;
    if (now.month < dateBirth!.month ||
        (now.month == dateBirth!.month && now.day < dateBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Copy with method for immutability
  Employee copyWith({
    Id? id,
    DocumentType? documentType,
    String? documentNumber,
    String? firstName,
    String? lastName,
    String? address,
    DateTime? dateContract,
    DateTime? dateBirth,
    Sex? sex,
    int? positionId,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      dateContract: dateContract ?? this.dateContract,
      dateBirth: dateBirth ?? this.dateBirth,
      sex: sex ?? this.sex,
      positionId: positionId ?? this.positionId,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
