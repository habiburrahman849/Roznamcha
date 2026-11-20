import 'package:drift/drift.dart';
import 'package:roznamcha/core/constants/app_strings.dart';
import 'package:roznamcha/core/errors/app_exception.dart';
import 'package:roznamcha/core/utils/text_utils.dart';
import 'package:roznamcha/data/db/app_database.dart';

class CustomerRepository {
  CustomerRepository(this._db);

  final AppDatabase _db;

  Stream<List<Customer>> watchAll() {
    return (_db.select(_db.customers)
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .watch();
  }

  Future<int> create({required String name, String? phone}) {
    return _db.into(_db.customers).insert(
          CustomersCompanion.insert(
            name: _requireName(name),
            phone: Value(blankToNull(phone)),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> update({required int id, required String name, String? phone}) {
    return (_db.update(_db.customers)..where((row) => row.id.equals(id)))
        .write(
      CustomersCompanion(
        name: Value(_requireName(name)),
        phone: Value(blankToNull(phone)),
      ),
    );
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.customers)..where((row) => row.id.equals(id))).go();
  }

  String _requireName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const AppException(AppStrings.customerNameRequired);
    }
    return trimmed;
  }
}
