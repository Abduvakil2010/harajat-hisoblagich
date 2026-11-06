import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../core/finance/savings_calculator.dart';
import '../../core/money/currency.dart';
import '../local/app_database.dart';

class SavingsGoalDraft {
  const SavingsGoalDraft({
    required this.name,
    required this.targetMinor,
    required this.currency,
    required this.iconKey,
    required this.color,
    this.targetDate,
    this.description,
  });

  final String name;
  final int targetMinor;
  final Currency currency;
  final String iconKey;
  final int color;
  final DateTime? targetDate;
  final String? description;
}

class InsufficientSavingsException implements Exception {
  const InsufficientSavingsException();
}

/// Savings goals track money the user sets aside. Deposits and withdrawals
/// are recorded as goal entries only; they do not create income/expense
/// transactions (see README › Accounting rules).
class SavingsRepository {
  SavingsRepository(this._db, {Uuid? uuid, DateTime Function()? clock})
    : _uuid = uuid ?? const Uuid(),
      _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Stream<List<SavingsProgress>> watchAll() {
    final goals =
        (_db.select(_db.savingsGoals)..orderBy([
              (g) => OrderingTerm.asc(g.completedAt),
              (g) => OrderingTerm.desc(g.createdAt),
            ]))
            .watch();
    final entries = _db.select(_db.savingsEntries).watch();
    return Rx.combineLatest2(goals, entries, (
      List<SavingsGoalRecord> gs,
      List<SavingsEntryRecord> es,
    ) {
      return [
        for (final g in gs)
          SavingsProgress(g, es.where((e) => e.goalId == g.id).toList()),
      ];
    });
  }

  Stream<SavingsProgress?> watchOne(String id) =>
      watchAll().map((list) => list.where((p) => p.goal.id == id).firstOrNull);

  Future<String> create(SavingsGoalDraft d) async {
    _validate(d);
    final now = _clock();
    final id = _uuid.v4();
    await _db
        .into(_db.savingsGoals)
        .insert(
          SavingsGoalsCompanion.insert(
            id: id,
            name: d.name.trim(),
            targetMinor: d.targetMinor,
            currency: d.currency,
            targetDate: Value(d.targetDate),
            description: Value(_clean(d.description)),
            iconKey: d.iconKey,
            color: d.color,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> update(String id, SavingsGoalDraft d) async {
    _validate(d);
    await (_db.update(_db.savingsGoals)..where((g) => g.id.equals(id))).write(
      SavingsGoalsCompanion(
        name: Value(d.name.trim()),
        targetMinor: Value(d.targetMinor),
        currency: Value(d.currency),
        targetDate: Value(d.targetDate),
        description: Value(_clean(d.description)),
        iconKey: Value(d.iconKey),
        color: Value(d.color),
        updatedAt: Value(_clock()),
      ),
    );
  }

  void _validate(SavingsGoalDraft d) {
    if (d.name.trim().isEmpty) throw ArgumentError('name');
    if (d.targetMinor <= 0) throw ArgumentError('target');
  }

  static String? _clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.savingsGoals)..where((g) => g.id.equals(id))).go();

  Future<void> setCompleted(String id, bool completed) =>
      (_db.update(_db.savingsGoals)..where((g) => g.id.equals(id))).write(
        SavingsGoalsCompanion(
          completedAt: Value(completed ? _clock() : null),
          updatedAt: Value(_clock()),
        ),
      );

  Future<void> deposit(
    String goalId,
    int amountMinor, {
    DateTime? date,
    String? note,
  }) async {
    if (amountMinor <= 0) throw ArgumentError('amount');
    await _insertEntry(goalId, amountMinor, date, note);
  }

  /// Withdraws money; throws [InsufficientSavingsException] when the amount
  /// exceeds what is saved.
  Future<void> withdraw(
    String goalId,
    int amountMinor, {
    DateTime? date,
    String? note,
  }) => _db.transaction(() async {
    if (amountMinor <= 0) throw ArgumentError('amount');
    final sum = _db.savingsEntries.amountMinor.sum();
    final r =
        await (_db.selectOnly(_db.savingsEntries)
              ..addColumns([sum])
              ..where(_db.savingsEntries.goalId.equals(goalId)))
            .getSingle();
    final saved = r.read(sum) ?? 0;
    if (amountMinor > saved) throw const InsufficientSavingsException();
    await _insertEntry(goalId, -amountMinor, date, note);
  });

  Future<void> _insertEntry(
    String goalId,
    int signed,
    DateTime? date,
    String? note,
  ) async {
    final now = _clock();
    await _db
        .into(_db.savingsEntries)
        .insert(
          SavingsEntriesCompanion.insert(
            id: _uuid.v4(),
            goalId: goalId,
            amountMinor: signed,
            date: date ?? now,
            note: Value(_clean(note)),
            createdAt: now,
          ),
        );
  }

  Future<void> deleteEntry(String entryId) =>
      (_db.delete(_db.savingsEntries)..where((e) => e.id.equals(entryId))).go();
}
