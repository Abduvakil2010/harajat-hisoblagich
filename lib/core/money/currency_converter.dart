import 'currency.dart';
import 'money.dart';

/// A clearly identified exchange rate: `1 base = rate quote`.
class ExchangeRateQuote {
  const ExchangeRateQuote({
    required this.base,
    required this.quote,
    required this.rate,
    required this.source,
    required this.effectiveDate,
    this.id,
  });

  final int? id;
  final Currency base;
  final Currency quote;
  final double rate;
  final String source;
  final DateTime effectiveDate;

  bool connects(Currency a, Currency b) =>
      (base == a && quote == b) || (base == b && quote == a);
}

/// Result of a conversion including how the rate was chosen.
class ConversionResult {
  const ConversionResult(this.money, this.rate, {this.approximated = false});

  final Money money;
  final ExchangeRateQuote? rate;

  /// True when no rate existed on or before the requested date and the
  /// oldest known rate was used instead.
  final bool approximated;
}

/// Converts amounts between currencies using user-provided rates.
///
/// ## Conversion policy (documented in README)
/// * Never adds different currencies directly.
/// * Flows (income/expense of a period) are converted per transaction using
///   the most recent rate effective **on or before the transaction date**.
/// * If a transaction predates every known rate, the oldest known rate is
///   used and the result is flagged as `approximated`.
/// * Balances (stocks) are converted with the latest known rate.
/// * If no rate exists for a currency pair, conversion returns `null` and the
///   UI shows separate per-currency totals instead of a combined figure.
class CurrencyConverter {
  CurrencyConverter(Iterable<ExchangeRateQuote> quotes)
    : _quotes = List.of(quotes)
        ..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));

  final List<ExchangeRateQuote> _quotes;

  static final empty = CurrencyConverter(const []);

  List<ExchangeRateQuote> get quotes => List.unmodifiable(_quotes);

  bool canConvert(Currency from, Currency to) =>
      from == to || _quotes.any((q) => q.connects(from, to));

  /// Picks the rate for the pair at [at] (or the latest if [at] is null).
  (ExchangeRateQuote, bool)? rateFor(
    Currency from,
    Currency to, {
    DateTime? at,
  }) {
    final pair = _quotes.where((q) => q.connects(from, to)).toList();
    if (pair.isEmpty) return null;
    if (at == null) return (pair.last, false);
    final day = DateTime(at.year, at.month, at.day, 23, 59, 59);
    ExchangeRateQuote? best;
    for (final q in pair) {
      if (!q.effectiveDate.isAfter(day)) best = q;
    }
    if (best != null) return (best, false);
    return (pair.first, true);
  }

  ConversionResult? convert(Money money, Currency to, {DateTime? at}) {
    if (money.currency == to) return ConversionResult(money, null);
    final found = rateFor(money.currency, to, at: at);
    if (found == null) return null;
    final (q, approx) = found;
    if (q.rate <= 0) return null;
    final factor = q.base == money.currency ? q.rate : 1 / q.rate;
    final major = money.minor / money.currency.minorFactor * factor;
    return ConversionResult(
      Money((major * to.minorFactor).round(), to),
      q,
      approximated: approx,
    );
  }

  /// Converts a multi-currency sum at a single point in time.
  /// Returns null if any part cannot be converted.
  Money? convertTotal(MultiCurrencyAmount amount, Currency to, {DateTime? at}) {
    var total = 0;
    for (final c in Currency.values) {
      final v = amount.minorOf(c);
      if (v == 0) continue;
      final r = convert(Money(v, c), to, at: at);
      if (r == null) return null;
      total += r.money.minor;
    }
    return Money(total, to);
  }
}
