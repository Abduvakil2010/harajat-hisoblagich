import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/finance/savings_calculator.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/states.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final goals = ref.watch(savingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.savingsGoals)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.newGoal),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.newGoal),
      ),
      body: AsyncView(
        value: goals,
        builder: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.savings_rounded,
              title: l.emptyGoalsTitle,
              message: l.emptyGoalsBody,
              actionLabel: l.newGoal,
              onAction: () => context.push(Routes.newGoal),
            );
          }
          final active = list.where((g) => !g.isCompleted).toList();
          final done = list.where((g) => g.isCompleted).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Insets.lg,
              Insets.sm,
              Insets.lg,
              96,
            ),
            children: [
              for (final g in active) ...[
                GoalCard(g),
                const SizedBox(height: Insets.md),
              ],
              if (done.isNotEmpty) ...[
                SectionHeader(l.completedGoals),
                for (final g in done) ...[
                  GoalCard(g),
                  const SizedBox(height: Insets.md),
                ],
              ],
              Padding(
                padding: const EdgeInsets.all(Insets.sm),
                child: Text(
                  l.savingsAccountingNote,
                  style: context.text.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard(this.p, {super.key});
  final SavingsProgress p;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color = Color(p.goal.color);
    return AppCard(
      onTap: () => context.push(Routes.goal(p.goal.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: AppIcons.of(p.goal.iconKey), color: color),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.goal.name,
                      style: context.text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      p.isCompleted
                          ? l.completed
                          : (p.goal.targetDate == null
                                ? l.noDeadline
                                : l.byDate(
                                    context.dates.day(p.goal.targetDate!),
                                  )),
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${(p.ratio * 100).round()}%',
                style: context.text.titleMedium?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: Insets.md),
          AppProgressBar(value: p.ratio, color: color, height: 8),
          const SizedBox(height: Insets.sm),
          Row(
            children: [
              Expanded(
                child: AmountText(p.saved, style: context.text.bodyMedium),
              ),
              Text(' / ', style: context.text.bodySmall),
              AmountText(
                p.target,
                style: context.text.bodySmall?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
