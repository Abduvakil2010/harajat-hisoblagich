import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications for recurring-payment reminders and budget alerts.
///
/// Reminders are *scheduled with the OS* at their due date, so they fire
/// even when the app is not running. The app re-schedules them on every
/// launch and whenever recurring payments change, so nothing depends on the
/// app staying in the background.
class NotificationService {
  NotificationService._(this._plugin);

  factory NotificationService.disabled() => NotificationService._(null);

  final FlutterLocalNotificationsPlugin? _plugin;

  static const _reminderChannel = AndroidNotificationDetails(
    'hisobai_reminders',
    'Payment reminders',
    channelDescription: 'Reminders for upcoming recurring payments',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  static const _budgetChannel = AndroidNotificationDetails(
    'hisobai_budget',
    'Budget alerts',
    channelDescription: 'Alerts when monthly budgets reach their thresholds',
    importance: Importance.high,
    priority: Priority.high,
  );

  bool get isEnabled => _plugin != null;

  /// Initialises the plugin. Never throws; returns a disabled service if the
  /// platform does not support notifications (e.g. in tests).
  static Future<NotificationService> initialize() async {
    try {
      tzdata.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      return NotificationService._(plugin);
    } catch (e) {
      if (kDebugMode) debugPrint('Notifications unavailable: $e');
      return NotificationService.disabled();
    }
  }

  /// Asks the OS for permission (Android 13+, iOS). Returns true if granted.
  Future<bool> requestPermission() async {
    final p = _plugin;
    if (p == null) return false;
    try {
      final android = p
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = p
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (_) {}
    return false;
  }

  /// Stable 31-bit notification id derived from a string key.
  static int idFor(String key) {
    var h = 0;
    for (final c in key.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }

  /// Schedules a reminder at 09:00 local time on [due]. If that moment has
  /// passed, nothing is scheduled.
  Future<void> scheduleReminder({
    required String key,
    required DateTime due,
    required String title,
    required String body,
  }) async {
    final p = _plugin;
    if (p == null) return;
    final when = tz.TZDateTime(tz.local, due.year, due.month, due.day, 9);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;
    try {
      await p.zonedSchedule(
        id: idFor(key),
        scheduledDate: when,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: _reminderChannel,
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to schedule reminder: $e');
    }
  }

  Future<void> cancel(String key) async {
    try {
      await _plugin?.cancel(id: idFor(key));
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    try {
      await _plugin?.cancelAll();
    } catch (_) {}
  }

  Future<void> showBudgetAlert({
    required String key,
    required String title,
    required String body,
  }) async {
    final p = _plugin;
    if (p == null) return;
    try {
      await p.show(
        id: idFor(key),
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: _budgetChannel,
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (_) {}
  }
}
