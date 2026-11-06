import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hisobai/core/money/currency.dart';
import 'package:hisobai/data/local/app_database.dart';
import 'package:hisobai/data/models/enums.dart';

int _seq = 0;

/// Builds an in-memory transaction record for pure calculation tests.
TransactionRecord tx({
  required int amount,
  TransactionType type = TransactionType.expense,
  Currency currency = Currency.uzs,
  int categoryId = 1,
  required DateTime date,
  String title = 'Test',
}) {
  _seq++;
  return TransactionRecord(
    id: 'tx$_seq',
    title: title,
    amountMinor: amount,
    currency: currency,
    categoryId: categoryId,
    date: date,
    paymentMethod: PaymentMethod.cash,
    type: type,
    searchText: title.toLowerCase(),
    createdAt: date,
    updatedAt: date,
  );
}

/// Major units → minor units helper (100 minor per unit).
int m(num major) => (major * 100).round();

/// A fresh in-memory database with default categories seeded.
AppDatabase testDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

Future<int> categoryIdByKey(AppDatabase db, String key) async =>
    (await (db.select(
      db.categories,
    )..where((c) => c.key.equals(key))).getSingle()).id;
