import '../../../core/finance/budget_calculator.dart';
import '../../../core/finance/debt_calculator.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../data/models/enums.dart';
import 'financial_snapshot.dart';
import 'findings.dart';

/// Evaluates budgets, goals and debts, and proposes practical limits.
class BudgetRecommendationEngine {
  const BudgetRecommendationEngine();

  /// Alerts for budgets past their warning threshold, most severe first.
  List<Finding> budgetFindings(FinancialSnapshot s) {
    if (s.budgets.isEmpty) {
      return const [InsufficientData(InsufficientScope.noBudgets)];
    }
    final daysLeft = s.thisMonth.end
        .difference(DateTime(s.now.year, s.now.month, s.now.day))
        .inDays;
    return [
      for (final b in s.budgets)
        if (b.level == BudgetLevel.ok)
          BudgetOk(b, daysLeft)
        else
          BudgetAlert(b),
    ]..sort((a, b) => _severity(b).compareTo(_severity(a)));
  }

  static int _severity(Finding f) => switch (f) {
    BudgetAlert(:final status) => 10 + status.level.index,
    BudgetOk(:final status) => status.isTotal ? 1 : 0,
    _ => -1,
  };

  /// Suggests limits for the biggest categories that have no budget yet,
  /// using the average of the last 3 complete months, rounded to a friendly
  /// number and trimmed by 10 % as a gentle saving target.
  List<BudgetSuggestion> suggestions(FinancialSnapshot s, {int max = 2}) {
    final months = s
        .previousMonths(3)
        .where((m) => s.ledger.count(TransactionType.expense, m) > 0)
        .toList();
    if (months.isEmpty) return const [];
    final budgeted = {for (final b in s.budgets) b.budget.categoryId};
    final totals = <int, int>{};
    for (final m in months) {
      for (final c in s.ledger.byCategory(TransactionType.expense, m)) {
        totals[c.categoryId] = (totals[c.categoryId] ?? 0) + c.minor;
      }
    }
    final sorted =
        totals.entries.where((e) => !budgeted.contains(e.key)).toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in sorted.take(max))
        () {
          final avg = (e.value / months.length).round();
          return BudgetSuggestion(
            categoryId: e.key,
            average: Money(avg, s.currency),
            suggested: Money(
              roundFriendly((avg * 0.9).round(), s.currency),
              s.currency,
            ),
          );
        }(),
    ];
  }

  /// Rounds minor units to a "nice" number (e.g. 1 234 567 → 1 250 000).
  static int roundFriendly(int minor, Currency c) {
    final major = minor / c.minorFactor;
    double step;
    if (major >= 1000000) {
      step = 50000;
    } else if (major >= 100000) {
      step = 10000;
    } else if (major >= 10000) {
      step = 1000;
    } else if (major >= 1000) {
      step = 100;
    } else if (major >= 100) {
      step = 10;
    } else {
      step = 1;
    }
    final rounded = (major / step).round() * step;
    return (rounded * c.minorFactor).round();
  }

  List<Finding> goalFindings(FinancialSnapshot s) {
    final active = s.goals.where((g) => !g.isCompleted).toList();
    if (active.isEmpty) {
      return const [InsufficientData(InsufficientScope.noGoals)];
    }
    active.sort((a, b) => b.ratio.compareTo(a.ratio));
    return [
      for (final g in active)
        GoalProgress(
          name: g.goal.name,
          ratio: g.ratio,
          remaining: g.remaining,
          monthlyNeeded: g.monthlyNeeded(s.now) == null
              ? null
              : Money(g.monthlyNeeded(s.now)!, g.goal.currency),
        ),
    ];
  }

  Finding debtFinding(FinancialSnapshot s) {
    if (s.debts.isEmpty) {
      return const InsufficientData(InsufficientScope.noDebts);
    }
    final totals = DebtCalculator.totals(s.debts);
    final statuses = s.debts.map((d) => d.statusAt(s.now)).toList();
    return DebtOverview(
      iOwe: totals.iOwe.toMoneyList(),
      owedToMe: totals.owedToMe.toMoneyList(),
      overdue: statuses.where((x) => x == DebtStatus.overdue).length,
      active: statuses.where((x) => x != DebtStatus.completed).length,
    );
  }
}
