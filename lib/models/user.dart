
import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  // Foreign key reference to employee
  @Index()
  int? employeeId;

  // User credentials and information
  String? name;
  
  @Index()
  String? email;
  
  DateTime? emailVerifiedAt;
  
  // User status
  @Index()
  bool isActive;
  
  String? rememberToken;

  // Timestamps for record management
  @Index()
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id = Isar.autoIncrement,
    this.employeeId,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.isActive = true,
    this.rememberToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Check if user email is verified
  bool get isEmailVerified => emailVerifiedAt != null;

  /// Copy with method for immutability
  User copyWith({
    Id? id,
    int? employeeId,
    String? name,
    String? email,
    DateTime? emailVerifiedAt,
    bool? isActive,
    String? rememberToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      isActive: isActive ?? this.isActive,
      rememberToken: rememberToken ?? this.rememberToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
