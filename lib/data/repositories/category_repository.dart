import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../local/default_categories.dart';
import '../models/enums.dart';

class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<CategoryRecord>> watchAll() =>
      (_db.select(_db.categories)..orderBy([
            (c) => OrderingTerm.asc(c.sortOrder),
            (c) => OrderingTerm.asc(c.id),
          ]))
          .watch();

  Future<List<CategoryRecord>> all() => _db.select(_db.categories).get();

  Future<int> create({
    required String name,
    required TransactionType type,
    required String iconKey,
    required int color,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(name, 'name');
    final maxOrder = _db.categories.sortOrder.max();
    final row = await (_db.selectOnly(
      _db.categories,
    )..addColumns([maxOrder])).getSingle();
    return _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: Value(trimmed),
            type: type,
            iconKey: iconKey,
            color: color,
            sortOrder: Value((row.read(maxOrder) ?? 0) + 1),
          ),
        );
  }

  Future<void> updateCategory(
    int id, {
    String? name,
    String? iconKey,
    int? color,
  }) => (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
    CategoriesCompanion(
      name: name == null ? const Value.absent() : Value(name.trim()),
      iconKey: iconKey == null ? const Value.absent() : Value(iconKey),
      color: color == null ? const Value.absent() : Value(color),
    ),
  );

  /// Deletes a custom category. Its transactions and recurring payments are
  /// moved to the built-in "Other" category of the same type so no financial
  /// record is lost. Built-in categories cannot be deleted.
  Future<void> delete(int id) => _db.transaction(() async {
    final cat = await (_db.select(
      _db.categories,
    )..where((c) => c.id.equals(id))).getSingle();
    if (cat.isDefault) {
      throw StateError('Built-in categories cannot be deleted');
    }
    final fallback = await (_db.select(
      _db.categories,
    )..where((c) => c.key.equals(fallbackCategoryKey[cat.type]!))).getSingle();
    await (_db.update(_db.transactions)..where((t) => t.categoryId.equals(id)))
        .write(TransactionsCompanion(categoryId: Value(fallback.id)));
    await (_db.update(_db.recurringPayments)
          ..where((t) => t.categoryId.equals(id)))
        .write(RecurringPaymentsCompanion(categoryId: Value(fallback.id)));
    await (_db.delete(_db.budgets)..where((b) => b.categoryId.equals(id))).go();
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  });

  Future<int> usageCount(int id) async {
    final c = _db.transactions.id.count();
    final r =
        await (_db.selectOnly(_db.transactions)
              ..addColumns([c])
              ..where(_db.transactions.categoryId.equals(id)))
            .getSingle();
    return r.read(c) ?? 0;
  }
}
