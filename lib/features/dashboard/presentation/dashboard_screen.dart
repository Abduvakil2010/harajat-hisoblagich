import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/finance_providers.dart';
import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/finance/budget_calculator.dart';
import '../../../core/finance/ledger.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/date_range.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/charts.dart';
import '../../../shared/widgets/states.dart';
import '../../transactions/widgets/transaction_tile.dart';
import '../widgets/insights_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final window = ref.watch(analysisWindowProvider);
    final ledger = ref.watch(ledgerProvider(window));
    final recent = ref.watch(recentTransactionsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(clockProvider),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              SliverPadding(
                padding: Insets.page,
                sliver: SliverList.list(
                  children: [
                    const _BalanceCard(),
                    const SizedBox(height: Insets.md),
                    AsyncView(
                      value: ledger,
                      builder: (lg) => _IncomeExpenseRow(ledger: lg),
                    ),
                    const _QuickActions(),
                    AsyncView(
                      value: ledger,
                      builder: (lg) => lg.isEmpty
                          ? const SizedBox.shrink()
                          : _ExpenseChartCard(ledger: lg),
                    ),
                    const _BudgetCard(),
                    const InsightsCard(),
                    SectionHeader(
                      l.recentTransactions,
                      actionLabel: l.viewAll,
                      onAction: () => context.push(Routes.transactions),
                    ),
                    AsyncView(
                      value: recent,
                      builder: (list) => list.isEmpty
                          ? AppCard(
                              child: EmptyState(
                                compact: true,
                                icon: Icons.receipt_long_rounded,
                                title: l.emptyTransactionsTitle,
                                message: l.emptyTransactionsBody,
                                actionLabel: l.addTransaction,
                                onAction: () =>
                                    context.push(Routes.newTransaction),
                              ),
                            )
                          : AppCard(
                              padding: const EdgeInsets.symmetric(
                                vertical: Insets.xs,
                                horizontal: Insets.xs,
                              ),
                              child: Column(
                                children: [
                                  for (final t in list) TransactionTile(t),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: Insets.xxxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final name = ref.watch(settingsProvider.select((s) => s.displayName));
    final hidden = ref.watch(settingsProvider.select((s) => s.hideAmounts));
    final hour = ref.watch(clockProvider)().hour;
    final greeting = hour < 12
        ? l.goodMorning
        : (hour < 18 ? l.goodAfternoon : l.goodEvening);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Insets.xl,
        Insets.lg,
        Insets.sm,
        Insets.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
                Text(
                  name ?? 'HisobAI',
                  style: context.text.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: hidden ? l.showAmounts : l.hideAmounts,
            onPressed: () => ref
                .read(settingsProvider.notifier)
                .update((s) => s.copyWith(hideAmounts: !hidden)),
            icon: Icon(
              hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            ),
          ),
          IconButton(
            tooltip: l.allTransactions,
            onPressed: () => context.push(Routes.transactions),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final balance = ref.watch(balanceProvider);
    final month = ref.watch(currentMonthProvider);
    final ledger = ref.watch(ledgerProvider(month));
    final hidden = ref.watch(settingsProvider.select((s) => s.hideAmounts));
    final fmt = context.money;
    const white = Colors.white;

    return AppCard(
      gradient: context.palette.heroGradient,
      padding: const EdgeInsets.all(Insets.xl),
      child: AsyncView(
        value: balance,
        builder: (b) {
          final net = ledger.value?.net(month);
          final converted = b.converted;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l.totalBalance,
                    style: context.text.bodyMedium?.copyWith(
                      color: white.withValues(alpha: 0.8),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ref
                          .watch(
                            settingsProvider.select((s) => s.primaryCurrency),
                          )
                          .code,
                      style: context.text.labelSmall?.copyWith(color: white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Insets.sm),
              if (converted != null)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    fmt.format(converted, hidden: hidden),
                    style: context.text.displayMedium?.copyWith(color: white),
                  ),
                )
              else ...[
                for (final m in b.raw.toMoneyList())
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      fmt.format(m, hidden: hidden),
                      style: context.text.displaySmall?.copyWith(color: white),
                    ),
                  ),
                if (b.raw.isEmpty)
                  Text(
                    fmt.format(
                      Money.zero(ref.watch(settingsProvider).primaryCurrency),
                      hidden: hidden,
                    ),
                    style: context.text.displayMedium?.copyWith(color: white),
                  ),
                const SizedBox(height: Insets.xs),
                InkWell(
                  onTap: () => context.push(Routes.rates),
                  child: Text(
                    l.balanceSeparateNote,
                    style: context.text.bodySmall?.copyWith(
                      color: white.withValues(alpha: 0.85),
                      decoration: TextDecoration.underline,
                      decorationColor: white,
                    ),
                  ),
                ),
              ],
              if (net != null && ledger.value!.count(null, month) > 0) ...[
                const SizedBox(height: Insets.md),
                _ChangeChip(net: net, balanceNow: converted, hidden: hidden),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  const _ChangeChip({
    required this.net,
    required this.balanceNow,
    required this.hidden,
  });

  final ConvertedSum net;
  final Money? balanceNow;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final positive = net.minor >= 0;
    String? pct;
    final now = balanceNow;
    if (now != null && now.currency == net.currency) {
      final start = now.minor - net.minor;
      if (start > 0) {
        pct =
            '${positive ? '+' : '−'}${(net.minor.abs() / start * 100).toStringAsFixed(1)}%';
      }
    }
    final text =
        '${context.money.format(net.money, hidden: hidden, signed: true)}${pct == null ? '' : '  ($pct)'}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$text ${l.thisMonthSuffix}',
              style: context.text.labelMedium?.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeExpenseRow extends ConsumerWidget {
  const _IncomeExpenseRow({required this.ledger});

  final Ledger ledger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final month = ref.watch(currentMonthProvider);
    final prev = month.previous();
    final now = ref.watch(clockProvider)();
    // Fair comparison: same number of days at the start of last month.
    final toDate = DateRange(
      month.start,
      DateTime(now.year, now.month, now.day + 1),
    );
    final prevSame = DateRange(
      prev.start,
      DateTime(
        prev.start.year,
        prev.start.month,
        prev.start.day + toDate.dayCount,
      ),
    );
    double? change(TransactionType t) {
      final before = ledger.total(t, prevSame).minor;
      if (before <= 0 || ledger.count(null, prev) == 0) return null;
      return (ledger.total(t, toDate).minor - before) / before;
    }

    Widget card(TransactionType type) {
      final isIncome = type == TransactionType.income;
      final color = isIncome ? context.palette.income : context.palette.expense;
      final sum = ledger.total(type, month);
      final c = change(type);
      return Expanded(
        child: AppCard(
          padding: const EdgeInsets.all(Insets.lg),
          onTap: () => context.push(Routes.transactions),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      isIncome
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      size: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: Insets.sm),
                  Expanded(
                    child: Text(
                      isIncome ? l.income : l.expenses,
                      style: context.text.labelMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Insets.md),
              ConvertedAmountText(sum, style: context.text.titleLarge),
              const SizedBox(height: Insets.xs),
              Text(
                c == null
                    ? l.thisMonth
                    : '${c >= 0 ? '↑' : '↓'} ${(c.abs() * 100).round()}% ${l.vsLastMonth}',
                style: context.text.bodySmall?.copyWith(
                  color: c == null
                      ? context.palette.textSecondary
                      : ((c >= 0) == isIncome
                            ? context.palette.income
                            : context.palette.expense),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        card(TransactionType.income),
        const SizedBox(width: Insets.md),
        card(TransactionType.expense),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      (Icons.pie_chart_rounded, l.budgets, Routes.budgets),
      (Icons.savings_rounded, l.savingsGoals, Routes.savings),
      (Icons.handshake_rounded, l.debts, Routes.debts),
      (Icons.autorenew_rounded, l.recurringPayments, Routes.recurring),
      (Icons.description_rounded, l.reports, Routes.reports),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: Insets.md),
      child: SizedBox(
        height: 84,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: Insets.sm),
          itemBuilder: (context, i) {
            final (icon, label, route) = items[i];
            return SizedBox(
              width: 86,
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: Insets.xs,
                  vertical: Insets.md,
                ),
                onTap: () => context.push(route),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: context.colors.primary, size: 24),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: context.text.labelSmall?.copyWith(
                        letterSpacing: 0,
                        color: context.colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _ChartPeriod { daily, weekly, monthly }

class _ExpenseChartCard extends ConsumerStatefulWidget {
  const _ExpenseChartCard({required this.ledger});
  final Ledger ledger;

  @override
  ConsumerState<_ExpenseChartCard> createState() => _ExpenseChartCardState();
}

class _ExpenseChartCardState extends ConsumerState<_ExpenseChartCard> {
  _ChartPeriod _period = _ChartPeriod.daily;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = ref.watch(clockProvider)();
    final dates = context.dates;
    final lg = widget.ledger;
    List<BarPoint> points;
    switch (_period) {
      case _ChartPeriod.daily:
        final range = DateRange(
          DateTime(now.year, now.month, now.day - 6),
          DateTime(now.year, now.month, now.day + 1),
        );
        final values = lg.daily(TransactionType.expense, range);
        final days = range.days.toList();
        points = [
          for (var i = 0; i < days.length; i++)
            BarPoint(
              dates.weekday(days[i]),
              values[i],
              tooltipLabel: dates.day(days[i]),
            ),
        ];
      case _ChartPeriod.weekly:
        points = [
          for (final (r, v) in lg.weekly(TransactionType.expense, now, 6))
            BarPoint(
              dates.dayShort(r.start),
              v,
              tooltipLabel:
                  '${dates.dayShort(r.start)} – ${dates.dayShort(r.lastDay)}',
            ),
        ];
      case _ChartPeriod.monthly:
        points = [
          for (final (r, v) in lg.monthly(TransactionType.expense, now, 6))
            BarPoint(
              dates.monthShort(r.start),
              v,
              tooltipLabel: dates.month(r.start),
            ),
        ];
    }
    final total = points.fold<int>(0, (a, p) => a + p.minor);

    return Column(
      children: [
        SectionHeader(l.expenseOverview),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<_ChartPeriod>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: _ChartPeriod.daily,
                      label: Text(l.daily),
                    ),
                    ButtonSegment(
                      value: _ChartPeriod.weekly,
                      label: Text(l.weekly),
                    ),
                    ButtonSegment(
                      value: _ChartPeriod.monthly,
                      label: Text(l.monthly),
                    ),
                  ],
                  selected: {_period},
                  onSelectionChanged: (s) => setState(() => _period = s.first),
                ),
              ),
              const SizedBox(height: Insets.lg),
              Text(l.totalForPeriod, style: context.text.labelMedium),
              AmountText(
                Money(total, lg.currency),
                style: context.text.titleLarge,
              ),
              const SizedBox(height: Insets.lg),
              MoneyBarChart(
                points: points,
                currency: lg.currency,
                color: context.palette.expense,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  const _BudgetCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final statuses = ref.watch(budgetStatusesProvider);
    return Column(
      children: [
        SectionHeader(
          l.monthlyBudget,
          actionLabel: l.manage,
          onAction: () => context.push(Routes.budgets),
        ),
        AsyncView(
          value: statuses,
          builder: (list) {
            final total = list.where((s) => s.isTotal).firstOrNull;
            if (total == null) {
              return AppCard(
                onTap: () => context.push(Routes.budgets),
                child: Row(
                  children: [
                    IconTile(
                      icon: Icons.pie_chart_rounded,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: Insets.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.noBudgetTitle, style: context.text.titleSmall),
                          Text(l.noBudgetBody, style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              );
            }
            return BudgetProgressCard(
              status: total,
              onTap: () => context.push(Routes.budgets),
            );
          },
        ),
      ],
    );
  }
}

/// Budget progress with spent / remaining / percentage.
class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    super.key,
    required this.status,
    this.title,
    this.onTap,
    this.trailing,
  });

  final BudgetStatus status;
  final String? title;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color = budgetColor(context, status.level);
    final pct = (status.ratio * 100).round();
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title ?? l.thisMonth,
                  style: context.text.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pct%',
                  style: context.text.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: Insets.md),
          AppProgressBar(value: status.ratio, color: color, height: 10),
          const SizedBox(height: Insets.md),
          Row(
            children: [
              Expanded(
                child: _Metric(label: l.spent, money: status.spentMoney),
              ),
              Expanded(
                child: _Metric(
                  label: status.remaining >= 0 ? l.remaining : l.overBudget,
                  money: status.remainingMoney.abs(),
                  color: status.remaining >= 0 ? null : context.palette.expense,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: l.limit,
                  money: status.limitMoney,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          if (status.level != BudgetLevel.ok) ...[
            const SizedBox(height: Insets.md),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(switch (status.level) {
                    BudgetLevel.exceeded => l.budgetLevelExceeded,
                    BudgetLevel.critical => l.budgetLevelCritical(pct),
                    _ => l.budgetLevelWarning(pct),
                  }, style: context.text.bodySmall?.copyWith(color: color)),
                ),
              ],
            ),
          ],
          if (!status.unconverted.isEmpty) ...[
            const SizedBox(height: Insets.sm),
            Text(
              l.budgetUnconvertedNote,
              style: context.text.bodySmall?.copyWith(
                color: context.palette.warning,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Color budgetColor(BuildContext context, BudgetLevel level) => switch (level) {
  BudgetLevel.ok => context.palette.income,
  BudgetLevel.warning => context.palette.warning,
  BudgetLevel.critical => const Color(0xFFFF8A4C),
  BudgetLevel.exceeded => context.palette.expense,
};

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.money,
    this.color,
    this.alignEnd = false,
  });
  final String label;
  final Money money;
  final Color? color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.text.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 2),
      AmountText(
        money,
        style: context.text.titleSmall?.copyWith(color: color),
        compact: true,
      ),
    ],
  );
}
