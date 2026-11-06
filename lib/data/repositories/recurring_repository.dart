import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/finance/recurrence_scheduler.dart';
import '../../core/money/currency.dart';
import '../../core/utils/date_range.dart';
import '../local/app_database.dart';
import '../models/enums.dart';
import 'transaction_repository.dart';

class RecurringDraft {
  const RecurringDraft({
    required this.title,
    required this.amountMinor,
    required this.currency,
    required this.categoryId,
    required this.type,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.paymentMethod = PaymentMethod.cash,
    this.isActive = true,
    this.reminderEnabled = true,
  });

  final String title;
  final int amountMinor;
  final Currency currency;
  final int categoryId;
  final TransactionType type;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final PaymentMethod paymentMethod;
  final bool isActive;
  final bool reminderEnabled;
}

/// Result of processing due occurrences.
class RecurringProcessResult {
  const RecurringProcessResult(this.created, this.skippedDuplicates);
  final int created;
  final int skippedDuplicates;
}

class RecurringRepository {
  RecurringRepository(
    this._db,
    this._transactions, {
    Uuid? uuid,
    DateTime Function()? clock,
    this.scheduler = const RecurrenceScheduler(),
  }) : _uuid = uuid ?? const Uuid(),
       _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final TransactionRepository _transactions;
  final Uuid _uuid;
  final DateTime Function() _clock;
  final RecurrenceScheduler scheduler;

  /// Safety cap on how many missed occurrences are posted per run.
  static const maxCatchUp = 400;

  Stream<List<RecurringPaymentRecord>> watchAll() =>
      (_db.select(_db.recurringPayments)..orderBy([
            (r) => OrderingTerm.desc(r.isActive),
            (r) => OrderingTerm.asc(r.nextDueDate),
          ]))
          .watch();

  Future<List<RecurringPaymentRecord>> all() =>
      _db.select(_db.recurringPayments).get();

  Stream<RecurringPaymentRecord?> watchById(String id) => (_db.select(
    _db.recurringPayments,
  )..where((r) => r.id.equals(id))).watchSingleOrNull();

  void _validate(RecurringDraft d) {
    if (d.title.trim().isEmpty) throw ArgumentError('title');
    if (d.amountMinor <= 0) throw ArgumentError('amount');
    if (d.endDate != null &&
        d.endDate!.dateOnly.isBefore(d.startDate.dateOnly)) {
      throw ArgumentError('endDate');
    }
  }

  Future<String> create(RecurringDraft d) async {
    _validate(d);
    final now = _clock();
    final id = _uuid.v4();
    await _db
        .into(_db.recurringPayments)
        .insert(
          RecurringPaymentsCompanion.insert(
            id: id,
            title: d.title.trim(),
            amountMinor: d.amountMinor,
            currency: d.currency,
            categoryId: d.categoryId,
            type: d.type,
            paymentMethod: d.paymentMethod,
            frequency: d.frequency,
            startDate: d.startDate.dateOnly,
            endDate: Value(d.endDate?.dateOnly),
            nextDueDate: Value(
              scheduler.nextAfter(
                start: d.startDate,
                frequency: d.frequency,
                end: d.endDate,
              ),
            ),
            isActive: Value(d.isActive),
            reminderEnabled: Value(d.reminderEnabled),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> update(String id, RecurringDraft d) async {
    _validate(d);
    final lastPosted = await _lastPostedDate(id);
    final next = scheduler.nextAfter(
      start: d.startDate,
      frequency: d.frequency,
      end: d.endDate,
      after: lastPosted,
    );
    await (_db.update(
      _db.recurringPayments,
    )..where((r) => r.id.equals(id))).write(
      RecurringPaymentsCompanion(
        title: Value(d.title.trim()),
        amountMinor: Value(d.amountMinor),
        currency: Value(d.currency),
        categoryId: Value(d.categoryId),
        type: Value(d.type),
        paymentMethod: Value(d.paymentMethod),
        frequency: Value(d.frequency),
        startDate: Value(d.startDate.dateOnly),
        endDate: Value(d.endDate?.dateOnly),
        nextDueDate: Value(next),
        isActive: Value(d.isActive),
        reminderEnabled: Value(d.reminderEnabled),
        updatedAt: Value(_clock()),
      ),
    );
  }

  Future<void> setActive(String id, bool active) =>
      (_db.update(_db.recurringPayments)..where((r) => r.id.equals(id))).write(
        RecurringPaymentsCompanion(
          isActive: Value(active),
          updatedAt: Value(_clock()),
        ),
      );

  /// Deletes the schedule. Already posted transactions are kept.
  Future<void> delete(String id) =>
      (_db.delete(_db.recurringPayments)..where((r) => r.id.equals(id))).go();

  Future<DateTime?> _lastPostedDate(String id) async {
    final maxDate = _db.transactions.date.max();
    final r =
        await (_db.selectOnly(_db.transactions)
              ..addColumns([maxDate])
              ..where(_db.transactions.recurringId.equals(id)))
            .getSingle();
    return r.read(maxDate);
  }

  /// Posts every due occurrence up to and including today.
  ///
  /// Safe to call on every launch/resume: each occurrence has a unique
  /// `occurrenceKey`, so re-running never creates duplicates even if the app
  /// was killed half-way.
  Future<RecurringProcessResult> processDue() async {
    final today = _clock().dateOnly;
    var created = 0;
    var skipped = 0;
    final active = await (_db.select(
      _db.recurringPayments,
    )..where((r) => r.isActive.equals(true) & r.nextDueDate.isNotNull())).get();
    for (final r in active) {
      if (r.nextDueDate!.isAfter(today)) continue;
      final dates = scheduler.occurrencesBetween(
        start: r.startDate,
        frequency: r.frequency,
        end: r.endDate,
        after: DateTime(
          r.nextDueDate!.year,
          r.nextDueDate!.month,
          r.nextDueDate!.day - 1,
        ),
        until: today,
        maxCount: maxCatchUp,
      );
      await _db.transaction(() async {
        for (final d in dates) {
          final ok = await _transactions.addOccurrence(
            TransactionDraft(
              title: r.title,
              amountMinor: r.amountMinor,
              currency: r.currency,
              categoryId: r.categoryId,
              date: DateTime(d.year, d.month, d.day, 9),
              type: r.type,
              paymentMethod: r.paymentMethod,
              recurringId: r.id,
              occurrenceKey: RecurrenceScheduler.occurrenceKey(r.id, d),
            ),
          );
          ok ? created++ : skipped++;
        }
        // If the catch-up cap was hit, continue from the last posted date on
        // the next run instead of skipping the remaining occurrences.
        final capped = dates.length >= maxCatchUp;
        final next = scheduler.nextAfter(
          start: r.startDate,
          frequency: r.frequency,
          end: r.endDate,
          after: capped ? dates.last : today,
        );
        await (_db.update(_db.recurringPayments)
              ..where((x) => x.id.equals(r.id)))
            .write(RecurringPaymentsCompanion(nextDueDate: Value(next)));
      });
    }
    return RecurringProcessResult(created, skipped);
  }
}
