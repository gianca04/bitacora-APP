import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/isar_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/menu_repository.dart';
import '../repositories/work_report_repository.dart';
import '../repositories/photo_repository.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/menu_viewmodel.dart';
import '../viewmodels/work_report_viewmodel.dart';
import '../viewmodels/photo_viewmodel.dart';
import '../controllers/auth_controller.dart';
import '../controllers/menu_controller.dart';
import '../controllers/work_report_controller.dart';
import '../controllers/photo_controller.dart';

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

/// Provider for the Isar database service singleton
/// This is the foundation for all database operations
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
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

// ============================================================================
// VIEWMODEL PROVIDERS (StateNotifierProviders)
// ViewModels manage UI state and coordinate with repositories
// ============================================================================

/// Provider for authentication view model
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository: repo);
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
  return PhotoViewModel(repository: repo);
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
