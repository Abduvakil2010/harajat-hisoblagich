import 'currency.dart';

/// An immutable amount of money in a single currency, stored in minor units.
class Money implements Comparable<Money> {
  const Money(this.minor, this.currency);

  const Money.zero(this.currency) : minor = 0;

  /// Creates money from a major-unit decimal value (e.g. 12.5 USD).
  factory Money.fromMajor(num major, Currency currency) =>
      Money((major * currency.minorFactor).round(), currency);

  final int minor;
  final Currency currency;

  double get major => minor / currency.minorFactor;
  bool get isZero => minor == 0;
  bool get isNegative => minor < 0;
  bool get isPositive => minor > 0;

  Money operator +(Money other) {
    _assertSame(other);
    return Money(minor + other.minor, currency);
  }

  Money operator -(Money other) {
    _assertSame(other);
    return Money(minor - other.minor, currency);
  }

  Money operator -() => Money(-minor, currency);

  Money abs() => Money(minor.abs(), currency);

  void _assertSame(Money other) {
    if (other.currency != currency) {
      throw ArgumentError(
        'Cannot combine ${currency.code} and ${other.currency.code} '
        'without an explicit conversion.',
      );
    }
  }

  @override
  int compareTo(Money other) {
    _assertSame(other);
    return minor.compareTo(other.minor);
  }

  @override
  bool operator ==(Object other) =>
      other is Money && other.minor == minor && other.currency == currency;

  @override
  int get hashCode => Object.hash(minor, currency);

  @override
  String toString() =>
      '${major.toStringAsFixed(currency.minorDigits)} ${currency.code}';
}

/// A sum that may contain several currencies that must never be added
/// together without a conversion.
class MultiCurrencyAmount {
  MultiCurrencyAmount([Map<Currency, int>? values])
    : _values = Map.unmodifiable(values ?? const {});

  final Map<Currency, int> _values;

  Map<Currency, int> get values => _values;

  int minorOf(Currency c) => _values[c] ?? 0;

  bool get isEmpty => _values.values.every((v) => v == 0);

  /// Currencies with a non-zero amount, in enum order.
  List<Currency> get currencies =>
      Currency.values.where((c) => (_values[c] ?? 0) != 0).toList();

  bool get isSingleCurrency => currencies.length <= 1;

  MultiCurrencyAmount add(Currency c, int minor) {
    final next = Map<Currency, int>.from(_values);
    next[c] = (next[c] ?? 0) + minor;
    return MultiCurrencyAmount(next);
  }

  MultiCurrencyAmount operator +(MultiCurrencyAmount other) {
    final next = Map<Currency, int>.from(_values);
    other._values.forEach((c, v) => next[c] = (next[c] ?? 0) + v);
    return MultiCurrencyAmount(next);
  }

  MultiCurrencyAmount operator -(MultiCurrencyAmount other) {
    final next = Map<Currency, int>.from(_values);
    other._values.forEach((c, v) => next[c] = (next[c] ?? 0) - v);
    return MultiCurrencyAmount(next);
  }

  List<Money> toMoneyList() => [
    for (final c in Currency.values)
      if ((_values[c] ?? 0) != 0) Money(_values[c]!, c),
  ];

  @override
  bool operator ==(Object other) {
    if (other is! MultiCurrencyAmount) return false;
    for (final c in Currency.values) {
      if (minorOf(c) != other.minorOf(c)) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(Currency.values.map(minorOf));

  @override
  String toString() => toMoneyList().join(' + ');
}
