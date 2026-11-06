import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/l10n.dart';
import '../data/models/enums.dart';
import '../features/budgets/application/budget_alert_service.dart';
import '../features/recurring_payments/application/recurring_service.dart';
import 'providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class HisobApp extends ConsumerStatefulWidget {
  const HisobApp({super.key});

  @override
  ConsumerState<HisobApp> createState() => _HisobAppState();
}

class _HisobAppState extends ConsumerState<HisobApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recurringServiceProvider).run();
      ref.read(budgetAlertServiceProvider).start();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The app may have been suspended across midnight: catch up recurring
    // payments whenever it comes back to the foreground.
    if (state == AppLifecycleState.resumed) {
      ref.read(recurringServiceProvider).run();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final localeCode = ref.watch(settingsProvider.select((s) => s.localeCode));
    final theme = ref.watch(settingsProvider.select((s) => s.theme));

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (theme) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      },
      locale: localeCode == null ? null : Locale(localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (device, supported) {
        if (device != null) {
          for (final l in supported) {
            if (l.languageCode == device.languageCode) return l;
          }
        }
        return const Locale('uz');
      },
      builder: (context, child) {
        // Respect user text scaling, but clamp extreme values so financial
        // layouts stay readable without clipping.
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.35,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
