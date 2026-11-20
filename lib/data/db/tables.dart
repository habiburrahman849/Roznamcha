import 'package:drift/drift.dart';

@DataClassName('Shop')
class Shops extends Table {
  @override
  String get tableName => 'shop';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get ownerName => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get logoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get unit => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
}

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
}

class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer()
      .nullable()
      .references(Customers, #id, onDelete: KeyAction.setNull)();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  RealColumn get subtotal => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  TextColumn get paymentType => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class InvoiceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId =>
      integer().references(Invoices, #id, onDelete: KeyAction.cascade)();
  IntColumn get productId => integer()
      .nullable()
      .references(Products, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  RealColumn get qty => real()();
  RealColumn get price => real()();
  RealColumn get lineTotal => real()();
}

/// A roznamcha line. [invoiceId] links the sale that an invoice creates so
/// deleting either side keeps the books in sync.
@DataClassName('LedgerEntry')
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get paymentType => text()();
  TextColumn get note => text().nullable()();
  IntColumn get invoiceId => integer()
      .nullable()
      .references(Invoices, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime()();
}

/// Single-row display settings. The shop row stays limited to shop identity.
@DataClassName('AppSetting')
class AppSettings extends Table {
  @override
  String get tableName => 'app_settings';

  IntColumn get id => integer()();
  TextColumn get currencySymbol => text().withDefault(const Constant('Rs.'))();
  IntColumn get decimalDigits => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
