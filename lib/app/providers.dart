import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/finance/budget_calculator.dart';
import '../core/finance/debt_calculator.dart';
import '../core/finance/savings_calculator.dart';
import '../core/money/currency_converter.dart';
import '../core/services/notification_service.dart';
import '../core/utils/date_range.dart';
import '../data/local/app_database.dart';
import '../data/models/app_settings.dart';
import '../data/models/enums.dart';
import '../data/remote/cloud_backup_service.dart';
import '../data/repositories/backup_repository.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/debt_repository.dart';
import '../data/repositories/exchange_rate_repository.dart';
import '../data/repositories/recurring_repository.dart';
import '../data/repositories/savings_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/transaction_repository.dart';

// ---------------------------------------------------------------------------
// Infrastructure (overridden in main.dart / tests)
// ---------------------------------------------------------------------------

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final cloudBackupServiceProvider = Provider<CloudBackupService>(
  (ref) => CloudBackupService.unavailable(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.disabled(),
);

/// Injectable clock so time-dependent logic is testable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

final settingsRepositoryProvider = Provider(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);
final transactionRepositoryProvider = Provider(
  (ref) => TransactionRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);
final categoryRepositoryProvider = Provider(
  (ref) => CategoryRepository(ref.watch(databaseProvider)),
);
final budgetRepositoryProvider = Provider(
  (ref) => BudgetRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);
final exchangeRateRepositoryProvider = Provider(
  (ref) => ExchangeRateRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);
final recurringRepositoryProvider = Provider(
  (ref) => RecurringRepository(
    ref.watch(databaseProvider),
    ref.watch(transactionRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);
final savingsRepositoryProvider = Provider(
  (ref) => SavingsRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);
final debtRepositoryProvider = Provider(
  (ref) => DebtRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);
final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);
final backupRepositoryProvider = Provider(
  (ref) => BackupRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> update(AppSettings Function(AppSettings s) change) async {
    final next = change(state);
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> reset() async {
    await ref.read(settingsRepositoryProvider).clear();
    state = const AppSettings();
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

final budgetThresholdsProvider = Provider((ref) {
  final s = ref.watch(settingsProvider);
  return BudgetThresholds(
    warning: s.budgetWarningPercent / 100,
    critical: s.budgetCriticalPercent / 100,
  );
});

// ---------------------------------------------------------------------------
// Reference data
// ---------------------------------------------------------------------------

final categoriesProvider = StreamProvider<List<CategoryRecord>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

final categoryMapProvider = Provider<Map<int, CategoryRecord>>((ref) {
  final list = ref.watch(categoriesProvider).value ?? const [];
  return {for (final c in list) c.id: c};
});

final exchangeRatesProvider = StreamProvider<List<ExchangeRateQuote>>(
  (ref) => ref.watch(exchangeRateRepositoryProvider).watchQuotes(),
);

final converterProvider = Provider<CurrencyConverter>((ref) {
  final quotes = ref.watch(exchangeRatesProvider).value;
  return quotes == null ? CurrencyConverter.empty : CurrencyConverter(quotes);
});

// ---------------------------------------------------------------------------
// Live data streams
// ---------------------------------------------------------------------------

final transactionsInRangeProvider =
    StreamProvider.family<List<TransactionRecord>, DateRange>(
      (ref, range) =>
          ref.watch(transactionRepositoryProvider).watchRange(range),
    );

final recentTransactionsProvider = StreamProvider<List<TransactionRecord>>(
  (ref) => ref.watch(transactionRepositoryProvider).watchRecent(6),
);

final allTimeTotalsProvider = StreamProvider(
  (ref) => ref.watch(transactionRepositoryProvider).watchAllTimeTotals(),
);

final transactionByIdProvider =
    StreamProvider.family<TransactionRecord?, String>(
      (ref, id) => ref.watch(transactionRepositoryProvider).watchById(id),
    );

final budgetsProvider = StreamProvider<List<BudgetRecord>>(
  (ref) => ref.watch(budgetRepositoryProvider).watchAll(),
);

final savingsProvider = StreamProvider<List<SavingsProgress>>(
  (ref) => ref.watch(savingsRepositoryProvider).watchAll(),
);

final debtsProvider = StreamProvider<List<DebtState>>(
  (ref) => ref.watch(debtRepositoryProvider).watchAll(),
);

final recurringProvider = StreamProvider<List<RecurringPaymentRecord>>(
  (ref) => ref.watch(recurringRepositoryProvider).watchAll(),
);

final chatMessagesProvider = StreamProvider<List<ChatMessageRecord>>(
  (ref) => ref.watch(chatRepositoryProvider).watchAll(),
);

/// The current month, re-evaluated from the injectable clock.
final currentMonthProvider = Provider<DateRange>(
  (ref) => DateRange.month(ref.watch(clockProvider)()),
);

/// Transactions for the current and previous month, used by the dashboard,
/// budgets and the assistant.
final twoMonthWindowProvider = Provider<DateRange>((ref) {
  final m = ref.watch(currentMonthProvider);
  return DateRange(m.previous().start, m.end);
});

/// Budget statuses for the current month.
final budgetStatusesProvider = Provider<AsyncValue<List<BudgetStatus>>>((ref) {
  final budgets = ref.watch(budgetsProvider);
  final month = ref.watch(currentMonthProvider);
  final txs = ref.watch(transactionsInRangeProvider(month));
  final converter = ref.watch(converterProvider);
  final thresholds = ref.watch(budgetThresholdsProvider);
  if (budgets.isLoading || txs.isLoading) return const AsyncLoading();
  if (budgets.hasError) return AsyncError(budgets.error!, budgets.stackTrace!);
  if (txs.hasError) return AsyncError(txs.error!, txs.stackTrace!);
  return AsyncData(
    const BudgetCalculator().evaluate(
      budgets: budgets.value!,
      transactions: txs.value!,
      converter: converter,
      month: month,
      thresholds: thresholds,
    ),
  );
});

/// Helper used by forms to know which categories apply to a type.
List<CategoryRecord> categoriesOfType(
  List<CategoryRecord> all,
  TransactionType type,
) => all.where((c) => c.type == type).toList();
