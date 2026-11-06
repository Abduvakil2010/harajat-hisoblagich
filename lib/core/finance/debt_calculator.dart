import '../../data/local/app_database.dart';
import '../../data/models/enums.dart';
import '../money/money.dart';
import '../utils/date_range.dart';

/// Derived state of a debt.
///
/// ## Accounting behaviour
/// Debts are a separate ledger. Creating a debt or recording a repayment does
/// **not** create income or expense transactions and never changes the cash
/// balance or statistics. The dashboard shows debts as separate totals
/// ("I owe" / "Owed to me").
class DebtState {
  const DebtState(this.debt, this.payments);

  final DebtRecord debt;
  final List<DebtPaymentRecord> payments;

  int get paidMinor => payments.fold<int>(0, (a, p) => a + p.amountMinor);
  int get remainingMinor {
    final r = debt.originalMinor - paidMinor;
    return r < 0 ? 0 : r;
  }

  double get ratioPaid => debt.originalMinor <= 0
      ? 0
      : (paidMinor / debt.originalMinor).clamp(0, 1);

  Money get original => Money(debt.originalMinor, debt.currency);
  Money get remaining => Money(remainingMinor, debt.currency);
  Money get paid => Money(paidMinor, debt.currency);

  DebtStatus statusAt(DateTime now) {
    if (remainingMinor == 0) return DebtStatus.completed;
    final due = debt.dueDate;
    if (due != null && due.dateOnly.isBefore(now.dateOnly)) {
      return DebtStatus.overdue;
    }
    return DebtStatus.active;
  }
}

class DebtTotals {
  const DebtTotals(this.iOwe, this.owedToMe);
  final MultiCurrencyAmount iOwe;
  final MultiCurrencyAmount owedToMe;
}

class DebtCalculator {
  const DebtCalculator();

  /// A repayment must be positive and not exceed the remaining balance.
  static bool isValidRepayment(DebtState s, int amountMinor) =>
      amountMinor > 0 && amountMinor <= s.remainingMinor;

  static DebtTotals totals(Iterable<DebtState> debts) {
    var owe = MultiCurrencyAmount();
    var owed = MultiCurrencyAmount();
    for (final d in debts) {
      if (d.remainingMinor == 0) continue;
      if (d.debt.direction == DebtDirection.iOwe) {
        owe = owe.add(d.debt.currency, d.remainingMinor);
      } else {
        owed = owed.add(d.debt.currency, d.remainingMinor);
      }
    }
    return DebtTotals(owe, owed);
  }
}
