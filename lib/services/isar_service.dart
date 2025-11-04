import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/work_report.dart';
import '../models/photo.dart';
import '../models/connectivity_preferences.dart';
import '../models/user.dart';
import '../models/employee.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  Isar? _isar;

  /// Initialize Isar database with all collections
  Future<Isar> initialize() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final dir = await getApplicationDocumentsDirectory();
    
    _isar = await Isar.open(
      [
        WorkReportSchema,
        PhotoSchema,
        ConnectivityPreferencesSchema,
        UserSchema,
        EmployeeSchema,
      ],
      directory: dir.path,
      inspector: true, // Enable Isar Inspector for debugging (disable in production)
    );

    return _isar!;
  }

  /// Get the current Isar instance
  Isar get instance {
    if (_isar == null || !_isar!.isOpen) {
      throw StateError(
        'Isar has not been initialized. Call initialize() first.',
      );
    }
    return _isar!;
  }

  /// Close the database
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// Clear all data from the database (useful for testing)
  Future<void> clearDatabase() async {
    final isar = instance;
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}
