import 'package:flutter_test/flutter_test.dart';
import 'package:hisobai/core/money/currency.dart';
import 'package:hisobai/core/money/currency_converter.dart';
import 'package:hisobai/core/money/money.dart';
import 'package:hisobai/core/money/money_format.dart';

void main() {
  group('Money', () {
    test('adds and subtracts in minor units without float errors', () {
      final a = Money.fromMajor(0.1, Currency.usd);
      final b = Money.fromMajor(0.2, Currency.usd);
      expect((a + b).minor, 30);
      expect((b - a).minor, 10);
    });

    test('refuses to mix currencies', () {
      expect(
        () => const Money(100, Currency.usd) + const Money(100, Currency.uzs),
        throwsArgumentError,
      );
    });

    test('MultiCurrencyAmount keeps currencies apart', () {
      final total = MultiCurrencyAmount()
          .add(Currency.uzs, 500000)
          .add(Currency.usd, 1000)
          .add(Currency.uzs, 250000);
      expect(total.minorOf(Currency.uzs), 750000);
      expect(total.minorOf(Currency.usd), 1000);
      expect(total.isSingleCurrency, isFalse);
    });
  });

  group('MoneyFormat.parseMinor', () {
    test('parses grouped and decimal input', () {
      expect(MoneyFormat.parseMinor('12 500', Currency.uzs), 1250000);
      expect(MoneyFormat.parseMinor('12,500.50', Currency.usd), 1250050);
      expect(MoneyFormat.parseMinor('12500,5', Currency.usd), 1250050);
      expect(MoneyFormat.parseMinor('1.250.000', Currency.uzs), 125000000);
      expect(MoneyFormat.parseMinor('0.99', Currency.usd), 99);
    });

    test('rejects invalid input', () {
      expect(MoneyFormat.parseMinor('', Currency.usd), isNull);
      expect(MoneyFormat.parseMinor('abc', Currency.usd), isNull);
      expect(MoneyFormat.parseMinor('1.234', Currency.usd), 123400); // grouping
      expect(MoneyFormat.parseMinor('1.2.3', Currency.usd), isNull);
      expect(MoneyFormat.parseMinor('-5', Currency.usd), isNull);
    });

    test('round-trips through toInput', () {
      expect(MoneyFormat.toInput(1250050, Currency.usd), '12500.50');
      expect(MoneyFormat.toInput(500000, Currency.uzs), '5000');
    });

    test('formats with currency and sign', () {
      final f = MoneyFormat('en');
      expect(f.format(const Money(500000000, Currency.uzs)), '5,000,000 UZS');
      expect(f.format(const Money(1234, Currency.usd)), r'$12.34');
      expect(f.format(const Money(-1234, Currency.usd)), r'−$12.34');
      expect(
        f.format(const Money(1234, Currency.usd), hidden: true),
        contains('••'),
      );
    });
  });

  group('CurrencyConverter', () {
    final quotes = [
      ExchangeRateQuote(
        base: Currency.usd,
        quote: Currency.uzs,
        rate: 12000,
        source: 'manual',
        effectiveDate: DateTime(2026, 1, 1),
      ),
      ExchangeRateQuote(
        base: Currency.usd,
        quote: Currency.uzs,
        rate: 12600,
        source: 'manual',
        effectiveDate: DateTime(2026, 6, 1),
      ),
    ];
    final c = CurrencyConverter(quotes);

    test('uses the rate effective on the given date', () {
      final early = c.convert(
        const Money(100, Currency.usd),
        Currency.uzs,
        at: DateTime(2026, 3, 10),
      )!;
      expect(early.money.minor, 1200000); // 1 USD = 12 000 UZS
      final late = c.convert(
        const Money(100, Currency.usd),
        Currency.uzs,
        at: DateTime(2026, 7, 1),
      )!;
      expect(late.money.minor, 1260000);
    });

    test('converts in the inverse direction', () {
      final r = c.convert(
        const Money(1260000, Currency.uzs),
        Currency.usd,
        at: DateTime(2026, 7, 1),
      )!;
      expect(r.money.minor, 100);
    });

    test('flags dates before every known rate as approximated', () {
      final r = c.convert(
        const Money(100, Currency.usd),
        Currency.uzs,
        at: DateTime(2025, 1, 1),
      )!;
      expect(r.approximated, isTrue);
      expect(r.money.minor, 1200000);
    });

    test('latest rate is used when no date given', () {
      expect(
        c.convert(const Money(100, Currency.usd), Currency.uzs)!.money.minor,
        1260000,
      );
    });

    test('returns null without a rate instead of mixing currencies', () {
      final none = CurrencyConverter.empty;
      expect(
        none.convert(const Money(100, Currency.usd), Currency.uzs),
        isNull,
      );
      final mixed = MultiCurrencyAmount()
          .add(Currency.usd, 100)
          .add(Currency.uzs, 100);
      expect(none.convertTotal(mixed, Currency.uzs), isNull);
      expect(c.convertTotal(mixed, Currency.uzs)!.minor, 1260000 + 100);
    });
  });
}
