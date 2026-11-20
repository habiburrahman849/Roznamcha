import 'package:intl/intl.dart';
import 'package:roznamcha/core/constants/app_strings.dart';

/// Inclusive start and exclusive end, both at local midnight boundaries.
typedef DateRange = ({DateTime start, DateTime end});

abstract final class AppDateUtils {
  static DateTime startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime startOfWeek(DateTime value) {
    final day = startOfDay(value);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static DateRange today([DateTime? now]) {
    final start = startOfDay(now ?? DateTime.now());
    return (start: start, end: start.add(const Duration(days: 1)));
  }

  static DateRange thisWeek([DateTime? now]) {
    final current = now ?? DateTime.now();
    return (start: startOfWeek(current), end: today(current).end);
  }

  static DateRange thisMonth([DateTime? now]) {
    final current = now ?? DateTime.now();
    return (
      start: DateTime(current.year, current.month),
      end: today(current).end,
    );
  }

  static DateRange inclusiveDays(DateTime start, DateTime end) {
    final first = startOfDay(start);
    final last = startOfDay(end);
    final from = first.isBefore(last) ? first : last;
    final to = first.isBefore(last) ? last : first;
    return (start: from, end: to.add(const Duration(days: 1)));
  }

  static List<DateTime> daysInRange(DateTime start, DateTime endExclusive) {
    final days = <DateTime>[];
    var cursor = startOfDay(start);
    final end = startOfDay(endExclusive);
    while (cursor.isBefore(end)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return days;
  }

  static String greeting(DateTime now) {
    if (now.hour < 12) return AppStrings.goodMorning;
    if (now.hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  static String sectionLabel(DateTime day, [DateTime? now]) {
    final current = startOfDay(now ?? DateTime.now());
    final date = startOfDay(day);
    if (date == current) return AppStrings.today;
    if (date == current.subtract(const Duration(days: 1))) {
      return AppStrings.yesterday;
    }
    return dateLabel(date);
  }

  static String dateLabel(DateTime value) =>
      DateFormat('d MMM y', 'en_US').format(value);

  static String shortDay(DateTime value) =>
      DateFormat('d MMM', 'en_US').format(value);

  static String timeLabel(DateTime value) =>
      DateFormat('h:mm a', 'en_US').format(value);

  static String rangeLabel(DateRange range) {
    final lastShown = range.end.subtract(const Duration(days: 1));
    return '${dateLabel(range.start)} – ${dateLabel(lastShown)}';
  }
}
