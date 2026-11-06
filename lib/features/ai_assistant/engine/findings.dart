import '../../../core/finance/budget_calculator.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/date_range.dart';

/// Structured analysis results. Findings carry numbers only; turning them
/// into language is the job of [AIResponseGenerator], which keeps the
/// analysis independent from wording and language.
sealed class Finding {
  const Finding();
}

/// Not enough recorded data to answer reliably.
class InsufficientData extends Finding {
  const InsufficientData(this.scope);
  final InsufficientScope scope;
}

enum InsufficientScope {
  noTransactions,
  noExpensesInPeriod,
  noIncomeInPeriod,
  noPreviousMonth,
  noBudgets,
  noGoals,
  noDebts,
}

class TopCategory extends Finding {
  const TopCategory({
    required this.categoryId,
    required this.amount,
    required this.share,
    required this.total,
    required this.period,
    required this.runnersUp,
  });

  final int categoryId;
  final Money amount;
  final double share;
  final Money total;
  final DateRange period;

  /// Next categories with their shares (max 2).
  final List<(int, double)> runnersUp;
}

class PeriodTotal extends Finding {
  const PeriodTotal({
    required this.expense,
    required this.income,
    required this.period,
    required this.count,
    this.incomplete = false,
  });
  final Money expense;
  final Money income;
  final DateRange period;
  final int count;

  /// Some amounts lacked an exchange rate and were left out.
  final bool incomplete;

  Money get net => income - expense;
}

class CategorySpend extends Finding {
  const CategorySpend({
    required this.categoryId,
    required this.amount,
    required this.share,
    required this.count,
    required this.period,
  });
  final int categoryId;
  final Money amount;
  final double share;
  final int count;
  final DateRange period;
}

/// Month-to-date comparison against the same days of last month.
class MonthComparison extends Finding {
  const MonthComparison({
    required this.currentExpense,
    required this.previousExpense,
    required this.currentIncome,
    required this.previousIncome,
    required this.days,
  });

  final Money currentExpense;
  final Money previousExpense;
  final Money currentIncome;
  final Money previousIncome;
  final int days;

  /// Relative change of expenses, null when last month had none.
  double? get expenseChange => previousExpense.minor == 0
      ? null
      : (currentExpense.minor - previousExpense.minor) / previousExpense.minor;
  double? get incomeChange => previousIncome.minor == 0
      ? null
      : (currentIncome.minor - previousIncome.minor) / previousIncome.minor;
}

class CategoryIncrease extends Finding {
  const CategoryIncrease({
    required this.categoryId,
    required this.current,
    required this.baseline,
    required this.ratio,
  });
  final int categoryId;
  final Money current;

  /// Average of previous months over the same number of days.
  final Money baseline;
  final double ratio;
}

/// Category whose spending rose for consecutive months.
class RisingTrend extends Finding {
  const RisingTrend({required this.categoryId, required this.months});
  final int categoryId;
  final List<Money> months;
}

class SavingsRate extends Finding {
  const SavingsRate({
    required this.income,
    required this.expense,
    required this.period,
  });
  final Money income;
  final Money expense;
  final DateRange period;
  Money get net => income - expense;
  double? get rate => income.minor <= 0 ? null : net.minor / income.minor;
}

class BudgetAlert extends Finding {
  const BudgetAlert(this.status);
  final BudgetStatus status;
}

class BudgetOk extends Finding {
  const BudgetOk(this.status, this.daysLeft);
  final BudgetStatus status;
  final int daysLeft;

  /// Remaining amount that can be spent per day for the rest of the month.
  int get dailyAllowance =>
      daysLeft <= 0 ? 0 : (status.remaining / daysLeft).floor();
}

/// Suggests a category limit based on recent average spending.
class BudgetSuggestion extends Finding {
  const BudgetSuggestion({
    required this.categoryId,
    required this.average,
    required this.suggested,
  });
  final int categoryId;
  final Money average;
  final Money suggested;
}

class GoalProgress extends Finding {
  const GoalProgress({
    required this.name,
    required this.ratio,
    required this.remaining,
    this.monthlyNeeded,
  });
  final String name;
  final double ratio;
  final Money remaining;
  final Money? monthlyNeeded;
}

class DebtOverview extends Finding {
  const DebtOverview({
    required this.iOwe,
    required this.owedToMe,
    required this.overdue,
    required this.active,
  });
  final List<Money> iOwe;
  final List<Money> owedToMe;
  final int overdue;
  final int active;
}

class LargestExpense extends Finding {
  const LargestExpense({
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
  });
  final String title;
  final Money amount;
  final DateTime date;
  final int categoryId;
}

class BalanceSummary extends Finding {
  const BalanceSummary(this.parts, this.converted);
  final List<Money> parts;
  final Money? converted;
}
