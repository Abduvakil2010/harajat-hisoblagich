import '../../data/local/app_database.dart';
import '../../data/models/enums.dart';
import '../money/currency_converter.dart';
import '../money/money.dart';
import '../utils/date_range.dart';
import 'ledger.dart';

/// User-configurable warning thresholds (fractions of the limit).
class BudgetThresholds {
  const BudgetThresholds({this.warning = 0.75, this.critical = 0.90});

  final double warning;
  final double critical;
}

enum BudgetLevel { ok, warning, critical, exceeded }

class BudgetStatus {
  const BudgetStatus({
    required this.budget,
    required this.spent,
    required this.level,
    required this.unconverted,
  });

  final BudgetRecord budget;

  /// Spending in the budget's currency.
  final int spent;
  final BudgetLevel level;

  /// Spending that could not be converted into the budget currency.
  final MultiCurrencyAmount unconverted;

  int get limit => budget.limitMinor;
  int get remaining => limit - spent;
  Money get limitMoney => Money(limit, budget.currency);
  Money get spentMoney => Money(spent, budget.currency);
  Money get remainingMoney => Money(remaining, budget.currency);

  /// Fraction used, may exceed 1.
  double get ratio => limit <= 0 ? 0 : spent / limit;
  bool get isTotal => budget.categoryId == null;
}

class BudgetCalculator {
  const BudgetCalculator();

  static BudgetLevel levelFor(double ratio, BudgetThresholds t) {
    if (ratio >= 1.0) return BudgetLevel.exceeded;
    if (ratio >= t.critical) return BudgetLevel.critical;
    if (ratio >= t.warning) return BudgetLevel.warning;
    return BudgetLevel.ok;
  }

  /// Evaluates each budget against expenses inside [month].
  List<BudgetStatus> evaluate({
    required List<BudgetRecord> budgets,
    required List<TransactionRecord> transactions,
    required CurrencyConverter converter,
    required DateRange month,
    BudgetThresholds thresholds = const BudgetThresholds(),
  }) {
    final ledgers = <Object, Ledger>{};
    final result = <BudgetStatus>[];
    for (final b in budgets) {
      final ledger = ledgers.putIfAbsent(
        b.currency,
        () => Ledger(transactions, b.currency, converter),
      );
      int spent;
      MultiCurrencyAmount missing;
      if (b.categoryId == null) {
        final sum = ledger.total(TransactionType.expense, month);
        spent = sum.minor;
        missing = sum.unconverted;
      } else {
        spent = ledger.categoryTotal(
          b.categoryId!,
          TransactionType.expense,
          month,
        );
        missing = MultiCurrencyAmount();
        for (final t in transactions) {
          if (t.type == TransactionType.expense &&
              t.categoryId == b.categoryId &&
              month.contains(t.date) &&
              ledger.valueOf(t) == null) {
            missing = missing.add(t.currency, t.amountMinor);
          }
        }
      }
      final ratio = b.limitMinor <= 0 ? 0.0 : spent / b.limitMinor;
      result.add(
        BudgetStatus(
          budget: b,
          spent: spent,
          level: levelFor(ratio, thresholds),
          unconverted: missing,
        ),
      );
    }
    result.sort((a, b) {
      if (a.isTotal != b.isTotal) return a.isTotal ? -1 : 1;
      return b.ratio.compareTo(a.ratio);
    });
    return result;
  }
}
