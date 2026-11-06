import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/currency_converter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/states.dart';

class ExchangeRatesScreen extends ConsumerWidget {
  const ExchangeRatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final rates = ref.watch(exchangeRatesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.exchangeRates)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAppSheet(context, (_) => const RateFormSheet()),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.addRate),
      ),
      body: AsyncView(
        value: rates,
        builder: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(
            Insets.lg,
            Insets.sm,
            Insets.lg,
            96,
          ),
          children: [
            AppCard(
              color: context.palette.surface2,
              borderless: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: Insets.md),
                  Expanded(
                    child: Text(
                      l.conversionPolicy,
                      style: context.text.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Insets.md),
            if (list.isEmpty)
              EmptyState(
                icon: Icons.currency_exchange_rounded,
                title: l.noRatesTitle,
                message: l.noRatesBody,
                actionLabel: l.addRate,
                onAction: () =>
                    showAppSheet(context, (_) => const RateFormSheet()),
              )
            else
              for (var i = 0; i < list.length; i++) ...[
                AppCard(
                  padding: const EdgeInsets.fromLTRB(
                    Insets.lg,
                    Insets.md,
                    Insets.xs,
                    Insets.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '1 ${list[i].base.code} = ${_fmtRate(list[i].rate)} ${list[i].quote.code}',
                                  style: context.text.titleSmall,
                                ),
                                if (i == 0) ...[
                                  const SizedBox(width: Insets.sm),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.palette.income.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      l.latest,
                                      style: context.text.labelSmall?.copyWith(
                                        color: context.palette.income,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l.effectiveFrom(context.dates.day(list[i].effectiveDate))} · ${list[i].source == 'manual' ? l.sourceManual : list[i].source}',
                              style: context.text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l.edit,
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        onPressed: () => showAppSheet(
                          context,
                          (_) => RateFormSheet(existing: list[i]),
                        ),
                      ),
                      IconButton(
                        tooltip: l.delete,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: context.palette.expense,
                        ),
                        onPressed: () async {
                          final ok = await confirmAction(
                            context,
                            title: l.deleteRateTitle,
                            message: l.deleteRateBody,
                            destructive: true,
                          );
                          if (ok) {
                            await ref
                                .read(exchangeRateRepositoryProvider)
                                .delete(list[i].id!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Insets.sm),
              ],
          ],
        ),
      ),
    );
  }

  static String _fmtRate(double r) =>
      r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toString();
}

class RateFormSheet extends ConsumerStatefulWidget {
  const RateFormSheet({super.key, this.existing});
  final ExchangeRateQuote? existing;

  @override
  ConsumerState<RateFormSheet> createState() => _RateFormSheetState();
}

class _RateFormSheetState extends ConsumerState<RateFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _rate = TextEditingController(
    text: widget.existing == null
        ? ''
        : ExchangeRatesScreen._fmtRate(widget.existing!.rate),
  );
  late DateTime _date = widget.existing?.effectiveDate ?? DateTime.now();

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  double? _parse(String s) =>
      double.tryParse(s.replaceAll(RegExp(r'[\s ]'), '').replaceAll(',', '.'));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final rate = _parse(_rate.text)!;
    final repo = ref.read(exchangeRateRepositoryProvider);
    if (widget.existing == null) {
      await repo.add(
        base: Currency.usd,
        quote: Currency.uzs,
        rate: rate,
        effectiveDate: _date,
      );
    } else {
      await repo.updateRate(
        widget.existing!.id!,
        rate: rate,
        effectiveDate: _date,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final base = widget.existing?.base ?? Currency.usd;
    final quote = widget.existing?.quote ?? Currency.uzs;
    return SafeArea(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.xl,
            0,
            Insets.xl,
            Insets.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? l.addRate : l.editRate,
                style: context.text.titleLarge,
              ),
              const SizedBox(height: Insets.lg),
              TextFormField(
                controller: _rate,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]')),
                ],
                decoration: InputDecoration(
                  labelText: l.rate,
                  prefixText: '1 ${base.code} = ',
                  suffixText: quote.code,
                ),
                validator: (v) {
                  final r = _parse(v ?? '');
                  if (r == null) return l.validationAmountInvalid;
                  if (r <= 0) return l.validationAmountPositive;
                  return null;
                },
              ),
              const SizedBox(height: Insets.lg),
              DateField(
                label: l.effectiveDate,
                value: _date,
                onChanged: (d) => setState(() => _date = d ?? _date),
              ),
              const SizedBox(height: Insets.sm),
              Text(l.rateManualNote, style: context.text.bodySmall),
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
