import '../../core/money/currency.dart';
import '../../core/money/money.dart';
import 'enums.dart';

/// User preferences. Persisted in shared preferences (not financial data).
class AppSettings {
  const AppSettings({
    this.onboardingDone = false,
    this.localeCode,
    this.theme = AppThemePreference.system,
    this.primaryCurrency = Currency.uzs,
    this.hideAmounts = false,
    this.displayName,
    this.openingBalances = const {},
    this.budgetWarningPercent = 75,
    this.budgetCriticalPercent = 90,
    this.notificationsEnabled = true,
    this.budgetAlertsEnabled = true,
    this.cloudBackupConsent = false,
    this.lastCloudBackupAt,
  });

  final bool onboardingDone;

  /// `uz`, `ru`, `en` or null for system language.
  final String? localeCode;
  final AppThemePreference theme;
  final Currency primaryCurrency;
  final bool hideAmounts;
  final String? displayName;

  /// Initial balance per currency, set during onboarding / in settings.
  final Map<Currency, int> openingBalances;
  final int budgetWarningPercent;
  final int budgetCriticalPercent;
  final bool notificationsEnabled;
  final bool budgetAlertsEnabled;
  final bool cloudBackupConsent;
  final DateTime? lastCloudBackupAt;

  MultiCurrencyAmount get openingBalance =>
      MultiCurrencyAmount(openingBalances);

  AppSettings copyWith({
    bool? onboardingDone,
    String? Function()? localeCode,
    AppThemePreference? theme,
    Currency? primaryCurrency,
    bool? hideAmounts,
    String? Function()? displayName,
    Map<Currency, int>? openingBalances,
    int? budgetWarningPercent,
    int? budgetCriticalPercent,
    bool? notificationsEnabled,
    bool? budgetAlertsEnabled,
    bool? cloudBackupConsent,
    DateTime? Function()? lastCloudBackupAt,
  }) => AppSettings(
    onboardingDone: onboardingDone ?? this.onboardingDone,
    localeCode: localeCode != null ? localeCode() : this.localeCode,
    theme: theme ?? this.theme,
    primaryCurrency: primaryCurrency ?? this.primaryCurrency,
    hideAmounts: hideAmounts ?? this.hideAmounts,
    displayName: displayName != null ? displayName() : this.displayName,
    openingBalances: openingBalances ?? this.openingBalances,
    budgetWarningPercent: budgetWarningPercent ?? this.budgetWarningPercent,
    budgetCriticalPercent: budgetCriticalPercent ?? this.budgetCriticalPercent,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
    cloudBackupConsent: cloudBackupConsent ?? this.cloudBackupConsent,
    lastCloudBackupAt: lastCloudBackupAt != null
        ? lastCloudBackupAt()
        : this.lastCloudBackupAt,
  );

  Map<String, Object?> toJson() => {
    'onboardingDone': onboardingDone,
    'localeCode': localeCode,
    'theme': theme.name,
    'primaryCurrency': primaryCurrency.code,
    'hideAmounts': hideAmounts,
    'displayName': displayName,
    'openingBalances': {
      for (final e in openingBalances.entries) e.key.code: e.value,
    },
    'budgetWarningPercent': budgetWarningPercent,
    'budgetCriticalPercent': budgetCriticalPercent,
    'notificationsEnabled': notificationsEnabled,
    'budgetAlertsEnabled': budgetAlertsEnabled,
    'cloudBackupConsent': cloudBackupConsent,
    'lastCloudBackupAt': lastCloudBackupAt?.toIso8601String(),
  };

  factory AppSettings.fromJson(Map<String, Object?> j) {
    final ob = <Currency, int>{};
    final raw = j['openingBalances'];
    if (raw is Map) {
      raw.forEach((k, v) {
        final c = Currency.tryParse(k as String?);
        if (c != null && v is int) ob[c] = v;
      });
    }
    int pct(Object? v, int d) => v is int && v > 0 && v <= 100 ? v : d;
    return AppSettings(
      onboardingDone: j['onboardingDone'] == true,
      localeCode: const {'uz', 'ru', 'en'}.contains(j['localeCode'])
          ? j['localeCode'] as String
          : null,
      theme: AppThemePreference.values.firstWhere(
        (t) => t.name == j['theme'],
        orElse: () => AppThemePreference.system,
      ),
      primaryCurrency:
          Currency.tryParse(j['primaryCurrency'] as String?) ?? Currency.uzs,
      hideAmounts: j['hideAmounts'] == true,
      displayName: j['displayName'] as String?,
      openingBalances: ob,
      budgetWarningPercent: pct(j['budgetWarningPercent'], 75),
      budgetCriticalPercent: pct(j['budgetCriticalPercent'], 90),
      notificationsEnabled: j['notificationsEnabled'] != false,
      budgetAlertsEnabled: j['budgetAlertsEnabled'] != false,
      cloudBackupConsent: j['cloudBackupConsent'] == true,
      lastCloudBackupAt: DateTime.tryParse(
        j['lastCloudBackupAt'] as String? ?? '',
      ),
    );
  }
}
