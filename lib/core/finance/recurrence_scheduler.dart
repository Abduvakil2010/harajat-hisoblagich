import '../../data/models/enums.dart';
import '../utils/date_range.dart';

/// Pure, deterministic recurrence maths.
///
/// Occurrence *n* is always computed from the start date (never by adding to
/// the previous occurrence), so monthly payments anchored on the 31st land on
/// the last day of shorter months without drifting.
class RecurrenceScheduler {
  const RecurrenceScheduler();

  DateTime occurrence(DateTime start, RecurrenceFrequency f, int n) {
    final s = start.dateOnly;
    switch (f) {
      case RecurrenceFrequency.daily:
        return DateTime(s.year, s.month, s.day + n);
      case RecurrenceFrequency.weekly:
        return DateTime(s.year, s.month, s.day + 7 * n);
      case RecurrenceFrequency.monthly:
        return _clampedMonth(s.year, s.month + n, s.day);
      case RecurrenceFrequency.yearly:
        return _clampedMonth(s.year + n, s.month, s.day);
    }
  }

  static DateTime _clampedMonth(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDay ? lastDay : day);
  }

  /// All occurrences with `after < date <= until` (dates only), respecting
  /// the optional [end] date. [after] null means "from the start".
  List<DateTime> occurrencesBetween({
    required DateTime start,
    required RecurrenceFrequency frequency,
    DateTime? end,
    DateTime? after,
    required DateTime until,
    int maxCount = 1000,
  }) {
    final result = <DateTime>[];
    final limit = until.dateOnly;
    final endDay = end?.dateOnly;
    final afterDay = after?.dateOnly;
    var n = _firstIndexAfter(start, frequency, afterDay);
    while (result.length < maxCount) {
      final d = occurrence(start, frequency, n);
      if (d.isAfter(limit)) break;
      if (endDay != null && d.isAfter(endDay)) break;
      if (afterDay == null || d.isAfter(afterDay)) result.add(d);
      n++;
    }
    return result;
  }

  /// The first occurrence strictly after [after] (or the first ever when
  /// null), or null if the schedule has ended.
  DateTime? nextAfter({
    required DateTime start,
    required RecurrenceFrequency frequency,
    DateTime? end,
    DateTime? after,
  }) {
    final afterDay = after?.dateOnly;
    var n = _firstIndexAfter(start, frequency, afterDay);
    for (var guard = 0; guard < 100000; guard++, n++) {
      final d = occurrence(start, frequency, n);
      if (end != null && d.isAfter(end.dateOnly)) return null;
      if (afterDay == null || d.isAfter(afterDay)) return d;
    }
    return null;
  }

  /// Skips quickly towards [after] for long-running daily schedules.
  int _firstIndexAfter(DateTime start, RecurrenceFrequency f, DateTime? after) {
    if (after == null || !after.isAfter(start.dateOnly)) return 0;
    final days = after.difference(start.dateOnly).inDays;
    final approx = switch (f) {
      RecurrenceFrequency.daily => days,
      RecurrenceFrequency.weekly => days ~/ 7,
      RecurrenceFrequency.monthly => days ~/ 31,
      RecurrenceFrequency.yearly => days ~/ 366,
    };
    return approx > 1 ? approx - 1 : 0;
  }

  /// Stable identifier of an occurrence, used as a unique DB key.
  static String occurrenceKey(String recurringId, DateTime date) {
    final d = date.dateOnly;
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$recurringId@${d.year}-$mm-$dd';
  }
}
