import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Understand, organize and control your money.'**
  String get aboutTagline;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @activeHint.
  ///
  /// In en, this message translates to:
  /// **'Inactive payments are not recorded'**
  String get activeHint;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add budget'**
  String get addBudget;

  /// No description provided for @addDebt.
  ///
  /// In en, this message translates to:
  /// **'Add debt'**
  String get addDebt;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get addMoney;

  /// No description provided for @addRate.
  ///
  /// In en, this message translates to:
  /// **'Add rate'**
  String get addRate;

  /// No description provided for @addRecurring.
  ///
  /// In en, this message translates to:
  /// **'Add recurring'**
  String get addRecurring;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @aiBalance.
  ///
  /// In en, this message translates to:
  /// **'Your current balance is {amount}.'**
  String aiBalance(String amount);

  /// No description provided for @aiBalanceSeparate.
  ///
  /// In en, this message translates to:
  /// **'Your balance by currency: {list}. Add an exchange rate to see a combined total.'**
  String aiBalanceSeparate(String list);

  /// No description provided for @aiBudgetCritical.
  ///
  /// In en, this message translates to:
  /// **'{name}: {percent}% used, only {remaining} left.'**
  String aiBudgetCritical(String name, String percent, String remaining);

  /// No description provided for @aiBudgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'{name}: {percent}% used — over the limit by {amount}.'**
  String aiBudgetExceeded(String name, String percent, String amount);

  /// No description provided for @aiBudgetOk.
  ///
  /// In en, this message translates to:
  /// **'{name}: you are within budget — {percent}% used, {remaining} left (about {daily} per day).'**
  String aiBudgetOk(
    String name,
    String percent,
    String remaining,
    String daily,
  );

  /// No description provided for @aiBudgetWarning.
  ///
  /// In en, this message translates to:
  /// **'{name}: {percent}% used, {remaining} left.'**
  String aiBudgetWarning(String name, String percent, String remaining);

  /// No description provided for @aiCategoryIncrease.
  ///
  /// In en, this message translates to:
  /// **'{category} spending is {percent}% higher than usual: {current} so far vs a typical {baseline}.'**
  String aiCategoryIncrease(
    String category,
    String percent,
    String current,
    String baseline,
  );

  /// No description provided for @aiCategorySpend.
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} on {category} {period} — {percent}% of expenses across {count} records.'**
  String aiCategorySpend(
    String category,
    String period,
    String amount,
    String percent,
    int count,
  );

  /// No description provided for @aiCategorySpendNone.
  ///
  /// In en, this message translates to:
  /// **'There are no {category} expenses {period}.'**
  String aiCategorySpendNone(String category, String period);

  /// No description provided for @aiCompareLess.
  ///
  /// In en, this message translates to:
  /// **'In the first {days} days of this month you spent {current}, {percent}% less than in the same days last month ({previous}).'**
  String aiCompareLess(
    int days,
    String current,
    String percent,
    String previous,
  );

  /// No description provided for @aiCompareMore.
  ///
  /// In en, this message translates to:
  /// **'In the first {days} days of this month you spent {current}, {percent}% more than in the same days last month ({previous}).'**
  String aiCompareMore(
    int days,
    String current,
    String percent,
    String previous,
  );

  /// No description provided for @aiCompareNoPrevExpense.
  ///
  /// In en, this message translates to:
  /// **'In the first {days} days of this month you spent {current}. Last month had no expenses in the same days.'**
  String aiCompareNoPrevExpense(int days, String current);

  /// No description provided for @aiCompareSame.
  ///
  /// In en, this message translates to:
  /// **'In the first {days} days of this month you spent {current}, about the same as last month ({previous}).'**
  String aiCompareSame(int days, String current, String previous);

  /// No description provided for @aiDebtOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue: {count}.'**
  String aiDebtOverdue(int count);

  /// No description provided for @aiDebtOverview.
  ///
  /// In en, this message translates to:
  /// **'You owe {owe} in total; others owe you {owed}. Open debts: {active}.'**
  String aiDebtOverview(String owe, String owed, int active);

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'ℹ This is informational guidance based on your records, not professional financial advice.'**
  String get aiDisclaimer;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I could not analyse your data right now. Please try again.'**
  String get aiError;

  /// No description provided for @aiGoalMonthly.
  ///
  /// In en, this message translates to:
  /// **'Saving {amount} per month will get you there on time.'**
  String aiGoalMonthly(String amount);

  /// No description provided for @aiGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'“{name}”: {percent}% reached, {remaining} to go.'**
  String aiGoalProgress(String name, String percent, String remaining);

  /// No description provided for @aiGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello! I can analyse your spending, budgets, savings goals and debts. Try one of the suggested questions below.'**
  String get aiGreeting;

  /// No description provided for @aiHelp.
  ///
  /// In en, this message translates to:
  /// **'I can answer questions like:\n• Where did most of my money go?\n• How much did I spend on food this month?\n• How much did I save?\n• Compare with last month\n• How is my budget?\n• Any unusual spending?\n• How are my goals and debts?\n• How can I save money?'**
  String get aiHelp;

  /// No description provided for @aiLargestExpense.
  ///
  /// In en, this message translates to:
  /// **'Your largest expense was “{title}” — {amount} on {date} ({category}).'**
  String aiLargestExpense(
    String title,
    String amount,
    String date,
    String category,
  );

  /// No description provided for @aiNextCategories.
  ///
  /// In en, this message translates to:
  /// **'Next: {list}.'**
  String aiNextCategories(String list);

  /// No description provided for @aiNoBudgets.
  ///
  /// In en, this message translates to:
  /// **'You haven’t set a budget yet. Set a monthly limit in Budgets and I’ll track it for you.'**
  String get aiNoBudgets;

  /// No description provided for @aiNoDebts.
  ///
  /// In en, this message translates to:
  /// **'You have no debt records.'**
  String get aiNoDebts;

  /// No description provided for @aiNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses are recorded for this period.'**
  String get aiNoExpenses;

  /// No description provided for @aiNoGoals.
  ///
  /// In en, this message translates to:
  /// **'You don’t have any active savings goals.'**
  String get aiNoGoals;

  /// No description provided for @aiNoIncome.
  ///
  /// In en, this message translates to:
  /// **'No income is recorded for this period.'**
  String get aiNoIncome;

  /// No description provided for @aiNoPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'There is no data for previous months yet, so I can’t make a comparison.'**
  String get aiNoPreviousMonth;

  /// No description provided for @aiNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'I don’t have enough data yet. Add a few transactions and I’ll be able to analyse your spending.'**
  String get aiNoTransactions;

  /// No description provided for @aiNoUnusual.
  ///
  /// In en, this message translates to:
  /// **'I don’t see any unusual increases in your spending this month.'**
  String get aiNoUnusual;

  /// No description provided for @aiOverspent.
  ///
  /// In en, this message translates to:
  /// **'Your expenses {period} exceeded your income by {amount}.'**
  String aiOverspent(String period, String amount);

  /// No description provided for @aiPeriodTotal.
  ///
  /// In en, this message translates to:
  /// **'Expenses {period}: {expense}. Income: {income}. Records: {count}.'**
  String aiPeriodTotal(String period, String expense, String income, int count);

  /// No description provided for @aiRisingTrend.
  ///
  /// In en, this message translates to:
  /// **'{category} expenses have grown for three months in a row.'**
  String aiRisingTrend(String category);

  /// No description provided for @aiSaved.
  ///
  /// In en, this message translates to:
  /// **'The difference between your income and expenses {period} is {amount}.'**
  String aiSaved(String period, String amount);

  /// No description provided for @aiSavingsRate.
  ///
  /// In en, this message translates to:
  /// **'That is {percent}% of your income.'**
  String aiSavingsRate(String percent);

  /// No description provided for @aiSuggest1.
  ///
  /// In en, this message translates to:
  /// **'Where did most of my money go this month?'**
  String get aiSuggest1;

  /// No description provided for @aiSuggest2.
  ///
  /// In en, this message translates to:
  /// **'How much did I save this month?'**
  String get aiSuggest2;

  /// No description provided for @aiSuggest3.
  ///
  /// In en, this message translates to:
  /// **'How can I save money?'**
  String get aiSuggest3;

  /// No description provided for @aiSuggest4.
  ///
  /// In en, this message translates to:
  /// **'Compare with last month'**
  String get aiSuggest4;

  /// No description provided for @aiSuggest5.
  ///
  /// In en, this message translates to:
  /// **'How is my budget?'**
  String get aiSuggest5;

  /// No description provided for @aiSuggest6.
  ///
  /// In en, this message translates to:
  /// **'Any unusual spending?'**
  String get aiSuggest6;

  /// No description provided for @aiSuggestLimit.
  ///
  /// In en, this message translates to:
  /// **'You spend about {average} per month on {category}. A monthly limit of {suggested} could help you save.'**
  String aiSuggestLimit(String category, String average, String suggested);

  /// No description provided for @aiTipCreateGoal.
  ///
  /// In en, this message translates to:
  /// **'Create a savings goal — a clear target makes saving easier to keep up.'**
  String get aiTipCreateGoal;

  /// No description provided for @aiTipIncrease.
  ///
  /// In en, this message translates to:
  /// **'Watch this increase: {text}'**
  String aiTipIncrease(String text);

  /// No description provided for @aiTipKeepSaving.
  ///
  /// In en, this message translates to:
  /// **'You are keeping {percent}% of your income this month — keep it up.'**
  String aiTipKeepSaving(String percent);

  /// No description provided for @aiTipSaveMore.
  ///
  /// In en, this message translates to:
  /// **'You are setting aside less than 10% of your income. Try moving a fixed amount to a savings goal right after you get paid.'**
  String get aiTipSaveMore;

  /// No description provided for @aiTipTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Start with your largest category. {text} Setting a limit for it usually has the biggest effect.'**
  String aiTipTopCategory(String text);

  /// No description provided for @aiTipsIntro.
  ///
  /// In en, this message translates to:
  /// **'Based on your records:'**
  String get aiTipsIntro;

  /// No description provided for @aiTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Most of your spending {period} went to {category}: {amount}, which is {percent}% of all expenses.'**
  String aiTopCategory(
    String period,
    String category,
    String amount,
    String percent,
  );

  /// No description provided for @aiUnknown.
  ///
  /// In en, this message translates to:
  /// **'I’m not sure I understood. I can tell you about your spending, income, savings, budgets, goals and debts — try “Where did most of my money go this month?”'**
  String get aiUnknown;

  /// No description provided for @alertThresholds.
  ///
  /// In en, this message translates to:
  /// **'Alert thresholds'**
  String get alertThresholds;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @allExpenses.
  ///
  /// In en, this message translates to:
  /// **'All expenses'**
  String get allExpenses;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All transactions'**
  String get allTransactions;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @anyDate.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get anyDate;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HisobAI'**
  String get appTitle;

  /// No description provided for @appliesTo.
  ///
  /// In en, this message translates to:
  /// **'Applies to'**
  String get appliesTo;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @askAssistant.
  ///
  /// In en, this message translates to:
  /// **'Ask assistant'**
  String get askAssistant;

  /// No description provided for @askHint.
  ///
  /// In en, this message translates to:
  /// **'Ask a question…'**
  String get askHint;

  /// No description provided for @assistantEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'I analyse your transactions, budgets, goals and debts to answer questions and suggest improvements.'**
  String get assistantEmptyBody;

  /// No description provided for @assistantEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about your money'**
  String get assistantEmptyTitle;

  /// No description provided for @assistantLocalNote.
  ///
  /// In en, this message translates to:
  /// **'This assistant runs entirely on your device using built-in rules. It does not use an online AI service and never sends your data anywhere.'**
  String get assistantLocalNote;

  /// No description provided for @assistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline · based on your records'**
  String get assistantSubtitle;

  /// No description provided for @assistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get assistantTitle;

  /// No description provided for @assistantTyping.
  ///
  /// In en, this message translates to:
  /// **'Assistant is typing'**
  String get assistantTyping;

  /// No description provided for @availableAmount.
  ///
  /// In en, this message translates to:
  /// **'Available: {amount}'**
  String availableAmount(String amount);

  /// No description provided for @avgDailySpending.
  ///
  /// In en, this message translates to:
  /// **'Avg. daily spending'**
  String get avgDailySpending;

  /// No description provided for @backupAndSync.
  ///
  /// In en, this message translates to:
  /// **'Backup & sync'**
  String get backupAndSync;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backupNow;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// No description provided for @backupUnencryptedNote.
  ///
  /// In en, this message translates to:
  /// **'Backup files are not encrypted and contain your financial records.'**
  String get backupUnencryptedNote;

  /// No description provided for @balanceSeparateNote.
  ///
  /// In en, this message translates to:
  /// **'Shown per currency — add a USD/UZS rate to combine'**
  String get balanceSeparateNote;

  /// No description provided for @budgetAlertBody.
  ///
  /// In en, this message translates to:
  /// **'{name}: {percent}% of the monthly limit used.'**
  String budgetAlertBody(String name, int percent);

  /// No description provided for @budgetAlerts.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get budgetAlerts;

  /// No description provided for @budgetExceededTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget exceeded'**
  String get budgetExceededTitle;

  /// No description provided for @budgetExplain.
  ///
  /// In en, this message translates to:
  /// **'A monthly budget is a spending limit that applies to every month. HisobAI compares it with your actual expenses.'**
  String get budgetExplain;

  /// No description provided for @budgetLevelCritical.
  ///
  /// In en, this message translates to:
  /// **'{percent}% used — you are close to the limit'**
  String budgetLevelCritical(int percent);

  /// No description provided for @budgetLevelExceeded.
  ///
  /// In en, this message translates to:
  /// **'Budget exceeded'**
  String get budgetLevelExceeded;

  /// No description provided for @budgetLevelWarning.
  ///
  /// In en, this message translates to:
  /// **'{percent}% used — keep an eye on spending'**
  String budgetLevelWarning(int percent);

  /// No description provided for @budgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget saved'**
  String get budgetSaved;

  /// No description provided for @budgetStandingNote.
  ///
  /// In en, this message translates to:
  /// **'The limit repeats every month until you change or delete it.'**
  String get budgetStandingNote;

  /// No description provided for @budgetUnconvertedNote.
  ///
  /// In en, this message translates to:
  /// **'Some expenses in another currency are not counted — add an exchange rate.'**
  String get budgetUnconvertedNote;

  /// No description provided for @budgetWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget warning'**
  String get budgetWarningTitle;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @builtIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get builtIn;

  /// No description provided for @byDate.
  ///
  /// In en, this message translates to:
  /// **'By {date}'**
  String byDate(String date);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @catBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get catBusiness;

  /// No description provided for @catCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get catCommunication;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get catFreelance;

  /// No description provided for @catGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get catGift;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get catHousing;

  /// No description provided for @catInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get catInvestment;

  /// No description provided for @catOtherExpense.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOtherExpense;

  /// No description provided for @catOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOtherIncome;

  /// No description provided for @catPersonalCare.
  ///
  /// In en, this message translates to:
  /// **'Personal care'**
  String get catPersonalCare;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get catTravel;

  /// No description provided for @catUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtilities;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @categoriesSelected.
  ///
  /// In en, this message translates to:
  /// **'Categories: {count}'**
  String categoriesSelected(int count);

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @categoryDistribution.
  ///
  /// In en, this message translates to:
  /// **'Category distribution'**
  String get categoryDistribution;

  /// No description provided for @categoryLimits.
  ///
  /// In en, this message translates to:
  /// **'Category limits'**
  String get categoryLimits;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearConversation.
  ///
  /// In en, this message translates to:
  /// **'Clear conversation'**
  String get clearConversation;

  /// No description provided for @clearConversationBody.
  ///
  /// In en, this message translates to:
  /// **'All messages will be deleted from this device.'**
  String get clearConversationBody;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup'**
  String get cloudBackup;

  /// No description provided for @cloudBackupDone.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup completed'**
  String get cloudBackupDone;

  /// No description provided for @cloudConsent.
  ///
  /// In en, this message translates to:
  /// **'I agree to store my backup in the cloud'**
  String get cloudConsent;

  /// No description provided for @cloudDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup deleted'**
  String get cloudDeleted;

  /// No description provided for @cloudExplain.
  ///
  /// In en, this message translates to:
  /// **'Stores an encrypted-in-transit copy of your data in Firebase under an anonymous identity tied to this installation. If you uninstall the app, that copy can no longer be accessed — keep a backup file too.'**
  String get cloudExplain;

  /// No description provided for @cloudNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup is not configured in this build. Everything else works offline; use the backup file to keep a copy.'**
  String get cloudNotConfigured;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @completedGoals.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedGoals;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @conversionPolicy.
  ///
  /// In en, this message translates to:
  /// **'Conversion policy: UZS and USD are never added directly. Each transaction is converted with the latest rate effective on its date; if it predates all rates, the oldest rate is used. Your balance is converted with the latest rate. Without any rate, totals are shown per currency.'**
  String get conversionPolicy;

  /// No description provided for @conversionPolicyShort.
  ///
  /// In en, this message translates to:
  /// **'Each transaction is converted with the latest rate effective on its date (oldest rate if earlier than all rates).'**
  String get conversionPolicyShort;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @criticalAt.
  ///
  /// In en, this message translates to:
  /// **'Critical at'**
  String get criticalAt;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get customRange;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @dailySpending.
  ///
  /// In en, this message translates to:
  /// **'Daily spending'**
  String get dailySpending;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @dataReset.
  ///
  /// In en, this message translates to:
  /// **'All data was deleted'**
  String get dataReset;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debt;

  /// No description provided for @debtAccountingNote.
  ///
  /// In en, this message translates to:
  /// **'Debts are tracked separately: creating a debt or recording a repayment does not change your balance, income or expenses.'**
  String get debtAccountingNote;

  /// No description provided for @debtActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get debtActive;

  /// No description provided for @debtCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get debtCompleted;

  /// No description provided for @debtIOwe.
  ///
  /// In en, this message translates to:
  /// **'I owe'**
  String get debtIOwe;

  /// No description provided for @debtOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get debtOverdue;

  /// No description provided for @debtOwedToMe.
  ///
  /// In en, this message translates to:
  /// **'Owed to me'**
  String get debtOwedToMe;

  /// No description provided for @debtSaved.
  ///
  /// In en, this message translates to:
  /// **'Debt saved'**
  String get debtSaved;

  /// No description provided for @debts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debts;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Your transactions are not affected.'**
  String get deleteBudgetBody;

  /// No description provided for @deleteBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete budget?'**
  String get deleteBudgetTitle;

  /// No description provided for @deleteCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'This category is not used by any transaction.'**
  String get deleteCategoryBody;

  /// No description provided for @deleteCategoryInUse.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions use this category. They will be moved to “Other”.'**
  String deleteCategoryInUse(int count);

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCloudBody.
  ///
  /// In en, this message translates to:
  /// **'Your local data is not affected.'**
  String get deleteCloudBody;

  /// No description provided for @deleteCloudCopy.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud copy'**
  String get deleteCloudCopy;

  /// No description provided for @deleteCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud backup?'**
  String get deleteCloudTitle;

  /// No description provided for @deleteDebtBody.
  ///
  /// In en, this message translates to:
  /// **'The debt and all its repayments will be deleted.'**
  String get deleteDebtBody;

  /// No description provided for @deleteDebtTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete debt?'**
  String get deleteDebtTitle;

  /// No description provided for @deleteEntryBody.
  ///
  /// In en, this message translates to:
  /// **'The saved amount will be recalculated.'**
  String get deleteEntryBody;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get deleteEntryTitle;

  /// No description provided for @deleteGoalBody.
  ///
  /// In en, this message translates to:
  /// **'The goal and its history will be deleted. Your transactions are not affected.'**
  String get deleteGoalBody;

  /// No description provided for @deleteGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete goal?'**
  String get deleteGoalTitle;

  /// No description provided for @deleteRateBody.
  ///
  /// In en, this message translates to:
  /// **'Converted totals will be recalculated with the remaining rates.'**
  String get deleteRateBody;

  /// No description provided for @deleteRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete rate?'**
  String get deleteRateTitle;

  /// No description provided for @deleteRecurringBody.
  ///
  /// In en, this message translates to:
  /// **'Already recorded transactions are kept. Future payments will not be created.'**
  String get deleteRecurringBody;

  /// No description provided for @deleteRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring payment?'**
  String get deleteRecurringTitle;

  /// No description provided for @deleteRepaymentBody.
  ///
  /// In en, this message translates to:
  /// **'The remaining amount will be recalculated.'**
  String get deleteRepaymentBody;

  /// No description provided for @deleteRepaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete repayment?'**
  String get deleteRepaymentTitle;

  /// No description provided for @deleteTransactionBody.
  ///
  /// In en, this message translates to:
  /// **'Balances, budgets and statistics will be recalculated. This cannot be undone.'**
  String get deleteTransactionBody;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get deleteTransactionTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @disclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'Insights and recommendations are informational only and are not professional financial advice.'**
  String get disclaimerBody;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Not financial advice'**
  String get disclaimerTitle;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'How should we greet you?'**
  String get displayNameHint;

  /// No description provided for @displayNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Your name (optional)'**
  String get displayNameOptional;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @dueDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Due date (optional)'**
  String get dueDateOptional;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'due {date}'**
  String dueOn(String date);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get editBudget;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @editDebt.
  ///
  /// In en, this message translates to:
  /// **'Edit debt'**
  String get editDebt;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get editGoal;

  /// No description provided for @editRate.
  ///
  /// In en, this message translates to:
  /// **'Edit rate'**
  String get editRate;

  /// No description provided for @editRecurring.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring payment'**
  String get editRecurring;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransaction;

  /// No description provided for @effectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective date'**
  String get effectiveDate;

  /// No description provided for @effectiveFrom.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String effectiveFrom(String date);

  /// No description provided for @emptyDebtsBody.
  ///
  /// In en, this message translates to:
  /// **'Track money you borrowed or lent and record repayments as they happen.'**
  String get emptyDebtsBody;

  /// No description provided for @emptyDebtsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get emptyDebtsTitle;

  /// No description provided for @emptyGoalsBody.
  ///
  /// In en, this message translates to:
  /// **'Saving for a laptop, travel or an emergency fund? Create a goal and track every step.'**
  String get emptyGoalsBody;

  /// No description provided for @emptyGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet'**
  String get emptyGoalsTitle;

  /// No description provided for @emptyRecurringBody.
  ///
  /// In en, this message translates to:
  /// **'Add rent, subscriptions, utilities or regular income — HisobAI records them automatically when they are due.'**
  String get emptyRecurringBody;

  /// No description provided for @emptyRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'No recurring payments'**
  String get emptyRecurringTitle;

  /// No description provided for @emptyStatsBody.
  ///
  /// In en, this message translates to:
  /// **'Charts are built only from your own records. Add your first transaction to get started.'**
  String get emptyStatsBody;

  /// No description provided for @emptyStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your statistics will appear here'**
  String get emptyStatsTitle;

  /// No description provided for @emptyTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Record your first income or expense to see your balance come to life.'**
  String get emptyTransactionsBody;

  /// No description provided for @emptyTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get emptyTransactionsTitle;

  /// No description provided for @endDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End date (optional)'**
  String get endDateOptional;

  /// No description provided for @ended.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get ended;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Please try again. Your data is safe.'**
  String get errorGeneric;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get errorSaving;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @exceededAlwaysNote.
  ///
  /// In en, this message translates to:
  /// **'You are always notified when a budget is exceeded (100%).'**
  String get exceededAlwaysNote;

  /// No description provided for @excelContents.
  ///
  /// In en, this message translates to:
  /// **'Excel workbook with Summary, Transactions, Categories and Budget sheets.'**
  String get excelContents;

  /// No description provided for @exchangeRates.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates'**
  String get exchangeRates;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @expenseOverview.
  ///
  /// In en, this message translates to:
  /// **'Expense overview'**
  String get expenseOverview;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportData;

  /// No description provided for @fileBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup file'**
  String get fileBackup;

  /// No description provided for @fileBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Export everything to a JSON file you can keep or move to another phone, and import it later.'**
  String get fileBackupBody;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get filterByCategory;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @freqDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get freqDaily;

  /// No description provided for @freqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get freqMonthly;

  /// No description provided for @freqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get freqWeekly;

  /// No description provided for @freqYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get freqYearly;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @fromRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring payment'**
  String get fromRecurring;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @goalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Goal marked as completed'**
  String get goalCompleted;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @goalNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. New laptop'**
  String get goalNameHint;

  /// No description provided for @goalReachedSnack.
  ///
  /// In en, this message translates to:
  /// **'Congratulations — you reached your target!'**
  String get goalReachedSnack;

  /// No description provided for @goalReopened.
  ///
  /// In en, this message translates to:
  /// **'Goal reopened'**
  String get goalReopened;

  /// No description provided for @goalSaved.
  ///
  /// In en, this message translates to:
  /// **'Goal saved'**
  String get goalSaved;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'HisobAI user'**
  String get guestUser;

  /// No description provided for @hideAmounts.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts'**
  String get hideAmounts;

  /// No description provided for @hideAmountsHint.
  ///
  /// In en, this message translates to:
  /// **'Mask balances and amounts on screen'**
  String get hideAmountsHint;

  /// No description provided for @highestExpense.
  ///
  /// In en, this message translates to:
  /// **'Highest expense'**
  String get highestExpense;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get importData;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @incomeVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Income vs expenses'**
  String get incomeVsExpenses;

  /// No description provided for @initialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial balance'**
  String get initialBalance;

  /// No description provided for @initialBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'Money you already had before you started using HisobAI. It is added to your balance but not counted as income.'**
  String get initialBalanceHint;

  /// No description provided for @initialBalanceOptional.
  ///
  /// In en, this message translates to:
  /// **'Initial balance (optional)'**
  String get initialBalanceOptional;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @insightsNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Add a few more transactions and HisobAI will start showing personal insights here.'**
  String get insightsNotEnoughData;

  /// No description provided for @insufficientDataBadge.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get insufficientDataBadge;

  /// No description provided for @invalidBackup.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid HisobAI backup.'**
  String get invalidBackup;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get last3Months;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String lastBackup(String date);

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @localDataNote.
  ///
  /// In en, this message translates to:
  /// **'Your data lives only on this device unless you export it. Make regular backups.'**
  String get localDataNote;

  /// No description provided for @localProfileNote.
  ///
  /// In en, this message translates to:
  /// **'No account needed · data stays on this device'**
  String get localProfileNote;

  /// No description provided for @lowestExpense.
  ///
  /// In en, this message translates to:
  /// **'Lowest expense'**
  String get lowestExpense;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get markCompleted;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudget;

  /// No description provided for @monthlyExpenseTrend.
  ///
  /// In en, this message translates to:
  /// **'Monthly expense trend'**
  String get monthlyExpenseTrend;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit'**
  String get monthlyLimit;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get navAdd;

  /// No description provided for @navAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get navAssistant;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStats;

  /// No description provided for @netCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Net cash flow'**
  String get netCashFlow;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get newGoal;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String nextDue(String date);

  /// No description provided for @noBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Set a spending limit to track your month'**
  String get noBudgetBody;

  /// No description provided for @noBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'No monthly budget yet'**
  String get noBudgetTitle;

  /// No description provided for @noCategoryLimits.
  ///
  /// In en, this message translates to:
  /// **'No category limits yet. Add one to control a specific kind of spending.'**
  String get noCategoryLimits;

  /// No description provided for @noCloudBackup.
  ///
  /// In en, this message translates to:
  /// **'No cloud backup found'**
  String get noCloudBackup;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No transactions for this period'**
  String get noDataForPeriod;

  /// No description provided for @noDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get noDeadline;

  /// No description provided for @noEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No deposits yet.'**
  String get noEntriesYet;

  /// No description provided for @noRateShort.
  ///
  /// In en, this message translates to:
  /// **'no exchange rate'**
  String get noRateShort;

  /// No description provided for @noRatesBody.
  ///
  /// In en, this message translates to:
  /// **'Without a rate HisobAI keeps UZS and USD totals separate. Add a rate to see combined amounts.'**
  String get noRatesBody;

  /// No description provided for @noRatesTitle.
  ///
  /// In en, this message translates to:
  /// **'No exchange rates'**
  String get noRatesTitle;

  /// No description provided for @noRepaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No repayments yet.'**
  String get noRepaymentsYet;

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try different search words or filters.'**
  String get noResultsBody;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get noResultsTitle;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @notFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This record no longer exists.'**
  String get notFoundBody;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Payment reminders and budget alerts'**
  String get notificationsHint;

  /// No description provided for @ofAmount.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String ofAmount(String amount);

  /// No description provided for @onbBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Set monthly limits and get warned before you overspend.'**
  String get onbBudgetBody;

  /// No description provided for @onbBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your budget'**
  String get onbBudgetTitle;

  /// No description provided for @onbGoalsBody.
  ///
  /// In en, this message translates to:
  /// **'Save for what matters, track debts and recurring payments — all in one place.'**
  String get onbGoalsBody;

  /// No description provided for @onbGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reach your savings goals'**
  String get onbGoalsTitle;

  /// No description provided for @onbNoAccountNote.
  ///
  /// In en, this message translates to:
  /// **'No email, phone number or account is required. Your data stays on this device.'**
  String get onbNoAccountNote;

  /// No description provided for @onbSetupBody.
  ///
  /// In en, this message translates to:
  /// **'You can change all of this later in Profile.'**
  String get onbSetupBody;

  /// No description provided for @onbSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s set things up'**
  String get onbSetupTitle;

  /// No description provided for @onbStart.
  ///
  /// In en, this message translates to:
  /// **'Start using HisobAI'**
  String get onbStart;

  /// No description provided for @onbUnderstandBody.
  ///
  /// In en, this message translates to:
  /// **'See where every so‘m and dollar goes with clear charts and honest insights from your own records.'**
  String get onbUnderstandBody;

  /// No description provided for @onbUnderstandTitle.
  ///
  /// In en, this message translates to:
  /// **'Understand your money'**
  String get onbUnderstandTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A calm, private place for your money. No registration — start in seconds.'**
  String get onbWelcomeBody;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to HisobAI'**
  String get onbWelcomeTitle;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'The operation failed. Nothing was changed.'**
  String get operationFailed;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @originalAmount.
  ///
  /// In en, this message translates to:
  /// **'Original amount'**
  String get originalAmount;

  /// No description provided for @originalBelowPaid.
  ///
  /// In en, this message translates to:
  /// **'The original amount cannot be less than what has already been repaid.'**
  String get originalBelowPaid;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get overBudget;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @payInFull.
  ///
  /// In en, this message translates to:
  /// **'Pay in full'**
  String get payInFull;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @pdfContents.
  ///
  /// In en, this message translates to:
  /// **'Branded PDF with summary, category breakdown, budget overview and full transaction list.'**
  String get pdfContents;

  /// No description provided for @perMonthNeeded.
  ///
  /// In en, this message translates to:
  /// **'{amount} / month needed'**
  String perMonthNeeded(String amount);

  /// No description provided for @periodLastMonth.
  ///
  /// In en, this message translates to:
  /// **'last month'**
  String get periodLastMonth;

  /// No description provided for @periodLastMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get periodLastMonthTitle;

  /// No description provided for @periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get periodThisMonth;

  /// No description provided for @periodThisMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get periodThisMonthTitle;

  /// No description provided for @personOrOrganization.
  ///
  /// In en, this message translates to:
  /// **'Person or organization'**
  String get personOrOrganization;

  /// No description provided for @pmBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get pmBankTransfer;

  /// No description provided for @pmCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get pmCard;

  /// No description provided for @pmCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get pmCash;

  /// No description provided for @pmMobileWallet.
  ///
  /// In en, this message translates to:
  /// **'Mobile wallet'**
  String get pmMobileWallet;

  /// No description provided for @pmOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pmOther;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @primaryCurrency.
  ///
  /// In en, this message translates to:
  /// **'Primary currency'**
  String get primaryCurrency;

  /// No description provided for @privacyAiBody.
  ///
  /// In en, this message translates to:
  /// **'The assistant is a built-in, rule-based analysis engine. It is not connected to an external AI service and only uses the records you entered.'**
  String get privacyAiBody;

  /// No description provided for @privacyAiTitle.
  ///
  /// In en, this message translates to:
  /// **'About the AI assistant'**
  String get privacyAiTitle;

  /// No description provided for @privacyAndAbout.
  ///
  /// In en, this message translates to:
  /// **'Privacy & about'**
  String get privacyAndAbout;

  /// No description provided for @privacyCloudBody.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup is off by default and only works if this build is connected to Firebase. When you turn it on, an anonymous identity is created and your backup is stored in a private area only that identity can access.'**
  String get privacyCloudBody;

  /// No description provided for @privacyCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional cloud backup'**
  String get privacyCloudTitle;

  /// No description provided for @privacyLocalBody.
  ///
  /// In en, this message translates to:
  /// **'All records are stored in a local database on this phone. HisobAI works fully offline. Local data is not automatically backed up — use Backup & sync to export a copy.'**
  String get privacyLocalBody;

  /// No description provided for @privacyLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device'**
  String get privacyLocalTitle;

  /// No description provided for @privacyNoAccountBody.
  ///
  /// In en, this message translates to:
  /// **'HisobAI does not ask for an email, phone number, Google or Apple account.'**
  String get privacyNoAccountBody;

  /// No description provided for @privacyNoAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'No registration'**
  String get privacyNoAccountTitle;

  /// No description provided for @privacySecurityBody.
  ///
  /// In en, this message translates to:
  /// **'Data is protected by your phone’s app sandbox and device encryption. The app database itself is not additionally encrypted, and exported backup files are plain JSON — keep them somewhere safe. Use a screen lock on your device.'**
  String get privacySecurityBody;

  /// No description provided for @privacySecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get privacySecurityTitle;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @rateManualNote.
  ///
  /// In en, this message translates to:
  /// **'Rates are entered by you; HisobAI does not download rates from the internet.'**
  String get rateManualNote;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @recordRepayment.
  ///
  /// In en, this message translates to:
  /// **'Record repayment'**
  String get recordRepayment;

  /// No description provided for @recurringAutoNote.
  ///
  /// In en, this message translates to:
  /// **'Due payments are recorded automatically each time you open the app, exactly once per due date. Reminders are scheduled with your phone so they arrive even if the app is closed.'**
  String get recurringAutoNote;

  /// No description provided for @recurringBackfillNote.
  ///
  /// In en, this message translates to:
  /// **'The start date is in the past: payments since that date will be recorded when you save.'**
  String get recurringBackfillNote;

  /// No description provided for @recurringPayments.
  ///
  /// In en, this message translates to:
  /// **'Recurring payments'**
  String get recurringPayments;

  /// No description provided for @recurringSaved.
  ///
  /// In en, this message translates to:
  /// **'Recurring payment saved'**
  String get recurringSaved;

  /// No description provided for @recurringTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rent, Internet, Netflix'**
  String get recurringTitleHint;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {amount}'**
  String remainingAmount(String amount);

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'{title}: {amount} is due today.'**
  String reminderBody(String title, String amount);

  /// No description provided for @reminderHint.
  ///
  /// In en, this message translates to:
  /// **'Notify me at 9:00 on the due date'**
  String get reminderHint;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment due today'**
  String get reminderTitle;

  /// No description provided for @reopenGoal.
  ///
  /// In en, this message translates to:
  /// **'Reopen goal'**
  String get reopenGoal;

  /// No description provided for @repaymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Repayment recorded'**
  String get repaymentRecorded;

  /// No description provided for @repaymentTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The repayment is larger than the remaining amount.'**
  String get repaymentTooLarge;

  /// No description provided for @repayments.
  ///
  /// In en, this message translates to:
  /// **'Repayments'**
  String get repayments;

  /// No description provided for @reportEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Choose another period or add transactions first.'**
  String get reportEmptyHint;

  /// No description provided for @reportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the report. Please try again.'**
  String get reportFailed;

  /// No description provided for @reportPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Report period'**
  String get reportPeriodLabel;

  /// No description provided for @reportSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {name}'**
  String reportSaved(String name);

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get resetData;

  /// No description provided for @resetDataBody.
  ///
  /// In en, this message translates to:
  /// **'All transactions, budgets, goals, debts, recurring payments, rates, chat history and settings will be permanently deleted from this device. Export a backup first if you may need them.'**
  String get resetDataBody;

  /// No description provided for @resetDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'I understand this cannot be undone'**
  String get resetDataConfirm;

  /// No description provided for @resetDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get resetDataTitle;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Backup from {date}: {tx} transactions, {goals} goals, {debts} debts. All current data on this device will be replaced.'**
  String restoreBackupBody(String date, int tx, int goals, int debts);

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get restoreBackupTitle;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Data restored'**
  String get restoreDone;

  /// No description provided for @rptBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get rptBudget;

  /// No description provided for @rptBudgetOverview.
  ///
  /// In en, this message translates to:
  /// **'Budget overview'**
  String get rptBudgetOverview;

  /// No description provided for @rptCategoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get rptCategoryBreakdown;

  /// No description provided for @rptCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get rptCount;

  /// No description provided for @rptFinancialReport.
  ///
  /// In en, this message translates to:
  /// **'Financial report'**
  String get rptFinancialReport;

  /// No description provided for @rptGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get rptGenerated;

  /// No description provided for @rptMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get rptMetric;

  /// No description provided for @rptPeriod.
  ///
  /// In en, this message translates to:
  /// **'Report period'**
  String get rptPeriod;

  /// No description provided for @rptRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rptRate;

  /// No description provided for @rptRatesUsed.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates'**
  String get rptRatesUsed;

  /// No description provided for @rptReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get rptReport;

  /// No description provided for @rptShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get rptShare;

  /// No description provided for @rptSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get rptSummary;

  /// No description provided for @rptTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get rptTransactions;

  /// No description provided for @rptType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get rptType;

  /// No description provided for @rptUnconverted.
  ///
  /// In en, this message translates to:
  /// **'Not converted'**
  String get rptUnconverted;

  /// No description provided for @rptUnconvertedNote.
  ///
  /// In en, this message translates to:
  /// **'Amounts in other currencies without an exchange rate are shown separately and not included in totals.'**
  String get rptUnconvertedNote;

  /// No description provided for @rptUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get rptUsed;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveToDevice.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveToDevice;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @savingsAccountingNote.
  ///
  /// In en, this message translates to:
  /// **'Savings goals track money you set aside. Deposits and withdrawals are not counted as income or expenses.'**
  String get savingsAccountingNote;

  /// No description provided for @savingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get savingsGoals;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search by title or note'**
  String get searchTransactions;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get setBudget;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @showAmounts.
  ///
  /// In en, this message translates to:
  /// **'Show amounts'**
  String get showAmounts;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortAmountHigh.
  ///
  /// In en, this message translates to:
  /// **'Amount: high to low'**
  String get sortAmountHigh;

  /// No description provided for @sortAmountLow.
  ///
  /// In en, this message translates to:
  /// **'Amount: low to high'**
  String get sortAmountLow;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldest;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @sourceManual.
  ///
  /// In en, this message translates to:
  /// **'Entered manually'**
  String get sourceManual;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @statsMissingRateNote.
  ///
  /// In en, this message translates to:
  /// **'Some transactions are in another currency and are excluded until you add an exchange rate.'**
  String get statsMissingRateNote;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get targetAmount;

  /// No description provided for @targetDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Target date (optional)'**
  String get targetDateOptional;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @thisMonthSuffix.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get thisMonthSuffix;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @thresholdsSummary.
  ///
  /// In en, this message translates to:
  /// **'Warn at {warning}% and {critical}%, and when exceeded'**
  String thresholdsSummary(int warning, int critical);

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleHintExpense.
  ///
  /// In en, this message translates to:
  /// **'e.g. Groceries at Korzinka'**
  String get titleHintExpense;

  /// No description provided for @titleHintIncome.
  ///
  /// In en, this message translates to:
  /// **'e.g. October salary'**
  String get titleHintIncome;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @totalForPeriod.
  ///
  /// In en, this message translates to:
  /// **'Total for period'**
  String get totalForPeriod;

  /// No description provided for @totalIOwe.
  ///
  /// In en, this message translates to:
  /// **'I owe'**
  String get totalIOwe;

  /// No description provided for @totalMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Total monthly budget'**
  String get totalMonthlyBudget;

  /// No description provided for @totalOwedToMe.
  ///
  /// In en, this message translates to:
  /// **'Owed to me'**
  String get totalOwedToMe;

  /// No description provided for @transactionAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added'**
  String get transactionAdded;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction details'**
  String get transactionDetails;

  /// No description provided for @transactionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated'**
  String get transactionUpdated;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @validationAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validationAmountInvalid;

  /// No description provided for @validationAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero'**
  String get validationAmountPositive;

  /// No description provided for @validationAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get validationAmountRequired;

  /// No description provided for @validationCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get validationCategoryRequired;

  /// No description provided for @validationEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End date cannot be before the start date'**
  String get validationEndBeforeStart;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get validationNameRequired;

  /// No description provided for @validationTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get validationTitleRequired;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get vsLastMonth;

  /// No description provided for @warningAt.
  ///
  /// In en, this message translates to:
  /// **'Warning at'**
  String get warningAt;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @weeklyComparison.
  ///
  /// In en, this message translates to:
  /// **'Weekly comparison'**
  String get weeklyComparison;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @withdrawTooMuch.
  ///
  /// In en, this message translates to:
  /// **'You can’t withdraw more than is saved.'**
  String get withdrawTooMuch;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
