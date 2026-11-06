import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobai/core/finance/budget_calculator.dart';
import 'package:hisobai/core/finance/ledger.dart';
import 'package:hisobai/core/localization/l10n.dart';
import 'package:hisobai/core/money/currency.dart';
import 'package:hisobai/core/money/currency_converter.dart';
import 'package:hisobai/core/utils/date_range.dart';
import 'package:hisobai/data/local/app_database.dart';
import 'package:hisobai/data/models/enums.dart';
import 'package:hisobai/features/ai_assistant/engine/assistant_engine.dart';
import 'package:hisobai/features/ai_assistant/engine/financial_analysis_engine.dart';
import 'package:hisobai/features/ai_assistant/engine/financial_snapshot.dart';
import 'package:hisobai/features/ai_assistant/engine/findings.dart';
import 'package:hisobai/features/ai_assistant/engine/intent_classifier.dart';
import 'package:hisobai/features/ai_assistant/engine/monthly_comparison_engine.dart';
import 'package:hisobai/features/ai_assistant/engine/spending_pattern_analyzer.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers.dart';

CategoryRecord cat(int id, String key, TransactionType type) => CategoryRecord(
  id: id,
  key: key,
  type: type,
  iconKey: 'category',
  color: 0,
  isDefault: true,
  sortOrder: id,
);

final categories = {
  1: cat(1, 'food', TransactionType.expense),
  2: cat(2, 'transport', TransactionType.expense),
  3: cat(3, 'shopping', TransactionType.expense),
  20: cat(20, 'salary', TransactionType.income),
};

FinancialSnapshot snapshot(
  List<TransactionRecord> txs, {
  DateTime? now,
  List<BudgetStatus> budgets = const [],
}) => FinancialSnapshot(
  now: now ?? DateTime(2026, 11, 20),
  currency: Currency.uzs,
  ledger: Ledger(txs, Currency.uzs, CurrencyConverter.empty),
  budgets: budgets,
  goals: const [],
  debts: const [],
  categories: categories,
);

