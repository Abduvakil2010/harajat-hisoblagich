import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/money/currency.dart';
import '../../core/money/money.dart';
import '../../core/utils/date_range.dart';
import '../local/app_database.dart';
import '../models/enums.dart';

/// Validated input for creating or editing a transaction.
class TransactionDraft {
  const TransactionDraft({
    required this.title,
    required this.amountMinor,
    required this.currency,
    required this.categoryId,
    required this.date,
    required this.type,
    this.paymentMethod = PaymentMethod.cash,
    this.description,
    this.recurringId,
    this.occurrenceKey,
  });

  final String title;
  final int amountMinor;
  final Currency currency;
  final int categoryId;
  final DateTime date;
  final TransactionType type;
  final PaymentMethod paymentMethod;
  final String? description;
  final String? recurringId;
  final String? occurrenceKey;
}

enum TransactionSort { dateDesc, dateAsc, amountDesc, amountAsc }

/// Filter for the transactions list.
class TransactionQuery {
  const TransactionQuery({
    this.search = '',
    this.type,
    this.categoryIds = const {},
    this.range,
    this.sort = TransactionSort.dateDesc,
  });

  final String search;
  final TransactionType? type;
  final Set<int> categoryIds;
  final DateRange? range;
  final TransactionSort sort;

  bool get isFiltered =>
      search.isNotEmpty ||
      type != null ||
      categoryIds.isNotEmpty ||
      range != null;

  TransactionQuery copyWith({
    String? search,
    TransactionType? Function()? type,
    Set<int>? categoryIds,
    DateRange? Function()? range,
    TransactionSort? sort,
  }) => TransactionQuery(
    search: search ?? this.search,
    type: type != null ? type() : this.type,
    categoryIds: categoryIds ?? this.categoryIds,
    range: range != null ? range() : this.range,
    sort: sort ?? this.sort,
  );

  @override
  bool operator ==(Object other) =>
      other is TransactionQuery &&
      other.search == search &&
      other.type == type &&
      other.range == range &&
      other.sort == sort &&
      other.categoryIds.length == categoryIds.length &&
      other.categoryIds.containsAll(categoryIds);

  @override
  int get hashCode => Object.hash(
    search,
    type,
    range,
    sort,
    Object.hashAllUnordered(categoryIds),
  );
}

class TransactionValidationException implements Exception {
  const TransactionValidationException(this.field);
  final String field;
  @override
  String toString() => 'Invalid transaction field: $field';
}

class TransactionRepository {
  TransactionRepository(this._db, {Uuid? uuid, DateTime Function()? clock})
    : _uuid = uuid ?? const Uuid(),
      _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _clock;

  static void validate(TransactionDraft d) {
    if (d.title.trim().isEmpty) {
      throw const TransactionValidationException('title');
    }
    if (d.amountMinor <= 0) {
      throw const TransactionValidationException('amount');
    }
  }

