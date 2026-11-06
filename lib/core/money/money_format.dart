import 'package:intl/intl.dart';

import 'currency.dart';
import 'money.dart';

/// Locale-aware money formatting and parsing.
class MoneyFormat {
  MoneyFormat(this.locale);

  final String locale;

  static const hiddenMask = '••••••';

  final Map<String, NumberFormat> _cache = {};

  NumberFormat _fmt(int decimals) => _cache.putIfAbsent(
    '$decimals',
    () => NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimals,
    ),
  );

  /// Formats [money]. Shows minor digits only when they are non-zero for
  /// currencies that hide them by default (UZS).
  String format(
    Money money, {
    bool hidden = false,
    bool signed = false,
    bool compact = false,
  }) {
    if (hidden) return _decorate(hiddenMask, money.currency, false, false);
    final major = money.major.abs();
    String number;
    if (compact && major >= 1000000) {
      number = NumberFormat.compact(locale: locale).format(major);
    } else {
      var decimals = money.currency.displayDecimals;
      if (decimals == 0 && money.minor % money.currency.minorFactor != 0) {
        decimals = money.currency.minorDigits;
      }
      number = _fmt(decimals).format(major);
    }
    return _decorate(
      number,
      money.currency,
      money.isNegative,
      signed && money.isPositive,
    );
  }

  String formatMinor(
    int minor,
    Currency currency, {
    bool hidden = false,
    bool signed = false,
    bool compact = false,
  }) => format(
    Money(minor, currency),
    hidden: hidden,
    signed: signed,
    compact: compact,
  );

  String _decorate(String number, Currency c, bool negative, bool plus) {
    final sign = negative ? '−' : (plus ? '+' : '');
    switch (c) {
      case Currency.usd:
        return '$sign\$$number';
      case Currency.uzs:
        return '$sign$number UZS';
    }
  }

  /// Formats a number for an input field (no grouping symbols).
  static String toInput(int minor, Currency currency) {
    final whole = minor ~/ currency.minorFactor;
    final frac = (minor % currency.minorFactor).abs();
    if (frac == 0) return '$whole';
    return '$whole.${frac.toString().padLeft(currency.minorDigits, '0')}';
  }

  /// Parses user input like `12 500`, `12,500.50`, `12500,5` into minor
  /// units. Returns null if the input is not a valid non-negative number.
  static int? parseMinor(String raw, Currency currency) {
    final s = raw.trim().replaceAll(RegExp(r'[\s  _]'), '');
    if (s.isEmpty) return null;
    if (!RegExp(r'^[0-9.,]+$').hasMatch(s)) return null;
    final lastComma = s.lastIndexOf(',');
    final lastDot = s.lastIndexOf('.');
    String intPart;
    var fracPart = '';
    if (lastComma >= 0 && lastDot >= 0) {
      final decIdx = lastComma > lastDot ? lastComma : lastDot;
      intPart = s.substring(0, decIdx).replaceAll(RegExp('[.,]'), '');
      fracPart = s.substring(decIdx + 1);
    } else if (lastComma >= 0 || lastDot >= 0) {
      final sep = lastComma >= 0 ? ',' : '.';
      final parts = s.split(sep);
      final tail = parts.last;
      if (parts.length == 2 && tail.length <= currency.minorDigits) {
        intPart = parts.first;
        fracPart = tail;
      } else if (parts.skip(1).every((p) => p.length == 3)) {
        intPart = parts.join();
      } else {
        return null;
      }
    } else {
      intPart = s;
    }
    if (fracPart.contains(RegExp('[.,]'))) return null;
    if (fracPart.length > currency.minorDigits) return null;
    if (intPart.isEmpty) intPart = '0';
    final whole = int.tryParse(intPart);
    if (whole == null) return null;
    final frac = fracPart.isEmpty
        ? 0
        : int.parse(fracPart.padRight(currency.minorDigits, '0'));
    // Guard against overflow for absurd inputs (> 10^15 major units).
    if (intPart.length > 15) return null;
    return whole * currency.minorFactor + frac;
  }
}
