import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/services/notification_service.dart';
import 'data/local/app_database.dart';
import 'data/remote/cloud_backup_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase.open();

  // Optional services. Both degrade gracefully: without Firebase config the
  // cloud backup is disabled; without notification support reminders are off.
  final (notifications, cloud) = await (
    NotificationService.initialize(),
    CloudBackupService.initialize(),
  ).wait;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
        cloudBackupServiceProvider.overrideWithValue(cloud),
      ],
      child: const HisobApp(),
    ),
  );
}
