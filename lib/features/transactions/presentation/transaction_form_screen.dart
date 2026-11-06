import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money_format.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/states.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({
    super.key,
    this.editId,
    this.initialType = TransactionType.expense,
  });

  final String? editId;
  final TransactionType initialType;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _title = TextEditingController();
  final _description = TextEditingController();
  late TransactionType _type = widget.initialType;
  late Currency _currency = ref.read(settingsProvider).primaryCurrency;
  int? _categoryId;
  DateTime _date = DateTime.now();
  PaymentMethod _method = PaymentMethod.cash;
  bool _loaded = false;
  bool _saving = false;
  bool _categoryError = false;

  bool get _isEdit => widget.editId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      ref.read(transactionRepositoryProvider).getById(widget.editId!).then((t) {
        if (!mounted || t == null) return;
        setState(() {
          _type = t.type;
          _currency = t.currency;
          _amount.text = MoneyFormat.toInput(t.amountMinor, t.currency);
          _title.text = t.title;
          _description.text = t.description ?? '';
          _categoryId = t.categoryId;
          _date = t.date;
          _method = t.paymentMethod;
          _loaded = true;
        });
      });
    } else {
      _loaded = true;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final valid = _formKey.currentState!.validate();
    setState(() => _categoryError = _categoryId == null);
    if (!valid || _categoryId == null) return;
    final minor = MoneyFormat.parseMinor(_amount.text, _currency)!;
    final draft = TransactionDraft(
      title: _title.text,
      amountMinor: minor,
      currency: _currency,
      categoryId: _categoryId!,
      date: _date,
      type: _type,
      paymentMethod: _method,
      description: _description.text,
    );
    setState(() => _saving = true);
    try {
      final repo = ref.read(transactionRepositoryProvider);
      if (_isEdit) {
        await repo.update(widget.editId!, draft);
      } else {
        await repo.add(draft);
      }
      if (!mounted) return;
      unawaited(HapticFeedback.lightImpact());
      showSnack(context, _isEdit ? l.transactionUpdated : l.transactionAdded);
      context.pop();
    } catch (_) {
      if (mounted) showSnack(context, l.errorSaving, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final ok = await confirmAction(
      context,
      title: l.deleteTransactionTitle,
      message: l.deleteTransactionBody,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(transactionRepositoryProvider).delete(widget.editId!);
    if (!mounted) return;
    showSnack(context, l.transactionDeleted);
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final categories =
        ref.watch(categoriesProvider).value ?? const <CategoryRecord>[];
    final ofType = categoriesOfType(categories, _type);
    final typeColor = _type == TransactionType.income
        ? context.palette.income
        : context.palette.expense;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l.close,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEdit ? l.editTransaction : l.addTransaction),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: l.delete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: context.palette.expense,
              ),
              onPressed: _delete,
            ),
        ],
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
                        icon: const Icon(Icons.north_east_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text(l.income),
                        icon: const Icon(Icons.south_west_rounded, size: 18),
                      ),
                    ],
                    selected: {_type},
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (s) => s.contains(WidgetState.selected)
                            ? typeColor.withValues(alpha: 0.16)
                            : null,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (s) =>
                            s.contains(WidgetState.selected) ? typeColor : null,
                      ),
                    ),
                    onSelectionChanged: (s) => setState(() {
                      if (_type != s.first) _categoryId = null;
                      _type = s.first;
                    }),
                  ),
                  const SizedBox(height: Insets.xl),
                  AmountField(
                    controller: _amount,
                    currency: _currency,
                    large: true,
                    autofocus: !_isEdit,
                    onCurrencyChanged: (c) => setState(() => _currency = c),
                  ),
                  const SizedBox(height: Insets.lg),
                  TextFormField(
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 80,
                    decoration: InputDecoration(
                      labelText: l.title,
                      hintText: _type == TransactionType.expense
                          ? l.titleHintExpense
                          : l.titleHintIncome,
                      counterText: '',
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? l.validationTitleRequired
                        : null,
                  ),
                  const SizedBox(height: Insets.xl),
                  Row(
                    children: [
                      Text(l.category, style: context.text.titleSmall),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => context.push(Routes.categories),
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: Text(l.manage),
                      ),
                    ],
                  ),
                  const SizedBox(height: Insets.sm),
                  Wrap(
                    spacing: Insets.sm,
                    runSpacing: Insets.sm,
                    children: [
                      for (final c in ofType)
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
                      padding: const EdgeInsets.only(
                        top: Insets.sm,
                        left: Insets.sm,
                      ),
                      child: Text(
                        l.validationCategoryRequired,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: Insets.xl),
                  DateField(
                    label: l.date,
                    value: _date,
                    lastDate: DateTime.now().add(const Duration(days: 366)),
                    onChanged: (d) {
                      if (d == null) return;
                      setState(
                        () => _date = DateTime(
                          d.year,
                          d.month,
                          d.day,
                          _date.hour,
                          _date.minute,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: Insets.lg),
                  DropdownButtonFormField<PaymentMethod>(
                    initialValue: _method,
                    decoration: InputDecoration(
                      labelText: l.paymentMethod,
                      prefixIcon: const Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                    ),
                    items: [
                      for (final m in PaymentMethod.values)
                        DropdownMenuItem(
                          value: m,
                          child: Text(l.paymentMethodLabel(m)),
                        ),
                    ],
                    onChanged: (m) =>
                        setState(() => _method = m ?? PaymentMethod.cash),
                  ),
                  const SizedBox(height: Insets.lg),
                  TextFormField(
                    controller: _description,
                    maxLines: 3,
                    minLines: 1,
                    maxLength: 300,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l.descriptionOptional,
                      prefixIcon: const Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: Insets.xl),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : Text(_isEdit ? l.saveChanges : l.save),
                  ),
                ],
              ),
            ),
    );
  }
}
