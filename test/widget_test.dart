import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobai/app/app.dart';
import 'package:hisobai/app/providers.dart';
import 'package:hisobai/data/local/app_database.dart';
import 'package:hisobai/data/models/app_settings.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

/// Pumps the real app with an in-memory database and mock preferences.
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  AppSettings? settings,
}) async {
  SharedPreferences.setMockInitialValues({
    if (settings != null) 'hisobai.settings.v1': jsonEncode(settings.toJson()),
  });
  final prefs = await SharedPreferences.getInstance();
  final db = testDb();
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: const HisobApp(),
    ),
  );
  await settle(tester);
  return db;
}

/// Pumps frames without waiting for infinite animations to end.
Future<void> settle(WidgetTester tester, [int frames = 15]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> disposeApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await db.close();
  await settle(tester, 3);
}

void main() {
  setUpAll(() => initializeDateFormatting());

  testWidgets(
    'first launch shows onboarding and finishes without registration',
    (tester) async {
      final db = await pumpApp(tester);
      expect(find.text('Welcome to HisobAI'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await settle(tester);
      expect(find.text('Let’s set things up'), findsOneWidget);
      await tester.tap(find.text('Start using HisobAI'));
      await settle(tester);
      expect(find.text('Total balance'), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
      await disposeApp(tester, db);
    },
  );

  testWidgets('bottom navigation switches between all sections', (
    tester,
  ) async {
    final db = await pumpApp(
      tester,
      settings: const AppSettings(onboardingDone: true, localeCode: 'en'),
    );
    await tester.tap(find.text('Statistics').last);
    await settle(tester);
    expect(find.text('Your statistics will appear here'), findsOneWidget);
    await tester.tap(find.text('Assistant'));
    await settle(tester);
    expect(find.text('Ask about your money'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await settle(tester);
    expect(find.text('Primary currency'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await settle(tester);
    expect(find.text('Total balance'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('transaction form validates and saves, dashboard updates', (
    tester,
  ) async {
    final db = await pumpApp(
      tester,
      settings: const AppSettings(onboardingDone: true, localeCode: 'en'),
    );
    await tester.tap(find.byTooltip('Add transaction'));
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester, 5);
    expect(find.text('Enter an amount'), findsOneWidget);
    expect(find.text('Enter a title'), findsOneWidget);
    expect(find.text('Choose a category'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '0');
    await tester.tap(find.text('Save'));
    await settle(tester, 5);
    expect(find.text('Amount must be greater than zero'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '45000');
    await tester.enterText(find.byType(TextFormField).at(1), 'Groceries');
    await tester.tap(find.text('Food'));
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await settle(tester);

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.textContaining('45,000 UZS'), findsWidgets);
    final saved = await db.select(db.transactions).get();
    expect(saved.single.amountMinor, m(45000));
    await disposeApp(tester, db);
  });

  testWidgets('switching language updates the UI immediately', (tester) async {
    final db = await pumpApp(
      tester,
      settings: const AppSettings(onboardingDone: true, localeCode: 'en'),
    );
    await tester.tap(find.text('Profile'));
    await settle(tester);
    await tester.tap(find.text('Language'));
    await settle(tester);
    await tester.tap(find.text('Русский'));
    await settle(tester);
    expect(find.text('Основная валюта'), findsOneWidget);
    expect(find.text('Профиль'), findsWidgets);
    await disposeApp(tester, db);
  });

  testWidgets('theme can be switched to dark', (tester) async {
    final db = await pumpApp(
      tester,
      settings: const AppSettings(onboardingDone: true, localeCode: 'en'),
    );
    await tester.tap(find.text('Profile'));
    await settle(tester);
    await tester.tap(find.text('Theme'));
    await settle(tester);
    await tester.tap(find.text('Dark').last);
    await settle(tester);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    await disposeApp(tester, db);
  });
}
