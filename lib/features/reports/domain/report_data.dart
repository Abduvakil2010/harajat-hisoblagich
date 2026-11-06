import '../../../core/finance/budget_calculator.dart';
import '../../../core/finance/ledger.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/currency_converter.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/date_range.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/enums.dart';

/// Plain, isolate-safe localized labels for reports.
class ReportLabels {
  const ReportLabels(this.values, this.locale);

  final Map<String, String> values;
  final String locale;

  String operator [](String key) => values[key] ?? key;
}

class ReportRow {
  const ReportRow({
    required this.date,
    required this.title,
    required this.category,
    required this.type,
    required this.amount,
    required this.converted,
    required this.paymentMethod,
    this.description,
  });

  final DateTime date;
  final String title;
  final String category;
  final TransactionType type;

  /// Original amount in its own currency.
  final Money amount;

  /// Value in the report currency at the transaction-date rate (null when no
  /// rate exists).
  final Money? converted;
  final String paymentMethod;
  final String? description;
}

class ReportCategoryLine {
  const ReportCategoryLine(
    this.name,
    this.type,
    this.amount,
    this.share,
    this.count,
  );
  final String name;
  final TransactionType type;
  final Money amount;
  final double share;
  final int count;
}

class ReportBudgetLine {
  const ReportBudgetLine(this.name, this.limit, this.spent, this.ratio);
  final String name;
  final Money limit;
  final Money spent;
  final double ratio;
  Money get remaining => limit - spent;
}

/// Everything a PDF / Excel report contains. Built from real records only.
class ReportData {
  const ReportData({
    required this.period,
    required this.currency,
    required this.income,
    required this.expense,
    required this.net,
    required this.categories,
    required this.rows,
    required this.budgets,
    required this.budgetMonth,
    required this.generatedAt,
    required this.rates,
  });

  final DateRange period;
  final Currency currency;
  final ConvertedSum income;
  final ConvertedSum expense;
  final ConvertedSum net;
  final List<ReportCategoryLine> categories;
  final List<ReportRow> rows;
  final List<ReportBudgetLine> budgets;
  final DateTime budgetMonth;
  final DateTime generatedAt;

  /// Rates that were available when the report was generated.
  final List<ExchangeRateQuote> rates;

  bool get isEmpty => rows.isEmpty;

  static ReportData build({
    required DateRange period,
    required List<TransactionRecord> transactions,
    required Currency currency,
    required CurrencyConverter converter,
    required Map<int, CategoryRecord> categories,
    required String Function(CategoryRecord?) categoryName,
    required String Function(PaymentMethod) paymentLabel,
    required List<BudgetRecord> budgets,
    required DateTime now,
  }) {
    final inPeriod = transactions.where((t) => period.contains(t.date)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final ledger = Ledger(inPeriod, currency, converter);

    final cats = <ReportCategoryLine>[
      for (final type in TransactionType.values)
        for (final s in ledger.byCategory(type, period))
          ReportCategoryLine(
            categoryName(categories[s.categoryId]),
            type,
            Money(s.minor, currency),
            s.share,
            s.count,
          ),
    ];

    final rows = [
      for (final t in inPeriod)
        ReportRow(
          date: t.date,
          title: t.title,
          category: categoryName(categories[t.categoryId]),
          type: t.type,
          amount: Money(t.amountMinor, t.currency),
          converted: ledger.valueOf(t) == null
              ? null
              : Money(ledger.valueOf(t)!, currency),
          paymentMethod: paymentLabel(t.paymentMethod),
          description: t.description,
        ),
    ];

    // Budgets are monthly: evaluate them for the month in which the period ends.
    final last = period.lastDay;
    final budgetMonth = DateRange.month(last);
    final statuses = const BudgetCalculator().evaluate(
      budgets: budgets,
      transactions: transactions,
      converter: converter,
      month: budgetMonth,
    );

    return ReportData(
      period: period,
      currency: currency,
      income: ledger.total(TransactionType.income, period),
      expense: ledger.total(TransactionType.expense, period),
      net: ledger.net(period),
      categories: cats,
      rows: rows,
      budgets: [
        for (final s in statuses)
          ReportBudgetLine(
            s.isTotal ? '' : categoryName(categories[s.budget.categoryId]),
            s.limitMoney,
            s.spentMoney,
            s.ratio,
          ),
      ],
      budgetMonth: budgetMonth.start,
      generatedAt: now,
      rates: converter.quotes,
    );
  }
}
