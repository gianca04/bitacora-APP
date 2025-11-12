import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/isar_service.dart';
import '../services/photo_storage_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/menu_repository.dart';
import '../repositories/work_report_repository.dart';
import '../repositories/photo_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/employee_repository.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/menu_viewmodel.dart';
import '../viewmodels/work_report_viewmodel.dart';
import '../viewmodels/photo_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/employee_viewmodel.dart';
import '../controllers/auth_controller.dart';
import '../controllers/menu_controller.dart';
import '../controllers/work_report_controller.dart';
import '../controllers/photo_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/employee_controller.dart';

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

/// Provider for the Isar database service singleton
/// This is the foundation for all database operations
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

/// Provider for the photo storage service
/// Handles photo persistence, compression, and cleanup
final photoStorageServiceProvider = Provider<PhotoStorageService>((ref) {
  return PhotoStorageService();
});

// ============================================================================
// REPOSITORY PROVIDERS
// Repositories handle data operations and business logic
// ============================================================================

/// Provider for authentication repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for menu repository
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository();
});

/// Provider for WorkReport repository
/// Depends on isarServiceProvider to access the database
final workReportRepositoryProvider = Provider<WorkReportRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return WorkReportRepository(isarService);
});

/// Provider for Photo repository
/// Depends on isarServiceProvider to access the database
final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return PhotoRepository(isarService);
});

/// Provider for User repository
/// Depends on isarServiceProvider to access the database
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return UserRepository(isarService);
});

/// Provider for Employee repository
/// Depends on isarServiceProvider to access the database
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return EmployeeRepository(isarService);
});

// ============================================================================
// VIEWMODEL PROVIDERS (StateNotifierProviders)
// ViewModels manage UI state and coordinate with repositories
// ============================================================================

/// Provider for authentication view model
/// Manages authentication state throughout the app lifecycle
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository: repo);
});

/// Provider that initializes authentication on app startup
/// This ensures stored authentication is checked before the router is built
final authInitProvider = FutureProvider<bool>((ref) async {
  final authViewModel = ref.watch(authViewModelProvider.notifier);
  final hasAuth = await authViewModel.checkAuthStatus();
  return hasAuth;
});

/// Provider for menu view model
final menuViewModelProvider =
    StateNotifierProvider<MenuViewModel, MenuViewState>((ref) {
  final repo = ref.watch(menuRepositoryProvider);
  return MenuViewModel(repository: repo);
});

/// Provider for WorkReport view model
final workReportViewModelProvider =
    StateNotifierProvider<WorkReportViewModel, WorkReportState>((ref) {
  final repo = ref.watch(workReportRepositoryProvider);
  return WorkReportViewModel(repository: repo);
});

/// Provider for Photo view model
final photoViewModelProvider =
    StateNotifierProvider<PhotoViewModel, PhotoState>((ref) {
  final repo = ref.watch(photoRepositoryProvider);
  final storageService = ref.watch(photoStorageServiceProvider);
  return PhotoViewModel(
    repository: repo,
    storageService: storageService,
  );
});

/// Provider for User view model
final userViewModelProvider =
    StateNotifierProvider<UserViewModel, UserState>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UserViewModel(repository: repo);
});

/// Provider for Employee view model
final employeeViewModelProvider =
    StateNotifierProvider<EmployeeViewModel, EmployeeState>((ref) {
  final repo = ref.watch(employeeRepositoryProvider);
  return EmployeeViewModel(repository: repo);
});

// ============================================================================
// CONTROLLER PROVIDERS (Optional Layer)
// Controllers act as facades between UI and ViewModels
// Note: In Riverpod best practices, you can work directly with ViewModels
// ============================================================================

/// Provider for authentication controller
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

/// Provider for menu controller
final menuControllerProvider = Provider<MenuController>((ref) {
  return MenuController(ref);
});

/// Provider for WorkReport controller
final workReportControllerProvider = Provider<WorkReportController>((ref) {
  return WorkReportController(ref);
});

/// Provider for Photo controller
final photoControllerProvider = Provider<PhotoController>((ref) {
  return PhotoController(ref);
});

/// Provider for User controller
final userControllerProvider = Provider<UserController>((ref) {
  return UserController(ref);
});

/// Provider for Employee controller
final employeeControllerProvider = Provider<EmployeeController>((ref) {
  return EmployeeController(ref);
});
