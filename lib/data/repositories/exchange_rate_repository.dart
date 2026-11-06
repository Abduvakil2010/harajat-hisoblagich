import 'package:drift/drift.dart';

import '../../core/money/currency.dart';
import '../../core/money/currency_converter.dart';
import '../local/app_database.dart';

class ExchangeRateRepository {
  ExchangeRateRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const manualSource = 'manual';

  final AppDatabase _db;
  final DateTime Function() _clock;

  Stream<List<ExchangeRateQuote>> watchQuotes() =>
      (_db.select(_db.exchangeRates)..orderBy([
            (r) => OrderingTerm.desc(r.effectiveDate),
            (r) => OrderingTerm.desc(r.id),
          ]))
          .watch()
          .map((rows) => rows.map(toQuote).toList());

  static ExchangeRateQuote toQuote(ExchangeRateRecord r) => ExchangeRateQuote(
    id: r.id,
    base: r.base,
    quote: r.quote,
    rate: r.rate,
    source: r.source,
    effectiveDate: r.effectiveDate,
  );

  Future<void> add({
    required Currency base,
    required Currency quote,
    required double rate,
    required DateTime effectiveDate,
    String source = manualSource,
  }) async {
    if (base == quote) throw ArgumentError('base == quote');
    if (!(rate > 0) || rate.isInfinite) throw ArgumentError.value(rate, 'rate');
    await _db
        .into(_db.exchangeRates)
        .insert(
          ExchangeRatesCompanion.insert(
            base: base,
            quote: quote,
            rate: rate,
            source: source,
            effectiveDate: DateTime(
              effectiveDate.year,
              effectiveDate.month,
              effectiveDate.day,
            ),
            createdAt: _clock(),
          ),
        );
  }

  Future<void> updateRate(
    int id, {
    required double rate,
    required DateTime effectiveDate,
  }) async {
    if (!(rate > 0) || rate.isInfinite) throw ArgumentError.value(rate, 'rate');
    await (_db.update(_db.exchangeRates)..where((r) => r.id.equals(id))).write(
      ExchangeRatesCompanion(
        rate: Value(rate),
        effectiveDate: Value(
          DateTime(effectiveDate.year, effectiveDate.month, effectiveDate.day),
        ),
      ),
    );
  }

  Future<void> delete(int id) =>
      (_db.delete(_db.exchangeRates)..where((r) => r.id.equals(id))).go();
}
