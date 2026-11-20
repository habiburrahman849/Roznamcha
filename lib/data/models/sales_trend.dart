import 'package:roznamcha/core/constants/app_config.dart';
import 'package:roznamcha/core/utils/currency.dart';
import 'package:roznamcha/core/utils/date_utils.dart';
import 'package:roznamcha/data/models/enums.dart';

class ChartEntry {
  const ChartEntry({
    required this.createdAt,
    required this.type,
    required this.amount,
  });

  final DateTime createdAt;
  final EntryType type;
  final double amount;
}

class SalesPoint {
  const SalesPoint({required this.label, required this.amount});

  final String label;
  final double amount;
}

abstract final class SalesTrend {
  static List<SalesPoint> build({
    required Iterable<ChartEntry> entries,
    required DateTime start,
    required DateTime endExclusive,
  }) {
    final sales = entries.where((entry) => entry.type == EntryType.sale);
    final days = AppDateUtils.daysInRange(start, endExclusive);
    if (days.isEmpty) return const [];
    if (days.length <= AppConfig.chartDailyLimit) {
      return [
        for (final day in days)
          SalesPoint(
            label: AppDateUtils.shortDay(day),
            amount: _total(
              sales,
              (entry) => AppDateUtils.startOfDay(entry.createdAt) == day,
            ),
          ),
      ];
    }

    // A long custom range is grouped by week so the bars stay readable.
    final buckets = <DateTime, double>{};
    for (final day in days) {
      buckets[AppDateUtils.startOfWeek(day)] = 0;
    }
    for (final entry in sales) {
      final week = AppDateUtils.startOfWeek(entry.createdAt);
      buckets[week] = (buckets[week] ?? 0) + entry.amount;
    }
    final keys = buckets.keys.toList()..sort();
    return [
      for (final key in keys)
        SalesPoint(
          label: AppDateUtils.shortDay(key),
          amount: roundMoney(buckets[key] ?? 0),
        ),
    ];
  }

  static double _total(
    Iterable<ChartEntry> sales,
    bool Function(ChartEntry entry) include,
  ) {
    var sum = 0.0;
    for (final entry in sales) {
      if (include(entry)) sum += entry.amount;
    }
    return roundMoney(sum);
  }
}
