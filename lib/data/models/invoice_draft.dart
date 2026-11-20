import 'package:roznamcha/core/utils/currency.dart';
import 'package:roznamcha/data/models/enums.dart';

class InvoiceLineDraft {
  const InvoiceLineDraft({
    required this.localId,
    required this.name,
    required this.qty,
    required this.price,
    this.productId,
  });

  final int localId;
  final int? productId;
  final String name;
  final double qty;
  final double price;

  double get lineTotal => roundMoney(qty * price);

  InvoiceLineDraft copyWith({double? qty}) {
    return InvoiceLineDraft(
      localId: localId,
      productId: productId,
      name: name,
      qty: qty ?? this.qty,
      price: price,
    );
  }
}

class InvoiceDraft {
  const InvoiceDraft({
    this.customerId,
    this.customerName = '',
    this.customerPhone = '',
    this.saveCustomer = false,
    this.lines = const [],
    this.discount = 0,
    this.paymentType = PaymentType.cash,
    this.nextLineId = 1,
  });

  static const empty = InvoiceDraft();

  final int? customerId;
  final String customerName;
  final String customerPhone;
  final bool saveCustomer;
  final List<InvoiceLineDraft> lines;
  final double discount;
  final PaymentType paymentType;
  final int nextLineId;

  double get subtotal =>
      roundMoney(lines.fold<double>(0, (sum, line) => sum + line.lineTotal));

  double get total => roundMoney(subtotal - discount);

  bool get discountValid => discount >= 0 && discount <= subtotal + 0.0001;

  InvoiceDraft addLine({
    int? productId,
    required String name,
    required double qty,
    required double price,
  }) {
    if (productId != null) {
      final index = lines.indexWhere((line) => line.productId == productId);
      if (index >= 0) {
        final updated = [...lines];
        final current = updated[index];
        updated[index] = current.copyWith(qty: current.qty + qty);
        return copyWith(lines: updated);
      }
    }
    return copyWith(
      lines: [
        ...lines,
        InvoiceLineDraft(
          localId: nextLineId,
          productId: productId,
          name: name.trim(),
          qty: qty,
          price: roundMoney(price),
        ),
      ],
      nextLineId: nextLineId + 1,
    );
  }

  InvoiceDraft updateQty(int localId, double qty) {
    return copyWith(
      lines: [
        for (final line in lines)
          if (line.localId == localId) line.copyWith(qty: qty) else line,
      ],
    );
  }

  InvoiceDraft removeLine(int localId) {
    return copyWith(
      lines: [for (final line in lines) if (line.localId != localId) line],
    );
  }

  InvoiceDraft copyWith({
    int? customerId,
    bool clearCustomer = false,
    String? customerName,
    String? customerPhone,
    bool? saveCustomer,
    List<InvoiceLineDraft>? lines,
    double? discount,
    PaymentType? paymentType,
    int? nextLineId,
  }) {
    return InvoiceDraft(
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      saveCustomer: saveCustomer ?? this.saveCustomer,
      lines: lines ?? this.lines,
      discount: discount ?? this.discount,
      paymentType: paymentType ?? this.paymentType,
      nextLineId: nextLineId ?? this.nextLineId,
    );
  }
}
