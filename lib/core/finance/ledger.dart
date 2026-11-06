import '../../data/local/app_database.dart';
import '../../data/models/enums.dart';
import '../money/currency.dart';
import '../money/currency_converter.dart';
import '../money/money.dart';
import '../utils/date_range.dart';

/// A sum expressed in one display currency, with an honest account of
/// anything that could not be converted.
class ConvertedSum {
  ConvertedSum({
    required this.minor,
    required this.currency,
    MultiCurrencyAmount? unconverted,
    this.approximated = false,
  }) : unconverted = unconverted ?? MultiCurrencyAmount();

  final int minor;
  final Currency currency;

  /// Amounts left out because no exchange rate exists.
  final MultiCurrencyAmount unconverted;
  final bool approximated;

  Money get money => Money(minor, currency);
  bool get isComplete => unconverted.isEmpty;
}

class CategoryShare {
  const CategoryShare(this.categoryId, this.minor, this.share, this.count);
  final int categoryId;
  final int minor;

  /// 0..1 share of the total.
  final double share;
  final int count;
}

class _Entry {
  _Entry(this.tx, this.value, this.approximated);
  final TransactionRecord tx;

  /// Value in the display currency, or null when not convertible.
  final int? value;
  final bool approximated;
}

/// Converts a list of transactions into one display currency exactly once and
/// offers every aggregate the dashboard, statistics, AI and reports need.
///
/// This is the single source of truth for flow calculations, so every screen
/// shows consistent numbers.
class Ledger {
  Ledger(
    Iterable<TransactionRecord> transactions,
    this.currency,
    this.converter,
  ) : _entries = [
        for (final t in transactions) _convert(t, currency, converter),
      ];

  final Currency currency;
  final CurrencyConverter converter;
  final List<_Entry> _entries;

  static _Entry _convert(
    TransactionRecord t,
    Currency target,
    CurrencyConverter c,
  ) {
    final r = c.convert(Money(t.amountMinor, t.currency), target, at: t.date);
    return _Entry(t, r?.money.minor, r?.approximated ?? false);
  }

  List<TransactionRecord> get transactions => [for (final e in _entries) e.tx];

  bool get isEmpty => _entries.isEmpty;

  Iterable<_Entry> _of(TransactionType? type, [DateRange? range]) =>
      _entries.where(
        (e) =>
            (type == null || e.tx.type == type) &&
            (range == null || range.contains(e.tx.date)),
      );

  int count(TransactionType? type, [DateRange? range]) =>
      _of(type, range).length;

  ConvertedSum total(TransactionType type, [DateRange? range]) {
    var sum = 0;
    var approx = false;
    var missing = MultiCurrencyAmount();
    for (final e in _of(type, range)) {
      if (e.value == null) {
        missing = missing.add(e.tx.currency, e.tx.amountMinor);
      } else {
        sum += e.value!;
        approx |= e.approximated;
      }
    }
    return ConvertedSum(
      minor: sum,
      currency: currency,
      unconverted: missing,
      approximated: approx,
    );
  }

  /// Income minus expenses in the display currency.
  ConvertedSum net([DateRange? range]) {
    final i = total(TransactionType.income, range);
    final e = total(TransactionType.expense, range);
    return ConvertedSum(
      minor: i.minor - e.minor,
      currency: currency,
      unconverted: i.unconverted - e.unconverted,
      approximated: i.approximated || e.approximated,
    );
  }

  /// Raw per-currency totals, never converted.
  MultiCurrencyAmount rawTotal(TransactionType type, [DateRange? range]) {
    var m = MultiCurrencyAmount();
    for (final e in _of(type, range)) {
      m = m.add(e.tx.currency, e.tx.amountMinor);
    }
    return m;
  }

  /// Category breakdown sorted by amount (largest first).
  List<CategoryShare> byCategory(TransactionType type, [DateRange? range]) {
    final sums = <int, int>{};
    final counts = <int, int>{};
    for (final e in _of(type, range)) {
      if (e.value == null) continue;
      sums[e.tx.categoryId] = (sums[e.tx.categoryId] ?? 0) + e.value!;
      counts[e.tx.categoryId] = (counts[e.tx.categoryId] ?? 0) + 1;
    }
    final total = sums.values.fold<int>(0, (a, b) => a + b);
    final list = [
      for (final entry in sums.entries)
        CategoryShare(
          entry.key,
          entry.value,
          total == 0 ? 0 : entry.value / total,
          counts[entry.key] ?? 0,
        ),
    ]..sort((a, b) => b.minor.compareTo(a.minor));
    return list;
  }

  int categoryTotal(int categoryId, TransactionType type, [DateRange? range]) {
    var sum = 0;
    for (final e in _of(type, range)) {
      if (e.tx.categoryId == categoryId && e.value != null) sum += e.value!;
    }
    return sum;
  }

  /// One value per day of [range].
  List<int> daily(TransactionType type, DateRange range) {
    final days = range.days.toList();
    final values = List<int>.filled(days.length, 0);
    for (final e in _of(type, range)) {
      if (e.value == null) continue;
      final idx = e.tx.date.dateOnly.difference(range.start).inDays;
      if (idx >= 0 && idx < values.length) values[idx] += e.value!;
    }
    return values;
  }

  /// Totals for each of [weeks] ISO weeks ending with the week of [anchor].
  List<(DateRange, int)> weekly(
    TransactionType type,
    DateTime anchor,
    int weeks,
  ) {
    final last = DateRange.week(anchor);
    return [
      for (var i = weeks - 1; i >= 0; i--)
        () {
          final start = DateTime(
            last.start.year,
            last.start.month,
            last.start.day - 7 * i,
          );
          final r = DateRange(
            start,
            DateTime(start.year, start.month, start.day + 7),
          );
          return (r, total(type, r).minor);
        }(),
    ];
  }

  /// Totals for each of [months] calendar months ending with [anchor]'s month.
  List<(DateRange, int)> monthly(
    TransactionType type,
    DateTime anchor,
    int months,
  ) => [
    for (var i = months - 1; i >= 0; i--)
      () {
        final r = DateRange.month(DateTime(anchor.year, anchor.month - i));
        return (r, total(type, r).minor);
      }(),
  ];

  /// The single largest / smallest convertible transaction of [type].
  TransactionRecord? extreme(
    TransactionType type, {
    required bool highest,
    DateRange? range,
  }) {
    _Entry? best;
    for (final e in _of(type, range)) {
      if (e.value == null) continue;
      if (best == null ||
          (highest ? e.value! > best.value! : e.value! < best.value!)) {
        best = e;
      }
    }
    return best?.tx;
  }

  int? valueOf(TransactionRecord tx) {
    for (final e in _entries) {
      if (identical(e.tx, tx) || e.tx.id == tx.id) return e.value;
    }
    return null;
  }

  /// Average daily expense over [range] (calendar days, not only days with
  /// spending). For the current period pass a range ending today.
  int averageDaily(TransactionType type, DateRange range) {
    final days = range.dayCount;
    if (days <= 0) return 0;
    return (total(type, range).minor / days).round();
  }
}
