import 'package:drift/drift.dart';
import 'package:roznamcha/core/constants/app_strings.dart';
import 'package:roznamcha/core/errors/app_exception.dart';
import 'package:roznamcha/core/utils/currency.dart';
import 'package:roznamcha/core/utils/text_utils.dart';
import 'package:roznamcha/data/db/app_database.dart';

class ProductRepository {
  ProductRepository(this._db);

  final AppDatabase _db;

  Stream<List<Product>> watchAll() {
    return (_db.select(_db.products)
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .watch();
  }

  Future<bool> hasAny() async {
    final rows = await (_db.select(_db.products)..limit(1)).get();
    return rows.isNotEmpty;
  }

  Future<int> create({
    required String name,
    required double price,
    String? unit,
  }) {
    return _db.into(_db.products).insert(
          ProductsCompanion.insert(
            name: _requireName(name),
            price: _requirePrice(price),
            unit: Value(blankToNull(unit)),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> update({
    required int id,
    required String name,
    required double price,
    String? unit,
  }) {
    return (_db.update(_db.products)..where((row) => row.id.equals(id))).write(
      ProductsCompanion(
        name: Value(_requireName(name)),
        price: Value(_requirePrice(price)),
        unit: Value(blankToNull(unit)),
      ),
    );
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.products)..where((row) => row.id.equals(id))).go();
  }

  String _requireName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const AppException(AppStrings.productNameRequired);
    }
    return trimmed;
  }

  double _requirePrice(double price) {
    if (price.isNaN || price.isInfinite || price < 0) {
      throw const AppException(AppStrings.priceInvalid);
    }
    return roundMoney(price);
  }
}
