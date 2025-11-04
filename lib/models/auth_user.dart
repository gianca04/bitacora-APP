/// User information from authentication response
/// Note: This is different from the local User model
class AuthUser {
  final int id;
  final String name;
  final String email;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
  });

  /// Create AuthUser from JSON
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  /// Convert AuthUser to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'AuthUser(id: $id, name: $name, email: $email)';
  }
}
