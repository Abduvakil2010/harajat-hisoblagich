import 'package:fl_chart/fl_chart.dart';
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
import '../../../core/money/money.dart';
import '../../../core/money/money_format.dart';
import '../../../data/repositories/savings_repository.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/states.dart';

final _goalProvider = StreamProvider.autoDispose
    .family<SavingsProgress?, String>(
      (ref, id) => ref.watch(savingsRepositoryProvider).watchOne(id),
    );

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final goal = ref.watch(_goalProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: Text(l.goal),
        actions: [
          IconButton(
            tooltip: l.edit,
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push(Routes.editGoal(id)),
          ),
          IconButton(
            tooltip: l.delete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: context.palette.expense,
            ),
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: l.deleteGoalTitle,
                message: l.deleteGoalBody,
                destructive: true,
              );
              if (!ok || !context.mounted) return;
              await ref.read(savingsRepositoryProvider).delete(id);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      body: AsyncView(
        value: goal,
        builder: (p) {
          if (p == null) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: l.notFound,
              message: l.notFoundBody,
            );
          }
          final color = Color(p.goal.color);
          final monthly = p.monthlyNeeded(DateTime.now());
          final entries = [...p.entries]
            ..sort((a, b) => b.date.compareTo(a.date));
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Insets.lg,
              Insets.sm,
              Insets.lg,
              Insets.xxxl,
            ),
            children: [
              AppCard(
                padding: const EdgeInsets.all(Insets.xl),
                child: Column(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: p.ratio),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, _) => CircularProgressIndicator(
                              value: v,
                              strokeWidth: 10,
                              strokeCap: StrokeCap.round,
                              color: color,
                              backgroundColor: context.palette.surface2,
                            ),
                          ),
                          Center(
                            child: Icon(
                              AppIcons.of(p.goal.iconKey),
                              size: 44,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Insets.lg),
                    Text(
                      p.goal.name,
                      style: context.text.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    if (p.goal.description != null) ...[
                      const SizedBox(height: Insets.xs),
                      Text(
                        p.goal.description!,
                        style: context.text.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: Insets.md),
                    Text(
                      '${(p.ratio * 100).toStringAsFixed(1)}%',
                      style: context.text.displaySmall?.copyWith(color: color),
                    ),
                    const SizedBox(height: Insets.md),
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(label: l.saved, money: p.saved),
                        ),
                        Expanded(
                          child: _Stat(label: l.remaining, money: p.remaining),
                        ),
                        Expanded(
                          child: _Stat(label: l.target, money: p.target),
                        ),
                      ],
                    ),
                    if (p.goal.targetDate != null) ...[
                      const Divider(height: Insets.xxl),
                      Row(
                        children: [
                          Icon(
                            Icons.event_rounded,
                            size: 18,
                            color: context.palette.textSecondary,
                          ),
                          const SizedBox(width: Insets.sm),
                          Expanded(
                            child: Text(
                              l.byDate(context.dates.day(p.goal.targetDate!)),
                              style: context.text.bodyMedium,
                            ),
                          ),
                          if (monthly != null)
                            Flexible(
                              child: Text(
                                l.perMonthNeeded(
                                  context.money.format(
                                    Money(monthly, p.goal.currency),
                                  ),
                                ),
                                style: context.text.bodySmall,
                                textAlign: TextAlign.end,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Insets.md),
              if (!p.isCompleted)
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => showAppSheet(
                          context,
                          (_) => _EntrySheet(progress: p, deposit: true),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l.addMoney),
                      ),
                    ),
                    const SizedBox(width: Insets.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: p.savedMinor > 0
                            ? () => showAppSheet(
                                context,
                                (_) => _EntrySheet(progress: p, deposit: false),
                              )
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                        label: Text(l.withdraw),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: Insets.sm),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref
                      .read(savingsRepositoryProvider)
                      .setCompleted(p.goal.id, !p.isCompleted);
                  if (context.mounted) {
                    showSnack(
                      context,
                      p.isCompleted ? l.goalReopened : l.goalCompleted,
                    );
                  }
                },
                icon: Icon(
                  p.isCompleted ? Icons.replay_rounded : Icons.flag_rounded,
                ),
                label: Text(p.isCompleted ? l.reopenGoal : l.markCompleted),
              ),
              if (p.history.length >= 2) ...[
                SectionHeader(l.progress),
                AppCard(
                  child: _HistoryChart(p: p, color: color),
                ),
              ],
              SectionHeader(l.history),
              if (entries.isEmpty)
                AppCard(
                  child: Text(l.noEntriesYet, style: context.text.bodyMedium),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: Insets.xs),
                  child: Column(
                    children: [
                      for (final e in entries)
                        ListTile(
                          leading: Icon(
                            e.amountMinor >= 0
                                ? Icons.south_west_rounded
                                : Icons.north_east_rounded,
                            color: e.amountMinor >= 0
                                ? context.palette.income
                                : context.palette.expense,
                          ),
                          title: AmountText(
                            Money(e.amountMinor, p.goal.currency),
                            signed: true,
                          ),
                          subtitle: Text(
                            [
                              context.dates.day(e.date),
                              if (e.note != null) e.note!,
                            ].join(' · '),
                          ),
                          trailing: IconButton(
                            tooltip: l.delete,
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () async {
                              final ok = await confirmAction(
                                context,
                                title: l.deleteEntryTitle,
                                message: l.deleteEntryBody,
                                destructive: true,
                              );
                              if (ok) {
                                await ref
                                    .read(savingsRepositoryProvider)
                                    .deleteEntry(e.id);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.money});
  final String label;
  final Money money;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: context.text.bodySmall),
      const SizedBox(height: 2),
      AmountText(money, style: context.text.titleSmall, compact: true),
    ],
  );
}

