/// An inclusive-start, exclusive-end date range with value equality, so it can
/// be used as a provider family key.
class DateRange {
  const DateRange(this.start, this.end);

  /// The calendar month containing [date].
  factory DateRange.month(DateTime date) => DateRange(
    DateTime(date.year, date.month),
    DateTime(date.year, date.month + 1),
  );

  /// The single day containing [date].
  factory DateRange.day(DateTime date) => DateRange(
    DateTime(date.year, date.month, date.day),
    DateTime(date.year, date.month, date.day + 1),
  );

  /// The ISO week (Monday–Sunday) containing [date].
  factory DateRange.week(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final start = d.subtract(Duration(days: d.weekday - 1));
    return DateRange(start, DateTime(start.year, start.month, start.day + 7));
  }

  factory DateRange.year(DateTime date) =>
      DateRange(DateTime(date.year), DateTime(date.year + 1));

  /// Inclusive custom range from day [from] to day [to].
  factory DateRange.days(DateTime from, DateTime to) => DateRange(
    DateTime(from.year, from.month, from.day),
    DateTime(to.year, to.month, to.day + 1),
  );

  final DateTime start;
  final DateTime end;

  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(end);

  int get dayCount {
    var n = 0;
    var d = start;
    while (d.isBefore(end)) {
      n++;
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return n;
  }

  /// Last day included in the range.
  DateTime get lastDay => DateTime(end.year, end.month, end.day - 1);

  /// The range of the same length immediately before this one. For calendar
  /// months the previous calendar month is returned.
  DateRange previous() {
    if (start.day == 1 && end.day == 1 && _monthsBetween(start, end) == 1) {
      return DateRange.month(DateTime(start.year, start.month - 1));
    }
    final len = dayCount;
    return DateRange(DateTime(start.year, start.month, start.day - len), start);
  }

  static int _monthsBetween(DateTime a, DateTime b) =>
      (b.year - a.year) * 12 + b.month - a.month;

  /// All days in the range.
  Iterable<DateTime> get days sync* {
    var d = start;
    while (d.isBefore(end)) {
      yield d;
      d = DateTime(d.year, d.month, d.day + 1);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start – $end)';
}

extension DateOnly on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
  bool isSameDay(DateTime o) =>
      year == o.year && month == o.month && day == o.day;
  bool isSameMonth(DateTime o) => year == o.year && month == o.month;
}
