import 'package:roznamcha/core/utils/currency.dart';
import 'package:roznamcha/data/models/enums.dart';

class AmountLine {
  const AmountLine({
    required this.type,
    required this.paymentType,
    required this.amount,
  });

  final EntryType type;
  final PaymentType paymentType;
  final double amount;
}

class PeriodStats {
  const PeriodStats({
    required this.totalSale,
    required this.totalPurchase,
    required this.cashInHand,
    required this.bankTransfer,
  });

  static const empty = PeriodStats(
    totalSale: 0,
    totalPurchase: 0,
    cashInHand: 0,
    bankTransfer: 0,
  );

  final double totalSale;
  final double totalPurchase;
  final double cashInHand;
  final double bankTransfer;

  double get net => roundMoney(totalSale - totalPurchase);

  factory PeriodStats.fromLines(Iterable<AmountLine> lines) {
    var sale = 0.0;
    var purchase = 0.0;
    var cash = 0.0;
    var bank = 0.0;
    for (final line in lines) {
      final incoming = line.type == EntryType.sale;
      final signed = incoming ? line.amount : -line.amount;
      if (incoming) {
        sale += line.amount;
      } else {
        purchase += line.amount;
      }
      if (line.paymentType == PaymentType.cash) {
        cash += signed;
      } else {
        bank += signed;
      }
    }
    return PeriodStats(
      totalSale: roundMoney(sale),
      totalPurchase: roundMoney(purchase),
      cashInHand: roundMoney(cash),
      bankTransfer: roundMoney(bank),
    );
  }
}
