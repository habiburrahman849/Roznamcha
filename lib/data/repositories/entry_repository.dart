import 'package:drift/drift.dart';
import 'package:roznamcha/core/constants/app_strings.dart';
import 'package:roznamcha/core/errors/app_exception.dart';
import 'package:roznamcha/core/utils/currency.dart';
import 'package:roznamcha/core/utils/text_utils.dart';
import 'package:roznamcha/data/db/app_database.dart';
import 'package:roznamcha/data/models/enums.dart';
import 'package:roznamcha/data/models/period_stats.dart';
import 'package:roznamcha/data/models/sales_trend.dart';
import 'package:roznamcha/data/repositories/invoice_repository.dart';

class EntryRepository {
  EntryRepository(this._db, this._invoices);

  final AppDatabase _db;
  final InvoiceRepository _invoices;

  Stream<List<LedgerEntry>> watchRange({
    DateTime? start,
    DateTime? endExclusive,
  }) {
    final query = _db.select(_db.entries)
      ..orderBy([
        (row) => OrderingTerm.desc(row.createdAt),
        (row) => OrderingTerm.desc(row.id),
      ]);
    if (start != null) {
      query.where((row) => row.createdAt.isBiggerOrEqualValue(start));
    }
    if (endExclusive != null) {
      query.where((row) => row.createdAt.isSmallerThanValue(endExclusive));
    }
    return query.watch();
  }

  Stream<PeriodStats> watchStats({
    required DateTime start,
    required DateTime endExclusive,
  }) {
    return watchRange(start: start, endExclusive: endExclusive).map(
      (rows) => PeriodStats.fromLines(rows.map(_line)),
    );
  }

  Stream<List<ChartEntry>> watchChartEntries({
    required DateTime start,
    required DateTime endExclusive,
  }) {
    return watchRange(start: start, endExclusive: endExclusive).map(
      (rows) => [
        for (final row in rows)
          ChartEntry(
            createdAt: row.createdAt,
            type: EntryType.fromStorage(row.type),
            amount: row.amount,
          ),
      ],
    );
  }

  Future<int> add({
    required EntryType type,
    required double amount,
    required PaymentType paymentType,
    String? note,
    DateTime? createdAt,
  }) {
    final parsed = _requireAmount(amount);
    return _db.into(_db.entries).insert(
          EntriesCompanion.insert(
            type: type.storageValue,
            amount: parsed,
            paymentType: paymentType.storageValue,
            note: Value(blankToNull(note)),
            createdAt: createdAt ?? DateTime.now(),
          ),
        );
  }

  /// Deletes a ledger line. A line created by an invoice deletes that invoice
  /// too, including its items and the line itself.
  Future<void> delete(int id) async {
    final entry = await (_db.select(_db.entries)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (entry == null) return;
    final invoiceId = entry.invoiceId;
    if (invoiceId != null) {
      await _invoices.delete(invoiceId);
      return;
    }
    await (_db.delete(_db.entries)..where((row) => row.id.equals(id))).go();
  }

  AmountLine _line(LedgerEntry entry) {
    return AmountLine(
      type: EntryType.fromStorage(entry.type),
      paymentType: PaymentType.fromStorage(entry.paymentType),
      amount: entry.amount,
    );
  }

  double _requireAmount(double amount) {
    if (amount.isNaN || amount.isInfinite || amount <= 0) {
      throw const AppException(AppStrings.amountInvalid);
    }
    return roundMoney(amount);
  }
}
