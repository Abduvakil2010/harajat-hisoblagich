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
import '../../../core/money/money_format.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/debt_repository.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/states.dart';

final _debtProvider = StreamProvider.autoDispose.family<DebtState?, String>(
  (ref, id) => ref.watch(debtRepositoryProvider).watchOne(id),
);

class DebtDetailScreen extends ConsumerWidget {
  const DebtDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final debt = ref.watch(_debtProvider(id));
    final now = ref.watch(clockProvider)();
    return Scaffold(
      appBar: AppBar(
        title: Text(l.debt),
        actions: [
          IconButton(
            tooltip: l.edit,
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push(Routes.editDebt(id)),
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
                title: l.deleteDebtTitle,
                message: l.deleteDebtBody,
                destructive: true,
              );
              if (!ok || !context.mounted) return;
              await ref.read(debtRepositoryProvider).delete(id);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      body: AsyncView(
        value: debt,
        builder: (s) {
          if (s == null) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: l.notFound,
              message: l.notFoundBody,
            );
          }
          final status = s.statusAt(now);
          final owe = s.debt.direction == DebtDirection.iOwe;
          final color = owe ? context.palette.expense : context.palette.income;
          final payments = [...s.payments]
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.debt.counterparty,
                            style: context.text.titleLarge,
                          ),
                        ),
                        _StatusChip(status: status),
                      ],
                    ),
                    Text(
                      l.debtDirectionLabel(s.debt.direction),
                      style: context.text.bodySmall,
                    ),
                    const SizedBox(height: Insets.lg),
                    Text(l.remaining, style: context.text.labelMedium),
                    AmountText(
                      s.remaining,
                      style: context.text.displaySmall?.copyWith(color: color),
                    ),
                    const SizedBox(height: Insets.md),
                    AppProgressBar(
                      value: s.ratioPaid,
                      color: color,
                      height: 10,
                    ),
                    const SizedBox(height: Insets.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l.paid}: ${context.money.format(s.paid)}',
                            style: context.text.bodySmall,
                          ),
                        ),
                        Text(
                          '${l.original}: ${context.money.format(s.original)}',
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                    const Divider(height: Insets.xxl),
                    _row(
                      context,
                      l.startDate,
                      context.dates.day(s.debt.startDate),
                    ),
                    if (s.debt.dueDate != null)
                      _row(
                        context,
                        l.dueDate,
                        context.dates.day(s.debt.dueDate!),
                      ),
                    if (s.debt.description != null)
                      _row(context, l.description, s.debt.description!),
                  ],
                ),
              ),
              const SizedBox(height: Insets.md),
              if (s.remainingMinor > 0)
                FilledButton.icon(
                  onPressed: () =>
                      showAppSheet(context, (_) => _RepaymentSheet(state: s)),
                  icon: const Icon(Icons.payments_rounded),
                  label: Text(l.recordRepayment),
                ),
              Padding(
                padding: const EdgeInsets.all(Insets.sm),
                child: Text(
                  l.debtAccountingNote,
                  style: context.text.bodySmall,
                ),
              ),
              SectionHeader(l.repayments),
              if (payments.isEmpty)
                AppCard(
                  child: Text(
                    l.noRepaymentsYet,
                    style: context.text.bodyMedium,
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: Insets.xs),
                  child: Column(
                    children: [
                      for (final p in payments)
                        ListTile(
                          leading: Icon(
                            Icons.check_circle_rounded,
                            color: color,
                          ),
                          title: AmountText(
                            Money(p.amountMinor, s.debt.currency),
                          ),
                          subtitle: Text(
                            [
                              context.dates.day(p.date),
                              if (p.note != null) p.note!,
                            ].join(' · '),
                          ),
                          trailing: IconButton(
                            tooltip: l.delete,
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () async {
                              final ok = await confirmAction(
                                context,
                                title: l.deleteRepaymentTitle,
                                message: l.deleteRepaymentBody,
                                destructive: true,
                              );
                              if (ok) {
                                await ref
                                    .read(debtRepositoryProvider)
                                    .deletePayment(p.id);
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

  Widget _row(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(label, style: context.text.bodySmall)),
        Expanded(child: Text(value, style: context.text.bodyMedium)),
      ],
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final DebtStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      DebtStatus.active => context.colors.primary,
      DebtStatus.overdue => context.palette.expense,
      DebtStatus.completed => context.palette.income,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        context.l10n.debtStatusLabel(status),
        style: context.text.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _RepaymentSheet extends ConsumerStatefulWidget {
  const _RepaymentSheet({required this.state});
  final DebtState state;

  @override
  ConsumerState<_RepaymentSheet> createState() => _RepaymentSheetState();
}

class _RepaymentSheetState extends ConsumerState<_RepaymentSheet> {
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
      widget.state.debt.currency,
    )!;
    if (!DebtCalculator.isValidRepayment(widget.state, minor)) {
      showSnack(context, l.repaymentTooLarge, error: true);
      return;
    }
    try {
      await ref
          .read(debtRepositoryProvider)
          .addPayment(
            widget.state.debt.id,
            minor,
            date: _date,
            note: _note.text,
          );
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(context, l.repaymentRecorded);
    } on RepaymentTooLargeException {
      if (mounted) showSnack(context, l.repaymentTooLarge, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = widget.state;
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
              Text(l.recordRepayment, style: context.text.titleLarge),
              Text(
                l.remainingAmount(context.money.format(s.remaining)),
                style: context.text.bodySmall,
              ),
              const SizedBox(height: Insets.lg),
              AmountField(
                controller: _amount,
                currency: s.debt.currency,
                autofocus: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _amount.text = MoneyFormat.toInput(
                    s.remainingMinor,
                    s.debt.currency,
                  ),
                  child: Text(l.payInFull),
                ),
              ),
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
