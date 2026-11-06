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
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/states.dart';
import '../application/recurring_service.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final items = ref.watch(recurringProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.recurringPayments)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.newRecurring),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.addRecurring),
      ),
      body: AsyncView(
        value: items,
        builder: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.autorenew_rounded,
              title: l.emptyRecurringTitle,
              message: l.emptyRecurringBody,
              actionLabel: l.addRecurring,
              onAction: () => context.push(Routes.newRecurring),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              Insets.lg,
              Insets.sm,
              Insets.lg,
              96,
            ),
            itemCount: list.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: Insets.sm),
            itemBuilder: (context, i) {
              if (i == list.length) {
                return Padding(
                  padding: const EdgeInsets.all(Insets.sm),
                  child: Text(
                    l.recurringAutoNote,
                    style: context.text.bodySmall,
                  ),
                );
              }
              return _RecurringTile(list[i]);
            },
          );
        },
      ),
    );
  }
}

class _RecurringTile extends ConsumerWidget {
  const _RecurringTile(this.r);
  final RecurringPaymentRecord r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = ref.watch(categoryMapProvider)[r.categoryId];
    final next = r.nextDueDate;
    final subtitle = [
      l.frequencyLabel(r.frequency),
      if (!r.isActive)
        l.paused
      else if (next != null)
        l.nextDue(context.dates.day(next))
      else
        l.ended,
    ].join(' · ');

    return Opacity(
      opacity: r.isActive ? 1 : 0.6,
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(
          Insets.md,
          Insets.md,
          Insets.xs,
          Insets.md,
        ),
        onTap: () => context.push(Routes.editRecurring(r.id)),
        child: Row(
          children: [
            IconTile(
              icon: AppIcons.of(c?.iconKey ?? 'category'),
              color: Color(c?.color ?? 0xFF90A4AE),
            ),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                    style: context.text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AmountText(
                    Money(r.amountMinor, r.currency),
                    type: r.type,
                    style: context.text.titleSmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: r.isActive,
              onChanged: (v) async {
                await ref.read(recurringRepositoryProvider).setActive(r.id, v);
                await ref.read(recurringServiceProvider).run();
              },
            ),
            PopupMenuButton<String>(
              tooltip: l.more,
              onSelected: (v) async {
                if (v == 'edit') {
                  await context.push(Routes.editRecurring(r.id));
                } else {
                  final ok = await confirmAction(
                    context,
                    title: l.deleteRecurringTitle,
                    message: l.deleteRecurringBody,
                    destructive: true,
                  );
                  if (!ok) return;
                  await ref.read(recurringRepositoryProvider).delete(r.id);
                  await ref
                      .read(notificationServiceProvider)
                      .cancel('recurring:${r.id}');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l.edit)),
                PopupMenuItem(value: 'delete', child: Text(l.delete)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
