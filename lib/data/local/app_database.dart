import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/money/currency.dart';
import '../models/enums.dart';
import 'default_categories.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The single local database of HisobAI (SQLite via Drift).
///
/// All user data lives here; the app is fully functional offline.
@DriftDatabase(
  tables: [
    Categories,
    Transactions,
    Budgets,
    ExchangeRates,
    RecurringPayments,
    SavingsGoals,
    SavingsEntries,
    Debts,
    DebtPayments,
    ChatMessages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the on-device database file `hisobai.sqlite`.
  factory AppDatabase.open() => AppDatabase(
    driftDatabase(
      name: 'hisobai',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedDefaultCategories();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Inserts built-in categories that are missing. Idempotent.
  Future<void> seedDefaultCategories() async {
    final all = [...defaultExpenseCategories, ...defaultIncomeCategories];
    await batch((b) {
      for (var i = 0; i < all.length; i++) {
        final c = all[i];
        b.insert(
          categories,
          CategoriesCompanion.insert(
            key: Value(c.key),
            type: c.type,
            iconKey: c.iconKey,
            color: c.color,
            isDefault: const Value(true),
            sortOrder: Value(i),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  /// Deletes every user record and re-seeds default categories.
  Future<void> wipeAll() => transaction(() async {
    for (final t in <TableInfo<Table, Object?>>[
      chatMessages,
      debtPayments,
      debts,
      savingsEntries,
      savingsGoals,
      budgets,
      transactions,
      recurringPayments,
      exchangeRates,
      categories,
    ]) {
      await delete(t).go();
    }
    await seedDefaultCategories();
  });
}
