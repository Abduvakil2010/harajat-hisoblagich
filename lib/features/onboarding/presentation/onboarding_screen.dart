import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money_format.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/form_fields.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _balance = TextEditingController();
  int _index = 0;

  static const _introCount = 4;

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _introCount) {
      _page.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _finish() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;
    final settings = ref.read(settingsProvider);
    final currency = settings.primaryCurrency;
    final opening = MoneyFormat.parseMinor(_balance.text, currency) ?? 0;
    final name = _name.text.trim();
    await ref
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(
            onboardingDone: true,
            displayName: () => name.isEmpty ? null : name,
            openingBalances: opening > 0 ? {currency: opening} : const {},
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pages = [
      _IntroPage(
        icon: Icons.account_balance_wallet_rounded,
        title: l.onbWelcomeTitle,
        body: l.onbWelcomeBody,
      ),
      _IntroPage(
        icon: Icons.insights_rounded,
        title: l.onbUnderstandTitle,
        body: l.onbUnderstandBody,
      ),
      _IntroPage(
        icon: Icons.pie_chart_rounded,
        title: l.onbBudgetTitle,
        body: l.onbBudgetBody,
      ),
      _IntroPage(
        icon: Icons.savings_rounded,
        title: l.onbGoalsTitle,
        body: l.onbGoalsBody,
      ),
      _SetupPage(formKey: _formKey, name: _name, balance: _balance),
    ];
    final isLast = _index == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.xl,
                Insets.md,
                Insets.sm,
                0,
              ),
              child: Row(
                children: [
                  const _Logo(),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: () => _page.animateToPage(
                        _introCount,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                      ),
                      child: Text(l.skip),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.xl,
                Insets.sm,
                Insets.xl,
                Insets.xl,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _index ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? context.colors.primary
                            : context.palette.outline,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: isLast ? _finish : _next,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(140, 52),
                    ),
                    child: Text(isLast ? l.onbStart : l.next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          gradient: LinearGradient(
            colors: [context.colors.primary, context.palette.accent],
          ),
        ),
        child: const Icon(
          Icons.auto_graph_rounded,
          size: 18,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: Insets.sm),
      Text('HisobAI', style: context.text.titleMedium),
    ],
  );
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Insets.xxl),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: context.palette.heroGradient,
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.25),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Icon(icon, size: 56, color: Colors.white),
              ),
              const SizedBox(height: Insets.xxxl),
              Text(title, style: context.text.displaySmall),
              const SizedBox(height: Insets.md),
              Text(
                body,
                style: context.text.bodyLarge?.copyWith(
                  color: context.palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupPage extends ConsumerWidget {
  const _SetupPage({
    required this.formKey,
    required this.name,
    required this.balance,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final ctrl = ref.read(settingsProvider.notifier);
    final current = Localizations.localeOf(context).languageCode;

    Widget label(String t) => Padding(
      padding: const EdgeInsets.only(top: Insets.xl, bottom: Insets.sm),
      child: Text(t, style: context.text.labelMedium),
    );

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
        children: [
          Text(l.onbSetupTitle, style: context.text.headlineMedium),
          const SizedBox(height: Insets.xs),
          Text(
            l.onbSetupBody,
            style: context.text.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
          label(l.language),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'uz', label: Text('O‘zbek')),
              ButtonSegment(value: 'ru', label: Text('Русский')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {s.localeCode ?? current},
            onSelectionChanged: (v) =>
                ctrl.update((x) => x.copyWith(localeCode: () => v.first)),
          ),
          label(l.primaryCurrency),
          SegmentedButton<Currency>(
            segments: [
              for (final c in Currency.values)
                ButtonSegment(value: c, label: Text(c.code)),
            ],
            selected: {s.primaryCurrency},
            onSelectionChanged: (v) =>
                ctrl.update((x) => x.copyWith(primaryCurrency: v.first)),
          ),
          label(l.theme),
          SegmentedButton<AppThemePreference>(
            segments: [
              for (final t in AppThemePreference.values)
                ButtonSegment(value: t, label: Text(l.themeLabel(t))),
            ],
            selected: {s.theme},
            onSelectionChanged: (v) =>
                ctrl.update((x) => x.copyWith(theme: v.first)),
          ),
          label(l.displayNameOptional),
          TextFormField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            decoration: InputDecoration(
              hintText: l.displayNameHint,
              counterText: '',
            ),
          ),
          label(l.initialBalanceOptional),
          AmountField(
            controller: balance,
            currency: s.primaryCurrency,
            allowZero: true,
            label: l.initialBalance,
          ),
          const SizedBox(height: Insets.sm),
          Text(l.onbNoAccountNote, style: context.text.bodySmall),
          const SizedBox(height: Insets.xxl),
        ],
      ),
    );
  }
}
