import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/app_theme.dart';
import '../../core/localization/l10n.dart';
import '../../core/money/currency.dart';

/// One bar of a [MoneyBarChart].
class BarPoint {
  const BarPoint(
    this.label,
    this.minor, {
    this.tooltipLabel,
    this.secondaryMinor,
  });
  final String label;
  final int minor;
  final String? tooltipLabel;

  /// Optional second series (e.g. income next to expenses).
  final int? secondaryMinor;
}

/// Interactive bar chart for money values with tooltips.
class MoneyBarChart extends ConsumerWidget {
  const MoneyBarChart({
    super.key,
    required this.points,
    required this.currency,
    this.color,
    this.secondaryColor,
    this.height = 180,
    this.highlightLast = true,
  });

  final List<BarPoint> points;
  final Currency currency;
  final Color? color;
  final Color? secondaryColor;
  final double height;
  final bool highlightLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(settingsProvider.select((s) => s.hideAmounts));
    final fmt = context.money;
    final primary = color ?? context.colors.primary;
    final secondary = secondaryColor ?? context.palette.income;
    final hasSecondary = points.any((p) => p.secondaryMinor != null);
    final maxY = points.fold<int>(
      0,
      (m, p) => math.max(m, math.max(p.minor, p.secondaryMinor ?? 0)),
    );
    final top = maxY == 0 ? 1.0 : maxY * 1.15;
    final barWidth = hasSecondary
        ? (points.length > 8 ? 6.0 : 9.0)
        : (points.length > 10 ? 10.0 : 16.0);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: top,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: top / 4,
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
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= points.length) {
                    return const SizedBox.shrink();
                  }
                  // Thin out labels on dense charts.
                  final step = points.length > 12
                      ? (points.length / 6).ceil()
                      : 1;
                  if (i % step != 0 && i != points.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(
                      points[i].label,
                      style: context.text.labelSmall?.copyWith(
                        letterSpacing: 0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => context.palette.surface2,
              tooltipBorderRadius: BorderRadius.circular(10),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final p = points[group.x];
                final value = rodIndex == 0 ? p.minor : (p.secondaryMinor ?? 0);
                return BarTooltipItem(
                  '${p.tooltipLabel ?? p.label}\n',
                  context.text.labelSmall!.copyWith(letterSpacing: 0),
                  children: [
                    TextSpan(
                      text: fmt.formatMinor(value, currency, hidden: hidden),
                      style: context.text.titleSmall?.copyWith(
                        color: rod.color,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 3,
                barRods: [
                  BarChartRodData(
                    toY: points[i].minor.toDouble(),
                    width: barWidth,
                    color:
                        highlightLast && !hasSecondary && i != points.length - 1
                        ? primary.withValues(alpha: 0.45)
                        : primary,
                    borderRadius: BorderRadius.circular(barWidth / 2.2),
                  ),
                  if (hasSecondary)
                    BarChartRodData(
                      toY: (points[i].secondaryMinor ?? 0).toDouble(),
                      width: barWidth,
                      color: secondary,
                      borderRadius: BorderRadius.circular(barWidth / 2.2),
                    ),
                ],
              ),
          ],
        ),
        duration: const Duration(milliseconds: 350),
      ),
    );
  }
}

/// A legend row item.
class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          style: context.text.labelMedium,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
