import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/money/money_format.dart';

/// Coordinates recurring payment processing and reminder scheduling.
class RecurringService {
  RecurringService(this._ref);

  final Ref _ref;
  Future<void>? _running;

  /// Posts due occurrences and refreshes OS reminders. Concurrent calls
  /// share one run so occurrences are never processed twice in parallel.
  Future<void> run() => _running ??= _run().whenComplete(() => _running = null);

  Future<void> _run() async {
    try {
      await _ref.read(recurringRepositoryProvider).processDue();
      await rescheduleReminders();
    } catch (e) {
      if (kDebugMode) debugPrint('Recurring processing failed: $e');
    }
  }

  Future<void> rescheduleReminders() async {
    final notifications = _ref.read(notificationServiceProvider);
    if (!notifications.isEnabled) return;
    final settings = _ref.read(settingsProvider);
    final l = lookupAppLocalizations(
      Locale(settings.localeCode ?? _systemLanguage()),
    );
    final items = await _ref.read(recurringRepositoryProvider).all();
    for (final r in items) {
      final key = 'recurring:${r.id}';
      await notifications.cancel(key);
      if (!settings.notificationsEnabled ||
          !r.isActive ||
          !r.reminderEnabled ||
          r.nextDueDate == null) {
        continue;
      }
      final amount = MoneyFormat(l.localeName)
          .formatMinor(r.amountMinor, r.currency);
      await notifications.scheduleReminder(
        key: key,
        due: r.nextDueDate!,
        title: l.reminderTitle,
        body: l.reminderBody(r.title, amount),
      );
    }
  }

  static String _systemLanguage() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return supportedLanguageCodes.contains(code) ? code : 'uz';
  }
}

final recurringServiceProvider = Provider((ref) => RecurringService(ref));
