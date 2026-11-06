import '../../../core/finance/budget_calculator.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/money.dart';
import '../../../core/money/money_format.dart';
import '../../../core/utils/date_range.dart';
import '../../../data/local/app_database.dart';
import 'findings.dart';

/// Renders [Finding]s as natural language in the app's current language.
///
/// All numbers come from the findings; this class only chooses wording.
class AIResponseGenerator {
  AIResponseGenerator(this.l, this.categories, {DateTime? now})
    : _fmt = MoneyFormat(l.localeName),
      _now = now ?? DateTime.now();

  final AppLocalizations l;
  final Map<int, CategoryRecord> categories;
  final MoneyFormat _fmt;
  final DateTime _now;

  String money(Money m) => _fmt.format(m);
  String _pct(double ratio) => '${(ratio * 100).round()}';
  String _cat(int id) => l.categoryName(categories[id]);

  String period(DateRange r) {
    final thisMonth = DateRange.month(_now);
    if (r.start == thisMonth.start) return l.periodThisMonth;
    if (r.start == thisMonth.previous().start) return l.periodLastMonth;
    return Dates(l.localeName).month(r.start);
  }

  String budgetName(BudgetStatus s) =>
      s.isTotal ? l.monthlyBudget : _cat(s.budget.categoryId!);

  /// One concise sentence per finding (used for dashboard insights and as
  /// building blocks of chat answers). Sentences may start with a period
  /// placeholder ("shu oyda …"), so the first letter is capitalised.
  String render(Finding f) => _capitalize(_render(f));

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _render(Finding f) => switch (f) {
    InsufficientData(:final scope) => switch (scope) {
      InsufficientScope.noTransactions => l.aiNoTransactions,
      InsufficientScope.noExpensesInPeriod => l.aiNoExpenses,
      InsufficientScope.noIncomeInPeriod => l.aiNoIncome,
      InsufficientScope.noPreviousMonth => l.aiNoPreviousMonth,
      InsufficientScope.noBudgets => l.aiNoBudgets,
      InsufficientScope.noGoals => l.aiNoGoals,
      InsufficientScope.noDebts => l.aiNoDebts,
    },
    TopCategory() => l.aiTopCategory(
      period(f.period),
      _cat(f.categoryId),
      money(f.amount),
      _pct(f.share),
    ),
    PeriodTotal() => l.aiPeriodTotal(
      period(f.period),
      money(f.expense),
      money(f.income),
      f.count,
    ),
    CategorySpend() =>
      f.count == 0
          ? l.aiCategorySpendNone(_cat(f.categoryId), period(f.period))
          : l.aiCategorySpend(
              _cat(f.categoryId),
              period(f.period),
              money(f.amount),
              _pct(f.share),
              f.count,
            ),
    MonthComparison() => _comparison(f),
    CategoryIncrease() => l.aiCategoryIncrease(
      _cat(f.categoryId),
      _pct(f.ratio - 1),
      money(f.current),
      money(f.baseline),
    ),
    RisingTrend() => l.aiRisingTrend(_cat(f.categoryId)),
    SavingsRate() =>
      f.net.isNegative
          ? l.aiOverspent(period(f.period), money(f.net.abs()))
          : l.aiSaved(period(f.period), money(f.net)) +
                (f.rate == null ? '' : ' ${l.aiSavingsRate(_pct(f.rate!))}'),
    BudgetAlert(:final status) => switch (status.level) {
      BudgetLevel.exceeded => l.aiBudgetExceeded(
        budgetName(status),
        _pct(status.ratio),
        money(status.remainingMoney.abs()),
      ),
      BudgetLevel.critical => l.aiBudgetCritical(
        budgetName(status),
        _pct(status.ratio),
        money(status.remainingMoney),
      ),
      _ => l.aiBudgetWarning(
        budgetName(status),
        _pct(status.ratio),
        money(status.remainingMoney),
      ),
    },
    BudgetOk() => l.aiBudgetOk(
      budgetName(f.status),
      _pct(f.status.ratio),
      money(f.status.remainingMoney),
      money(Money(f.dailyAllowance, f.status.budget.currency)),
    ),
    BudgetSuggestion() => l.aiSuggestLimit(
      _cat(f.categoryId),
      money(f.average),
      money(f.suggested),
    ),
    GoalProgress() =>
      l.aiGoalProgress(f.name, _pct(f.ratio), money(f.remaining)) +
          (f.monthlyNeeded == null
              ? ''
              : ' ${l.aiGoalMonthly(money(f.monthlyNeeded!))}'),
    DebtOverview() =>
      l.aiDebtOverview(
            f.iOwe.isEmpty ? '0' : f.iOwe.map(money).join(' + '),
            f.owedToMe.isEmpty ? '0' : f.owedToMe.map(money).join(' + '),
            f.active,
          ) +
          (f.overdue > 0 ? ' ${l.aiDebtOverdue(f.overdue)}' : ''),
    LargestExpense() => l.aiLargestExpense(
      f.title,
      money(f.amount),
      Dates(l.localeName).day(f.date),
      _cat(f.categoryId),
    ),
    BalanceSummary() =>
      f.converted != null
          ? l.aiBalance(money(f.converted!))
          : l.aiBalanceSeparate(f.parts.map(money).join(', ')),
  };

  String _comparison(MonthComparison f) {
    final change = f.expenseChange;
    if (change == null) {
      return l.aiCompareNoPrevExpense(f.days, money(f.currentExpense));
    }
    if (change.abs() < 0.05) {
      return l.aiCompareSame(
        f.days,
        money(f.currentExpense),
        money(f.previousExpense),
      );
    }
    return change > 0
        ? l.aiCompareMore(
            f.days,
            money(f.currentExpense),
            _pct(change),
            money(f.previousExpense),
          )
        : l.aiCompareLess(
            f.days,
            money(f.currentExpense),
            _pct(-change),
            money(f.previousExpense),
          );
  }
}