class _HistoryChart extends StatelessWidget {
  const _HistoryChart({required this.p, required this.color});
  final SavingsProgress p;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final h = p.history;
    final maxY =
        [
          p.goal.targetMinor,
          ...h.map((e) => e.$2),
        ].reduce((a, b) => a > b ? a : b) *
        1.1;
    return SizedBox(
      height: 170,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => context.palette.surface2,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${context.dates.day(h[s.x.toInt()].$1)}\n${context.money.formatMinor(h[s.x.toInt()].$2, p.goal.currency)}',
                    context.text.labelMedium!.copyWith(color: color),
                  ),
              ],
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: p.goal.targetMinor.toDouble(),
                color: context.palette.textSecondary.withValues(alpha: 0.5),
                dashArray: [6, 4],
                strokeWidth: 1,
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < h.length; i++)
                  FlSpot(i.toDouble(), h[i].$2.toDouble()),
              ],
              color: color,
              barWidth: 3,
              isCurved: true,
              preventCurveOverShooting: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntrySheet extends ConsumerStatefulWidget {
  const _EntrySheet({required this.progress, required this.deposit});
  final SavingsProgress progress;
  final bool deposit;

  @override
  ConsumerState<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<_EntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    final minor = MoneyFormat.parseMinor(
      _amount.text,
      widget.progress.goal.currency,
    )!;
    final repo = ref.read(savingsRepositoryProvider);
    try {
      if (widget.deposit) {
        await repo.deposit(
          widget.progress.goal.id,
          minor,
          date: _date,
          note: _note.text,
        );
      } else {
        await repo.withdraw(
          widget.progress.goal.id,
          minor,
          date: _date,
          note: _note.text,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
      final reached =
          widget.deposit &&
          widget.progress.savedMinor + minor >=
              widget.progress.goal.targetMinor;
      showSnack(context, reached ? l.goalReachedSnack : l.saved);
    } on InsufficientSavingsException {
      if (mounted) showSnack(context, l.withdrawTooMuch, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = widget.progress;
    return SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Insets.xl,
            0,
            Insets.xl,
            Insets.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.deposit ? l.addMoney : l.withdraw,
                style: context.text.titleLarge,
              ),
              if (!widget.deposit)
                Text(
                  l.availableAmount(context.money.format(p.saved)),
                  style: context.text.bodySmall,
                ),
              const SizedBox(height: Insets.lg),
              AmountField(
                controller: _amount,
                currency: p.goal.currency,
                autofocus: true,
              ),
              const SizedBox(height: Insets.lg),
              DateField(
                label: l.date,
                value: _date,
                onChanged: (d) => setState(() => _date = d ?? _date),
              ),
              const SizedBox(height: Insets.lg),
              TextFormField(
                controller: _note,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: l.noteOptional,
                  counterText: '',
                ),
              ),
              const SizedBox(height: Insets.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _save, child: Text(l.save)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
