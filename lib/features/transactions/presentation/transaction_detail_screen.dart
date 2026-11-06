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
import '../../../shared/widgets/amount_text.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/states.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final tx = ref.watch(transactionByIdProvider(id));
    final categories = ref.watch(categoryMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.transactionDetails),
        actions: [
          IconButton(
            tooltip: l.edit,
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push(Routes.editTransaction(id)),
          ),
          IconButton(
            tooltip: l.delete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: context.palette.expense,
            ),
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: l.deleteTransactionTitle,
                message: l.deleteTransactionBody,
                destructive: true,
              );
              if (!ok || !context.mounted) return;
              await ref.read(transactionRepositoryProvider).delete(id);
              if (!context.mounted) return;
              showSnack(context, l.transactionDeleted);
              context.pop();
            },
          ),
        ],
      ),
      body: AsyncView(
        value: tx,
        builder: (t) {
          if (t == null) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: l.notFound,
              message: l.notFoundBody,
            );
          }
          final c = categories[t.categoryId];
          final color = Color(c?.color ?? 0xFF90A4AE);
          final dates = context.dates;
          Widget row(String label, String value, {IconData? icon}) => Padding(
            padding: const EdgeInsets.symmetric(vertical: Insets.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: context.palette.textSecondary),
                  const SizedBox(width: Insets.md),
                ],
                SizedBox(
                  width: 120,
                  child: Text(
                    label,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: context.text.bodyMedium,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
          return ListView(
            padding: const EdgeInsets.all(Insets.lg),
            children: [
              AppCard(
                padding: const EdgeInsets.all(Insets.xl),
                child: Column(
                  children: [
                    IconTile(
                      icon: AppIcons.of(c?.iconKey ?? 'category'),
                      color: color,
                      size: 64,
                    ),
                    const SizedBox(height: Insets.md),
                    Text(
                      t.title,
                      style: context.text.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Insets.sm),
                    AmountText(
                      Money(t.amountMinor, t.currency),
                      type: t.type,
                      style: context.text.displaySmall,
                    ),
                    const SizedBox(height: Insets.xs),
                    Text(l.typeLabel(t.type), style: context.text.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: Insets.md),
              AppCard(
                child: Column(
                  children: [
                    row(
                      l.category,
                      l.categoryName(c),
                      icon: Icons.category_rounded,
                    ),
                    row(
                      l.date,
                      dates.dayTime(t.date),
                      icon: Icons.calendar_today_rounded,
                    ),
                    row(
                      l.paymentMethod,
                      l.paymentMethodLabel(t.paymentMethod),
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    row(
                      l.currency,
                      t.currency.code,
                      icon: Icons.currency_exchange_rounded,
                    ),
                    if (t.recurringId != null)
                      row(
                        l.source,
                        l.fromRecurring,
                        icon: Icons.autorenew_rounded,
                      ),
                    if (t.description != null)
                      row(
                        l.description,
                        t.description!,
                        icon: Icons.notes_rounded,
                      ),
                    const Divider(height: Insets.xl),
                    row(l.created, dates.dayTime(t.createdAt)),
                    row(l.updated, dates.dayTime(t.updatedAt)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