  Future<String> add(TransactionDraft d) async {
    validate(d);
    final now = _clock();
    final id = _uuid.v4();
    await _db
        .into(_db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: id,
            title: d.title.trim(),
            amountMinor: d.amountMinor,
            currency: d.currency,
            categoryId: d.categoryId,
            date: d.date,
            description: Value(_clean(d.description)),
            searchText: Value(searchKey(d.title, d.description)),
            paymentMethod: d.paymentMethod,
            type: d.type,
            recurringId: Value(d.recurringId),
            occurrenceKey: Value(d.occurrenceKey),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  /// Inserts a recurring occurrence; returns false if it already exists.
  Future<bool> addOccurrence(TransactionDraft d) async {
    validate(d);
    final now = _clock();
    final inserted = await _db
        .into(_db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: _uuid.v4(),
            title: d.title.trim(),
            amountMinor: d.amountMinor,
            currency: d.currency,
            categoryId: d.categoryId,
            date: d.date,
            description: Value(_clean(d.description)),
            searchText: Value(searchKey(d.title, d.description)),
            paymentMethod: d.paymentMethod,
            type: d.type,
            recurringId: Value(d.recurringId),
            occurrenceKey: Value(d.occurrenceKey),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return inserted > 0;
  }

  Future<void> update(String id, TransactionDraft d) async {
    validate(d);
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        title: Value(d.title.trim()),
        amountMinor: Value(d.amountMinor),
        currency: Value(d.currency),
        categoryId: Value(d.categoryId),
        date: Value(d.date),
        description: Value(_clean(d.description)),
        searchText: Value(searchKey(d.title, d.description)),
        paymentMethod: Value(d.paymentMethod),
        type: Value(d.type),
        updatedAt: Value(_clock()),
      ),
    );
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();

  /// Normalised text used for case-insensitive search in any script.
  static String searchKey(String title, String? description) =>
      normalizeSearch('$title ${description ?? ''}');

  static String normalizeSearch(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[ʻʼ‘’`\']'), "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static String? _clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  Stream<TransactionRecord?> watchById(String id) => (_db.select(
    _db.transactions,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<TransactionRecord?> getById(String id) => (_db.select(
    _db.transactions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Transactions with `start <= date < end`, newest first.
  Stream<List<TransactionRecord>> watchRange(DateRange range) =>
      (_db.select(_db.transactions)
            ..where(
              (t) =>
                  t.date.isBiggerOrEqualValue(range.start) &
                  t.date.isSmallerThanValue(range.end),
            )
            ..orderBy([
              (t) => OrderingTerm.desc(t.date),
              (t) => OrderingTerm.desc(t.createdAt),
            ]))
          .watch();

  Future<List<TransactionRecord>> getRange(DateRange range) =>
      (_db.select(_db.transactions)
            ..where(
              (t) =>
                  t.date.isBiggerOrEqualValue(range.start) &
                  t.date.isSmallerThanValue(range.end),
            )
            ..orderBy([
              (t) => OrderingTerm.desc(t.date),
              (t) => OrderingTerm.desc(t.createdAt),
            ]))
          .get();

  Stream<List<TransactionRecord>> watchRecent(int limit) =>
      (_db.select(_db.transactions)
            ..orderBy([
              (t) => OrderingTerm.desc(t.date),
              (t) => OrderingTerm.desc(t.createdAt),
            ])
            ..limit(limit))
          .watch();

  /// Filtered, sorted, paginated query for the transactions list.
  Stream<List<TransactionRecord>> watchQuery(
    TransactionQuery q, {
    required int limit,
  }) {
    final s = _db.select(_db.transactions);
    s.where((t) {
      Expression<bool> e = const Constant(true);
      if (q.type != null) e = e & t.type.equalsValue(q.type);
      if (q.categoryIds.isNotEmpty) e = e & t.categoryId.isIn(q.categoryIds);
      if (q.range != null) {
        e =
            e &
            t.date.isBiggerOrEqualValue(q.range!.start) &
            t.date.isSmallerThanValue(q.range!.end);
      }
      final text = normalizeSearch(q.search).replaceAll(RegExp('[%_]'), '');
      if (text.isNotEmpty) {
        e = e & t.searchText.like('%$text%');
      }
      return e;
    });
    s.orderBy([
      switch (q.sort) {
        TransactionSort.dateDesc => (t) => OrderingTerm.desc(t.date),
        TransactionSort.dateAsc => (t) => OrderingTerm.asc(t.date),
        TransactionSort.amountDesc => (t) => OrderingTerm.desc(t.amountMinor),
        TransactionSort.amountAsc => (t) => OrderingTerm.asc(t.amountMinor),
      },
      (t) => OrderingTerm.desc(t.createdAt),
    ]);
    s.limit(limit);
    return s.watch();
  }

  /// All-time per-currency sums for income and expense, computed in SQL so
  /// large histories don't have to be loaded into memory.
  Stream<({MultiCurrencyAmount income, MultiCurrencyAmount expense})>
  watchAllTimeTotals() {
    final t = _db.transactions;
    final sum = t.amountMinor.sum();
    final q = _db.selectOnly(t)
      ..addColumns([t.type, t.currency, sum])
      ..groupBy([t.type, t.currency]);
    return q.watch().map((rows) {
      var income = MultiCurrencyAmount();
      var expense = MultiCurrencyAmount();
      for (final r in rows) {
        final type = t.type.converter.fromSql(r.read(t.type)!);
        final cur = t.currency.converter.fromSql(r.read(t.currency)!);
        final v = r.read(sum) ?? 0;
        if (type == TransactionType.income) {
          income = income.add(cur, v);
        } else {
          expense = expense.add(cur, v);
        }
      }
      return (income: income, expense: expense);
    });
  }

  Future<int> count() async {
    final c = _db.transactions.id.count();
    final r = await (_db.selectOnly(
      _db.transactions,
    )..addColumns([c])).getSingle();
    return r.read(c) ?? 0;
  }

  Future<List<TransactionRecord>> all() => (_db.select(
    _db.transactions,
  )..orderBy([(t) => OrderingTerm.asc(t.date)])).get();
}
