import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../data/local/app_database.dart';
import '../../data/models/enums.dart';
import '../../l10n/generated/app_localizations.dart';
import '../money/money_format.dart';

export '../../l10n/generated/app_localizations.dart';

const supportedLanguageCodes = ['uz', 'ru', 'en'];

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get localeTag => Localizations.localeOf(this).toLanguageTag();
  MoneyFormat get money =>
      MoneyFormat(Localizations.localeOf(this).languageCode);
}

/// Localized labels for domain values.
extension DomainLabels on AppLocalizations {
  String categoryName(CategoryRecord? c) {
    if (c == null) return catOtherExpense;
    if (c.name != null && c.name!.isNotEmpty) return c.name!;
    return defaultCategoryName(c.key ?? '');
  }

  String defaultCategoryName(String key) => switch (key) {
    'food' => catFood,
    'transport' => catTransport,
    'shopping' => catShopping,
    'entertainment' => catEntertainment,
    'health' => catHealth,
    'education' => catEducation,
    'housing' => catHousing,
    'utilities' => catUtilities,
    'communication' => catCommunication,
    'travel' => catTravel,
    'personalCare' => catPersonalCare,
    'otherExpense' => catOtherExpense,
    'salary' => catSalary,
    'freelance' => catFreelance,
    'business' => catBusiness,
    'gift' => catGift,
    'investment' => catInvestment,
    'otherIncome' => catOtherIncome,
    _ => key,
  };

  String paymentMethodLabel(PaymentMethod m) => switch (m) {
    PaymentMethod.cash => pmCash,
    PaymentMethod.card => pmCard,
    PaymentMethod.bankTransfer => pmBankTransfer,
    PaymentMethod.mobileWallet => pmMobileWallet,
    PaymentMethod.other => pmOther,
  };

  String frequencyLabel(RecurrenceFrequency f) => switch (f) {
    RecurrenceFrequency.daily => freqDaily,
    RecurrenceFrequency.weekly => freqWeekly,
    RecurrenceFrequency.monthly => freqMonthly,
    RecurrenceFrequency.yearly => freqYearly,
  };

  String typeLabel(TransactionType t) =>
      t == TransactionType.income ? income : expense;

  String debtDirectionLabel(DebtDirection d) =>
      d == DebtDirection.iOwe ? debtIOwe : debtOwedToMe;

  String debtStatusLabel(DebtStatus s) => switch (s) {
    DebtStatus.active => debtActive,
    DebtStatus.overdue => debtOverdue,
    DebtStatus.completed => debtCompleted,
  };

  String themeLabel(AppThemePreference t) => switch (t) {
    AppThemePreference.system => themeSystem,
    AppThemePreference.light => themeLight,
    AppThemePreference.dark => themeDark,
  };
}

/// Date formatting helpers bound to the current locale.
class Dates {
  Dates(this.locale);
  final String locale;

  String day(DateTime d) => DateFormat.yMMMd(locale).format(d);
  String dayShort(DateTime d) => DateFormat.MMMd(locale).format(d);
  String month(DateTime d) => DateFormat.yMMMM(locale).format(d);
  String monthShort(DateTime d) => DateFormat.MMM(locale).format(d);
  String weekday(DateTime d) => DateFormat.E(locale).format(d);
  String time(DateTime d) => DateFormat.Hm(locale).format(d);
  String dayTime(DateTime d) => '${day(d)}, ${time(d)}';

  /// "Today", "Yesterday" or a date.
  String relative(DateTime d, AppLocalizations l, DateTime now) {
    final a = DateTime(d.year, d.month, d.day);
    final b = DateTime(now.year, now.month, now.day);
    final diff = b.difference(a).inDays;
    if (diff == 0) return l.today;
    if (diff == 1) return l.yesterday;
    return a.year == b.year ? dayShort(d) : day(d);
  }
}

extension DatesContext on BuildContext {
  Dates get dates => Dates(Localizations.localeOf(this).languageCode);
}
