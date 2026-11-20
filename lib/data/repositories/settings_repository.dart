import 'package:drift/drift.dart';
import 'package:roznamcha/core/constants/app_config.dart';
import 'package:roznamcha/core/utils/text_utils.dart';
import 'package:roznamcha/data/db/app_database.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Stream<AppSetting> watch() {
    return (_db.select(_db.appSettings)
          ..where((row) => row.id.equals(AppConfig.settingsRowId)))
        .watchSingle();
  }

  Future<AppSetting> current() {
    return (_db.select(_db.appSettings)
          ..where((row) => row.id.equals(AppConfig.settingsRowId)))
        .getSingle();
  }

  Future<void> update({
    required String currencySymbol,
    required int decimalDigits,
  }) {
    final symbol = blankToNull(currencySymbol) ?? 'Rs.';
    final digits = decimalDigits <= 0 ? 0 : 2;
    return (_db.update(_db.appSettings)
          ..where((row) => row.id.equals(AppConfig.settingsRowId)))
        .write(
      AppSettingsCompanion(
        currencySymbol: Value(symbol),
        decimalDigits: Value(digits),
      ),
    );
  }
}
