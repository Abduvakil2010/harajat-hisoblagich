import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobai/core/money/currency.dart';
import 'package:hisobai/core/utils/date_range.dart';
import 'package:hisobai/data/local/app_database.dart';
import 'package:hisobai/data/models/app_settings.dart';
import 'package:hisobai/data/models/enums.dart';
import 'package:hisobai/data/repositories/backup_repository.dart';
import 'package:hisobai/data/repositories/budget_repository.dart';
import 'package:hisobai/data/repositories/category_repository.dart';
import 'package:hisobai/data/repositories/debt_repository.dart';
import 'package:hisobai/data/repositories/recurring_repository.dart';
import 'package:hisobai/data/repositories/savings_repository.dart';
import 'package:hisobai/data/repositories/transaction_repository.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late TransactionRepository txRepo;
  late int food;

  setUp(() async {
    db = testDb();
    txRepo = TransactionRepository(db);
    food = await categoryIdByKey(db, 'food');
  });
  tearDown(() => db.close());

  TransactionDraft draft({
    int amount = 1000,
    String title = 'Lunch',
    DateTime? date,
    TransactionType type = TransactionType.expense,
  }) => TransactionDraft(
    title: title,
    amountMinor: amount,
    currency: Currency.uzs,
    categoryId: food,
    date: date ?? DateTime(2026, 11, 5),
    type: type,
  );

  group('Transactions', () {
    test('seeds 18 default categories', () async {
      expect((await db.select(db.categories).get()).length, 18);
    });

    test('add, edit, delete update all-time totals', () async {
      final id = await txRepo.add(draft(amount: m(50000)));
      await txRepo.add(
        draft(amount: m(200000), type: TransactionType.income, title: 'Salary'),
      );
      var totals = await txRepo.watchAllTimeTotals().first;
      expect(totals.expense.minorOf(Currency.uzs), m(50000));
      expect(totals.income.minorOf(Currency.uzs), m(200000));

      await txRepo.update(id, draft(amount: m(70000)));
      totals = await txRepo.watchAllTimeTotals().first;
      expect(totals.expense.minorOf(Currency.uzs), m(70000));

      await txRepo.delete(id);
      totals = await txRepo.watchAllTimeTotals().first;
      expect(totals.expense.minorOf(Currency.uzs), 0);
    });

    test('rejects zero amounts and empty titles', () async {
      expect(
        () => txRepo.add(draft(amount: 0)),
        throwsA(isA<TransactionValidationException>()),
      );
      expect(
        () => txRepo.add(draft(title: '  ')),
        throwsA(isA<TransactionValidationException>()),
      );
    });

    test('search is case-insensitive for Cyrillic', () async {
      await txRepo.add(draft(title: 'Продукты в магазине'));
      await txRepo.add(draft(title: 'Taxi'));
      final r = await txRepo
          .watchQuery(const TransactionQuery(search: 'ПРОДУКТЫ'), limit: 50)
          .first;
      expect(r.map((t) => t.title), ['Продукты в магазине']);
    });

    test('filters by type, date and sorts by amount', () async {
      await txRepo.add(draft(amount: 300, date: DateTime(2026, 11, 1)));
      await txRepo.add(draft(amount: 100, date: DateTime(2026, 11, 2)));
      await txRepo.add(draft(amount: 900, date: DateTime(2026, 10, 2)));
      await txRepo.add(
        draft(
          amount: 500,
          type: TransactionType.income,
          date: DateTime(2026, 11, 3),
        ),
      );
      final r = await txRepo
          .watchQuery(
            TransactionQuery(
              type: TransactionType.expense,
              range: DateRange.month(DateTime(2026, 11)),
              sort: TransactionSort.amountDesc,
            ),
            limit: 50,
          )
          .first;
      expect(r.map((t) => t.amountMinor), [300, 100]);
    });
  });

  test('deleting a custom category moves its transactions to Other', () async {
    final cats = CategoryRepository(db);
    final id = await cats.create(
      name: 'Coffee',
      type: TransactionType.expense,
      iconKey: 'local_cafe',
      color: 0,
    );
    final txId = await txRepo.add(
      TransactionDraft(
        title: 'Latte',
        amountMinor: 100,
        currency: Currency.uzs,
        categoryId: id,
        date: DateTime(2026, 11, 1),
        type: TransactionType.expense,
      ),
    );
    await cats.delete(id);
    final moved = await txRepo.getById(txId);
    expect(moved!.categoryId, await categoryIdByKey(db, 'otherExpense'));
    expect(() => cats.delete(food), throwsStateError);
  });

  test('budget upsert keeps one total budget', () async {
    final repo = BudgetRepository(db);
    await repo.upsert(limitMinor: 100, currency: Currency.uzs);
    await repo.upsert(limitMinor: 200, currency: Currency.uzs);
    final all = await repo.all();
    expect(all.length, 1);
    expect(all.single.limitMinor, 200);
  });

  group('Recurring payments', () {
    test(
      'posts due occurrences once, even when processed repeatedly',
      () async {
        var now = DateTime(2026, 11, 6, 10);
        final repo = RecurringRepository(
          db,
          TransactionRepository(db),
          clock: () => now,
        );
        await repo.create(
          RecurringDraft(
            title: 'Internet',
            amountMinor: m(150000),
            currency: Currency.uzs,
            categoryId: food,
            type: TransactionType.expense,
            frequency: RecurrenceFrequency.monthly,
            startDate: DateTime(2026, 8, 31),
          ),
        );
        final first = await repo.processDue();
        expect(first.created, 3); // Aug 31, Sep 30, Oct 31
        final second = await repo.processDue(); // app restart, same day
        expect(second.created, 0);
        expect((await txRepo.all()).length, 3);

        // Simulate a crash mid-way: nextDueDate rolled back, keys still unique.
        await db
            .update(db.recurringPayments)
            .write(
              RecurringPaymentsCompanion(
                nextDueDate: Value(DateTime(2026, 8, 31)),
              ),
            );
        final replay = await repo.processDue();
        expect(replay.created, 0);
        expect(replay.skippedDuplicates, 3);

        now = DateTime(2026, 12, 1);
        expect((await repo.processDue()).created, 1); // Nov 30
        final r = (await repo.all()).single;
        expect(r.nextDueDate, DateTime(2026, 12, 31));
      },
    );

    test('inactive schedules are not posted', () async {
      final repo = RecurringRepository(
        db,
        TransactionRepository(db),
        clock: () => DateTime(2026, 11, 6),
      );
      await repo.create(
        RecurringDraft(
          title: 'Gym',
          amountMinor: 100,
          currency: Currency.uzs,
          categoryId: food,
          type: TransactionType.expense,
          frequency: RecurrenceFrequency.weekly,
          startDate: DateTime(2026, 10, 1),
          isActive: false,
        ),
      );
      expect((await repo.processDue()).created, 0);
    });
  });

  test('savings withdrawals cannot exceed saved amount', () async {
    final repo = SavingsRepository(db);
    final id = await repo.create(
      const SavingsGoalDraft(
        name: 'Phone',
        targetMinor: 1000,
        currency: Currency.uzs,
        iconKey: 'phone',
        color: 0,
      ),
    );
    await repo.deposit(id, 600);
    await repo.withdraw(id, 200);
    expect(
      () => repo.withdraw(id, 401),
      throwsA(isA<InsufficientSavingsException>()),
    );
    final p = (await repo.watchOne(id).first)!;
    expect(p.savedMinor, 400);
  });

  test('debt repayments update remaining and reject overpayment', () async {
    final repo = DebtRepository(db);
    final id = await repo.create(
      DebtDraft(
        direction: DebtDirection.iOwe,
        counterparty: 'Bank',
        originalMinor: 1000,
        currency: Currency.uzs,
        startDate: DateTime(2026, 10, 1),
      ),
    );
    await repo.addPayment(id, 300);
    await repo.addPayment(id, 200);
    var s = (await repo.watchOne(id).first)!;
    expect(s.remainingMinor, 500);
    expect(
      () => repo.addPayment(id, 501),
      throwsA(isA<RepaymentTooLargeException>()),
    );
    await repo.addPayment(id, 500);
    s = (await repo.watchOne(id).first)!;
    expect(s.statusAt(DateTime(2026, 11, 6)), DebtStatus.completed);
    // Debts never create income/expense transactions.
    expect(await txRepo.count(), 0);
  });

  test('backup export → restore round-trip preserves data', () async {
    await txRepo.add(draft(amount: 12345, title: 'Groceries'));
    final debts = DebtRepository(db);
    final debtId = await debts.create(
      DebtDraft(
        direction: DebtDirection.owedToMe,
        counterparty: 'Ali',
        originalMinor: 500,
        currency: Currency.usd,
        startDate: DateTime(2026, 9, 1),
      ),
    );
    await debts.addPayment(debtId, 100);

    final backup = BackupRepository(db);
    final json = await backup.exportString(
      const AppSettings(onboardingDone: true, localeCode: 'ru'),
    );

    final other = testDb();
    addTearDown(other.close);
    final restore = BackupRepository(other);
    final snap = restore.parse(json);
    expect(snap.count('transactions'), 1);
    expect(snap.settings!.localeCode, 'ru');
    await restore.restore(snap);

    final txs = await TransactionRepository(other).all();
    expect(txs.single.amountMinor, 12345);
    final restoredDebt = (await DebtRepository(other).watchOne(debtId).first)!;
    expect(restoredDebt.remainingMinor, 400);
    expect(
      () => restore.parse('{"format":"x"}'),
      throwsA(isA<InvalidBackupException>()),
    );
    expect(
      () => restore.parse('not json'),
      throwsA(isA<InvalidBackupException>()),
    );
  });
}
