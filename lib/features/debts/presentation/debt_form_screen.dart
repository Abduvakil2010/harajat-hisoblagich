import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money_format.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/debt_repository.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/states.dart';

class DebtFormScreen extends ConsumerStatefulWidget {
  const DebtFormScreen({super.key, this.editId});
  final String? editId;

  @override
  ConsumerState<DebtFormScreen> createState() => _DebtFormScreenState();
}

class _DebtFormScreenState extends ConsumerState<DebtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _person = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  DebtDirection _direction = DebtDirection.iOwe;
  late Currency _currency = ref.read(settingsProvider).primaryCurrency;
  DateTime _start = DateTime.now();
  DateTime? _due;
  bool _loaded = false;
  bool _hasPayments = false;

  @override
  void initState() {
    super.initState();
    if (widget.editId == null) {
      _loaded = true;
      return;
    }
    ref.read(debtRepositoryProvider).watchOne(widget.editId!).first.then((s) {
      if (!mounted || s == null) return;
      setState(() {
        _person.text = s.debt.counterparty;
        _amount.text = MoneyFormat.toInput(
          s.debt.originalMinor,
          s.debt.currency,
        );
        _description.text = s.debt.description ?? '';
        _direction = s.debt.direction;
        _currency = s.debt.currency;
        _start = s.debt.startDate;
        _due = s.debt.dueDate;
        _hasPayments = s.payments.isNotEmpty;
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _person.dispose();
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    final draft = DebtDraft(
      direction: _direction,
      counterparty: _person.text,
      originalMinor: MoneyFormat.parseMinor(_amount.text, _currency)!,
      currency: _currency,
      startDate: _start,
      dueDate: _due,
      description: _description.text,
    );
    try {
      final repo = ref.read(debtRepositoryProvider);
      if (widget.editId == null) {
        await repo.create(draft);
      } else {
        await repo.update(widget.editId!, draft);
      }
      if (!mounted) return;
      showSnack(context, l.debtSaved);
      context.pop();
    } on OriginalBelowPaidException {
      if (mounted) showSnack(context, l.originalBelowPaid, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editId == null ? l.addDebt : l.editDebt),
      ),
      body: !_loaded
          ? const LoadingView()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Insets.lg,
                  Insets.sm,
                  Insets.lg,
                  Insets.xxxl,
                ),
                children: [
                  SegmentedButton<DebtDirection>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: DebtDirection.iOwe,
                        label: Text(l.debtIOwe),
                      ),
                      ButtonSegment(
                        value: DebtDirection.owedToMe,
                        label: Text(l.debtOwedToMe),
                      ),
                    ],
                    selected: {_direction},
                    onSelectionChanged: (s) =>
                        setState(() => _direction = s.first),
                  ),
                  const SizedBox(height: Insets.lg),
                  TextFormField(
                    controller: _person,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l.personOrOrganization,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      counterText: '',
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? l.validationNameRequired
                        : null,
                  ),
                  const SizedBox(height: Insets.lg),
                  AmountField(
                    controller: _amount,
                    currency: _currency,
                    label: l.originalAmount,
                    onCurrencyChanged: _hasPayments
                        ? null
                        : (c) => setState(() => _currency = c),
                  ),
                  const SizedBox(height: Insets.lg),
                  DateField(
                    label: l.startDate,
                    value: _start,
                    onChanged: (d) => setState(() => _start = d ?? _start),
                  ),
                  const SizedBox(height: Insets.lg),
                  DateField(
                    label: l.dueDateOptional,
                    value: _due,
                    clearable: true,
                    onChanged: (d) => setState(() => _due = d),
                  ),
                  const SizedBox(height: Insets.lg),
                  TextFormField(
                    controller: _description,
                    maxLines: 3,
                    minLines: 1,
                    maxLength: 200,
                    decoration: InputDecoration(
                      labelText: l.descriptionOptional,
                    ),
                  ),
                  const SizedBox(height: Insets.xl),
                  FilledButton(onPressed: _save, child: Text(l.save)),
                ],
              ),
            ),
    );
  }
}
