import 'dart:convert';

import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../models/app_settings.dart';

class InvalidBackupException implements Exception {
  const InvalidBackupException(this.reason);
  final String reason;
  @override
  String toString() => 'InvalidBackupException: $reason';
}

/// A parsed, validated backup ready to be restored.
class BackupSnapshot {
  const BackupSnapshot(this.json);
  final Map<String, Object?> json;

  DateTime? get exportedAt =>
      DateTime.tryParse(json['exportedAt'] as String? ?? '');
  int count(String table) =>
      ((json['data'] as Map)[table] as List?)?.length ?? 0;
  AppSettings? get settings {
    final s = json['settings'];
    return s is Map<String, Object?> ? AppSettings.fromJson(s) : null;
  }
}

/// Full JSON export / import of every local table.
///
/// The file is plain JSON (not encrypted) – the UI warns users to store it
/// somewhere safe.
class BackupRepository {
  BackupRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const format = 'hisobai-backup';
  static const version = 1;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Future<Map<String, Object?>> exportJson(AppSettings settings) async {
    List<Map<String, dynamic>> rows(List<DataClass> list) => [
      for (final r in list) r.toJson(),
    ];
    return {
      'format': format,
      'version': version,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': _clock().toUtc().toIso8601String(),
      'settings': settings.copyWith(lastCloudBackupAt: () => null).toJson(),
      'data': {
        'categories': rows(await _db.select(_db.categories).get()),
        'transactions': rows(await _db.select(_db.transactions).get()),
        'budgets': rows(await _db.select(_db.budgets).get()),
        'exchangeRates': rows(await _db.select(_db.exchangeRates).get()),
        'recurringPayments': rows(
          await _db.select(_db.recurringPayments).get(),
        ),
        'savingsGoals': rows(await _db.select(_db.savingsGoals).get()),
        'savingsEntries': rows(await _db.select(_db.savingsEntries).get()),
        'debts': rows(await _db.select(_db.debts).get()),
        'debtPayments': rows(await _db.select(_db.debtPayments).get()),
      },
    };
  }

  Future<String> exportString(AppSettings settings) async =>
      const JsonEncoder.withIndent(' ').convert(await exportJson(settings));

  /// Parses and validates a backup without touching the database.
  BackupSnapshot parse(String raw) {
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const InvalidBackupException('not_json');
    }
    if (decoded is! Map<String, Object?>) {
      throw const InvalidBackupException('not_object');
    }
    if (decoded['format'] != format) {
      throw const InvalidBackupException('wrong_format');
    }
    final v = decoded['version'];
    if (v is! int || v > version) {
      throw const InvalidBackupException('unsupported_version');
    }
    final data = decoded['data'];
    if (data is! Map) throw const InvalidBackupException('no_data');
    // Decode everything once to validate types before restoring.
    try {
      _decodeAll(data);
    } catch (_) {
      throw const InvalidBackupException('corrupted');
    }
    return BackupSnapshot(decoded);
  }

  _Decoded _decodeAll(Map data) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) => [
      for (final e in (data[key] as List? ?? const []))
        f(Map<String, dynamic>.from(e as Map)),
    ];
    return _Decoded(
      categories: list('categories', CategoryRecord.fromJson),
      transactions: list('transactions', TransactionRecord.fromJson),
      budgets: list('budgets', BudgetRecord.fromJson),
      rates: list('exchangeRates', ExchangeRateRecord.fromJson),
      recurring: list('recurringPayments', RecurringPaymentRecord.fromJson),
      goals: list('savingsGoals', SavingsGoalRecord.fromJson),
      entries: list('savingsEntries', SavingsEntryRecord.fromJson),
      debts: list('debts', DebtRecord.fromJson),
      payments: list('debtPayments', DebtPaymentRecord.fromJson),
    );
  }

  /// Replaces **all** local data with the snapshot, atomically. If anything
  /// fails, the transaction is rolled back and existing data is kept.
  Future<void> restore(BackupSnapshot snapshot) async {
    final d = _decodeAll(snapshot.json['data'] as Map);
    await _db.transaction(() async {
      for (final t in <TableInfo<Table, Object?>>[
        _db.chatMessages,
        _db.debtPayments,
        _db.debts,
        _db.savingsEntries,
        _db.savingsGoals,
        _db.budgets,
        _db.transactions,
        _db.recurringPayments,
        _db.exchangeRates,
        _db.categories,
      ]) {
        await _db.delete(t).go();
      }
      await _db.batch((b) {
        b.insertAll(_db.categories, d.categories);
        b.insertAll(_db.exchangeRates, d.rates);
        b.insertAll(_db.recurringPayments, d.recurring);
        b.insertAll(_db.transactions, d.transactions);
        b.insertAll(_db.budgets, d.budgets);
        b.insertAll(_db.savingsGoals, d.goals);
        b.insertAll(_db.savingsEntries, d.entries);
        b.insertAll(_db.debts, d.debts);
        b.insertAll(_db.debtPayments, d.payments);
      });
      await _db.seedDefaultCategories();
    });
  }
}

class _Decoded {
  _Decoded({
    required this.categories,
    required this.transactions,
    required this.budgets,
    required this.rates,
    required this.recurring,
    required this.goals,
    required this.entries,
    required this.debts,
    required this.payments,
  });

  final List<CategoryRecord> categories;
  final List<TransactionRecord> transactions;
  final List<BudgetRecord> budgets;
  final List<ExchangeRateRecord> rates;
  final List<RecurringPaymentRecord> recurring;
  final List<SavingsGoalRecord> goals;
  final List<SavingsEntryRecord> entries;
  final List<DebtRecord> debts;
  final List<DebtPaymentRecord> payments;
}
