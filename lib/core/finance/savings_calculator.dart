import '../../data/local/app_database.dart';
import '../money/money.dart';

/// Derived state of a savings goal. The saved amount is always the sum of
/// its entries, so it can never drift from the history.
class SavingsProgress {
  const SavingsProgress(this.goal, this.entries);

  final SavingsGoalRecord goal;
  final List<SavingsEntryRecord> entries;

  int get savedMinor => entries.fold<int>(0, (a, e) => a + e.amountMinor);
  int get remainingMinor =>
      (goal.targetMinor - savedMinor).clamp(0, goal.targetMinor);
  double get ratio =>
      goal.targetMinor <= 0 ? 0 : (savedMinor / goal.targetMinor).clamp(0, 1);
  bool get isReached => savedMinor >= goal.targetMinor;
  bool get isCompleted => goal.completedAt != null;

  Money get saved => Money(savedMinor, goal.currency);
  Money get remaining => Money(remainingMinor, goal.currency);
  Money get target => Money(goal.targetMinor, goal.currency);

  /// Running balance after each entry, oldest first (for the progress chart).
  List<(DateTime, int)> get history {
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    var run = 0;
    return [for (final e in sorted) (e.date, run += e.amountMinor)];
  }

  /// Monthly amount needed to reach the target by its date, or null.
  int? monthlyNeeded(DateTime now) {
    final td = goal.targetDate;
    if (td == null || isReached) return null;
    final months = (td.year - now.year) * 12 + td.month - now.month;
    if (months <= 0) return remainingMinor;
    return (remainingMinor / months).ceil();
  }
}

class SavingsCalculator {
  const SavingsCalculator();

  /// Validates a withdrawal: it may not exceed the saved amount.
  static bool canWithdraw(SavingsProgress p, int amountMinor) =>
      amountMinor > 0 && amountMinor <= p.savedMinor;
}
