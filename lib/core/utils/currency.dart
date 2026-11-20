import 'package:intl/intl.dart';

/// Formats money with the shop's symbol and decimal setting.
class CurrencyFormat {
  const CurrencyFormat({required this.symbol, required this.decimalDigits});

  final String symbol;
  final int decimalDigits;

  static const fallback = CurrencyFormat(symbol: 'Rs.', decimalDigits: 0);

  String format(num amount) {
    final digits = decimalDigits <= 0 ? 0 : 2;
    final pattern = digits == 0 ? '#,##0' : '#,##0.00';
    final formatted = NumberFormat(pattern, 'en_US').format(amount);
    final trimmed = symbol.trim();
    if (trimmed.isEmpty) return formatted;
    return '$trimmed $formatted';
  }
}

/// Parses a typed amount. Thousands separators are ignored.
double? parseAmount(String raw) {
  final cleaned = raw.replaceAll(',', '').trim();
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value.isNaN || value.isInfinite) return null;
  return value;
}

/// Money is stored with at most two decimal places.
double roundMoney(double value) => (value * 100).roundToDouble() / 100;
