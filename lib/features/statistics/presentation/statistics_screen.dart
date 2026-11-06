import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/finance/ledger.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/date_range.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/charts.dart';
import '../../../shared/widgets/states.dart';

enum StatsPeriod { thisMonth, lastMonth, last3Months, thisYear, custom }

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  StatsPeriod _period = StatsPeriod.thisMonth;
  DateRange? _custom;
  int? _categoryId;

  DateRange _range(DateTime now) => switch (_period) {
    StatsPeriod.thisMonth => DateRange.month(now),
    StatsPeriod.lastMonth => DateRange.month(DateTime(now.year, now.month - 1)),
    StatsPeriod.last3Months => DateRange(
      DateTime(now.year, now.month - 2),
      DateRange.month(now).end,
    ),
    StatsPeriod.thisYear => DateRange.year(now),
    StatsPeriod.custom => _custom ?? DateRange.month(now),
  };

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
        _period = StatsPeriod.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = ref.watch(clockProvider)();
    final range = _range(now);
    // Load the selected period plus the last 12 months for trend charts.
    final trendStart = DateTime(now.year, now.month - 11);
    final load = DateRange(
      range.start.isBefore(trendStart) ? range.start : trendStart,
      range.end.isAfter(DateRange.month(now).end)
          ? range.end
          : DateRange.month(now).end,
    );
    final txs = ref.watch(transactionsInRangeProvider(load));
    final currency = ref.watch(
      settingsProvider.select((s) => s.primaryCurrency),
    );
    final converter = ref.watch(converterProvider);
    final categories = ref.watch(categoryMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.statistics),
        actions: [
          _CategoryFilterButton(
            selected: _categoryId,
            onChanged: (id) => setState(() => _categoryId = id),
          ),
        ],
      ),
      body: AsyncView(
        value: txs,
        builder: (list) {
          final filtered = _categoryId == null
              ? list
              : list.where((t) => t.categoryId == _categoryId).toList();
          final ledger = Ledger(filtered, currency, converter);
          final hasAny = ledger.count(null, range) > 0;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Insets.lg,
              0,
              Insets.lg,
              Insets.xxxl,
            ),
            children: [
              _PeriodChips(
                period: _period,
                customLabel: _custom == null
                    ? l.customRange
                    : '${context.dates.dayShort(_custom!.start)} – ${context.dates.dayShort(_custom!.lastDay)}',
                onSelect: (p) => p == StatsPeriod.custom
                    ? _pickCustom()
                    : setState(() => _period = p),
              ),
              if (_categoryId != null)
                Padding(
                  padding: const EdgeInsets.only(top: Insets.sm),
                  child: InputChip(
                    avatar: Icon(
                      AppIcons.of(
                        categories[_categoryId]?.iconKey ?? 'category',
                      ),
                      size: 16,
                    ),
                    label: Text(l.categoryName(categories[_categoryId])),
                    onDeleted: () => setState(() => _categoryId = null),
                  ),
                ),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: Insets.xxl),
                  child: EmptyState(
                    icon: Icons.insights_rounded,
                    title: l.emptyStatsTitle,
                    message: l.emptyStatsBody,
                    actionLabel: l.addTransaction,
                    onAction: () => context.push(Routes.newTransaction),
                  ),
                )
              else ...[
                _Overview(
                  ledger: ledger,
                  range: range,
                  now: now,
                  hasAny: hasAny,
                ),
                if (hasAny) ...[
                  _CategoryDistribution(
                    ledger: ledger,
                    range: range,
                    categories: categories,
                  ),
                  if (range.dayCount <= 62)
                    _DailySpending(ledger: ledger, range: range),
                ],
                _WeeklyComparison(ledger: ledger, now: now),
                _IncomeVsExpense(ledger: ledger, now: now),
                _MonthlyTrend(ledger: ledger, now: now),
                if (!converter.canConvert(Currency.uzs, Currency.usd) &&
                    list.map((t) => t.currency).toSet().length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: Insets.lg),
                    child: Text(
                      l.statsMissingRateNote,
                      style: context.text.bodySmall?.copyWith(
                        color: context.palette.warning,
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PeriodChips extends StatelessWidget {
  const _PeriodChips({
    required this.period,
    required this.onSelect,
    required this.customLabel,
  });
  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onSelect;
  final String customLabel;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final labels = {
      StatsPeriod.thisMonth: l.periodThisMonthTitle,
      StatsPeriod.lastMonth: l.periodLastMonthTitle,
      StatsPeriod.last3Months: l.last3Months,
      StatsPeriod.thisYear: l.thisYear,
      StatsPeriod.custom: customLabel,
    };
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final p in StatsPeriod.values)
            Padding(
              padding: const EdgeInsets.only(right: Insets.sm),
              child: ChoiceChip(
                label: Text(labels[p]!),
                avatar: p == StatsPeriod.custom
                    ? const Icon(Icons.date_range_rounded, size: 16)
                    : null,
                selected: period == p,
                onSelected: (_) => onSelect(p),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryFilterButton extends ConsumerWidget {
  const _CategoryFilterButton({
    required this.selected,
    required this.onChanged,
  });
  final int? selected;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cats =
        ref.watch(categoriesProvider).value ?? const <CategoryRecord>[];
    return PopupMenuButton<int>(
      tooltip: l.filterByCategory,
      icon: Icon(
        selected == null ? Icons.filter_list_rounded : Icons.filter_alt_rounded,
      ),
      onSelected: (v) => onChanged(v < 0 ? null : v),
      itemBuilder: (_) => [
        PopupMenuItem(value: -1, child: Text(l.allCategories)),
        for (final c in cats)
          PopupMenuItem(
            value: c.id,
            child: Row(
              children: [
                Icon(AppIcons.of(c.iconKey), size: 18, color: Color(c.color)),
                const SizedBox(width: Insets.sm),
                Expanded(
                  child: Text(
                    l.categoryName(c),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.ledger,
    required this.range,
    required this.now,
    required this.hasAny,
  });
  final Ledger ledger;
  final DateRange range;
  final DateTime now;
  final bool hasAny;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final income = ledger.total(TransactionType.income, range);
    final expense = ledger.total(TransactionType.expense, range);
    final net = ledger.net(range);
    // Average over elapsed days only, so the current month isn't diluted.
    final elapsedEnd = range.end.isAfter(now)
        ? DateTime(now.year, now.month, now.day + 1)
        : range.end;
    final avg = elapsedEnd.isAfter(range.start)
        ? ledger.averageDaily(
            TransactionType.expense,
            DateRange(range.start, elapsedEnd),
          )
        : 0;
    final highest = ledger.extreme(
      TransactionType.expense,
      highest: true,
      range: range,
    );
    final lowest = ledger.extreme(
      TransactionType.expense,
      highest: false,
      range: range,
    );

    Widget tile(String label, Widget value, {IconData? icon, Color? color}) =>
        AppCard(
          padding: const EdgeInsets.all(Insets.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: context.text.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Insets.sm),
              value,
            ],
          ),
        );

    Widget txValue(TransactionRecord? t) => t == null
        ? Text('—', style: context.text.titleMedium)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AmountText(
                Money(ledger.valueOf(t) ?? 0, ledger.currency),
                style: context.text.titleMedium,
              ),
              Text(
                t.title,
                style: context.text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

    final tiles = [
      tile(
        l.income,
        ConvertedAmountText(
          income,
          style: context.text.titleMedium?.copyWith(
            color: context.palette.income,
          ),
        ),
        icon: Icons.south_west_rounded,
        color: context.palette.income,
      ),
      tile(
        l.expenses,
        ConvertedAmountText(
          expense,
          style: context.text.titleMedium?.copyWith(
            color: context.palette.expense,
          ),
        ),
        icon: Icons.north_east_rounded,
        color: context.palette.expense,
      ),
      tile(
        l.netCashFlow,
        ConvertedAmountText(net, style: context.text.titleMedium),
        icon: Icons.account_balance_rounded,
        color: context.colors.primary,
      ),
      tile(
        l.avgDailySpending,
        AmountText(
          Money(avg, ledger.currency),
          style: context.text.titleMedium,
        ),
        icon: Icons.calendar_view_day_rounded,
        color: context.palette.warning,
      ),
      tile(
        l.highestExpense,
        txValue(highest),
        icon: Icons.arrow_upward_rounded,
        color: context.palette.expense,
      ),
      tile(
        l.lowestExpense,
        txValue(lowest),
        icon: Icons.arrow_downward_rounded,
        color: context.palette.income,
      ),
    ];
    return Column(
      children: [
        SectionHeader(l.overview),
        if (!hasAny)
          AppCard(
            child: Text(
              l.noDataForPeriod,
              style: context.text.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 560 ? 3 : 2;
              final w = (c.maxWidth - Insets.md * (cols - 1)) / cols;
              return Wrap(
                spacing: Insets.md,
                runSpacing: Insets.md,
                children: [for (final t in tiles) SizedBox(width: w, child: t)],
              );
            },
          ),
      ],
    );
  }
}

class _CategoryDistribution extends ConsumerStatefulWidget {
  const _CategoryDistribution({
    required this.ledger,
    required this.range,
    required this.categories,
  });
  final Ledger ledger;
  final DateRange range;
  final Map<int, CategoryRecord> categories;

  @override
  ConsumerState<_CategoryDistribution> createState() =>
      _CategoryDistributionState();
}

class _CategoryDistributionState extends ConsumerState<_CategoryDistribution> {
  int _touched = -1;
  TransactionType _type = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final shares = widget.ledger.byCategory(_type, widget.range);
    final total = shares.fold<int>(0, (a, s) => a + s.minor);
    return Column(
      children: [
        SectionHeader(l.categoryDistribution),
        AppCard(
          child: Column(
            children: [
              SegmentedButton<TransactionType>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text(l.expenses),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(l.income),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() {
                  _type = s.first;
                  _touched = -1;
                }),
              ),
              const SizedBox(height: Insets.lg),
              if (shares.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(Insets.lg),
                  child: Text(
                    l.noDataForPeriod,
                    style: context.text.bodyMedium,
                  ),
                )
              else ...[
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 62,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (!event.isInterestedForInteractions ||
                                  response?.touchedSection == null) {
                                if (_touched != -1) {
                                  setState(() => _touched = -1);
                                }
                                return;
                              }
                              setState(
                                () => _touched = response!
                                    .touchedSection!
                                    .touchedSectionIndex,
                              );
                            },
                          ),
                          sections: [
                            for (var i = 0; i < shares.length; i++)
                              PieChartSectionData(
                                value: shares[i].minor.toDouble(),
                                color: Color(
                                  widget
                                          .categories[shares[i].categoryId]
                                          ?.color ??
                                      0xFF90A4AE,
                                ),
                                radius: i == _touched ? 34 : 26,
                                title: '',
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _touched >= 0 && _touched < shares.length
                                ? l.categoryName(
                                    widget.categories[shares[_touched]
                                        .categoryId],
                                  )
                                : l.total,
                            style: context.text.labelMedium,
                          ),
                          SizedBox(
                            width: 110,
                            child: FittedBox(
                              child: AmountText(
                                Money(
                                  _touched >= 0 && _touched < shares.length
                                      ? shares[_touched].minor
                                      : total,
                                  widget.ledger.currency,
                                ),
                                style: context.text.titleMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Insets.lg),
                for (var i = 0; i < shares.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        IconTile(
                          icon: AppIcons.of(
                            widget.categories[shares[i].categoryId]?.iconKey ??
                                'category',
                          ),
                          color: Color(
                            widget.categories[shares[i].categoryId]?.color ??
                                0xFF90A4AE,
                          ),
                          size: 32,
                        ),
                        const SizedBox(width: Insets.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l.categoryName(
                                        widget.categories[shares[i].categoryId],
                                      ),
                                      style: context.text.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${(shares[i].share * 100).toStringAsFixed(1)}%',
                                    style: context.text.labelMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              AppProgressBar(
                                value: shares[i].share,
                                height: 5,
                                color: Color(
                                  widget
                                          .categories[shares[i].categoryId]
                                          ?.color ??
                                      0xFF90A4AE,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Insets.md),
                        AmountText(
                          Money(shares[i].minor, widget.ledger.currency),
                          style: context.text.titleSmall,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DailySpending extends StatelessWidget {
  const _DailySpending({required this.ledger, required this.range});
  final Ledger ledger;
  final DateRange range;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final days = range.days.toList();
    final values = ledger.daily(TransactionType.expense, range);
    return Column(
      children: [
        SectionHeader(l.dailySpending),
        AppCard(
          child: MoneyBarChart(
            highlightLast: false,
            color: context.palette.expense,
            currency: ledger.currency,
            points: [
              for (var i = 0; i < days.length; i++)
                BarPoint(
                  '${days[i].day}',
                  values[i],
                  tooltipLabel: context.dates.day(days[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyComparison extends StatelessWidget {
  const _WeeklyComparison({required this.ledger, required this.now});
  final Ledger ledger;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final weeks = ledger.weekly(TransactionType.expense, now, 8);
    final d = context.dates;
    return Column(
      children: [
        SectionHeader(l.weeklyComparison),
        AppCard(
          child: MoneyBarChart(
            color: context.colors.primary,
            currency: ledger.currency,
            points: [
              for (final (r, v) in weeks)
                BarPoint(
                  d.dayShort(r.start),
                  v,
                  tooltipLabel:
                      '${d.dayShort(r.start)} – ${d.dayShort(r.lastDay)}',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IncomeVsExpense extends StatelessWidget {
  const _IncomeVsExpense({required this.ledger, required this.now});
  final Ledger ledger;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final exp = ledger.monthly(TransactionType.expense, now, 6);
    final inc = ledger.monthly(TransactionType.income, now, 6);
    return Column(
      children: [
        SectionHeader(l.incomeVsExpenses),
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  LegendDot(color: context.palette.expense, label: l.expenses),
                  const SizedBox(width: Insets.lg),
                  LegendDot(color: context.palette.income, label: l.income),
                ],
              ),
              const SizedBox(height: Insets.lg),
              MoneyBarChart(
                color: context.palette.expense,
                secondaryColor: context.palette.income,
                currency: ledger.currency,
                points: [
                  for (var i = 0; i < exp.length; i++)
                    BarPoint(
                      context.dates.monthShort(exp[i].$1.start),
                      exp[i].$2,
                      secondaryMinor: inc[i].$2,
                      tooltipLabel: context.dates.month(exp[i].$1.start),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthlyTrend extends ConsumerWidget {
  const _MonthlyTrend({required this.ledger, required this.now});
  final Ledger ledger;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hidden = ref.watch(settingsProvider.select((s) => s.hideAmounts));
    final months = ledger.monthly(TransactionType.expense, now, 12);
    final maxV = months.fold<int>(0, (m, e) => e.$2 > m ? e.$2 : m);
    final color = context.colors.primary;
    return Column(
      children: [
        SectionHeader(l.monthlyExpenseTrend),
        AppCard(
          padding: const EdgeInsets.fromLTRB(
            Insets.md,
            Insets.xl,
            Insets.lg,
            Insets.md,
          ),
          child: SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxV == 0 ? 1 : maxV * 1.2,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxV == 0 ? 1 : maxV * 1.2 / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.palette.outline.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= months.length || i % 2 == 1) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            context.dates.monthShort(months[i].$1.start),
                            style: context.text.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => context.palette.surface2,
                    fitInsideHorizontally: true,
                    getTooltipItems: (spots) => [
                      for (final s in spots)
                        LineTooltipItem(
                          '${context.dates.month(months[s.x.toInt()].$1.start)}\n',
                          context.text.labelSmall!,
                          children: [
                            TextSpan(
                              text: context.money.formatMinor(
                                months[s.x.toInt()].$2,
                                ledger.currency,
                                hidden: hidden,
                              ),
                              style: context.text.titleSmall?.copyWith(
                                color: color,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < months.length; i++)
                        FlSpot(i.toDouble(), months[i].$2.toDouble()),
                    ],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: color,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withValues(alpha: 0.28),
                          color.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
