import 'package:drift/drift.dart';
import 'package:roznamcha/core/constants/app_strings.dart';
import 'package:roznamcha/core/errors/app_exception.dart';
import 'package:roznamcha/core/utils/currency.dart';
import 'package:roznamcha/core/utils/text_utils.dart';
import 'package:roznamcha/data/db/app_database.dart';
import 'package:roznamcha/data/models/enums.dart';
import 'package:roznamcha/data/models/invoice_detail.dart';
import 'package:roznamcha/data/models/invoice_draft.dart';
import 'package:roznamcha/data/models/top_product.dart';
import 'package:roznamcha/data/repositories/customer_repository.dart';

class InvoiceRepository {
  InvoiceRepository(this._db, this._customers);

  final AppDatabase _db;
  final CustomerRepository _customers;

  Stream<List<Invoice>> watchRecent({int limit = 5}) {
    return (_db.select(_db.invoices)
          ..orderBy([
            (row) => OrderingTerm.desc(row.createdAt),
            (row) => OrderingTerm.desc(row.id),
          ])
          ..limit(limit))
        .watch();
  }

  Stream<InvoiceDetail?> watchDetail(int id) {
    final invoiceStream = (_db.select(_db.invoices)
          ..where((row) => row.id.equals(id)))
        .watchSingleOrNull();
    return invoiceStream.asyncExpand((invoice) {
      if (invoice == null) return Stream<InvoiceDetail?>.value(null);
      final itemsStream = (_db.select(_db.invoiceItems)
            ..where((row) => row.invoiceId.equals(id))
            ..orderBy([(row) => OrderingTerm.asc(row.id)]))
          .watch();
      return itemsStream.map(
        (items) => InvoiceDetail(invoice: invoice, items: items),
      );
    });
  }

  Stream<List<TopProduct>> watchTopProducts({
    required DateTime start,
    required DateTime endExclusive,
    int? limit,
  }) {
    final sql = StringBuffer('''
SELECT ii.name AS name,
       SUM(ii.qty) AS qty,
       SUM(ii.line_total) AS revenue
FROM invoice_items ii
INNER JOIN invoices i ON i.id = ii.invoice_id
WHERE i.created_at >= ? AND i.created_at < ?
GROUP BY ii.name
ORDER BY qty DESC
''');
    final variables = <Variable<Object>>[
      Variable.withDateTime(start),
      Variable.withDateTime(endExclusive),
    ];
    if (limit != null) {
      sql.write('LIMIT ?');
      variables.add(Variable.withInt(limit));
    }
    final query = _db.customSelect(
      sql.toString(),
      variables: variables,
      readsFrom: {_db.invoiceItems, _db.invoices},
    );
    return query.watch().map((rows) {
      return [
        for (final row in rows)
          TopProduct(
            name: row.read<String>('name'),
            qty: row.read<double>('qty'),
            revenue: row.read<double>('revenue'),
          ),
      ];
    });
  }

  /// Saves a paid invoice, its lines, and one matching SALE entry.
  Future<int> create(InvoiceDraft draft) async {
    final name = draft.customerName.trim();
    if (name.isEmpty) {
      throw const AppException(AppStrings.customerNameRequired);
    }
    if (draft.lines.isEmpty) {
      throw const AppException(AppStrings.invoiceNeedsItems);
    }
    if (draft.discount < 0) {
      throw const AppException(AppStrings.discountInvalid);
    }
    if (!draft.discountValid) {
      throw const AppException(AppStrings.discountTooHigh);
    }
    for (final line in draft.lines) {
      if (line.name.trim().isEmpty) {
        throw const AppException(AppStrings.itemNameRequired);
      }
      if (line.qty <= 0) {
        throw const AppException(AppStrings.qtyInvalid);
      }
      if (line.price < 0) {
        throw const AppException(AppStrings.priceInvalid);
      }
    }

    return _db.transaction(() async {
      var customerId = draft.customerId;
      if (draft.saveCustomer && customerId == null) {
        customerId = await _customers.create(
          name: name,
          phone: draft.customerPhone,
        );
      }
      final now = DateTime.now();
      final invoiceId = await _db.into(_db.invoices).insert(
            InvoicesCompanion.insert(
              customerId: Value(customerId),
              customerName: Value(name),
              customerPhone: Value(blankToNull(draft.customerPhone)),
              subtotal: draft.subtotal,
              discount: Value(roundMoney(draft.discount)),
              total: draft.total,
              paymentType: draft.paymentType.storageValue,
              status: 'PAID',
              createdAt: now,
            ),
          );
      for (final line in draft.lines) {
        await _db.into(_db.invoiceItems).insert(
              InvoiceItemsCompanion.insert(
                invoiceId: invoiceId,
                productId: Value(line.productId),
                name: line.name.trim(),
                qty: line.qty,
                price: roundMoney(line.price),
                lineTotal: line.lineTotal,
              ),
            );
      }
      await _db.into(_db.entries).insert(
            EntriesCompanion.insert(
              type: EntryType.sale.storageValue,
              amount: draft.total,
              paymentType: draft.paymentType.storageValue,
              note: Value('${AppStrings.invoiceNotePrefix}$invoiceId'),
              invoiceId: Value(invoiceId),
              createdAt: now,
            ),
          );
      return invoiceId;
    });
  }

  Future<void> delete(int id) {
    return _db.transaction(() async {
      await (_db.delete(_db.invoiceItems)
            ..where((row) => row.invoiceId.equals(id)))
          .go();
      await (_db.delete(_db.entries)..where((row) => row.invoiceId.equals(id)))
          .go();
      await (_db.delete(_db.invoices)..where((row) => row.id.equals(id))).go();
    });
  }
}
