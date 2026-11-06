import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/date_range.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/states.dart';
import '../application/report_service.dart';
import '../domain/report_data.dart';

enum ReportPeriodKind { daily, weekly, monthly, custom }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriodKind _kind = ReportPeriodKind.monthly;
  DateTime _anchor = DateTime.now();
  DateRange? _custom;
  ReportFormat _format = ReportFormat.pdf;
  bool _busy = false;

  DateRange get _range => switch (_kind) {
    ReportPeriodKind.daily => DateRange.day(_anchor),
    ReportPeriodKind.weekly => DateRange.week(_anchor),
    ReportPeriodKind.monthly => DateRange.month(_anchor),
    ReportPeriodKind.custom => _custom ?? DateRange.month(_anchor),
  };

  void _shift(int dir) => setState(() {
    _anchor = switch (_kind) {
      ReportPeriodKind.daily => DateTime(
        _anchor.year,
        _anchor.month,
        _anchor.day + dir,
      ),
      ReportPeriodKind.weekly => DateTime(
        _anchor.year,
        _anchor.month,
        _anchor.day + 7 * dir,
      ),
      _ => DateTime(_anchor.year, _anchor.month + dir, 1),
    };
  });

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
    );
    if (r != null) {
      setState(() {
        _custom = DateRange.days(r.start, r.end);
        _kind = ReportPeriodKind.custom;
      });
    }
  }

  Future<void> _run({required bool share}) async {
    final l = context.l10n;
    final range = _range;
    setState(() => _busy = true);
    try {
      // Load the period plus its budget month so budget figures are complete.
      final budgetMonth = DateRange.month(range.lastDay);
      final load = DateRange(
        range.start.isBefore(budgetMonth.start)
            ? range.start
            : budgetMonth.start,
        range.end.isAfter(budgetMonth.end) ? range.end : budgetMonth.end,
      );
      final txs = await ref.read(transactionRepositoryProvider).getRange(load);
      final data = ReportData.build(
        period: range,
        transactions: txs,
        currency: ref.read(settingsProvider).primaryCurrency,
        converter: ref.read(converterProvider),
        categories: ref.read(categoryMapProvider),
        categoryName: l.categoryName,
        paymentLabel: l.paymentMethodLabel,
        budgets: await ref.read(budgetRepositoryProvider).all(),
        now: DateTime.now(),
      );
      const service = ReportService();
      final report = await service.generate(data, _format, l);
      if (!mounted) return;
      if (share) {
        await service.share(report, subject: l.rptFinancialReport);
      } else {
        final saved = await service.save(report);
        if (mounted && saved) {
          showSnack(context, l.reportSaved(report.fileName));
        }
      }
    } catch (_) {
      if (mounted) showSnack(context, l.reportFailed, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final range = _range;
    final preview = ref.watch(transactionsInRangeProvider(range));
    final currency = ref.watch(
      settingsProvider.select((s) => s.primaryCurrency),
    );
    final converter = ref.watch(converterProvider);
    final categories = ref.watch(categoryMapProvider);
    final d = context.dates;
    final label = switch (_kind) {
      ReportPeriodKind.daily => d.day(range.start),
      ReportPeriodKind.monthly => d.month(range.start),
      _ => '${d.day(range.start)} – ${d.day(range.lastDay)}',
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.reports)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Insets.lg,
          Insets.sm,
          Insets.lg,
          Insets.xxxl,
        ),
        children: [
          Text(l.reportPeriodLabel, style: context.text.labelMedium),
          const SizedBox(height: Insets.sm),
          Wrap(
            spacing: Insets.sm,
            runSpacing: Insets.sm,
            children: [
              for (final k in ReportPeriodKind.values)
                ChoiceChip(
                  label: Text(switch (k) {
                    ReportPeriodKind.daily => l.daily,
                    ReportPeriodKind.weekly => l.weekly,
                    ReportPeriodKind.monthly => l.monthly,
                    ReportPeriodKind.custom => l.customRange,
                  }),
                  selected: _kind == k,
                  onSelected: (_) => k == ReportPeriodKind.custom
                      ? _pickCustom()
                      : setState(() => _kind = k),
                ),
            ],
          ),
          const SizedBox(height: Insets.md),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.xs,
              vertical: Insets.xs,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: l.previous,
                  onPressed: _kind == ReportPeriodKind.custom
                      ? null
                      : () => _shift(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    label,
                    style: context.text.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  tooltip: l.next,
                  onPressed: _kind == ReportPeriodKind.custom
                      ? null
                      : () => _shift(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          SectionHeader(l.preview),
          AsyncView(
            value: preview,
            builder: (txs) {
              final data = ReportData.build(
                period: range,
                transactions: txs,
                currency: currency,
                converter: converter,
                categories: categories,
                categoryName: l.categoryName,
                paymentLabel: l.paymentMethodLabel,
                budgets: const [],
                now: DateTime.now(),
              );
              if (data.isEmpty) {
                return AppCard(
                  child: EmptyState(
                    compact: true,
                    icon: Icons.description_outlined,
                    title: l.noDataForPeriod,
                    message: l.reportEmptyHint,
                  ),
                );
              }
              return AppCard(
                child: Column(
                  children: [
                    _line(
                      context,
                      l.income,
                      ConvertedAmountText(
                        data.income,
                        crossAxisAlignment: CrossAxisAlignment.end,
                      ),
                    ),
                    _line(
                      context,
                      l.expenses,
                      ConvertedAmountText(
                        data.expense,
                        crossAxisAlignment: CrossAxisAlignment.end,
                      ),
                    ),
                    _line(
                      context,
                      l.netCashFlow,
                      ConvertedAmountText(
                        data.net,
                        crossAxisAlignment: CrossAxisAlignment.end,
                      ),
                    ),
                    _line(
                      context,
                      l.rptTransactions,
                      Text(
                        '${data.rows.length}',
                        style: context.text.titleSmall,
                      ),
                    ),
                    _line(
                      context,
                      l.categories,
                      Text(
                        '${data.categories.length}',
                        style: context.text.titleSmall,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SectionHeader(l.format),
          SegmentedButton<ReportFormat>(
            segments: const [
              ButtonSegment(
                value: ReportFormat.pdf,
                label: Text('PDF'),
                icon: Icon(Icons.picture_as_pdf_rounded),
              ),
              ButtonSegment(
                value: ReportFormat.excel,
                label: Text('Excel'),
                icon: Icon(Icons.table_chart_rounded),
              ),
            ],
            selected: {_format},
            onSelectionChanged: (s) => setState(() => _format = s.first),
          ),
          const SizedBox(height: Insets.sm),
          Text(
            _format == ReportFormat.pdf ? l.pdfContents : l.excelContents,
            style: context.text.bodySmall,
          ),
          const SizedBox(height: Insets.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _run(share: false),
                  icon: const Icon(Icons.download_rounded),
                  label: Text(l.saveToDevice),
                ),
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : () => _run(share: true),
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.ios_share_rounded),
                  label: Text(l.share),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String label, Widget value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ),
        Flexible(child: value),
      ],
    ),
  );
}
