import 'package:flutter_test/flutter_test.dart';
import 'package:hisobai/core/finance/budget_calculator.dart';
import 'package:hisobai/core/finance/debt_calculator.dart';
import 'package:hisobai/core/finance/ledger.dart';
import 'package:hisobai/core/finance/recurrence_scheduler.dart';
import 'package:hisobai/core/finance/savings_calculator.dart';
import 'package:hisobai/core/money/currency.dart';
import 'package:hisobai/core/money/currency_converter.dart';
import 'package:hisobai/core/utils/date_range.dart';
import 'package:hisobai/data/local/app_database.dart';
import 'package:hisobai/data/models/enums.dart';

import '../helpers.dart';

void main() {
  final nov = DateRange.month(DateTime(2026, 11));
  final rate = CurrencyConverter([
    ExchangeRateQuote(
      base: Currency.usd,
      quote: Currency.uzs,
      rate: 12500,
      source: 'manual',
      effectiveDate: DateTime(2026, 1, 1),
    ),
  ]);

  group('Ledger', () {
    final txs = [
      tx(
        amount: m(1000000),
        type: TransactionType.income,
        date: DateTime(2026, 11, 1),
        categoryId: 20,
      ),
      tx(amount: m(200000), date: DateTime(2026, 11, 2), categoryId: 1),
      tx(amount: m(100000), date: DateTime(2026, 11, 2), categoryId: 2),
      tx(amount: m(50000), date: DateTime(2026, 11, 5), categoryId: 1),
      tx(
        amount: m(999999),
        date: DateTime(2026, 10, 30),
        categoryId: 1,
      ), // outside range
    ];
    final ledger = Ledger(txs, Currency.uzs, CurrencyConverter.empty);

    test('income, expense and net per period', () {
      expect(ledger.total(TransactionType.income, nov).minor, m(1000000));
      expect(ledger.total(TransactionType.expense, nov).minor, m(350000));
      expect(ledger.net(nov).minor, m(650000));
    });

    test('category breakdown sorted with shares', () {
      final shares = ledger.byCategory(TransactionType.expense, nov);
      expect(shares.first.categoryId, 1);
      expect(shares.first.minor, m(250000));
      expect(shares.first.share, closeTo(250 / 350, 1e-9));
      expect(shares.first.count, 2);
    });

    test('daily series has one value per day', () {
      final week = DateRange.days(DateTime(2026, 11, 1), DateTime(2026, 11, 7));
      final daily = ledger.daily(TransactionType.expense, week);
      expect(daily.length, 7);
      expect(daily[1], m(300000));
      expect(daily[4], m(50000));
    });

    test('highest and lowest expense', () {
      expect(
        ledger
            .extreme(TransactionType.expense, highest: true, range: nov)!
            .amountMinor,
        m(200000),
      );
      expect(
        ledger
            .extreme(TransactionType.expense, highest: false, range: nov)!
            .amountMinor,
        m(50000),
      );
    });

    test('foreign currency without rate is reported, not mixed', () {
      final l = Ledger(
        [
          tx(amount: m(100000), date: DateTime(2026, 11, 3)),
          tx(
            amount: m(10),
            currency: Currency.usd,
            date: DateTime(2026, 11, 3),
          ),
        ],
        Currency.uzs,
        CurrencyConverter.empty,
      );
      final sum = l.total(TransactionType.expense, nov);
      expect(sum.minor, m(100000));
      expect(sum.unconverted.minorOf(Currency.usd), m(10));
      expect(sum.isComplete, isFalse);
    });

    test('foreign currency with rate is converted at the transaction date', () {
      final l = Ledger(
        [
          tx(amount: m(100000), date: DateTime(2026, 11, 3)),
          tx(
            amount: m(10),
            currency: Currency.usd,
            date: DateTime(2026, 11, 3),
          ),
        ],
        Currency.uzs,
        rate,
      );
      final sum = l.total(TransactionType.expense, nov);
      expect(sum.minor, m(100000 + 125000));
      expect(sum.isComplete, isTrue);
    });
  });

  group('BudgetCalculator', () {
    BudgetRecord budget(int limit, {int? categoryId}) => BudgetRecord(
      id: categoryId ?? 0,
      categoryId: categoryId,
      limitMinor: limit,
      currency: Currency.uzs,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    test('example from the spec: 5 000 000 limit, 3 200 000 spent', () {
      final s = const BudgetCalculator()
          .evaluate(
            budgets: [budget(m(5000000))],
            transactions: [
              tx(amount: m(3200000), date: DateTime(2026, 11, 10)),
            ],
            converter: CurrencyConverter.empty,
            month: nov,
          )
          .single;
      expect(s.spent, m(3200000));
      expect(s.remaining, m(1800000));
      expect((s.ratio * 100).round(), 64);
      expect(s.level, BudgetLevel.ok);
    });

    test('threshold levels', () {
      const t = BudgetThresholds(warning: 0.75, critical: 0.9);
      expect(BudgetCalculator.levelFor(0.74, t), BudgetLevel.ok);
      expect(BudgetCalculator.levelFor(0.75, t), BudgetLevel.warning);
      expect(BudgetCalculator.levelFor(0.9, t), BudgetLevel.critical);
      expect(BudgetCalculator.levelFor(1.0, t), BudgetLevel.exceeded);
      expect(BudgetCalculator.levelFor(1.3, t), BudgetLevel.exceeded);
      const custom = BudgetThresholds(warning: 0.5, critical: 0.6);
      expect(BudgetCalculator.levelFor(0.55, custom), BudgetLevel.warning);
    });

    test('category budgets only count their category', () {
      final s = const BudgetCalculator()
          .evaluate(
            budgets: [budget(m(100000), categoryId: 1)],
            transactions: [
              tx(amount: m(80000), date: DateTime(2026, 11, 3), categoryId: 1),
              tx(amount: m(500000), date: DateTime(2026, 11, 3), categoryId: 2),
            ],
            converter: CurrencyConverter.empty,
            month: nov,
          )
          .single;
      expect(s.spent, m(80000));
      expect(s.level, BudgetLevel.warning);
    });
  });

  group('Savings and debts', () {
    final goal = SavingsGoalRecord(
      id: 'g',
      name: 'Laptop',
      targetMinor: m(10000000),
      currency: Currency.uzs,
      iconKey: 'laptop',
      color: 0,
      targetDate: DateTime(2027, 5, 1),
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    SavingsEntryRecord entry(int v) => SavingsEntryRecord(
      id: '$v',
      goalId: 'g',
      amountMinor: v,
      date: DateTime(2026, 11),
      createdAt: DateTime(2026, 11),
    );

    test('saved amount is the sum of deposits and withdrawals', () {
      final p = SavingsProgress(goal, [
        entry(m(3000000)),
        entry(m(1000000)),
        entry(-m(500000)),
      ]);
      expect(p.savedMinor, m(3500000));
      expect(p.remainingMinor, m(6500000));
      expect(p.ratio, closeTo(0.35, 1e-9));
      expect(SavingsCalculator.canWithdraw(p, m(3500000)), isTrue);
      expect(SavingsCalculator.canWithdraw(p, m(3500001)), isFalse);
      expect(p.monthlyNeeded(DateTime(2026, 11, 6)), (m(6500000) / 6).ceil());
    });

    DebtRecord debt(DebtDirection d, int original, {DateTime? due}) =>
        DebtRecord(
          id: '$d$original',
          direction: d,
          counterparty: 'Ali',
          originalMinor: original,
          currency: Currency.uzs,
          startDate: DateTime(2026, 10),
          dueDate: due,
          createdAt: DateTime(2026, 10),
          updatedAt: DateTime(2026, 10),
        );
    DebtPaymentRecord pay(int v) => DebtPaymentRecord(
      id: '$v',
      debtId: 'x',
      amountMinor: v,
      date: DateTime(2026, 11),
      createdAt: DateTime(2026, 11),
    );

    test('partial repayments reduce remaining; status derived', () {
      final s = DebtState(
        debt(DebtDirection.iOwe, m(1000000), due: DateTime(2026, 11, 1)),
        [pay(m(400000))],
      );
      expect(s.remainingMinor, m(600000));
      expect(s.statusAt(DateTime(2026, 11, 6)), DebtStatus.overdue);
      expect(DebtCalculator.isValidRepayment(s, m(600000)), isTrue);
      expect(DebtCalculator.isValidRepayment(s, m(600001)), isFalse);
      final done = DebtState(debt(DebtDirection.iOwe, m(1000000)), [
        pay(m(1000000)),
      ]);
      expect(done.statusAt(DateTime(2026, 11, 6)), DebtStatus.completed);
    });

    test('totals split owed and receivable', () {
      final t = DebtCalculator.totals([
        DebtState(debt(DebtDirection.iOwe, m(100)), const []),
        DebtState(debt(DebtDirection.owedToMe, m(300)), [pay(m(100))]),
      ]);
      expect(t.iOwe.minorOf(Currency.uzs), m(100));
      expect(t.owedToMe.minorOf(Currency.uzs), m(200));
    });
  });

  group('RecurrenceScheduler', () {
    const s = RecurrenceScheduler();

    test('monthly on the 31st clamps to month end without drifting', () {
      final start = DateTime(2026, 1, 31);
      expect(
        s.occurrence(start, RecurrenceFrequency.monthly, 1),
        DateTime(2026, 2, 28),
      );
      expect(
        s.occurrence(start, RecurrenceFrequency.monthly, 2),
        DateTime(2026, 3, 31),
      );
      expect(
        s.occurrence(start, RecurrenceFrequency.monthly, 3),
        DateTime(2026, 4, 30),
      );
    });

    test('occurrencesBetween respects end date and after', () {
      final dates = s.occurrencesBetween(
        start: DateTime(2026, 11, 1),
        frequency: RecurrenceFrequency.weekly,
        end: DateTime(2026, 11, 20),
        after: DateTime(2026, 11, 1),
        until: DateTime(2026, 12, 31),
      );
      expect(dates, [DateTime(2026, 11, 8), DateTime(2026, 11, 15)]);
    });

    test('yearly and daily schedules', () {
      expect(
        s.occurrence(DateTime(2024, 2, 29), RecurrenceFrequency.yearly, 1),
        DateTime(2025, 2, 28),
      );
      expect(
        s.nextAfter(
          start: DateTime(2026, 1, 1),
          frequency: RecurrenceFrequency.daily,
          after: DateTime(2026, 3, 10),
        ),
        DateTime(2026, 3, 11),
      );
      expect(
        s.nextAfter(
          start: DateTime(2026, 1, 1),
          frequency: RecurrenceFrequency.monthly,
          end: DateTime(2026, 2, 15),
          after: DateTime(2026, 2, 1),
        ),
        isNull,
      );
    });

    test('occurrence keys are stable per date', () {
      expect(
        RecurrenceScheduler.occurrenceKey('r1', DateTime(2026, 3, 5, 14)),
        'r1@2026-03-05',
      );
    });
  });
}
