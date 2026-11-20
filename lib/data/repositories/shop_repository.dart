import 'package:drift/drift.dart';
import 'package:roznamcha/core/constants/app_config.dart';
import 'package:roznamcha/core/constants/app_strings.dart';
import 'package:roznamcha/core/errors/app_exception.dart';
import 'package:roznamcha/core/utils/text_utils.dart';
import 'package:roznamcha/data/db/app_database.dart';

class ShopRepository {
  ShopRepository(this._db);

  final AppDatabase _db;

  Stream<Shop?> watchShop() {
    return (_db.select(_db.shops)
          ..where((row) => row.id.equals(AppConfig.shopRowId)))
        .watchSingleOrNull();
  }

  Future<Shop?> getShop() {
    return (_db.select(_db.shops)
          ..where((row) => row.id.equals(AppConfig.shopRowId)))
        .getSingleOrNull();
  }

  Future<void> createShop({
    required String name,
    String? ownerName,
    String? phone,
    String? logoPath,
  }) async {
    final shopName = _requireName(name);
    await _db.into(_db.shops).insert(
          ShopsCompanion.insert(
            id: AppConfig.shopRowId,
            name: shopName,
            ownerName: Value(blankToNull(ownerName)),
            phone: Value(blankToNull(phone)),
            logoPath: Value(blankToNull(logoPath)),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> updateShop({
    required String name,
    String? ownerName,
    String? phone,
    String? logoPath,
  }) async {
    final shopName = _requireName(name);
    await (_db.update(_db.shops)
          ..where((row) => row.id.equals(AppConfig.shopRowId)))
        .write(
      ShopsCompanion(
        name: Value(shopName),
        ownerName: Value(blankToNull(ownerName)),
        phone: Value(blankToNull(phone)),
        logoPath: Value(blankToNull(logoPath)),
      ),
    );
  }

  String _requireName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const AppException(AppStrings.shopNameRequired);
    }
    return trimmed;
  }
}
