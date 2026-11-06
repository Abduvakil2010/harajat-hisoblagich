import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money_format.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/recurring_repository.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/states.dart';
import '../application/recurring_service.dart';

class RecurringFormScreen extends ConsumerStatefulWidget {
  const RecurringFormScreen({super.key, this.editId});
  final String? editId;

  @override
  ConsumerState<RecurringFormScreen> createState() =>
      _RecurringFormScreenState();
}

class _RecurringFormScreenState extends ConsumerState<RecurringFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  TransactionType _type = TransactionType.expense;
  late Currency _currency = ref.read(settingsProvider).primaryCurrency;
  int? _categoryId;
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  DateTime _start = DateTime.now();
  DateTime? _end;
  PaymentMethod _method = PaymentMethod.card;
  bool _active = true;
  bool _reminder = true;
  bool _loaded = false;
  bool _categoryError = false;

  @override
  void initState() {
    super.initState();
    if (widget.editId == null) {
      _loaded = true;
      return;
    }
    ref.read(recurringRepositoryProvider).watchById(widget.editId!).first.then((
      r,
    ) {
      if (!mounted || r == null) return;
      setState(() {
        _title.text = r.title;
        _amount.text = MoneyFormat.toInput(r.amountMinor, r.currency);
        _type = r.type;
        _currency = r.currency;
        _categoryId = r.categoryId;
        _frequency = r.frequency;
        _start = r.startDate;
        _end = r.endDate;
        _method = r.paymentMethod;
        _active = r.isActive;
        _reminder = r.reminderEnabled;
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final valid = _formKey.currentState!.validate();
    setState(() => _categoryError = _categoryId == null);
    if (!valid || _categoryId == null) return;
    if (_end != null &&
        _end!.isBefore(DateTime(_start.year, _start.month, _start.day))) {
      showSnack(context, l.validationEndBeforeStart, error: true);
      return;
    }
    final draft = RecurringDraft(
      title: _title.text,
      amountMinor: MoneyFormat.parseMinor(_amount.text, _currency)!,
      currency: _currency,
      categoryId: _categoryId!,
      type: _type,
      frequency: _frequency,
      startDate: _start,
      endDate: _end,
      paymentMethod: _method,
      isActive: _active,
      reminderEnabled: _reminder,
    );
    final repo = ref.read(recurringRepositoryProvider);
    if (widget.editId == null) {
      await repo.create(draft);
    } else {
      await repo.update(widget.editId!, draft);
    }
    if (_reminder && ref.read(settingsProvider).notificationsEnabled) {
      await ref.read(notificationServiceProvider).requestPermission();
    }
    // Post any occurrences that are already due and refresh reminders.
    await ref.read(recurringServiceProvider).run();
    if (!mounted) return;
    showSnack(context, l.recurringSaved);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cats = categoriesOfType(
      ref.watch(categoriesProvider).value ?? const [],
      _type,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editId == null ? l.addRecurring : l.editRecurring),
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
                  SegmentedButton<TransactionType>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text(l.expense),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text(l.income),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() {
                      if (s.first != _type) _categoryId = null;
                      _type = s.first;
                    }),
                  ),
                  const SizedBox(height: Insets.lg),
                  TextFormField(
                    controller: _title,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l.title,
                      hintText: l.recurringTitleHint,
                      counterText: '',
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? l.validationTitleRequired
                        : null,
                  ),
                  const SizedBox(height: Insets.lg),
                  AmountField(
                    controller: _amount,
                    currency: _currency,
                    onCurrencyChanged: (c) => setState(() => _currency = c),
                  ),
                  const SizedBox(height: Insets.lg),
                  Text(l.category, style: context.text.titleSmall),
                  const SizedBox(height: Insets.sm),
                  Wrap(
                    spacing: Insets.sm,
                    runSpacing: Insets.sm,
                    children: [
                      for (final c in cats)
                        ChoiceChip(
                          avatar: Icon(
                            AppIcons.of(c.iconKey),
                            size: 18,
                            color: Color(c.color),
                          ),
                          label: Text(l.categoryName(c)),
                          selected: _categoryId == c.id,
                          onSelected: (_) => setState(() {
                            _categoryId = c.id;
                            _categoryError = false;
                          }),
                        ),
                    ],
                  ),
                  if (_categoryError)
                    Padding(
                      padding: const EdgeInsets.only(top: Insets.sm),
                      child: Text(
                        l.validationCategoryRequired,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: Insets.lg),
                  DropdownButtonFormField<RecurrenceFrequency>(
                    initialValue: _frequency,
                    decoration: InputDecoration(
                      labelText: l.frequency,
                      prefixIcon: const Icon(Icons.repeat_rounded),
                    ),
                    items: [
                      for (final f in RecurrenceFrequency.values)
                        DropdownMenuItem(
                          value: f,
                          child: Text(l.frequencyLabel(f)),
                        ),
                    ],
                    onChanged: (f) => setState(
                      () => _frequency = f ?? RecurrenceFrequency.monthly,
                    ),
                  ),
                  const SizedBox(height: Insets.lg),
                  DateField(
                    label: l.startDate,
                    value: _start,
                    onChanged: (d) => setState(() => _start = d ?? _start),
                  ),
                  const SizedBox(height: Insets.lg),
                  DateField(
                    label: l.endDateOptional,
                    value: _end,
                    clearable: true,
                    firstDate: _start,
                    onChanged: (d) => setState(() => _end = d),
                  ),
                  const SizedBox(height: Insets.lg),
                  DropdownButtonFormField<PaymentMethod>(
                    initialValue: _method,
                    decoration: InputDecoration(labelText: l.paymentMethod),
                    items: [
                      for (final m in PaymentMethod.values)
                        DropdownMenuItem(
                          value: m,
                          child: Text(l.paymentMethodLabel(m)),
                        ),
                    ],
                    onChanged: (m) =>
                        setState(() => _method = m ?? PaymentMethod.card),
                  ),
                  const SizedBox(height: Insets.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.active),
                    subtitle: Text(l.activeHint),
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.reminder),
                    subtitle: Text(l.reminderHint),
                    value: _reminder,
                    onChanged: (v) => setState(() => _reminder = v),
                  ),
                  if (_start.isBefore(DateUtils.dateOnly(DateTime.now())) &&
                      widget.editId == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Insets.md),
                      child: Text(
                        l.recurringBackfillNote,
                        style: context.text.bodySmall?.copyWith(
                          color: context.palette.warning,
                        ),
                      ),
                    ),
                  FilledButton(onPressed: _save, child: Text(l.save)),
                ],
              ),
            ),
    );
  }
}
