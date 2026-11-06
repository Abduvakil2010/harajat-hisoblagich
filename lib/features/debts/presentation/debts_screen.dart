import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/finance/debt_calculator.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/money.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/states.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final debts = ref.watch(debtsProvider);
    final now = ref.watch(clockProvider)();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.debts),
          bottom: TabBar(
            tabs: [
              Tab(text: l.debtActive),
              Tab(text: l.debtOverdue),
              Tab(text: l.debtCompleted),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(Routes.newDebt),
          icon: const Icon(Icons.add_rounded),
          label: Text(l.addDebt),
        ),
        body: AsyncView(
          value: debts,
          builder: (all) {
            final totals = DebtCalculator.totals(all);
            List<DebtState> by(DebtStatus s) =>
                all.where((d) => d.statusAt(now) == s).toList();
            Widget list(List<DebtState> items) => items.isEmpty
                ? EmptyState(
                    icon: Icons.handshake_rounded,
                    title: l.emptyDebtsTitle,
                    message: l.emptyDebtsBody,
                    compact: true,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      Insets.lg,
                      0,
                      Insets.lg,
                      96,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Insets.sm),
                    itemBuilder: (_, i) => DebtTile(items[i], now: now),
                  );
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(Insets.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TotalCard(
                          label: l.totalIOwe,
                          amounts: totals.iOwe.toMoneyList(),
                          color: context.palette.expense,
                        ),
                      ),
                      const SizedBox(width: Insets.md),
                      Expanded(
                        child: _TotalCard(
                          label: l.totalOwedToMe,
                          amounts: totals.owedToMe.toMoneyList(),
                          color: context.palette.income,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      list(by(DebtStatus.active)),
                      list(by(DebtStatus.overdue)),
                      list(by(DebtStatus.completed)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.label,
    required this.amounts,
    required this.color,
  });
  final String label;
  final List<Money> amounts;
  final Color color;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(Insets.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.labelMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Insets.xs),
        if (amounts.isEmpty)
          Text('0', style: context.text.titleMedium?.copyWith(color: color))
        else
          for (final m in amounts)
            AmountText(
              m,
              style: context.text.titleMedium?.copyWith(color: color),
            ),
      ],
    ),
  );
}

class DebtTile extends StatelessWidget {
  const DebtTile(this.s, {super.key, required this.now});
  final DebtState s;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final status = s.statusAt(now);
    final owe = s.debt.direction == DebtDirection.iOwe;
    final color = owe ? context.palette.expense : context.palette.income;
    return AppCard(
      onTap: () => context.push(Routes.debt(s.debt.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(
                icon: owe
                    ? Icons.call_made_rounded
                    : Icons.call_received_rounded,
                color: color,
                size: 40,
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.debt.counterparty,
                      style: context.text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      [
                        l.debtDirectionLabel(s.debt.direction),
                        if (s.debt.dueDate != null)
                          l.dueOn(context.dates.day(s.debt.dueDate!)),
                      ].join(' · '),
                      style: context.text.bodySmall?.copyWith(
                        color: status == DebtStatus.overdue
                            ? context.palette.expense
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AmountText(
                    s.remaining,
                    style: context.text.titleSmall?.copyWith(color: color),
                  ),
                  Text(
                    l.ofAmount(context.money.format(s.original)),
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Insets.md),
          AppProgressBar(value: s.ratioPaid, color: color, height: 6),
        ],
      ),
    );
  }
}
