import 'package:drift/drift.dart';

import '../../core/money/currency.dart';
import '../local/app_database.dart';

/// Monthly budgets are standing limits: they apply to every calendar month
/// until edited or deleted. At most one total budget and one limit per
/// category exist.
class BudgetRepository {
  BudgetRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Stream<List<BudgetRecord>> watchAll() => _db.select(_db.budgets).watch();

  Future<List<BudgetRecord>> all() => _db.select(_db.budgets).get();

  /// Creates or replaces the budget for [categoryId] (null = total).
  Future<void> upsert({
    int? categoryId,
    required int limitMinor,
    required Currency currency,
  }) async {
    if (limitMinor <= 0) throw ArgumentError.value(limitMinor, 'limitMinor');
    final now = _clock();
    await _db.transaction(() async {
      final existing =
          await (_db.select(_db.budgets)..where(
                (b) => categoryId == null
                    ? b.categoryId.isNull()
                    : b.categoryId.equals(categoryId),
              ))
              .get();
      if (existing.isEmpty) {
        await _db
            .into(_db.budgets)
            .insert(
              BudgetsCompanion.insert(
                categoryId: Value(categoryId),
                limitMinor: limitMinor,
                currency: currency,
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_db.update(
          _db.budgets,
        )..where((b) => b.id.equals(existing.first.id))).write(
          BudgetsCompanion(
            limitMinor: Value(limitMinor),
            currency: Value(currency),
            updatedAt: Value(now),
          ),
        );
        // Remove accidental duplicates.
        for (final dup in existing.skip(1)) {
          await (_db.delete(
            _db.budgets,
          )..where((b) => b.id.equals(dup.id))).go();
        }
      }
    });
  }

  Future<void> delete(int id) =>
      (_db.delete(_db.budgets)..where((b) => b.id.equals(id))).go();
}
