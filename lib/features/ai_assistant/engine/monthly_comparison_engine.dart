import '../../../core/money/money.dart';
import '../../../data/models/enums.dart';
import 'financial_snapshot.dart';
import 'findings.dart';

/// Compares the current month with the previous one fairly: month-to-date
/// against the same number of days at the start of last month.
class MonthlyComparisonEngine {
  const MonthlyComparisonEngine();

  Finding compare(FinancialSnapshot s) {
    final prev = s.lastMonthSamePeriod;
    final prevFull = s.lastMonth;
    if (s.ledger.count(null, prevFull) == 0) {
      return const InsufficientData(InsufficientScope.noPreviousMonth);
    }
    final cur = s.thisMonthToDate;
    return MonthComparison(
      currentExpense: s.ledger.total(TransactionType.expense, cur).money,
      previousExpense: s.ledger.total(TransactionType.expense, prev).money,
      currentIncome: s.ledger.total(TransactionType.income, cur).money,
      previousIncome: s.ledger.total(TransactionType.income, prev).money,
      days: cur.dayCount,
    );
  }

  /// Net savings of the current month (income − expense).
  Finding savingsRate(FinancialSnapshot s) {
    final m = s.thisMonth;
    if (s.ledger.count(null, m) == 0) {
      return const InsufficientData(InsufficientScope.noTransactions);
    }
    return SavingsRate(
      income: s.ledger.total(TransactionType.income, m).money,
      expense: s.ledger.total(TransactionType.expense, m).money,
      period: m,
    );
  }

  /// Full-month totals of the last [n] complete months (oldest first).
  List<Money> monthlyExpenses(FinancialSnapshot s, int n) => [
    for (final m in s.previousMonths(n))
      s.ledger.total(TransactionType.expense, m).money,
  ];
}
