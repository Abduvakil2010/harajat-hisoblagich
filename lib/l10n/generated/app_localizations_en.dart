// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get aboutTagline => 'Understand, organize and control your money.';

  @override
  String get active => 'Active';

  @override
  String get activeHint => 'Inactive payments are not recorded';

  @override
  String get addBudget => 'Add budget';

  @override
  String get addDebt => 'Add debt';

  @override
  String get addMoney => 'Add money';

  @override
  String get addRate => 'Add rate';

  @override
  String get addRecurring => 'Add recurring';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String aiBalance(String amount) {
    return 'Your current balance is $amount.';
  }

  @override
  String aiBalanceSeparate(String list) {
    return 'Your balance by currency: $list. Add an exchange rate to see a combined total.';
  }

  @override
  String aiBudgetCritical(String name, String percent, String remaining) {
    return '$name: $percent% used, only $remaining left.';
  }

  @override
  String aiBudgetExceeded(String name, String percent, String amount) {
    return '$name: $percent% used — over the limit by $amount.';
  }

  @override
  String aiBudgetOk(
    String name,
    String percent,
    String remaining,
    String daily,
  ) {
    return '$name: you are within budget — $percent% used, $remaining left (about $daily per day).';
  }

  @override
  String aiBudgetWarning(String name, String percent, String remaining) {
    return '$name: $percent% used, $remaining left.';
  }

  @override
  String aiCategoryIncrease(
    String category,
    String percent,
    String current,
    String baseline,
  ) {
    return '$category spending is $percent% higher than usual: $current so far vs a typical $baseline.';
  }

  @override
  String aiCategorySpend(
    String category,
    String period,
    String amount,
    String percent,
    int count,
  ) {
    return 'You spent $amount on $category $period — $percent% of expenses across $count records.';
  }

  @override
  String aiCategorySpendNone(String category, String period) {
    return 'There are no $category expenses $period.';
  }

  @override
  String aiCompareLess(
    int days,
    String current,
    String percent,
    String previous,
  ) {
    return 'In the first $days days of this month you spent $current, $percent% less than in the same days last month ($previous).';
  }

  @override
  String aiCompareMore(
    int days,
    String current,
    String percent,
    String previous,
  ) {
    return 'In the first $days days of this month you spent $current, $percent% more than in the same days last month ($previous).';
  }

  @override
  String aiCompareNoPrevExpense(int days, String current) {
    return 'In the first $days days of this month you spent $current. Last month had no expenses in the same days.';
  }

  @override
  String aiCompareSame(int days, String current, String previous) {
    return 'In the first $days days of this month you spent $current, about the same as last month ($previous).';
  }

  @override
  String aiDebtOverdue(int count) {
    return 'Overdue: $count.';
  }

  @override
  String aiDebtOverview(String owe, String owed, int active) {
    return 'You owe $owe in total; others owe you $owed. Open debts: $active.';
  }

  @override
  String get aiDisclaimer =>
      'ℹ This is informational guidance based on your records, not professional financial advice.';

  @override
  String get aiError =>
      'Sorry, I could not analyse your data right now. Please try again.';

  @override
  String aiGoalMonthly(String amount) {
    return 'Saving $amount per month will get you there on time.';
  }

  @override
  String aiGoalProgress(String name, String percent, String remaining) {
    return '“$name”: $percent% reached, $remaining to go.';
  }

  @override
  String get aiGreeting =>
      'Hello! I can analyse your spending, budgets, savings goals and debts. Try one of the suggested questions below.';

  @override
  String get aiHelp =>
      'I can answer questions like:\n• Where did most of my money go?\n• How much did I spend on food this month?\n• How much did I save?\n• Compare with last month\n• How is my budget?\n• Any unusual spending?\n• How are my goals and debts?\n• How can I save money?';

  @override
  String aiLargestExpense(
    String title,
    String amount,
    String date,
    String category,
  ) {
    return 'Your largest expense was “$title” — $amount on $date ($category).';
  }

  @override
  String aiNextCategories(String list) {
    return 'Next: $list.';
  }

  @override
  String get aiNoBudgets =>
      'You haven’t set a budget yet. Set a monthly limit in Budgets and I’ll track it for you.';

  @override
  String get aiNoDebts => 'You have no debt records.';

  @override
  String get aiNoExpenses => 'No expenses are recorded for this period.';

  @override
  String get aiNoGoals => 'You don’t have any active savings goals.';

  @override
  String get aiNoIncome => 'No income is recorded for this period.';

  @override
  String get aiNoPreviousMonth =>
      'There is no data for previous months yet, so I can’t make a comparison.';

  @override
  String get aiNoTransactions =>
      'I don’t have enough data yet. Add a few transactions and I’ll be able to analyse your spending.';

  @override
  String get aiNoUnusual =>
      'I don’t see any unusual increases in your spending this month.';

  @override
  String aiOverspent(String period, String amount) {
    return 'Your expenses $period exceeded your income by $amount.';
  }

  @override
  String aiPeriodTotal(
    String period,
    String expense,
    String income,
    int count,
  ) {
    return 'Expenses $period: $expense. Income: $income. Records: $count.';
  }

  @override
  String aiRisingTrend(String category) {
    return '$category expenses have grown for three months in a row.';
  }

  @override
  String aiSaved(String period, String amount) {
    return 'The difference between your income and expenses $period is $amount.';
  }

  @override
  String aiSavingsRate(String percent) {
    return 'That is $percent% of your income.';
  }

  @override
  String get aiSuggest1 => 'Where did most of my money go this month?';

  @override
  String get aiSuggest2 => 'How much did I save this month?';

  @override
  String get aiSuggest3 => 'How can I save money?';

  @override
  String get aiSuggest4 => 'Compare with last month';

  @override
  String get aiSuggest5 => 'How is my budget?';

  @override
  String get aiSuggest6 => 'Any unusual spending?';

  @override
  String aiSuggestLimit(String category, String average, String suggested) {
    return 'You spend about $average per month on $category. A monthly limit of $suggested could help you save.';
  }

  @override
  String get aiTipCreateGoal =>
      'Create a savings goal — a clear target makes saving easier to keep up.';

  @override
  String aiTipIncrease(String text) {
    return 'Watch this increase: $text';
  }

  @override
  String aiTipKeepSaving(String percent) {
    return 'You are keeping $percent% of your income this month — keep it up.';
  }

  @override
  String get aiTipSaveMore =>
      'You are setting aside less than 10% of your income. Try moving a fixed amount to a savings goal right after you get paid.';

  @override
  String aiTipTopCategory(String text) {
    return 'Start with your largest category. $text Setting a limit for it usually has the biggest effect.';
  }

  @override
  String get aiTipsIntro => 'Based on your records:';

  @override
  String aiTopCategory(
    String period,
    String category,
    String amount,
    String percent,
  ) {
    return 'Most of your spending $period went to $category: $amount, which is $percent% of all expenses.';
  }

  @override
  String get aiUnknown =>
      'I’m not sure I understood. I can tell you about your spending, income, savings, budgets, goals and debts — try “Where did most of my money go this month?”';

  @override
  String get alertThresholds => 'Alert thresholds';

  @override
  String get all => 'All';

  @override
  String get allCategories => 'All categories';

  @override
  String get allExpenses => 'All expenses';

  @override
  String get allTransactions => 'All transactions';

  @override
  String get amount => 'Amount';

  @override
  String get anyDate => 'Any date';

  @override
  String get appTitle => 'HisobAI';

  @override
  String get appliesTo => 'Applies to';

  @override
  String get apply => 'Apply';

  @override
  String get askAssistant => 'Ask assistant';

  @override
  String get askHint => 'Ask a question…';

  @override
  String get assistantEmptyBody =>
      'I analyse your transactions, budgets, goals and debts to answer questions and suggest improvements.';

  @override
  String get assistantEmptyTitle => 'Ask about your money';

  @override
  String get assistantLocalNote =>
      'This assistant runs entirely on your device using built-in rules. It does not use an online AI service and never sends your data anywhere.';

  @override
  String get assistantSubtitle => 'Offline · based on your records';

  @override
  String get assistantTitle => 'AI Assistant';

  @override
  String get assistantTyping => 'Assistant is typing';

  @override
  String availableAmount(String amount) {
    return 'Available: $amount';
  }

  @override
  String get avgDailySpending => 'Avg. daily spending';

  @override
  String get backupAndSync => 'Backup & sync';

  @override
  String get backupNow => 'Back up now';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get backupUnencryptedNote =>
      'Backup files are not encrypted and contain your financial records.';

  @override
  String get balanceSeparateNote =>
      'Shown per currency — add a USD/UZS rate to combine';

  @override
  String budgetAlertBody(String name, int percent) {
    return '$name: $percent% of the monthly limit used.';
  }

  @override
  String get budgetAlerts => 'Budget alerts';

  @override
  String get budgetExceededTitle => 'Budget exceeded';

  @override
  String get budgetExplain =>
      'A monthly budget is a spending limit that applies to every month. HisobAI compares it with your actual expenses.';

  @override
  String budgetLevelCritical(int percent) {
    return '$percent% used — you are close to the limit';
  }

  @override
  String get budgetLevelExceeded => 'Budget exceeded';

  @override
  String budgetLevelWarning(int percent) {
    return '$percent% used — keep an eye on spending';
  }

  @override
  String get budgetSaved => 'Budget saved';

  @override
  String get budgetStandingNote =>
      'The limit repeats every month until you change or delete it.';

  @override
  String get budgetUnconvertedNote =>
      'Some expenses in another currency are not counted — add an exchange rate.';

  @override
  String get budgetWarningTitle => 'Budget warning';

  @override
  String get budgets => 'Budgets';

  @override
  String get builtIn => 'Built-in';

  @override
  String byDate(String date) {
    return 'By $date';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get catBusiness => 'Business';

  @override
  String get catCommunication => 'Communication';

  @override
  String get catEducation => 'Education';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catFood => 'Food';

  @override
  String get catFreelance => 'Freelance';

  @override
  String get catGift => 'Gift';

  @override
  String get catHealth => 'Health';

  @override
  String get catHousing => 'Housing';

  @override
  String get catInvestment => 'Investment';

  @override
  String get catOtherExpense => 'Other';

  @override
  String get catOtherIncome => 'Other';

  @override
  String get catPersonalCare => 'Personal care';

  @override
  String get catSalary => 'Salary';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catTransport => 'Transport';

  @override
  String get catTravel => 'Travel';

  @override
  String get catUtilities => 'Utilities';

  @override
  String get categories => 'Categories';

  @override
  String categoriesSelected(int count) {
    return 'Categories: $count';
  }

  @override
  String get category => 'Category';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoryDistribution => 'Category distribution';

  @override
  String get categoryLimits => 'Category limits';

  @override
  String get clear => 'Clear';

  @override
  String get clearConversation => 'Clear conversation';

  @override
  String get clearConversationBody =>
      'All messages will be deleted from this device.';

  @override
  String get close => 'Close';

  @override
  String get cloudBackup => 'Cloud backup';

  @override
  String get cloudBackupDone => 'Cloud backup completed';

  @override
  String get cloudConsent => 'I agree to store my backup in the cloud';

  @override
  String get cloudDeleted => 'Cloud backup deleted';

  @override
  String get cloudExplain =>
      'Stores an encrypted-in-transit copy of your data in Firebase under an anonymous identity tied to this installation. If you uninstall the app, that copy can no longer be accessed — keep a backup file too.';

  @override
  String get cloudNotConfigured =>
      'Cloud backup is not configured in this build. Everything else works offline; use the backup file to keep a copy.';

  @override
  String get color => 'Color';

  @override
  String get completed => 'Completed';

  @override
  String get completedGoals => 'Completed';

  @override
  String get confirm => 'Confirm';

  @override
  String get conversionPolicy =>
      'Conversion policy: UZS and USD are never added directly. Each transaction is converted with the latest rate effective on its date; if it predates all rates, the oldest rate is used. Your balance is converted with the latest rate. Without any rate, totals are shown per currency.';

  @override
  String get conversionPolicyShort =>
      'Each transaction is converted with the latest rate effective on its date (oldest rate if earlier than all rates).';

  @override
  String get created => 'Created';

  @override
  String get criticalAt => 'Critical at';

  @override
  String get currency => 'Currency';

  @override
  String get customRange => 'Custom range';

  @override
  String get daily => 'Daily';

  @override
  String get dailySpending => 'Daily spending';

  @override
  String get data => 'Data';

  @override
  String get dataReset => 'All data was deleted';

  @override
  String get date => 'Date';

  @override
  String get debt => 'Debt';

  @override
  String get debtAccountingNote =>
      'Debts are tracked separately: creating a debt or recording a repayment does not change your balance, income or expenses.';

  @override
  String get debtActive => 'Active';

  @override
  String get debtCompleted => 'Completed';

  @override
  String get debtIOwe => 'I owe';

  @override
  String get debtOverdue => 'Overdue';

  @override
  String get debtOwedToMe => 'Owed to me';

  @override
  String get debtSaved => 'Debt saved';

  @override
  String get debts => 'Debts';

  @override
  String get delete => 'Delete';

  @override
  String get deleteBudgetBody => 'Your transactions are not affected.';

  @override
  String get deleteBudgetTitle => 'Delete budget?';

  @override
  String get deleteCategoryBody =>
      'This category is not used by any transaction.';

  @override
  String deleteCategoryInUse(int count) {
    return '$count transactions use this category. They will be moved to “Other”.';
  }

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String get deleteCloudBody => 'Your local data is not affected.';

  @override
  String get deleteCloudCopy => 'Delete cloud copy';

  @override
  String get deleteCloudTitle => 'Delete cloud backup?';

  @override
  String get deleteDebtBody =>
      'The debt and all its repayments will be deleted.';

  @override
  String get deleteDebtTitle => 'Delete debt?';

  @override
  String get deleteEntryBody => 'The saved amount will be recalculated.';

  @override
  String get deleteEntryTitle => 'Delete entry?';

  @override
  String get deleteGoalBody =>
      'The goal and its history will be deleted. Your transactions are not affected.';

  @override
  String get deleteGoalTitle => 'Delete goal?';

  @override
  String get deleteRateBody =>
      'Converted totals will be recalculated with the remaining rates.';

  @override
  String get deleteRateTitle => 'Delete rate?';

  @override
  String get deleteRecurringBody =>
      'Already recorded transactions are kept. Future payments will not be created.';

  @override
  String get deleteRecurringTitle => 'Delete recurring payment?';

  @override
  String get deleteRepaymentBody =>
      'The remaining amount will be recalculated.';

  @override
  String get deleteRepaymentTitle => 'Delete repayment?';

  @override
  String get deleteTransactionBody =>
      'Balances, budgets and statistics will be recalculated. This cannot be undone.';

  @override
  String get deleteTransactionTitle => 'Delete transaction?';

  @override
  String get description => 'Description';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get disclaimerBody =>
      'Insights and recommendations are informational only and are not professional financial advice.';

  @override
  String get disclaimerTitle => 'Not financial advice';

  @override
  String get displayName => 'Display name';

  @override
  String get displayNameHint => 'How should we greet you?';

  @override
  String get displayNameOptional => 'Your name (optional)';

  @override
  String get dueDate => 'Due date';

  @override
  String get dueDateOptional => 'Due date (optional)';

  @override
  String dueOn(String date) {
    return 'due $date';
  }

  @override
  String get edit => 'Edit';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get editCategory => 'Edit category';

  @override
  String get editDebt => 'Edit debt';

  @override
  String get editGoal => 'Edit goal';

  @override
  String get editRate => 'Edit rate';

  @override
  String get editRecurring => 'Edit recurring payment';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get effectiveDate => 'Effective date';

  @override
  String effectiveFrom(String date) {
    return 'From $date';
  }

  @override
  String get emptyDebtsBody =>
      'Track money you borrowed or lent and record repayments as they happen.';

  @override
  String get emptyDebtsTitle => 'Nothing here';

  @override
  String get emptyGoalsBody =>
      'Saving for a laptop, travel or an emergency fund? Create a goal and track every step.';

  @override
  String get emptyGoalsTitle => 'No savings goals yet';

  @override
  String get emptyRecurringBody =>
      'Add rent, subscriptions, utilities or regular income — HisobAI records them automatically when they are due.';

  @override
  String get emptyRecurringTitle => 'No recurring payments';

  @override
  String get emptyStatsBody =>
      'Charts are built only from your own records. Add your first transaction to get started.';

  @override
  String get emptyStatsTitle => 'Your statistics will appear here';

  @override
  String get emptyTransactionsBody =>
      'Record your first income or expense to see your balance come to life.';

  @override
  String get emptyTransactionsTitle => 'No transactions yet';

  @override
  String get endDateOptional => 'End date (optional)';

  @override
  String get ended => 'Ended';

  @override
  String get errorGeneric => 'Please try again. Your data is safe.';

  @override
  String get errorSaving => 'Could not save. Please try again.';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get exceededAlwaysNote =>
      'You are always notified when a budget is exceeded (100%).';

  @override
  String get excelContents =>
      'Excel workbook with Summary, Transactions, Categories and Budget sheets.';

  @override
  String get exchangeRates => 'Exchange rates';

  @override
  String get expense => 'Expense';

  @override
  String get expenseOverview => 'Expense overview';

  @override
  String get expenses => 'Expenses';

  @override
  String get exportData => 'Export';

  @override
  String get fileBackup => 'Backup file';

  @override
  String get fileBackupBody =>
      'Export everything to a JSON file you can keep or move to another phone, and import it later.';

  @override
  String get filterByCategory => 'Filter by category';

  @override
  String get finance => 'Finance';

  @override
  String get format => 'Format';

  @override
  String get freqDaily => 'Daily';

  @override
  String get freqMonthly => 'Monthly';

  @override
  String get freqWeekly => 'Weekly';

  @override
  String get freqYearly => 'Yearly';

  @override
  String get frequency => 'Frequency';

  @override
  String get fromRecurring => 'Recurring payment';

  @override
  String get goal => 'Goal';

  @override
  String get goalCompleted => 'Goal marked as completed';

  @override
  String get goalName => 'Goal name';

  @override
  String get goalNameHint => 'e.g. New laptop';

  @override
  String get goalReachedSnack => 'Congratulations — you reached your target!';

  @override
  String get goalReopened => 'Goal reopened';

  @override
  String get goalSaved => 'Goal saved';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get guestUser => 'HisobAI user';

  @override
  String get hideAmounts => 'Hide amounts';

  @override
  String get hideAmountsHint => 'Mask balances and amounts on screen';

  @override
  String get highestExpense => 'Highest expense';

  @override
  String get history => 'History';

  @override
  String get icon => 'Icon';

  @override
  String get importData => 'Import from file';

  @override
  String get income => 'Income';

  @override
  String get incomeVsExpenses => 'Income vs expenses';

  @override
  String get initialBalance => 'Initial balance';

  @override
  String get initialBalanceHint =>
      'Money you already had before you started using HisobAI. It is added to your balance but not counted as income.';

  @override
  String get initialBalanceOptional => 'Initial balance (optional)';

  @override
  String get insights => 'Insights';

  @override
  String get insightsNotEnoughData =>
      'Add a few more transactions and HisobAI will start showing personal insights here.';

  @override
  String get insufficientDataBadge => 'Not enough data';

  @override
  String get invalidBackup => 'This file is not a valid HisobAI backup.';

  @override
  String get language => 'Language';

  @override
  String get last3Months => 'Last 3 months';

  @override
  String lastBackup(String date) {
    return 'Last backup: $date';
  }

  @override
  String get latest => 'Latest';

  @override
  String get limit => 'Limit';

  @override
  String get localDataNote =>
      'Your data lives only on this device unless you export it. Make regular backups.';

  @override
  String get localProfileNote =>
      'No account needed · data stays on this device';

  @override
  String get lowestExpense => 'Lowest expense';

  @override
  String get manage => 'Manage';

  @override
  String get markCompleted => 'Mark as completed';

  @override
  String get monthly => 'Monthly';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get monthlyExpenseTrend => 'Monthly expense trend';

  @override
  String get monthlyLimit => 'Monthly limit';

  @override
  String get more => 'More';

  @override
  String get name => 'Name';

  @override
  String get navAdd => 'Add transaction';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get navStats => 'Statistics';

  @override
  String get netCashFlow => 'Net cash flow';

  @override
  String get newCategory => 'New category';

  @override
  String get newGoal => 'New goal';

  @override
  String get next => 'Next';

  @override
  String nextDue(String date) {
    return 'Next: $date';
  }

  @override
  String get noBudgetBody => 'Set a spending limit to track your month';

  @override
  String get noBudgetTitle => 'No monthly budget yet';

  @override
  String get noCategoryLimits =>
      'No category limits yet. Add one to control a specific kind of spending.';

  @override
  String get noCloudBackup => 'No cloud backup found';

  @override
  String get noDataForPeriod => 'No transactions for this period';

  @override
  String get noDeadline => 'No deadline';

  @override
  String get noEntriesYet => 'No deposits yet.';

  @override
  String get noRateShort => 'no exchange rate';

  @override
  String get noRatesBody =>
      'Without a rate HisobAI keeps UZS and USD totals separate. Add a rate to see combined amounts.';

  @override
  String get noRatesTitle => 'No exchange rates';

  @override
  String get noRepaymentsYet => 'No repayments yet.';

  @override
  String get noResultsBody => 'Try different search words or filters.';

  @override
  String get noResultsTitle => 'Nothing found';

  @override
  String get notFound => 'Not found';

  @override
  String get notFoundBody => 'This record no longer exists.';

  @override
  String get notSet => 'Not set';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsHint => 'Payment reminders and budget alerts';

  @override
  String ofAmount(String amount) {
    return 'of $amount';
  }

  @override
  String get onbBudgetBody =>
      'Set monthly limits and get warned before you overspend.';

  @override
  String get onbBudgetTitle => 'Manage your budget';

  @override
  String get onbGoalsBody =>
      'Save for what matters, track debts and recurring payments — all in one place.';

  @override
  String get onbGoalsTitle => 'Reach your savings goals';

  @override
  String get onbNoAccountNote =>
      'No email, phone number or account is required. Your data stays on this device.';

  @override
  String get onbSetupBody => 'You can change all of this later in Profile.';

  @override
  String get onbSetupTitle => 'Let’s set things up';

  @override
  String get onbStart => 'Start using HisobAI';

  @override
  String get onbUnderstandBody =>
      'See where every so‘m and dollar goes with clear charts and honest insights from your own records.';

  @override
  String get onbUnderstandTitle => 'Understand your money';

  @override
  String get onbWelcomeBody =>
      'A calm, private place for your money. No registration — start in seconds.';

  @override
  String get onbWelcomeTitle => 'Welcome to HisobAI';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get operationFailed => 'The operation failed. Nothing was changed.';

  @override
  String get original => 'Original';

  @override
  String get originalAmount => 'Original amount';

  @override
  String get originalBelowPaid =>
      'The original amount cannot be less than what has already been repaid.';

  @override
  String get overBudget => 'Over budget';

  @override
  String get overview => 'Overview';

  @override
  String get paid => 'Paid';

  @override
  String get paused => 'Paused';

  @override
  String get payInFull => 'Pay in full';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get pdfContents =>
      'Branded PDF with summary, category breakdown, budget overview and full transaction list.';

  @override
  String perMonthNeeded(String amount) {
    return '$amount / month needed';
  }

  @override
  String get periodLastMonth => 'last month';

  @override
  String get periodLastMonthTitle => 'Last month';

  @override
  String get periodThisMonth => 'this month';

  @override
  String get periodThisMonthTitle => 'This month';

  @override
  String get personOrOrganization => 'Person or organization';

  @override
  String get pmBankTransfer => 'Bank transfer';

  @override
  String get pmCard => 'Card';

  @override
  String get pmCash => 'Cash';

  @override
  String get pmMobileWallet => 'Mobile wallet';

  @override
  String get pmOther => 'Other';

  @override
  String get preferences => 'Preferences';

  @override
  String get preview => 'Preview';

  @override
  String get previous => 'Previous';

  @override
  String get primaryCurrency => 'Primary currency';

  @override
  String get privacyAiBody =>
      'The assistant is a built-in, rule-based analysis engine. It is not connected to an external AI service and only uses the records you entered.';

  @override
  String get privacyAiTitle => 'About the AI assistant';

  @override
  String get privacyAndAbout => 'Privacy & about';

  @override
  String get privacyCloudBody =>
      'Cloud backup is off by default and only works if this build is connected to Firebase. When you turn it on, an anonymous identity is created and your backup is stored in a private area only that identity can access.';

  @override
  String get privacyCloudTitle => 'Optional cloud backup';

  @override
  String get privacyLocalBody =>
      'All records are stored in a local database on this phone. HisobAI works fully offline. Local data is not automatically backed up — use Backup & sync to export a copy.';

  @override
  String get privacyLocalTitle => 'Your data stays on your device';

  @override
  String get privacyNoAccountBody =>
      'HisobAI does not ask for an email, phone number, Google or Apple account.';

  @override
  String get privacyNoAccountTitle => 'No registration';

  @override
  String get privacySecurityBody =>
      'Data is protected by your phone’s app sandbox and device encryption. The app database itself is not additionally encrypted, and exported backup files are plain JSON — keep them somewhere safe. Use a screen lock on your device.';

  @override
  String get privacySecurityTitle => 'Security';

  @override
  String get progress => 'Progress';

  @override
  String get rate => 'Rate';

  @override
  String get rateManualNote =>
      'Rates are entered by you; HisobAI does not download rates from the internet.';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get recordRepayment => 'Record repayment';

  @override
  String get recurringAutoNote =>
      'Due payments are recorded automatically each time you open the app, exactly once per due date. Reminders are scheduled with your phone so they arrive even if the app is closed.';

  @override
  String get recurringBackfillNote =>
      'The start date is in the past: payments since that date will be recorded when you save.';

  @override
  String get recurringPayments => 'Recurring payments';

  @override
  String get recurringSaved => 'Recurring payment saved';

  @override
  String get recurringTitleHint => 'e.g. Rent, Internet, Netflix';

  @override
  String get remaining => 'Remaining';

  @override
  String remainingAmount(String amount) {
    return 'Remaining: $amount';
  }

  @override
  String get reminder => 'Reminder';

  @override
  String reminderBody(String title, String amount) {
    return '$title: $amount is due today.';
  }

  @override
  String get reminderHint => 'Notify me at 9:00 on the due date';

  @override
  String get reminderTitle => 'Payment due today';

  @override
  String get reopenGoal => 'Reopen goal';

  @override
  String get repaymentRecorded => 'Repayment recorded';

  @override
  String get repaymentTooLarge =>
      'The repayment is larger than the remaining amount.';

  @override
  String get repayments => 'Repayments';

  @override
  String get reportEmptyHint =>
      'Choose another period or add transactions first.';

  @override
  String get reportFailed => 'Could not create the report. Please try again.';

  @override
  String get reportPeriodLabel => 'Report period';

  @override
  String reportSaved(String name) {
    return 'Saved $name';
  }

  @override
  String get reports => 'Reports';

  @override
  String get resetData => 'Reset all data';

  @override
  String get resetDataBody =>
      'All transactions, budgets, goals, debts, recurring payments, rates, chat history and settings will be permanently deleted from this device. Export a backup first if you may need them.';

  @override
  String get resetDataConfirm => 'I understand this cannot be undone';

  @override
  String get resetDataTitle => 'Delete all data?';

  @override
  String get restore => 'Restore';

  @override
  String restoreBackupBody(String date, int tx, int goals, int debts) {
    return 'Backup from $date: $tx transactions, $goals goals, $debts debts. All current data on this device will be replaced.';
  }

  @override
  String get restoreBackupTitle => 'Replace all data?';

  @override
  String get restoreDone => 'Data restored';

  @override
  String get rptBudget => 'Budget';

  @override
  String get rptBudgetOverview => 'Budget overview';

  @override
  String get rptCategoryBreakdown => 'Categories';

  @override
  String get rptCount => 'Count';

  @override
  String get rptFinancialReport => 'Financial report';

  @override
  String get rptGenerated => 'Generated';

  @override
  String get rptMetric => 'Metric';

  @override
  String get rptPeriod => 'Report period';

  @override
  String get rptRate => 'Rate';

  @override
  String get rptRatesUsed => 'Exchange rates';

  @override
  String get rptReport => 'Report';

  @override
  String get rptShare => 'Share';

  @override
  String get rptSummary => 'Summary';

  @override
  String get rptTransactions => 'Transactions';

  @override
  String get rptType => 'Type';

  @override
  String get rptUnconverted => 'Not converted';

  @override
  String get rptUnconvertedNote =>
      'Amounts in other currencies without an exchange rate are shown separately and not included in totals.';

  @override
  String get rptUsed => 'Used';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saveToDevice => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get savingsAccountingNote =>
      'Savings goals track money you set aside. Deposits and withdrawals are not counted as income or expenses.';

  @override
  String get savingsGoals => 'Savings goals';

  @override
  String get searchTransactions => 'Search by title or note';

  @override
  String get send => 'Send';

  @override
  String get setBudget => 'Set budget';

  @override
  String get share => 'Share';

  @override
  String get showAmounts => 'Show amounts';

  @override
  String get skip => 'Skip';

  @override
  String get sort => 'Sort';

  @override
  String get sortAmountHigh => 'Amount: high to low';

  @override
  String get sortAmountLow => 'Amount: low to high';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get source => 'Source';

  @override
  String get sourceManual => 'Entered manually';

  @override
  String get spent => 'Spent';

  @override
  String get startDate => 'Start date';

  @override
  String get statistics => 'Statistics';

  @override
  String get statsMissingRateNote =>
      'Some transactions are in another currency and are excluded until you add an exchange rate.';

  @override
  String get target => 'Target';

  @override
  String get targetAmount => 'Target amount';

  @override
  String get targetDateOptional => 'Target date (optional)';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisMonthSuffix => 'this month';

  @override
  String get thisYear => 'This year';

  @override
  String thresholdsSummary(int warning, int critical) {
    return 'Warn at $warning% and $critical%, and when exceeded';
  }

  @override
  String get title => 'Title';

  @override
  String get titleHintExpense => 'e.g. Groceries at Korzinka';

  @override
  String get titleHintIncome => 'e.g. October salary';

  @override
  String get today => 'Today';

  @override
  String get total => 'Total';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get totalForPeriod => 'Total for period';

  @override
  String get totalIOwe => 'I owe';

  @override
  String get totalMonthlyBudget => 'Total monthly budget';

  @override
  String get totalOwedToMe => 'Owed to me';

  @override
  String get transactionAdded => 'Transaction added';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get transactionDetails => 'Transaction details';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get updated => 'Updated';

  @override
  String get validationAmountInvalid => 'Enter a valid number';

  @override
  String get validationAmountPositive => 'Amount must be greater than zero';

  @override
  String get validationAmountRequired => 'Enter an amount';

  @override
  String get validationCategoryRequired => 'Choose a category';

  @override
  String get validationEndBeforeStart =>
      'End date cannot be before the start date';

  @override
  String get validationNameRequired => 'Enter a name';

  @override
  String get validationTitleRequired => 'Enter a title';

  @override
  String get version => 'Version';

  @override
  String get viewAll => 'View all';

  @override
  String get vsLastMonth => 'vs last month';

  @override
  String get warningAt => 'Warning at';

  @override
  String get weekly => 'Weekly';

  @override
  String get weeklyComparison => 'Weekly comparison';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get withdrawTooMuch => 'You can’t withdraw more than is saved.';

  @override
  String get yesterday => 'Yesterday';
}
