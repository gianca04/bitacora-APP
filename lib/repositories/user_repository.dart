import 'package:isar/isar.dart';
import '../models/user.dart';
import '../services/isar_service.dart';

/// Repository for User CRUD operations following Flutter best practices
class UserRepository {
  final IsarService _isarService;

  UserRepository(this._isarService);

  /// Get all users
  Future<List<User>> getAll() async {
    final isar = _isarService.instance;
    return await isar.users.where().findAll();
  }

  /// Get user by ID
  Future<User?> getById(Id id) async {
    final isar = _isarService.instance;
    return await isar.users.get(id);
  }

  /// Get user by email
  Future<User?> getByEmail(String email) async {
    final isar = _isarService.instance;
    return await isar.users
        .filter()
        .emailEqualTo(email)
        .findFirst();
  }

  /// Get all active users
  Future<List<User>> getActiveUsers() async {
    final isar = _isarService.instance;
    return await isar.users
        .filter()
        .isActiveEqualTo(true)
        .findAll();
  }

  /// Get all inactive users
  Future<List<User>> getInactiveUsers() async {
    final isar = _isarService.instance;
    return await isar.users
        .filter()
        .isActiveEqualTo(false)
        .findAll();
  }

  /// Get user by employee ID
  Future<User?> getByEmployeeId(int employeeId) async {
    final isar = _isarService.instance;
    return await isar.users
        .filter()
        .employeeIdEqualTo(employeeId)
        .findFirst();
  }

  /// Get all users with verified email
  Future<List<User>> getVerifiedUsers() async {
    final isar = _isarService.instance;
    return await isar.users
        .filter()
        .emailVerifiedAtIsNotNull()
        .findAll();
  }

  /// Create a new user
  Future<Id> create(User user) async {
    final isar = _isarService.instance;
    return await isar.writeTxn(() async {
      return await isar.users.put(user);
    });
  }

  /// Update an existing user
  Future<void> update(User user) async {
    final isar = _isarService.instance;
    user.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
  }

  /// Delete a user
  Future<bool> delete(Id id) async {
    final isar = _isarService.instance;
    return await isar.writeTxn(() async {
      return await isar.users.delete(id);
    });
  }

  /// Activate a user
  Future<void> activate(Id id) async {
    final user = await getById(id);
    if (user != null) {
      final updatedUser = user.copyWith(isActive: true);
      await update(updatedUser);
    }
  }

  /// Deactivate a user
  Future<void> deactivate(Id id) async {
    final user = await getById(id);
    if (user != null) {
      final updatedUser = user.copyWith(isActive: false);
      await update(updatedUser);
    }
  }

  /// Verify user email
  Future<void> verifyEmail(Id id) async {
    final user = await getById(id);
    if (user != null) {
      final updatedUser = user.copyWith(emailVerifiedAt: DateTime.now());
      await update(updatedUser);
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    final user = await getByEmail(email);
    return user != null;
  }

  /// Watch all users (reactive)
  Stream<List<User>> watchAll() {
    final isar = _isarService.instance;
    return isar.users.where().watch(fireImmediately: true);
  }

  /// Watch a specific user (reactive)
  Stream<User?> watchUser(Id id) {
    final isar = _isarService.instance;
    return isar.users.watchObject(id, fireImmediately: true);
  }

  /// Watch active users (reactive)
  Stream<List<User>> watchActiveUsers() {
    final isar = _isarService.instance;
    return isar.users
        .filter()
        .isActiveEqualTo(true)
        .watch(fireImmediately: true);
  }
}
