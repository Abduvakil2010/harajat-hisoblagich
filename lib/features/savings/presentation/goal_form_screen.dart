import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money_format.dart';
import '../../../data/repositories/savings_repository.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/states.dart';

class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({super.key, this.editId});
  final String? editId;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _description = TextEditingController();
  late Currency _currency = ref.read(settingsProvider).primaryCurrency;
  DateTime? _targetDate;
  String _icon = 'savings';
  int _color = AppColors.pickerColors.first;
  bool _loaded = false;
  bool _hasEntries = false;

  @override
  void initState() {
    super.initState();
    if (widget.editId == null) {
      _loaded = true;
      return;
    }
    ref.read(savingsRepositoryProvider).watchOne(widget.editId!).first.then((
      p,
    ) {
      if (!mounted || p == null) return;
      setState(() {
        _name.text = p.goal.name;
        _target.text = MoneyFormat.toInput(p.goal.targetMinor, p.goal.currency);
        _description.text = p.goal.description ?? '';
        _currency = p.goal.currency;
        _targetDate = p.goal.targetDate;
        _icon = p.goal.iconKey;
        _color = p.goal.color;
        _hasEntries = p.entries.isNotEmpty;
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final draft = SavingsGoalDraft(
      name: _name.text,
      targetMinor: MoneyFormat.parseMinor(_target.text, _currency)!,
      currency: _currency,
      iconKey: _icon,
      color: _color,
      targetDate: _targetDate,
      description: _description.text,
    );
    final repo = ref.read(savingsRepositoryProvider);
    if (widget.editId == null) {
      await repo.create(draft);
    } else {
      await repo.update(widget.editId!, draft);
    }
    if (!mounted) return;
    showSnack(context, context.l10n.goalSaved);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editId == null ? l.newGoal : l.editGoal),
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
                  TextFormField(
                    controller: _name,
                    maxLength: 60,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l.goalName,
                      hintText: l.goalNameHint,
                      counterText: '',
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? l.validationNameRequired
                        : null,
                  ),
                  const SizedBox(height: Insets.lg),
                  AmountField(
                    controller: _target,
                    currency: _currency,
                    label: l.targetAmount,
                    // Currency is fixed once money was saved in it.
                    onCurrencyChanged: _hasEntries
                        ? null
                        : (c) => setState(() => _currency = c),
                  ),
                  const SizedBox(height: Insets.lg),
                  DateField(
                    label: l.targetDateOptional,
                    value: _targetDate,
                    clearable: true,
                    firstDate: DateTime.now(),
                    onChanged: (d) => setState(() => _targetDate = d),
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
                  const SizedBox(height: Insets.lg),
                  Text(l.icon, style: context.text.labelMedium),
                  const SizedBox(height: Insets.sm),
                  IconPicker(
                    keys: AppIcons.goalChoices,
                    selected: _icon,
                    color: Color(_color),
                    iconOf: AppIcons.of,
                    onSelected: (k) => setState(() => _icon = k),
                  ),
                  const SizedBox(height: Insets.lg),
                  Text(l.color, style: context.text.labelMedium),
                  const SizedBox(height: Insets.sm),
                  ColorPicker(
                    colors: AppColors.pickerColors,
                    selected: _color,
                    onSelected: (c) => setState(() => _color = c),
                  ),
                  const SizedBox(height: Insets.xxl),
                  FilledButton(onPressed: _save, child: Text(l.save)),
                ],
              ),
            ),
    );
  }
}
