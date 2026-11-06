import '../../../core/finance/budget_calculator.dart';
import '../../../core/finance/debt_calculator.dart';
import '../../../core/finance/ledger.dart';
import '../../../core/finance/savings_calculator.dart';
import '../../../core/money/currency.dart';
import '../../../core/utils/date_range.dart';
import '../../../data/local/app_database.dart';
import 'findings.dart';

/// Immutable view of the user's financial data that the assistant analyses.
/// Everything the assistant says is derived from this object – it has no
/// other data source, so it cannot invent records.
class FinancialSnapshot {
  FinancialSnapshot({
    required this.now,
    required this.currency,
    required this.ledger,
    required this.budgets,
    required this.goals,
    required this.debts,
    required this.categories,
    this.balance,
  });

  /// Current balance (opening balance + all-time income − expenses).
  final BalanceSummary? balance;

  final DateTime now;

  /// Display currency for all converted figures.
  final Currency currency;

  /// Transactions of (at least) the last [historyMonths] months.
  final Ledger ledger;
  final List<BudgetStatus> budgets;
  final List<SavingsProgress> goals;
  final List<DebtState> debts;
  final Map<int, CategoryRecord> categories;

  /// How many months of history the snapshot is expected to contain.
  static const historyMonths = 6;

  /// Window to load for a snapshot taken at [now].
  static DateRange windowFor(DateTime now) {
    final m = DateRange.month(now);
    return DateRange(
      DateTime(now.year, now.month - (historyMonths - 1)),
      m.end,
    );
  }

  DateRange get thisMonth => DateRange.month(now);
  DateRange get lastMonth => thisMonth.previous();

  /// Day 1 of this month up to and including today.
  DateRange get thisMonthToDate =>
      DateRange(thisMonth.start, DateTime(now.year, now.month, now.day + 1));

  /// The same number of days at the start of last month, for fair
  /// month-to-date comparisons.
  DateRange get lastMonthSamePeriod {
    final days = thisMonthToDate.dayCount;
    final end = DateTime(
      lastMonth.start.year,
      lastMonth.start.month,
      lastMonth.start.day + days,
    );
    return DateRange(
      lastMonth.start,
      end.isAfter(lastMonth.end) ? lastMonth.end : end,
    );
  }

  /// The [n] complete months before the current month (oldest first).
  List<DateRange> previousMonths(int n) => [
    for (var i = n; i >= 1; i--)
      DateRange.month(DateTime(now.year, now.month - i)),
  ];

  bool get hasAnyTransactions => !ledger.isEmpty;
}
