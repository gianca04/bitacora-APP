import '../models/user.dart';
import '../repositories/user_repository.dart';
import 'package:isar/isar.dart';

/// Service for User-specific business logic
/// Provides higher-level operations beyond simple CRUD
class UserService {
  final UserRepository _repository;

  UserService(this._repository);

  /// Authenticate user with email and password
  /// Returns user if credentials are valid, null otherwise
  /// Note: In production, use proper password hashing (e.g., bcrypt, argon2)
  Future<User?> authenticate(String email, String password) async {
    final user = await _repository.getByEmail(email);
    
    if (user == null || !user.isActive) {
      return null;
    }
    
    // TODO: Implement proper password verification with hashing
    // For now, direct comparison (NOT SECURE - only for development)
    if (user.password == password) {
      return user;
    }
    
    return null;
  }

  /// Register a new user
  /// Validates email uniqueness and sets default values
  Future<Id?> register({
    required String email,
    required String password,
    String? name,
    int? employeeId,
  }) async {
    // Check if email already exists
    final exists = await _repository.emailExists(email);
    if (exists) {
      return null;
    }

    // TODO: Hash password before storing
    // For production, use a package like crypto or bcrypt
    final user = User(
      email: email,
      password: password, // Should be hashed
      name: name,
      employeeId: employeeId,
      isActive: true,
    );

    return await _repository.create(user);
  }

  /// Update user password
  /// Note: Should hash the new password before storing
  Future<bool> updatePassword(Id userId, String newPassword) async {
    final user = await _repository.getById(userId);
    if (user == null) {
      return false;
    }

    // TODO: Hash password before storing
    final updatedUser = user.copyWith(password: newPassword);
    await _repository.update(updatedUser);
    return true;
  }

  /// Link user to an employee
  Future<bool> linkEmployee(Id userId, int employeeId) async {
    final user = await _repository.getById(userId);
    if (user == null) {
      return false;
    }

    final updatedUser = user.copyWith(employeeId: employeeId);
    await _repository.update(updatedUser);
    return true;
  }

  /// Unlink user from employee
  Future<bool> unlinkEmployee(Id userId) async {
    final user = await _repository.getById(userId);
    if (user == null) {
      return false;
    }

    final updatedUser = user.copyWith(employeeId: null);
    await _repository.update(updatedUser);
    return true;
  }

  /// Send email verification (placeholder)
  /// In production, this would send an actual email
  Future<bool> sendEmailVerification(Id userId) async {
    final user = await _repository.getById(userId);
    if (user == null) {
      return false;
    }

    // TODO: Implement actual email sending logic
    // For now, just mark as verified immediately
    await _repository.verifyEmail(userId);
    return true;
  }

  /// Get user statistics
  Future<UserStats> getUserStats() async {
    final allUsers = await _repository.getAll();
    final activeUsers = await _repository.getActiveUsers();
    final verifiedUsers = await _repository.getVerifiedUsers();

    return UserStats(
      total: allUsers.length,
      active: activeUsers.length,
      inactive: allUsers.length - activeUsers.length,
      verified: verifiedUsers.length,
    );
  }

  /// Bulk activate users
  Future<void> bulkActivate(List<Id> userIds) async {
    for (final id in userIds) {
      await _repository.activate(id);
    }
  }

  /// Bulk deactivate users
  Future<void> bulkDeactivate(List<Id> userIds) async {
    for (final id in userIds) {
      await _repository.deactivate(id);
    }
  }
}

/// User statistics data class
class UserStats {
  final int total;
  final int active;
  final int inactive;
  final int verified;

  UserStats({
    required this.total,
    required this.active,
    required this.inactive,
    required this.verified,
  });

  int get unverified => total - verified;
  double get activePercentage => total > 0 ? (active / total) * 100 : 0;
  double get verifiedPercentage => total > 0 ? (verified / total) * 100 : 0;
}
