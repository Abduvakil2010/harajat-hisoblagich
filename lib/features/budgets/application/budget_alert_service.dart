import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/finance/budget_calculator.dart';
import '../../../core/localization/l10n.dart';

/// Sends a local notification the first time a budget crosses the warning,
/// critical or exceeded level in a given month.
class BudgetAlertService {
  BudgetAlertService(this._ref);

  final Ref _ref;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    _ref.listen<AsyncValue<List<BudgetStatus>>>(budgetStatusesProvider, (
      _,
      next,
    ) {
      final list = next.value;
      if (list != null) _check(list);
    }, fireImmediately: true);
  }

  Future<void> _check(List<BudgetStatus> statuses) async {
    final settings = _ref.read(settingsProvider);
    final notifications = _ref.read(notificationServiceProvider);
    if (!settings.notificationsEnabled ||
        !settings.budgetAlertsEnabled ||
        !notifications.isEnabled) {
      return;
    }
    final prefs = _ref.read(sharedPreferencesProvider);
    final month = _ref.read(currentMonthProvider).start;
    final code =
        settings.localeCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final l = lookupAppLocalizations(
      Locale(supportedLanguageCodes.contains(code) ? code : 'uz'),
    );
    final categories = _ref.read(categoryMapProvider);

    for (final s in statuses) {
      if (s.level == BudgetLevel.ok) continue;
      final key = 'budgetAlert:${s.budget.id}:${month.year}-${month.month}';
      final previous = prefs.getInt(key) ?? 0;
      if (s.level.index <= previous) continue;
      await prefs.setInt(key, s.level.index);
      final name = s.isTotal
          ? l.monthlyBudget
          : l.categoryName(categories[s.budget.categoryId]);
      final percent = (s.ratio * 100).round();
      await notifications.showBudgetAlert(
        key: key,
        title: s.level == BudgetLevel.exceeded
            ? l.budgetExceededTitle
            : l.budgetWarningTitle,
        body: l.budgetAlertBody(name, percent),
      );
    }
  }
}

final budgetAlertServiceProvider = Provider((ref) => BudgetAlertService(ref));
