import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/finance/budget_calculator.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money_format.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/states.dart';
import '../../dashboard/presentation/dashboard_screen.dart'
    show BudgetProgressCard;

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final statuses = ref.watch(budgetStatusesProvider);
    final categories = ref.watch(categoryMapProvider);
    final month = ref.watch(currentMonthProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.budgets)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAppSheet(context, (_) => const BudgetFormSheet()),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.addBudget),
      ),
      body: AsyncView(
        value: statuses,
        builder: (list) {
          final total = list.where((s) => s.isTotal).firstOrNull;
          final cats = list.where((s) => !s.isTotal).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Insets.lg,
              Insets.sm,
              Insets.lg,
              96,
            ),
            children: [
              Text(
                context.dates.month(month.start),
                style: context.text.bodyMedium?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
              SectionHeader(l.totalMonthlyBudget),
              if (total == null)
                AppCard(
                  child: EmptyState(
                    compact: true,
                    icon: Icons.pie_chart_rounded,
                    title: l.noBudgetTitle,
                    message: l.budgetExplain,
                    actionLabel: l.setBudget,
                    onAction: () => showAppSheet(
                      context,
                      (_) => const BudgetFormSheet(totalOnly: true),
                    ),
                  ),
                )
              else
                BudgetProgressCard(
                  status: total,
                  title: l.allExpenses,
                  trailing: _menu(context, ref, total),
                ),
              SectionHeader(l.categoryLimits),
              if (cats.isEmpty)
                AppCard(
                  child: Text(
                    l.noCategoryLimits,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                )
              else
                for (final s in cats) ...[
                  BudgetProgressCard(
                    status: s,
                    title: l.categoryName(categories[s.budget.categoryId]),
                    trailing: _menu(context, ref, s),
                  ),
                  const SizedBox(height: Insets.md),
                ],
              SectionHeader(l.alertThresholds),
              AppCard(
                onTap: () =>
                    showAppSheet(context, (_) => const ThresholdsSheet()),
                child: Row(
                  children: [
                    IconTile(
                      icon: Icons.notifications_active_rounded,
                      color: context.palette.warning,
                      size: 40,
                    ),
                    const SizedBox(width: Insets.md),
                    Expanded(
                      child: Text(
                        l.thresholdsSummary(
                          settings.budgetWarningPercent,
                          settings.budgetCriticalPercent,
                        ),
                        style: context.text.bodyMedium,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _menu(BuildContext context, WidgetRef ref, BudgetStatus s) {
    final l = context.l10n;
    return PopupMenuButton<String>(
      tooltip: l.more,
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (v) async {
        if (v == 'edit') {
          await showAppSheet(context, (_) => BudgetFormSheet(existing: s));
        } else {
          final ok = await confirmAction(
            context,
            title: l.deleteBudgetTitle,
            message: l.deleteBudgetBody,
            destructive: true,
          );
          if (ok) await ref.read(budgetRepositoryProvider).delete(s.budget.id);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'edit', child: Text(l.edit)),
        PopupMenuItem(value: 'delete', child: Text(l.delete)),
      ],
    );
  }
}

class BudgetFormSheet extends ConsumerStatefulWidget {
  const BudgetFormSheet({super.key, this.existing, this.totalOnly = false});
  final BudgetStatus? existing;
  final bool totalOnly;

  @override
  ConsumerState<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  int? _categoryId; // null = total
  late Currency _currency;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _currency =
        e?.budget.currency ?? ref.read(settingsProvider).primaryCurrency;
    _categoryId = e?.budget.categoryId;
    if (e != null) {
      _amount.text = MoneyFormat.toInput(
        e.budget.limitMinor,
        e.budget.currency,
      );
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(budgetRepositoryProvider)
        .upsert(
          categoryId: _categoryId,
          limitMinor: MoneyFormat.parseMinor(_amount.text, _currency)!,
          currency: _currency,
        );
    if (mounted) {
      showSnack(context, context.l10n.budgetSaved);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cats = categoriesOfType(
      ref.watch(categoriesProvider).value ?? const [],
      TransactionType.expense,
    );
    final editing = widget.existing != null;
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
                editing ? l.editBudget : l.addBudget,
                style: context.text.titleLarge,
              ),
              const SizedBox(height: Insets.lg),
              if (!widget.totalOnly && !editing)
                DropdownButtonFormField<int?>(
                  initialValue: _categoryId,
                  decoration: InputDecoration(labelText: l.appliesTo),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l.allExpenses),
                    ),
                    for (final c in cats)
                      DropdownMenuItem<int?>(
                        value: c.id,
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.of(c.iconKey),
                              size: 18,
                              color: Color(c.color),
                            ),
                            const SizedBox(width: Insets.sm),
                            Text(l.categoryName(c)),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
              if (!widget.totalOnly && !editing)
                const SizedBox(height: Insets.lg),
              AmountField(
                controller: _amount,
                currency: _currency,
                label: l.monthlyLimit,
                autofocus: true,
                onCurrencyChanged: (c) => setState(() => _currency = c),
              ),
              const SizedBox(height: Insets.sm),
              Text(l.budgetStandingNote, style: context.text.bodySmall),
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

class ThresholdsSheet extends ConsumerStatefulWidget {
  const ThresholdsSheet({super.key});

  @override
  ConsumerState<ThresholdsSheet> createState() => _ThresholdsSheetState();
}

class _ThresholdsSheetState extends ConsumerState<ThresholdsSheet> {
  late double _warn = ref
      .read(settingsProvider)
      .budgetWarningPercent
      .toDouble();
  late double _crit = ref
      .read(settingsProvider)
      .budgetCriticalPercent
      .toDouble();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Insets.xl, 0, Insets.xl, Insets.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.alertThresholds, style: context.text.titleLarge),
            const SizedBox(height: Insets.lg),
            Text(
              '${l.warningAt}: ${_warn.round()}%',
              style: context.text.titleSmall,
            ),
            Slider(
              value: _warn,
              min: 50,
              max: 95,
              divisions: 9,
              label: '${_warn.round()}%',
              onChanged: (v) => setState(() {
                _warn = v;
                if (_crit <= _warn) _crit = (_warn + 5).clamp(55, 99);
              }),
            ),
            Text(
              '${l.criticalAt}: ${_crit.round()}%',
              style: context.text.titleSmall,
            ),
            Slider(
              value: _crit,
              min: 55,
              max: 99,
              divisions: 44,
              label: '${_crit.round()}%',
              onChanged: (v) => setState(() {
                _crit = v;
                if (_warn >= _crit) _warn = (_crit - 5).clamp(50, 95);
              }),
            ),
            Text(l.exceededAlwaysNote, style: context.text.bodySmall),
            const SizedBox(height: Insets.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await ref
                      .read(settingsProvider.notifier)
                      .update(
                        (s) => s.copyWith(
                          budgetWarningPercent: _warn.round(),
                          budgetCriticalPercent: _crit.round(),
                        ),
                      );
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
