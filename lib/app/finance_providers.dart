import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/finance/ledger.dart';
import '../core/money/money.dart';
import '../core/utils/date_range.dart';
import '../features/ai_assistant/engine/financial_snapshot.dart';
import '../features/ai_assistant/engine/findings.dart';
import 'providers.dart';

/// A [Ledger] for [range] in the user's primary currency.
final ledgerProvider = Provider.family<AsyncValue<Ledger>, DateRange>((
  ref,
  range,
) {
  final txs = ref.watch(transactionsInRangeProvider(range));
  final currency = ref.watch(settingsProvider.select((s) => s.primaryCurrency));
  final converter = ref.watch(converterProvider);
  return txs.whenData((list) => Ledger(list, currency, converter));
});

/// Current balance = opening balance + all income − all expenses.
class BalanceState {
  const BalanceState({required this.raw, required this.converted});

  /// Per-currency balance (never mixed).
  final MultiCurrencyAmount raw;

  /// Combined in the primary currency at the latest rate, or null if a
  /// needed rate is missing (UI then shows [raw] separately).
  final Money? converted;
}

final balanceProvider = Provider<AsyncValue<BalanceState>>((ref) {
  final totals = ref.watch(allTimeTotalsProvider);
  final settings = ref.watch(settingsProvider);
  final converter = ref.watch(converterProvider);
  return totals.whenData((t) {
    final raw = settings.openingBalance + t.income - t.expense;
    return BalanceState(
      raw: raw,
      converted: converter.convertTotal(raw, settings.primaryCurrency),
    );
  });
});

/// Window of history loaded for the dashboard and the assistant.
final analysisWindowProvider = Provider<DateRange>(
  (ref) => FinancialSnapshot.windowFor(ref.watch(clockProvider)()),
);

/// Everything the assistant and the insights engine analyse.
final financialSnapshotProvider = Provider<AsyncValue<FinancialSnapshot>>((
  ref,
) {
  final window = ref.watch(analysisWindowProvider);
  final ledger = ref.watch(ledgerProvider(window));
  final budgets = ref.watch(budgetStatusesProvider);
  final goals = ref.watch(savingsProvider);
  final debts = ref.watch(debtsProvider);
  final categories = ref.watch(categoryMapProvider);
  final balance = ref.watch(balanceProvider);
  final settings = ref.watch(settingsProvider);
  final now = ref.watch(clockProvider)();

  final all = [ledger, budgets, goals, debts, balance];
  if (all.any((a) => a.isLoading && !a.hasValue)) return const AsyncLoading();
  final err = all.where((a) => a.hasError && !a.hasValue).firstOrNull;
  if (err != null) {
    return AsyncError(err.error!, err.stackTrace ?? StackTrace.current);
  }

  final b = balance.value!;
  return AsyncData(
    FinancialSnapshot(
      now: now,
      currency: settings.primaryCurrency,
      ledger: ledger.value!,
      budgets: budgets.value!,
      goals: goals.value!,
      debts: debts.value!,
      categories: categories,
      balance: BalanceSummary(b.raw.toMoneyList(), b.converted),
    ),
  );
});
