import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/money.dart';
import '../../../data/local/app_database.dart';
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_card.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile(this.tx, {super.key, this.showDate = true});

  final TransactionRecord tx;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final category = ref.watch(categoryMapProvider)[tx.categoryId];
    final color = Color(category?.color ?? 0xFF90A4AE);
    final now = ref.watch(clockProvider)();
    final subtitle = [
      l.categoryName(category),
      if (showDate) context.dates.relative(tx.date, l, now),
    ].join(' · ');

    return InkWell(
      borderRadius: Radii.field,
      onTap: () => context.push(Routes.transaction(tx.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.sm,
          vertical: Insets.sm + 2,
        ),
        child: Row(
          children: [
            IconTile(
              icon: AppIcons.of(category?.iconKey ?? 'category'),
              color: color,
            ),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          tx.title,
                          style: context.text.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tx.recurringId != null) ...[
                        const SizedBox(width: Insets.xs),
                        Icon(
                          Icons.autorenew_rounded,
                          size: 14,
                          color: context.palette.textSecondary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Insets.sm),
            AmountText(
              Money(tx.amountMinor, tx.currency),
              type: tx.type,
              style: context.text.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
