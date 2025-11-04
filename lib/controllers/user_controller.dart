import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/user.dart';
import '../viewmodels/user_viewmodel.dart';
import '../providers/app_providers.dart';

/// Controller for User operations
/// Acts as a facade between UI and UserViewModel
/// Note: In Riverpod best practices, controllers are optional.
/// You can work directly with ViewModels from the UI.
class UserController {
  final Ref ref;

  UserController(this.ref);

  /// Load all users
  Future<UserState> loadAll() async {
    await ref.read(userViewModelProvider.notifier).loadAll();
    return ref.read(userViewModelProvider);
  }

  /// Load active users only
  Future<UserState> loadActiveUsers() async {
    await ref.read(userViewModelProvider.notifier).loadActiveUsers();
    return ref.read(userViewModelProvider);
  }

  /// Load inactive users only
  Future<UserState> loadInactiveUsers() async {
    await ref.read(userViewModelProvider.notifier).loadInactiveUsers();
    return ref.read(userViewModelProvider);
  }

  /// Load verified users
  Future<UserState> loadVerifiedUsers() async {
    await ref.read(userViewModelProvider.notifier).loadVerifiedUsers();
    return ref.read(userViewModelProvider);
  }

  /// Load user by ID
  Future<UserState> loadById(Id id) async {
    await ref.read(userViewModelProvider.notifier).loadById(id);
    return ref.read(userViewModelProvider);
  }

  /// Load user by email
  Future<UserState> loadByEmail(String email) async {
    await ref.read(userViewModelProvider.notifier).loadByEmail(email);
    return ref.read(userViewModelProvider);
  }

  /// Load user by employee ID
  Future<UserState> loadByEmployeeId(int employeeId) async {
    await ref.read(userViewModelProvider.notifier).loadByEmployeeId(employeeId);
    return ref.read(userViewModelProvider);
  }

  /// Create a new user
  Future<Id?> createUser(User user) async {
    return await ref.read(userViewModelProvider.notifier).createUser(user);
  }

  /// Update an existing user
  Future<bool> updateUser(User user) async {
    return await ref.read(userViewModelProvider.notifier).updateUser(user);
  }

  /// Delete a user
  Future<bool> deleteUser(Id id) async {
    return await ref.read(userViewModelProvider.notifier).deleteUser(id);
  }

  /// Activate a user
  Future<void> activateUser(Id id) async {
    await ref.read(userViewModelProvider.notifier).activateUser(id);
  }

  /// Deactivate a user
  Future<void> deactivateUser(Id id) async {
    await ref.read(userViewModelProvider.notifier).deactivateUser(id);
  }

  /// Verify user email
  Future<void> verifyEmail(Id id) async {
    await ref.read(userViewModelProvider.notifier).verifyEmail(id);
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    return await ref.read(userViewModelProvider.notifier).emailExists(email);
  }

  /// Set current authenticated user
  void setCurrentUser(User user) {
    ref.read(userViewModelProvider.notifier).setCurrentUser(user);
  }

  /// Logout current user
  void logout() {
    ref.read(userViewModelProvider.notifier).logout();
  }

  /// Clear error message
  void clearError() {
    ref.read(userViewModelProvider.notifier).clearError();
  }

  /// Get current state
  UserState get state => ref.read(userViewModelProvider);
}
