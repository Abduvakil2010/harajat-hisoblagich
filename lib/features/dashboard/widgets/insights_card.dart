import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/finance_providers.dart';
import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/finance/budget_calculator.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/widgets/app_card.dart';
import '../../ai_assistant/engine/ai_response_generator.dart';
import '../../ai_assistant/engine/financial_analysis_engine.dart';
import '../../ai_assistant/engine/findings.dart';

/// Short, data-driven insights. Hidden entirely when there is too little
/// data to say anything reliable.
class InsightsCard extends ConsumerWidget {
  const InsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final snapshot = ref.watch(financialSnapshotProvider).value;
    final categories = ref.watch(categoryMapProvider);
    if (snapshot == null) return const SizedBox.shrink();

    final findings = const FinancialAnalysisEngine().dashboardInsights(
      snapshot,
    );
    final gen = AIResponseGenerator(l, categories, now: snapshot.now);

    return Column(
      children: [
        SectionHeader(
          l.insights,
          actionLabel: l.askAssistant,
          onAction: () => context.go(Routes.assistant),
        ),
        AppCard(
          child: findings.isEmpty
              ? Row(
                  children: [
                    IconTile(
                      icon: Icons.auto_awesome,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: Insets.md),
                    Expanded(
                      child: Text(
                        l.insightsNotEnoughData,
                        style: context.text.bodyMedium,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    for (var i = 0; i < findings.length; i++) ...[
                      if (i > 0) const Divider(height: Insets.xl),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _icon(context, findings[i]),
                          const SizedBox(width: Insets.md),
                          Expanded(
                            child: Text(
                              gen.render(findings[i]),
                              style: context.text.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _icon(BuildContext context, Finding f) {
    final p = context.palette;
    final (icon, color) = switch (f) {
      BudgetAlert(:final status) when status.level == BudgetLevel.exceeded => (
        Icons.error_rounded,
        p.expense,
      ),
      BudgetAlert() => (Icons.warning_amber_rounded, p.warning),
      CategoryIncrease() ||
      RisingTrend() => (Icons.trending_up_rounded, p.expense),
      MonthComparison(:final expenseChange) when (expenseChange ?? 0) > 0 => (
        Icons.trending_up_rounded,
        p.warning,
      ),
      MonthComparison() => (Icons.trending_down_rounded, p.income),
      BudgetOk() => (Icons.verified_rounded, p.income),
      GoalProgress() => (Icons.flag_rounded, p.accent),
      _ => (Icons.auto_awesome, context.colors.primary),
    };
    return IconTile(icon: icon, color: color, size: 36);
  }
}
