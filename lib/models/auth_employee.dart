/// Employee information from authentication response
/// Note: This is different from the local Employee model
class AuthEmployee {
  final int id;
  final String documentType;
  final String documentNumber;
  final String firstName;
  final String lastName;
  final String position;

  AuthEmployee({
    required this.id,
    required this.documentType,
    required this.documentNumber,
    required this.firstName,
    required this.lastName,
    required this.position,
  });

  /// Create AuthEmployee from JSON
  factory AuthEmployee.fromJson(Map<String, dynamic> json) {
    return AuthEmployee(
      id: json['id'] as int,
      documentType: json['document_type'] as String,
      documentNumber: json['document_number'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      position: json['position'] as String,
    );
  }

  /// Convert AuthEmployee to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_type': documentType,
      'document_number': documentNumber,
      'first_name': firstName,
      'last_name': lastName,
      'position': position,
    };
  }

  /// Get full name
  String get fullName => '$firstName $lastName';

  @override
  String toString() {
    return 'AuthEmployee(id: $id, fullName: $fullName, position: $position)';
  }
}
