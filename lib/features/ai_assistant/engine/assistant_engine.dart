import '../../../core/localization/l10n.dart';
import '../../../data/models/enums.dart';
import 'ai_response_generator.dart';
import 'financial_analysis_engine.dart';
import 'financial_snapshot.dart';
import 'findings.dart';
import 'intent_classifier.dart';

/// A reply from the assistant.
class AssistantReply {
  const AssistantReply(this.text, {this.insufficientData = false});
  final String text;
  final bool insufficientData;
}

/// Contract for any assistant implementation.
///
/// The app ships with [LocalAssistantEngine] (rule-based, offline). A future
/// LLM-backed engine can implement this interface – e.g. by sending an
/// anonymised [FinancialSnapshot] summary to an API – without changing the
/// chat UI or the data layer.
abstract interface class AssistantEngine {
  Future<AssistantReply> reply(
    String message,
    FinancialSnapshot snapshot,
    AppLocalizations l,
  );
}

/// Offline, rule-based assistant. Every number in its answers is computed
/// from the snapshot; it never fabricates records.
class LocalAssistantEngine implements AssistantEngine {
  const LocalAssistantEngine({
    this.classifier = const IntentClassifier(),
    this.analysis = const FinancialAnalysisEngine(),
  });

  final IntentClassifier classifier;
  final FinancialAnalysisEngine analysis;

  @override
  Future<AssistantReply> reply(
    String message,
    FinancialSnapshot s,
    AppLocalizations l,
  ) async {
    final q = classifier.parse(message, s.categories.values.toList());
    final gen = AIResponseGenerator(l, s.categories, now: s.now);
    final period = q.period == AskedPeriod.lastMonth
        ? s.lastMonth
        : s.thisMonth;
    final p = analysis.patterns;
    final c = analysis.comparison;
    final r = analysis.recommendations;

    final dataIntents = {
      AssistantIntent.topCategory,
      AssistantIntent.spentTotal,
      AssistantIntent.categorySpend,
      AssistantIntent.savedThisMonth,
      AssistantIntent.savingTips,
      AssistantIntent.compareMonths,
      AssistantIntent.incomeVsExpense,
      AssistantIntent.unusualSpending,
      AssistantIntent.largestExpense,
    };
    if (dataIntents.contains(q.intent) && !s.hasAnyTransactions) {
      return AssistantReply(l.aiNoTransactions, insufficientData: true);
    }

    AssistantReply fromFindings(
      List<Finding> fs, {
      bool advice = false,
      String? intro,
    }) {
      final insufficient =
          fs.isNotEmpty && fs.every((f) => f is InsufficientData);
      final buffer = StringBuffer();
      if (intro != null) buffer.writeln(intro);
      buffer.write(fs.map(gen.render).join('\n'));
      if (advice && !insufficient) buffer.write('\n\n${l.aiDisclaimer}');
      return AssistantReply(
        buffer.toString().trim(),
        insufficientData: insufficient,
      );
    }

    switch (q.intent) {
      case AssistantIntent.greeting:
        return AssistantReply(l.aiGreeting);
      case AssistantIntent.help:
        return AssistantReply(l.aiHelp);
      case AssistantIntent.topCategory:
        final f = p.topCategory(s, period);
        if (f is TopCategory && f.runnersUp.isNotEmpty) {
          final rest = f.runnersUp
              .map(
                (e) =>
                    '${l.categoryName(s.categories[e.$1])} — ${(e.$2 * 100).round()}%',
              )
              .join(', ');
          return AssistantReply(
            '${gen.render(f)}\n${l.aiNextCategories(rest)}',
          );
        }
        return fromFindings([f]);
      case AssistantIntent.spentTotal:
      case AssistantIntent.incomeVsExpense:
        return fromFindings([p.periodTotal(s, period)]);
      case AssistantIntent.categorySpend:
        return fromFindings([p.categorySpend(s, q.categoryId!, period)]);
      case AssistantIntent.savedThisMonth:
        if (q.period == AskedPeriod.lastMonth) {
          final t = p.periodTotal(s, period);
          if (t is PeriodTotal) {
            return fromFindings([
              SavingsRate(income: t.income, expense: t.expense, period: period),
            ]);
          }
          return fromFindings([t]);
        }
        return fromFindings([c.savingsRate(s)]);
      case AssistantIntent.compareMonths:
        return fromFindings([c.compare(s)]);
      case AssistantIntent.unusualSpending:
        final inc = p.unusualIncreases(s);
        final trends = p.risingTrends(s);
        if (inc.isEmpty && trends.isEmpty) {
          final hasHistory = s
              .previousMonths(3)
              .any((m) => s.ledger.count(TransactionType.expense, m) > 0);
          return AssistantReply(
            hasHistory ? l.aiNoUnusual : l.aiNoPreviousMonth,
            insufficientData: !hasHistory,
          );
        }
        return fromFindings([...inc.take(3), ...trends.take(2)]);
      case AssistantIntent.largestExpense:
        return fromFindings([p.largestExpense(s, period)]);
      case AssistantIntent.budgetStatus:
        final fs = r.budgetFindings(s);
        final sugg = r.suggestions(s, max: 1);
        return fromFindings([...fs.take(4), ...sugg], advice: sugg.isNotEmpty);
      case AssistantIntent.goals:
        return fromFindings(r.goalFindings(s).take(4).toList());
      case AssistantIntent.debts:
        return fromFindings([r.debtFinding(s)]);
      case AssistantIntent.balance:
        final b = s.balance;
        if (b == null || b.parts.isEmpty) {
          return AssistantReply(l.aiNoTransactions, insufficientData: true);
        }
        return AssistantReply(gen.render(b));
      case AssistantIntent.savingTips:
        return _tips(s, gen, l);
      case AssistantIntent.unknown:
        return AssistantReply(l.aiUnknown);
    }
  }

  AssistantReply _tips(
    FinancialSnapshot s,
    AIResponseGenerator gen,
    AppLocalizations l,
  ) {
    final p = analysis.patterns;
    final tips = <String>[];

    final top = p.topCategory(
      s,
      s.ledger.count(TransactionType.expense, s.thisMonth) > 0
          ? s.thisMonth
          : s.lastMonth,
    );
    if (top is TopCategory) {
      tips.add(l.aiTipTopCategory(gen.render(top)));
    }
    for (final inc in p.unusualIncreases(s).take(1)) {
      tips.add(l.aiTipIncrease(gen.render(inc)));
    }
    for (final sug in analysis.recommendations.suggestions(s, max: 2)) {
      tips.add(gen.render(sug));
    }
    final rate = analysis.comparison.savingsRate(s);
    if (rate is SavingsRate && rate.rate != null) {
      tips.add(
        rate.rate! < 0.1
            ? l.aiTipSaveMore
            : l.aiTipKeepSaving((rate.rate! * 100).round().toString()),
      );
    }
    final noGoals = s.goals.where((g) => !g.isCompleted).isEmpty;
    if (noGoals) tips.add(l.aiTipCreateGoal);

    if (tips.isEmpty) {
      return AssistantReply(l.aiNoTransactions, insufficientData: true);
    }
    final body = [for (var i = 0; i < tips.length; i++) '${i + 1}. ${tips[i]}']
        .join('\n');
    return AssistantReply('${l.aiTipsIntro}\n$body\n\n${l.aiDisclaimer}');
  }
}
