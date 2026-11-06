import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money_format.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../recurring_payments/application/recurring_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _languageNames = {
    'uz': 'O‘zbekcha',
    'ru': 'Русский',
    'en': 'English',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final ctrl = ref.read(settingsProvider.notifier);
    final lang = s.localeCode ?? Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Insets.lg,
            Insets.lg,
            Insets.lg,
            Insets.xxxl,
          ),
          children: [
            Text(l.navProfile, style: context.text.headlineMedium),
            const SizedBox(height: Insets.lg),
            AppCard(
              onTap: () => _editName(context, ref),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: context.colors.primary.withValues(
                      alpha: 0.18,
                    ),
                    child: Text(
                      (s.displayName?.isNotEmpty ?? false)
                          ? s.displayName!.characters.first.toUpperCase()
                          : 'H',
                      style: context.text.titleLarge?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.displayName ?? l.guestUser,
                          style: context.text.titleMedium,
                        ),
                        Text(l.localProfileNote, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_rounded, size: 20),
                ],
              ),
            ),
            _Group(
              title: l.finance,
              tiles: [
                _Tile(
                  Icons.pie_chart_rounded,
                  l.budgets,
                  onTap: () => context.push(Routes.budgets),
                ),
                _Tile(
                  Icons.savings_rounded,
                  l.savingsGoals,
                  onTap: () => context.push(Routes.savings),
                ),
                _Tile(
                  Icons.handshake_rounded,
                  l.debts,
                  onTap: () => context.push(Routes.debts),
                ),
                _Tile(
                  Icons.autorenew_rounded,
                  l.recurringPayments,
                  onTap: () => context.push(Routes.recurring),
                ),
                _Tile(
                  Icons.category_rounded,
                  l.categories,
                  onTap: () => context.push(Routes.categories),
                ),
                _Tile(
                  Icons.description_rounded,
                  l.reports,
                  onTap: () => context.push(Routes.reports),
                ),
              ],
            ),
            _Group(
              title: l.preferences,
              tiles: [
                _Tile(
                  Icons.language_rounded,
                  l.language,
                  value: _languageNames[lang],
                  onTap: () async {
                    final v = await _choose<String>(context, l.language, {
                      for (final e in _languageNames.entries) e.key: e.value,
                    }, lang);
                    if (v != null) {
                      await ctrl.update((x) => x.copyWith(localeCode: () => v));
                    }
                  },
                ),
                _Tile(
                  Icons.payments_rounded,
                  l.primaryCurrency,
                  value: s.primaryCurrency.code,
                  onTap: () async {
                    final v = await _choose<Currency>(
                      context,
                      l.primaryCurrency,
                      {for (final c in Currency.values) c: c.code},
                      s.primaryCurrency,
                    );
                    if (v != null) {
                      await ctrl.update((x) => x.copyWith(primaryCurrency: v));
                    }
                  },
                ),
                _Tile(
                  Icons.currency_exchange_rounded,
                  l.exchangeRates,
                  onTap: () => context.push(Routes.rates),
                ),
                _Tile(
                  Icons.dark_mode_rounded,
                  l.theme,
                  value: l.themeLabel(s.theme),
                  onTap: () async {
                    final v = await _choose<AppThemePreference>(
                      context,
                      l.theme,
                      {
                        for (final t in AppThemePreference.values)
                          t: l.themeLabel(t),
                      },
                      s.theme,
                    );
                    if (v != null) {
                      await ctrl.update((x) => x.copyWith(theme: v));
                    }
                  },
                ),
                _Tile(
                  Icons.account_balance_wallet_rounded,
                  l.initialBalance,
                  value: s.openingBalance.isEmpty
                      ? l.notSet
                      : s.openingBalance
                            .toMoneyList()
                            .map(
                              (m) => context.money.format(
                                m,
                                hidden: s.hideAmounts,
                              ),
                            )
                            .join(' + '),
                  onTap: () => showAppSheet(
                    context,
                    (_) => const _OpeningBalanceSheet(),
                  ),
                ),
                _SwitchTile(
                  icon: Icons.notifications_rounded,
                  title: l.notifications,
                  subtitle: l.notificationsHint,
                  value: s.notificationsEnabled,
                  onChanged: (v) async {
                    if (v) {
                      await ref
                          .read(notificationServiceProvider)
                          .requestPermission();
                    }
                    await ctrl.update(
                      (x) => x.copyWith(notificationsEnabled: v),
                    );
                    if (!v) {
                      await ref.read(notificationServiceProvider).cancelAll();
                    }
                    await ref
                        .read(recurringServiceProvider)
                        .rescheduleReminders();
                  },
                ),
                _SwitchTile(
                  icon: Icons.warning_amber_rounded,
                  title: l.budgetAlerts,
                  subtitle: l.thresholdsSummary(
                    s.budgetWarningPercent,
                    s.budgetCriticalPercent,
                  ),
                  value: s.budgetAlertsEnabled,
                  onChanged: s.notificationsEnabled
                      ? (v) => ctrl.update(
                          (x) => x.copyWith(budgetAlertsEnabled: v),
                        )
                      : null,
                ),
                _SwitchTile(
                  icon: Icons.visibility_off_rounded,
                  title: l.hideAmounts,
                  subtitle: l.hideAmountsHint,
                  value: s.hideAmounts,
                  onChanged: (v) =>
                      ctrl.update((x) => x.copyWith(hideAmounts: v)),
                ),
              ],
            ),
            _Group(
              title: l.data,
              tiles: [
                _Tile(
                  Icons.cloud_sync_rounded,
                  l.backupAndSync,
                  onTap: () => context.push(Routes.backup),
                ),
                _Tile(
                  Icons.delete_forever_rounded,
                  l.resetData,
                  danger: true,
                  onTap: () => _reset(context, ref),
                ),
              ],
            ),
            _Group(
              title: l.about,
              tiles: [
                _Tile(
                  Icons.shield_rounded,
                  l.privacyAndAbout,
                  onTap: () => context.push(Routes.about),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final c = TextEditingController(
      text: ref.read(settingsProvider).displayName ?? '',
    );
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.displayName),
        content: TextField(
          controller: c,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: l.displayNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
            onPressed: () => Navigator.pop(ctx, c.text.trim()),
            child: Text(l.save),
          ),
        ],
      ),
    );
    c.dispose();
    if (v != null) {
      await ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(displayName: () => v.isEmpty ? null : v));
    }
  }

  Future<T?> _choose<T>(
    BuildContext context,
    String title,
    Map<T, String> options,
    T current,
  ) => showAppSheet<T>(
    context,
    (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.xl,
              0,
              Insets.xl,
              Insets.sm,
            ),
            child: Text(title, style: ctx.text.titleLarge),
          ),
          RadioGroup<T>(
            groupValue: current,
            onChanged: (v) => Navigator.pop(ctx, v),
            child: Column(
              children: [
                for (final e in options.entries)
                  RadioListTile<T>(value: e.key, title: Text(e.value)),
              ],
            ),
          ),
          const SizedBox(height: Insets.md),
        ],
      ),
    ),
  );

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ResetDialog(),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(databaseProvider).wipeAll();
    await ref.read(notificationServiceProvider).cancelAll();
    final prefs = ref.read(sharedPreferencesProvider);
    for (final k in prefs.getKeys().where(
      (k) => k.startsWith('budgetAlert:'),
    )) {
      await prefs.remove(k);
    }
    await ref.read(settingsProvider.notifier).reset();
    if (context.mounted) showSnack(context, l.dataReset);
  }
}