void main() {
  setUpAll(() => initializeDateFormatting());

  group('IntentClassifier (uz / ru / en)', () {
    const c = IntentClassifier();
    final cats = categories.values.toList();

    test('top category', () {
      expect(
        c.parse('Bu oyda eng ko‘p pulim nimaga ketdi?', cats).intent,
        AssistantIntent.topCategory,
      );
      expect(
        c.parse('На что ушло больше всего денег?', cats).intent,
        AssistantIntent.topCategory,
      );
      expect(
        c.parse('Where did most of my money go?', cats).intent,
        AssistantIntent.topCategory,
      );
    });

    test('savings this month and tips', () {
      expect(
        c.parse('Bu oy qancha pul jamg‘ardim?', cats).intent,
        AssistantIntent.savedThisMonth,
      );
      expect(
        c.parse('Сколько я сэкономил в этом месяце?', cats).intent,
        AssistantIntent.savedThisMonth,
      );
      expect(
        c.parse('Qanday qilib pul tejashim mumkin?', cats).intent,
        AssistantIntent.savingTips,
      );
      expect(
        c.parse('How can I save money?', cats).intent,
        AssistantIntent.savingTips,
      );
    });

    test('category questions and periods', () {
      final q = c.parse('How much did I spend on food last month?', cats);
      expect(q.intent, AssistantIntent.categorySpend);
      expect(q.categoryId, 1);
      expect(q.period, AskedPeriod.lastMonth);
      expect(c.parse('Сколько ушло на такси?', cats).categoryId, 2);
      expect(
        c.parse('Internet uchun qancha?', cats).intent,
        isNot(AssistantIntent.savedThisMonth),
      );
    });

    test('budgets, debts, comparison, unknown', () {
      expect(
        c.parse('Byudjetim qanday?', cats).intent,
        AssistantIntent.budgetStatus,
      );
      expect(c.parse('Мои долги', cats).intent, AssistantIntent.debts);
      expect(
        c.parse('Compare with last month', cats).intent,
        AssistantIntent.compareMonths,
      );
      expect(c.parse('qwerty', cats).intent, AssistantIntent.unknown);
    });
  });

  group('Analysis', () {
    final txs = [
      tx(
        amount: m(5000000),
        type: TransactionType.income,
        categoryId: 20,
        date: DateTime(2026, 11, 1),
      ),
      tx(amount: m(320000), categoryId: 1, date: DateTime(2026, 11, 3)),
      tx(amount: m(100000), categoryId: 2, date: DateTime(2026, 11, 4)),
      tx(amount: m(80000), categoryId: 3, date: DateTime(2026, 11, 5)),
      // October baseline
      tx(amount: m(100000), categoryId: 1, date: DateTime(2026, 10, 3)),
      tx(amount: m(100000), categoryId: 2, date: DateTime(2026, 10, 4)),
    ];
    final s = snapshot(txs);

    test('top category share is computed from records', () {
      final f = const SpendingPatternAnalyzer().topCategory(
        s,
        s.thisMonth,
      ) as TopCategory;
      expect(f.categoryId, 1);
      expect(f.amount.minor, m(320000));
      expect((f.share * 100).round(), 64); // 320 / 500
    });

    test('month comparison uses the same number of days', () {
      final f = const MonthlyComparisonEngine().compare(s) as MonthComparison;
      expect(f.days, 20);
      expect(f.currentExpense.minor, m(500000));
      expect(f.previousExpense.minor, m(200000));
      expect(f.expenseChange, closeTo(1.5, 1e-9));
    });

    test('detects an unusual category increase', () {
      final inc = const SpendingPatternAnalyzer().unusualIncreases(s);
      expect(inc.first.categoryId, 1);
      expect(inc.first.ratio, closeTo(3.2, 1e-9));
    });

    test('insufficient data produces no dashboard insights', () {
      expect(
        const FinancialAnalysisEngine().dashboardInsights(snapshot(const [])),
        isEmpty,
      );
    });
  });

  group('LocalAssistantEngine answers', () {
    const engine = LocalAssistantEngine();
    final txs = [
      tx(
        amount: m(1000000),
        type: TransactionType.income,
        categoryId: 20,
        date: DateTime(2026, 11, 1),
      ),
      tx(amount: m(100000), categoryId: 1, date: DateTime(2026, 11, 2)),
      tx(amount: m(50000), categoryId: 2, date: DateTime(2026, 11, 3)),
    ];

    test('answers in Uzbek with real numbers', () async {
      final l = lookupAppLocalizations(const Locale('uz'));
      final r = await engine.reply(
        'Bu oy qancha pul jamg‘ardim?',
        snapshot(txs),
        l,
      );
      expect(r.insufficientData, isFalse);
      expect(r.text, contains('850'));
      final top = await engine.reply(
        'eng ko‘p pul nimaga ketdi',
        snapshot(txs),
        l,
      );
      expect(top.text, contains('Oziq-ovqat'));
      expect(top.text, contains('67'));
    });

    test('answers in Russian and English', () async {
      final ru = await engine.reply(
        'Сколько я потратил?',
        snapshot(txs),
        lookupAppLocalizations(const Locale('ru')),
      );
      expect(ru.text, contains('150'));
      final en = await engine.reply(
        'How can I save money?',
        snapshot(txs),
        lookupAppLocalizations(const Locale('en')),
      );
      expect(en.text, contains('not professional financial advice'));
    });

    test('flags insufficient data instead of inventing numbers', () async {
      final l = lookupAppLocalizations(const Locale('en'));
      final r = await engine.reply(
        'Where did most of my money go?',
        snapshot(const []),
        l,
      );
      expect(r.insufficientData, isTrue);
      expect(r.text, l.aiNoTransactions);
      final cmp = await engine.reply(
        'Compare with last month',
        snapshot(txs),
        l,
      );
      expect(cmp.insufficientData, isTrue);
    });

    test('budget status uses actual budget evaluation', () async {
      final l = lookupAppLocalizations(const Locale('en'));
      final budgets = const BudgetCalculator().evaluate(
        budgets: [
          BudgetRecord(
            id: 1,
            limitMinor: m(160000),
            currency: Currency.uzs,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ],
        transactions: txs,
        converter: CurrencyConverter.empty,
        month: DateRange.month(DateTime(2026, 11)),
      );
      final r = await engine.reply(
        'How is my budget?',
        snapshot(txs, budgets: budgets),
        l,
      );
      expect(r.text, contains('94%'));
    });
  });
}
