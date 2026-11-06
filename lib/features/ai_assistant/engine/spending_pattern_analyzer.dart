import '../../../core/money/money.dart';
import '../../../core/utils/date_range.dart';
import '../../../data/models/enums.dart';
import 'financial_snapshot.dart';
import 'findings.dart';

/// Detects where money goes and how spending patterns change.
class SpendingPatternAnalyzer {
  const SpendingPatternAnalyzer({
    this.increaseRatio = 1.4,
    this.minIncreaseShare = 0.05,
  });

  /// A category counts as an unusual increase when it is at least this many
  /// times its baseline...
  final double increaseRatio;

  /// ...and represents at least this share of the period's spending.
  final double minIncreaseShare;

  Finding topCategory(FinancialSnapshot s, DateRange period) {
    final shares = s.ledger.byCategory(TransactionType.expense, period);
    if (shares.isEmpty) {
      return const InsufficientData(InsufficientScope.noExpensesInPeriod);
    }
    final total = shares.fold<int>(0, (a, b) => a + b.minor);
    final top = shares.first;
    return TopCategory(
      categoryId: top.categoryId,
      amount: Money(top.minor, s.currency),
      share: top.share,
      total: Money(total, s.currency),
      period: period,
      runnersUp: [
        for (final c in shares.skip(1).take(2)) (c.categoryId, c.share),
      ],
    );
  }

  Finding periodTotal(FinancialSnapshot s, DateRange period) {
    final count = s.ledger.count(null, period);
    if (count == 0) {
      return const InsufficientData(InsufficientScope.noTransactions);
    }
    final e = s.ledger.total(TransactionType.expense, period);
    final i = s.ledger.total(TransactionType.income, period);
    return PeriodTotal(
      expense: e.money,
      income: i.money,
      period: period,
      count: count,
      incomplete: !e.isComplete || !i.isComplete,
    );
  }

  Finding categorySpend(FinancialSnapshot s, int categoryId, DateRange period) {
    final shares = s.ledger.byCategory(TransactionType.expense, period);
    final match = shares.where((c) => c.categoryId == categoryId).firstOrNull;
    if (match == null) {
      return CategorySpend(
        categoryId: categoryId,
        amount: Money.zero(s.currency),
        share: 0,
        count: 0,
        period: period,
      );
    }
    return CategorySpend(
      categoryId: categoryId,
      amount: Money(match.minor, s.currency),
      share: match.share,
      count: match.count,
      period: period,
    );
  }

  /// Categories whose month-to-date spending is well above the average of the
  /// same days in the previous (up to 3) months.
  List<CategoryIncrease> unusualIncreases(FinancialSnapshot s) {
    final current = s.thisMonthToDate;
    final days = current.dayCount;
    final baselines = <DateRange>[
      for (final m in s.previousMonths(3))
        DateRange(
          m.start,
          _minDate(
            DateTime(m.start.year, m.start.month, m.start.day + days),
            m.end,
          ),
        ),
    ].where((r) => s.ledger.count(TransactionType.expense, r) > 0).toList();
    if (baselines.isEmpty) return const [];

    final currentShares = s.ledger.byCategory(TransactionType.expense, current);
    final total = currentShares.fold<int>(0, (a, b) => a + b.minor);
    final result = <CategoryIncrease>[];
    for (final c in currentShares) {
      if (total == 0 || c.minor / total < minIncreaseShare) continue;
      final base =
          baselines
              .map(
                (r) => s.ledger.categoryTotal(
                  c.categoryId,
                  TransactionType.expense,
                  r,
                ),
              )
              .fold<int>(0, (a, b) => a + b) /
          baselines.length;
      if (base <= 0) continue;
      final ratio = c.minor / base;
      if (ratio >= increaseRatio) {
        result.add(
          CategoryIncrease(
            categoryId: c.categoryId,
            current: Money(c.minor, s.currency),
            baseline: Money(base.round(), s.currency),
            ratio: ratio,
          ),
        );
      }
    }
    result.sort((a, b) => b.ratio.compareTo(a.ratio));
    return result;
  }

  /// Categories whose spending grew in each of the last 3 complete months.
  List<RisingTrend> risingTrends(FinancialSnapshot s) {
    final months = s.previousMonths(3);
    if (months.any((m) => s.ledger.count(TransactionType.expense, m) == 0)) {
      return const [];
    }
    final result = <RisingTrend>[];
    final ids = {
      for (final m in months)
        for (final c in s.ledger.byCategory(TransactionType.expense, m))
          c.categoryId,
    };
    for (final id in ids) {
      final values = [
        for (final m in months)
          s.ledger.categoryTotal(id, TransactionType.expense, m),
      ];
      final rising =
          values[0] > 0 && values[1] > values[0] && values[2] > values[1];
      if (rising && values[2] >= values[0] * 1.15) {
        result.add(
          RisingTrend(
            categoryId: id,
            months: [for (final v in values) Money(v, s.currency)],
          ),
        );
      }
    }
    return result;
  }

  Finding largestExpense(FinancialSnapshot s, DateRange period) {
    final tx = s.ledger.extreme(
      TransactionType.expense,
      highest: true,
      range: period,
    );
    if (tx == null) {
      return const InsufficientData(InsufficientScope.noExpensesInPeriod);
    }
    return LargestExpense(
      title: tx.title,
      amount: Money(s.ledger.valueOf(tx) ?? 0, s.currency),
      date: tx.date,
      categoryId: tx.categoryId,
    );
  }

  static DateTime _minDate(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
}
