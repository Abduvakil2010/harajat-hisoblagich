import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/enums.dart';
import '../features/ai_assistant/presentation/assistant_screen.dart';
import '../features/budgets/presentation/budgets_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/debts/presentation/debt_detail_screen.dart';
import '../features/debts/presentation/debt_form_screen.dart';
import '../features/debts/presentation/debts_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/recurring_payments/presentation/recurring_form_screen.dart';
import '../features/recurring_payments/presentation/recurring_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/savings/presentation/goal_detail_screen.dart';
import '../features/savings/presentation/goal_form_screen.dart';
import '../features/savings/presentation/savings_screen.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/settings/presentation/backup_screen.dart';
import '../features/settings/presentation/exchange_rates_screen.dart';
import '../features/settings/presentation/profile_screen.dart';
import '../features/statistics/presentation/statistics_screen.dart';
import '../features/transactions/presentation/categories_screen.dart';
import '../features/transactions/presentation/transaction_detail_screen.dart';
import '../features/transactions/presentation/transaction_form_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../shared/widgets/app_shell.dart';
import 'providers.dart';

abstract final class Routes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const stats = '/stats';
  static const assistant = '/assistant';
  static const profile = '/profile';
  static const transactions = '/transactions';
  static const newTransaction = '/transactions/new';
  static String transaction(String id) => '/transactions/$id';
  static String editTransaction(String id) => '/transactions/$id/edit';
  static const categories = '/categories';
  static const budgets = '/budgets';
  static const recurring = '/recurring';
  static const newRecurring = '/recurring/new';
  static String editRecurring(String id) => '/recurring/$id/edit';
  static const savings = '/savings';
  static const newGoal = '/savings/new';
  static String goal(String id) => '/savings/$id';
  static String editGoal(String id) => '/savings/$id/edit';
  static const debts = '/debts';
  static const newDebt = '/debts/new';
  static String debt(String id) => '/debts/$id';
  static String editDebt(String id) => '/debts/$id/edit';
  static const reports = '/reports';
  static const rates = '/settings/rates';
  static const backup = '/settings/backup';
  static const about = '/settings/about';
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Bridges Riverpod settings to GoRouter's refreshListenable.
class _OnboardingListenable extends ChangeNotifier {
  _OnboardingListenable(Ref ref) {
    _done = ref.read(settingsProvider).onboardingDone;
    ref.listen(settingsProvider.select((s) => s.onboardingDone), (_, next) {
      _done = next;
      notifyListeners();
    });
  }

  late bool _done;
  bool get done => _done;
}

final routerProvider = Provider<GoRouter>((ref) {
  final onboarding = _OnboardingListenable(ref);
  ref.onDispose(onboarding.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.home,
    refreshListenable: onboarding,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!onboarding.done && !atOnboarding) return Routes.onboarding;
      if (onboarding.done && atOnboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, _) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.stats,
                builder: (_, _) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.assistant,
                builder: (_, _) => const AssistantScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.transactions,
        builder: (_, _) => const TransactionsScreen(),
        routes: [
          GoRoute(
            path: 'new',
            pageBuilder: (_, state) => MaterialPage(
              fullscreenDialog: true,
              child: TransactionFormScreen(
                initialType: state.uri.queryParameters['type'] == 'income'
                    ? TransactionType.income
                    : TransactionType.expense,
              ),
            ),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                TransactionDetailScreen(id: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'edit',
                pageBuilder: (_, state) => MaterialPage(
                  fullscreenDialog: true,
                  child: TransactionFormScreen(
                    editId: state.pathParameters['id'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.categories,
        builder: (_, _) => const CategoriesScreen(),
      ),
      GoRoute(path: Routes.budgets, builder: (_, _) => const BudgetsScreen()),
      GoRoute(
        path: Routes.recurring,
        builder: (_, _) => const RecurringScreen(),
        routes: [
          GoRoute(path: 'new', builder: (_, _) => const RecurringFormScreen()),
          GoRoute(
            path: ':id/edit',
            builder: (_, state) =>
                RecurringFormScreen(editId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: Routes.savings,
        builder: (_, _) => const SavingsScreen(),
        routes: [
          GoRoute(path: 'new', builder: (_, _) => const GoalFormScreen()),
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                GoalDetailScreen(id: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, state) =>
                    GoalFormScreen(editId: state.pathParameters['id']),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.debts,
        builder: (_, _) => const DebtsScreen(),
        routes: [
          GoRoute(path: 'new', builder: (_, _) => const DebtFormScreen()),
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                DebtDetailScreen(id: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, state) =>
                    DebtFormScreen(editId: state.pathParameters['id']),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: Routes.reports, builder: (_, _) => const ReportsScreen()),
      GoRoute(
        path: Routes.rates,
        builder: (_, _) => const ExchangeRatesScreen(),
      ),
      GoRoute(path: Routes.backup, builder: (_, _) => const BackupScreen()),
      GoRoute(path: Routes.about, builder: (_, _) => const AboutScreen()),
    ],
  );
});
