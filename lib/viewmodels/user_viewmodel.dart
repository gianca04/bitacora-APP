import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';

/// Possible states for User operations
enum UserStatus { initial, loading, loaded, error, authenticated }

/// State class holding User data and status
class UserState {
  final UserStatus status;
  final List<User> users;
  final User? selectedUser;
  final User? currentUser;
  final String? errorMessage;

  const UserState._({
    required this.status,
    required this.users,
    this.selectedUser,
    this.currentUser,
    this.errorMessage,
  });

  UserState.initial()
      : this._(status: UserStatus.initial, users: []);

  UserState.loading()
      : this._(status: UserStatus.loading, users: []);

  UserState.loaded(List<User> users)
      : this._(status: UserStatus.loaded, users: users);

  UserState.authenticated(User user)
      : this._(
          status: UserStatus.authenticated,
          users: [],
          currentUser: user,
        );

  UserState.error(String message)
      : this._(
          status: UserStatus.error,
          users: [],
          errorMessage: message,
        );

  // Copy with method for partial updates
  UserState copyWith({
    UserStatus? status,
    List<User>? users,
    User? selectedUser,
    User? currentUser,
    String? errorMessage,
  }) {
    return UserState._(
      status: status ?? this.status,
      users: users ?? this.users,
      selectedUser: selectedUser ?? this.selectedUser,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => currentUser != null;
}

/// ViewModel for User operations
/// Manages User state and coordinates with UserRepository
class UserViewModel extends StateNotifier<UserState> {
  final UserRepository repository;

  UserViewModel({required this.repository}) : super(UserState.initial());

  /// Load all users
  Future<void> loadAll() async {
    state = UserState.loading();
    try {
      final users = await repository.getAll();
      state = UserState.loaded(users);
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  /// Load active users only
  Future<void> loadActiveUsers() async {
    state = UserState.loading();
    try {
      final users = await repository.getActiveUsers();
      state = UserState.loaded(users);
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  /// Load inactive users only
  Future<void> loadInactiveUsers() async {
    state = UserState.loading();
    try {
      final users = await repository.getInactiveUsers();
      state = UserState.loaded(users);
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  /// Load verified users
  Future<void> loadVerifiedUsers() async {
    state = UserState.loading();
    try {
      final users = await repository.getVerifiedUsers();
      state = UserState.loaded(users);
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  /// Get user by ID
  Future<void> loadById(Id id) async {
    state = state.copyWith(status: UserStatus.loading);
    try {
      final user = await repository.getById(id);
      if (user != null) {
        state = state.copyWith(
          status: UserStatus.loaded,
          selectedUser: user,
        );
      } else {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: 'User not found',
        );
      }
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  /// Get user by email
  Future<void> loadByEmail(String email) async {
    state = state.copyWith(status: UserStatus.loading);
    try {
      final user = await repository.getByEmail(email);
      if (user != null) {
        state = state.copyWith(
          status: UserStatus.loaded,
          selectedUser: user,
        );
      } else {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: 'User not found',
        );
      }
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  /// Get user by employee ID
  Future<void> loadByEmployeeId(int employeeId) async {
    state = state.copyWith(status: UserStatus.loading);
    try {
      final user = await repository.getByEmployeeId(employeeId);
      if (user != null) {
        state = state.copyWith(
          status: UserStatus.loaded,
          selectedUser: user,
        );
      } else {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: 'User not found',
        );
      }
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  /// Create a new user
  Future<Id?> createUser(User user) async {
    state = state.copyWith(status: UserStatus.loading);
    try {
      final id = await repository.create(user);
      await loadAll(); // Reload all users
      return id;
    } catch (e) {
      state = UserState.error(e.toString());
      return null;
    }
  }

  /// Update an existing user
  Future<bool> updateUser(User user) async {
    state = state.copyWith(status: UserStatus.loading);
    try {
      await repository.update(user);
      await loadAll(); // Reload all users
      return true;
    } catch (e) {
      state = UserState.error(e.toString());
      return false;
    }
  }

  /// Delete a user
  Future<bool> deleteUser(Id id) async {
    state = state.copyWith(status: UserStatus.loading);
    try {
      final success = await repository.delete(id);
      if (success) {
        await loadAll(); // Reload all users
      }
      return success;
    } catch (e) {
      state = UserState.error(e.toString());
      return false;
    }
  }

  /// Activate a user
  Future<void> activateUser(Id id) async {
    try {
      await repository.activate(id);
      await loadAll(); // Reload all users
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  /// Deactivate a user
  Future<void> deactivateUser(Id id) async {
    try {
      await repository.deactivate(id);
      await loadAll(); // Reload all users
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  /// Verify user email
  Future<void> verifyEmail(Id id) async {
    try {
      await repository.verifyEmail(id);
      await loadAll(); // Reload all users
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      return await repository.emailExists(email);
    } catch (e) {
      state = UserState.error(e.toString());
      return false;
    }
  }

  /// Set current authenticated user
  void setCurrentUser(User user) {
    state = state.copyWith(
      status: UserStatus.authenticated,
      currentUser: user,
    );
  }

  /// Logout current user
  void logout() {
    state = UserState.initial();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(
      status: UserStatus.initial,
      errorMessage: null,
    );
  }
}
