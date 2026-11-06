import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../core/finance/debt_calculator.dart';
import '../../core/money/currency.dart';
import '../local/app_database.dart';
import '../models/enums.dart';

class DebtDraft {
  const DebtDraft({
    required this.direction,
    required this.counterparty,
    required this.originalMinor,
    required this.currency,
    required this.startDate,
    this.dueDate,
    this.description,
  });

  final DebtDirection direction;
  final String counterparty;
  final int originalMinor;
  final Currency currency;
  final DateTime startDate;
  final DateTime? dueDate;
  final String? description;
}

class RepaymentTooLargeException implements Exception {
  const RepaymentTooLargeException();
}

class OriginalBelowPaidException implements Exception {
  const OriginalBelowPaidException();
}

class DebtRepository {
  DebtRepository(this._db, {Uuid? uuid, DateTime Function()? clock})
    : _uuid = uuid ?? const Uuid(),
      _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Stream<List<DebtState>> watchAll() {
    final debts = (_db.select(
      _db.debts,
    )..orderBy([(d) => OrderingTerm.desc(d.startDate)])).watch();
    final payments = (_db.select(
      _db.debtPayments,
    )..orderBy([(p) => OrderingTerm.desc(p.date)])).watch();
    return Rx.combineLatest2(debts, payments, (
      List<DebtRecord> ds,
      List<DebtPaymentRecord> ps,
    ) {
      return [
        for (final d in ds)
          DebtState(d, ps.where((p) => p.debtId == d.id).toList()),
      ];
    });
  }

  Stream<DebtState?> watchOne(String id) =>
      watchAll().map((l) => l.where((s) => s.debt.id == id).firstOrNull);

  Future<String> create(DebtDraft d) async {
    _validate(d);
    final now = _clock();
    final id = _uuid.v4();
    await _db
        .into(_db.debts)
        .insert(
          DebtsCompanion.insert(
            id: id,
            direction: d.direction,
            counterparty: d.counterparty.trim(),
            originalMinor: d.originalMinor,
            currency: d.currency,
            startDate: d.startDate,
            dueDate: Value(d.dueDate),
            description: Value(_clean(d.description)),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> update(String id, DebtDraft d) => _db.transaction(() async {
    _validate(d);
    final paid = await _paid(id);
    if (d.originalMinor < paid) throw const OriginalBelowPaidException();
    final existing = await (_db.select(
      _db.debts,
    )..where((x) => x.id.equals(id))).getSingle();
    // Currency cannot change once repayments exist (they are in that currency).
    final currency = paid > 0 ? existing.currency : d.currency;
    await (_db.update(_db.debts)..where((x) => x.id.equals(id))).write(
      DebtsCompanion(
        direction: Value(d.direction),
        counterparty: Value(d.counterparty.trim()),
        originalMinor: Value(d.originalMinor),
        currency: Value(currency),
        startDate: Value(d.startDate),
        dueDate: Value(d.dueDate),
        description: Value(_clean(d.description)),
        updatedAt: Value(_clock()),
      ),
    );
  });

  void _validate(DebtDraft d) {
    if (d.counterparty.trim().isEmpty) throw ArgumentError('counterparty');
    if (d.originalMinor <= 0) throw ArgumentError('amount');
  }

  static String? _clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  Future<int> _paid(String debtId) async {
    final sum = _db.debtPayments.amountMinor.sum();
    final r =
        await (_db.selectOnly(_db.debtPayments)
              ..addColumns([sum])
              ..where(_db.debtPayments.debtId.equals(debtId)))
            .getSingle();
    return r.read(sum) ?? 0;
  }

  /// Records a (partial) repayment. Rejects amounts above the remaining
  /// balance so a debt can never go negative.
  Future<void> addPayment(
    String debtId,
    int amountMinor, {
    DateTime? date,
    String? note,
  }) => _db.transaction(() async {
    if (amountMinor <= 0) throw ArgumentError('amount');
    final debt = await (_db.select(
      _db.debts,
    )..where((d) => d.id.equals(debtId))).getSingle();
    final paid = await _paid(debtId);
    if (paid + amountMinor > debt.originalMinor) {
      throw const RepaymentTooLargeException();
    }
    final now = _clock();
    await _db
        .into(_db.debtPayments)
        .insert(
          DebtPaymentsCompanion.insert(
            id: _uuid.v4(),
            debtId: debtId,
            amountMinor: amountMinor,
            date: date ?? now,
            note: Value(_clean(note)),
            createdAt: now,
          ),
        );
    await (_db.update(_db.debts)..where((d) => d.id.equals(debtId))).write(
      DebtsCompanion(updatedAt: Value(now)),
    );
  });

  Future<void> deletePayment(String paymentId) =>
      (_db.delete(_db.debtPayments)..where((p) => p.id.equals(paymentId))).go();

  Future<void> delete(String id) =>
      (_db.delete(_db.debts)..where((d) => d.id.equals(id))).go();
}
