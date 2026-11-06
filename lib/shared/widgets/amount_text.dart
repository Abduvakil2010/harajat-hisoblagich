import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../core/finance/ledger.dart';
import '../../core/localization/l10n.dart';
import '../../core/money/money.dart';
import '../../data/models/enums.dart';

/// Displays money respecting the global "hide amounts" preference.
class AmountText extends ConsumerWidget {
  const AmountText(
    this.money, {
    super.key,
    this.style,
    this.type,
    this.signed = false,
    this.compact = false,
    this.colored = true,
    this.textAlign,
  });

  final Money money;
  final TextStyle? style;

  /// When set, colours the amount (income green / expense red) and adds a sign.
  final TransactionType? type;
  final bool signed;
  final bool compact;
  final bool colored;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(settingsProvider.select((s) => s.hideAmounts));
    final m = switch (type) {
      TransactionType.expense => Money(-money.minor.abs(), money.currency),
      TransactionType.income => Money(money.minor.abs(), money.currency),
      null => money,
    };
    final color = !colored || type == null
        ? null
        : (type == TransactionType.income
              ? context.palette.income
              : context.palette.expense);
    return Text(
      context.money.format(
        m,
        hidden: hidden,
        signed: signed || type != null,
        compact: compact,
      ),
      style: AppTypography.amount
          .merge(style)
          .copyWith(color: color ?? style?.color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}

/// Displays a [ConvertedSum]; when some amounts could not be converted it
/// shows them separately with a hint instead of mixing currencies.
class ConvertedAmountText extends ConsumerWidget {
  const ConvertedAmountText(
    this.sum, {
    super.key,
    this.style,
    this.secondaryStyle,
    this.crossAxisAlignment,
  });

  final ConvertedSum sum;
  final TextStyle? style;
  final TextStyle? secondaryStyle;
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(settingsProvider.select((s) => s.hideAmounts));
    final extra = sum.unconverted.toMoneyList();
    final fmt = context.money;
    return Column(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            fmt.format(sum.money, hidden: hidden),
            style: AppTypography.amount.merge(style),
            maxLines: 1,
          ),
        ),
        if (extra.isNotEmpty)
          Text(
            '+ ${extra.map((m) => fmt.format(m, hidden: hidden)).join(' + ')} · ${context.l10n.noRateShort}',
            style: (secondaryStyle ?? context.text.bodySmall)?.copyWith(
              color: context.palette.warning,
            ),
            maxLines: 2,
          ),
      ],
    );
  }
}