class _ResetDialog extends StatefulWidget {
  const _ResetDialog();

  @override
  State<_ResetDialog> createState() => _ResetDialogState();
}

class _ResetDialogState extends State<_ResetDialog> {
  bool _understood = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: context.palette.expense,
        size: 32,
      ),
      title: Text(l.resetDataTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.resetDataBody),
          const SizedBox(height: Insets.md),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _understood,
            onChanged: (v) => setState(() => _understood = v ?? false),
            title: Text(l.resetDataConfirm, style: context.text.bodyMedium),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.error,
            minimumSize: const Size(64, 44),
          ),
          onPressed: _understood ? () => Navigator.pop(context, true) : null,
          child: Text(l.resetData),
        ),
      ],
    );
  }
}

class _OpeningBalanceSheet extends ConsumerStatefulWidget {
  const _OpeningBalanceSheet();

  @override
  ConsumerState<_OpeningBalanceSheet> createState() =>
      _OpeningBalanceSheetState();
}

class _OpeningBalanceSheetState extends ConsumerState<_OpeningBalanceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final Map<Currency, TextEditingController> _c = {
    for (final cur in Currency.values)
      cur: TextEditingController(
        text: (ref.read(settingsProvider).openingBalances[cur] ?? 0) == 0
            ? ''
            : MoneyFormat.toInput(
                ref.read(settingsProvider).openingBalances[cur]!,
                cur,
              ),
      ),
  };

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
              Text(l.initialBalance, style: context.text.titleLarge),
              Text(l.initialBalanceHint, style: context.text.bodySmall),
              const SizedBox(height: Insets.lg),
              for (final cur in Currency.values) ...[
                AmountField(
                  controller: _c[cur]!,
                  currency: cur,
                  allowZero: true,
                  label: '${l.initialBalance} (${cur.code})',
                ),
                const SizedBox(height: Insets.md),
              ],
              const SizedBox(height: Insets.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final map = <Currency, int>{
                      for (final cur in Currency.values)
                        if ((MoneyFormat.parseMinor(_c[cur]!.text, cur) ?? 0) >
                            0)
                          cur: MoneyFormat.parseMinor(_c[cur]!.text, cur)!,
                    };
                    await ref
                        .read(settingsProvider.notifier)
                        .update((s) => s.copyWith(openingBalances: map));
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(l.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.tiles});
  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeader(title),
      AppCard(
        padding: const EdgeInsets.symmetric(vertical: Insets.xs),
        child: Column(children: tiles),
      ),
    ],
  );
}

class _Tile extends StatelessWidget {
  const _Tile(
    this.icon,
    this.title, {
    this.value,
    this.onTap,
    this.danger = false,
  });
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? context.palette.expense : null;
    return ListTile(
      leading: Icon(icon, color: color ?? context.colors.primary),
      title: Text(title, style: context.text.bodyLarge?.copyWith(color: color)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                value!,
                style: context.text.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: Icon(icon, color: context.colors.primary),
    title: Text(title, style: context.text.bodyLarge),
    subtitle: subtitle == null ? null : Text(subtitle!),
    value: value,
    onChanged: onChanged,
  );
}
