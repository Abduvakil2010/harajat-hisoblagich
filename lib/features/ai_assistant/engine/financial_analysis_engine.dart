import '../../../core/finance/budget_calculator.dart';
import 'budget_recommendation_engine.dart';
import 'financial_snapshot.dart';
import 'findings.dart';
import 'monthly_comparison_engine.dart';
import 'spending_pattern_analyzer.dart';

/// Facade over the analysers. Produces prioritised findings for the
/// dashboard and assistant. Pure Dart – no Flutter, no I/O.
class FinancialAnalysisEngine {
  const FinancialAnalysisEngine({
    this.patterns = const SpendingPatternAnalyzer(),
    this.comparison = const MonthlyComparisonEngine(),
    this.recommendations = const BudgetRecommendationEngine(),
  });

  final SpendingPatternAnalyzer patterns;
  final MonthlyComparisonEngine comparison;
  final BudgetRecommendationEngine recommendations;

  /// Short insights for the home dashboard. Returns an empty list when
  /// there is not enough data – the UI then shows guidance instead of
  /// potentially misleading statements.
  List<Finding> dashboardInsights(FinancialSnapshot s, {int max = 3}) {
    if (!s.hasAnyTransactions) return const [];
    final out = <Finding>[];

    // 1. Budget alerts are the most actionable.
    for (final f in recommendations.budgetFindings(s)) {
      if (f is BudgetAlert) out.add(f);
    }
    // 2. Unusual category increases.
    out.addAll(patterns.unusualIncreases(s).take(2));
    // 3. Month-to-date spending compared to last month.
    final cmp = comparison.compare(s);
    if (cmp is MonthComparison &&
        cmp.expenseChange != null &&
        cmp.expenseChange!.abs() >= 0.1) {
      out.add(cmp);
    }
    // 4. Rising multi-month trends.
    out.addAll(patterns.risingTrends(s).take(1));
    // 5. Positive reinforcement: within total budget.
    final total = s.budgets.where((b) => b.isTotal).firstOrNull;
    if (total != null &&
        total.level == BudgetLevel.ok &&
        s.ledger.count(null, s.thisMonth) > 0) {
      out.add(
        BudgetOk(
          total,
          s.thisMonth.end
              .difference(DateTime(s.now.year, s.now.month, s.now.day))
              .inDays,
        ),
      );
    }
    // 6. Goals close to completion (≥ 75 %).
    for (final g in recommendations.goalFindings(s)) {
      if (g is GoalProgress && g.ratio >= 0.75 && g.ratio < 1) out.add(g);
    }
    // 7. Top category this month (only with a meaningful number of records).
    if (s.ledger.count(null, s.thisMonth) >= 3) {
      final top = patterns.topCategory(s, s.thisMonth);
      if (top is TopCategory) out.add(top);
    }
    return out.take(max).toList();
  }
}
