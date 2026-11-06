// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get about => 'О приложении';

  @override
  String get aboutTagline =>
      'Понимайте, упорядочивайте и контролируйте свои деньги.';

  @override
  String get active => 'Активно';

  @override
  String get activeHint => 'Неактивные платежи не записываются';

  @override
  String get addBudget => 'Добавить бюджет';

  @override
  String get addDebt => 'Добавить долг';

  @override
  String get addMoney => 'Пополнить';

  @override
  String get addRate => 'Добавить курс';

  @override
  String get addRecurring => 'Добавить платёж';

  @override
  String get addTransaction => 'Добавить операцию';

  @override
  String aiBalance(String amount) {
    return 'Ваш текущий баланс: $amount.';
  }

  @override
  String aiBalanceSeparate(String list) {
    return 'Ваш баланс по валютам: $list. Добавьте курс, чтобы увидеть общую сумму.';
  }

  @override
  String aiBudgetCritical(String name, String percent, String remaining) {
    return '$name: использовано $percent%, осталось всего $remaining.';
  }

  @override
  String aiBudgetExceeded(String name, String percent, String amount) {
    return '$name: использовано $percent% — лимит превышен на $amount.';
  }

  @override
  String aiBudgetOk(
    String name,
    String percent,
    String remaining,
    String daily,
  ) {
    return '$name: вы в рамках бюджета — использовано $percent%, осталось $remaining (примерно $daily в день).';
  }

  @override
  String aiBudgetWarning(String name, String percent, String remaining) {
    return '$name: использовано $percent%, осталось $remaining.';
  }

  @override
  String aiCategoryIncrease(
    String category,
    String percent,
    String current,
    String baseline,
  ) {
    return 'Расходы на «$category» на $percent% выше обычного: $current сейчас против обычных $baseline.';
  }

  @override
  String aiCategorySpend(
    String category,
    String period,
    String amount,
    String percent,
    int count,
  ) {
    return 'На «$category» $period вы потратили $amount — $percent% расходов, записей: $count.';
  }

  @override
  String aiCategorySpendNone(String category, String period) {
    return 'Расходов по категории «$category» $period нет.';
  }

  @override
  String aiCompareLess(
    int days,
    String current,
    String percent,
    String previous,
  ) {
    return 'За первые $days дн. этого месяца вы потратили $current — на $percent% меньше, чем за те же дни прошлого месяца ($previous).';
  }

  @override
  String aiCompareMore(
    int days,
    String current,
    String percent,
    String previous,
  ) {
    return 'За первые $days дн. этого месяца вы потратили $current — на $percent% больше, чем за те же дни прошлого месяца ($previous).';
  }

  @override
  String aiCompareNoPrevExpense(int days, String current) {
    return 'За первые $days дн. этого месяца вы потратили $current. В те же дни прошлого месяца расходов не было.';
  }

  @override
  String aiCompareSame(int days, String current, String previous) {
    return 'За первые $days дн. этого месяца вы потратили $current — примерно столько же, сколько в прошлом месяце ($previous).';
  }

  @override
  String aiDebtOverdue(int count) {
    return 'Просрочено: $count.';
  }

  @override
  String aiDebtOverview(String owe, String owed, int active) {
    return 'Вы должны всего $owe; вам должны $owed. Открытых долгов: $active.';
  }

  @override
  String get aiDisclaimer =>
      'ℹ Это информационная подсказка на основе ваших записей, а не профессиональная финансовая консультация.';

  @override
  String get aiError =>
      'Не удалось проанализировать данные. Попробуйте ещё раз.';

  @override
  String aiGoalMonthly(String amount) {
    return 'Откладывая $amount в месяц, вы успеете к сроку.';
  }

  @override
  String aiGoalProgress(String name, String percent, String remaining) {
    return '«$name»: достигнуто $percent%, осталось $remaining.';
  }

  @override
  String get aiGreeting =>
      'Здравствуйте! Я могу проанализировать ваши расходы, бюджеты, цели и долги. Попробуйте один из вопросов ниже.';

  @override
  String get aiHelp =>
      'Я могу ответить на вопросы:\n• На что ушло больше всего денег?\n• Сколько я потратил на еду в этом месяце?\n• Сколько я сэкономил?\n• Сравни с прошлым месяцем\n• Как мой бюджет?\n• Есть необычные расходы?\n• Как мои цели и долги?\n• Как сэкономить?';

  @override
  String aiLargestExpense(
    String title,
    String amount,
    String date,
    String category,
  ) {
    return 'Самый крупный расход — «$title»: $amount, $date ($category).';
  }

  @override
  String aiNextCategories(String list) {
    return 'Далее: $list.';
  }

  @override
  String get aiNoBudgets =>
      'Вы ещё не задали бюджет. Установите месячный лимит в разделе «Бюджеты», и я буду его отслеживать.';

  @override
  String get aiNoDebts => 'У вас нет записей о долгах.';

  @override
  String get aiNoExpenses => 'За этот период расходов не записано.';

  @override
  String get aiNoGoals => 'У вас нет активных целей накопления.';

  @override
  String get aiNoIncome => 'За этот период доходов не записано.';

  @override
  String get aiNoPreviousMonth =>
      'Данных за прошлые месяцы пока нет, поэтому сравнить не получится.';

  @override
  String get aiNoTransactions =>
      'Пока недостаточно данных. Добавьте несколько операций, и я смогу проанализировать ваши расходы.';

  @override
  String get aiNoUnusual =>
      'Необычного роста расходов в этом месяце я не вижу.';

  @override
  String aiOverspent(String period, String amount) {
    return 'Ваши расходы $period превысили доходы на $amount.';
  }

  @override
  String aiPeriodTotal(
    String period,
    String expense,
    String income,
    int count,
  ) {
    return 'Расходы $period: $expense. Доходы: $income. Записей: $count.';
  }

  @override
  String aiRisingTrend(String category) {
    return 'Расходы на «$category» растут три месяца подряд.';
  }

  @override
  String aiSaved(String period, String amount) {
    return 'Разница между доходами и расходами $period составляет $amount.';
  }

  @override
  String aiSavingsRate(String percent) {
    return 'Это $percent% ваших доходов.';
  }

  @override
  String get aiSuggest1 => 'На что ушло больше всего денег в этом месяце?';

  @override
  String get aiSuggest2 => 'Сколько я сэкономил в этом месяце?';

  @override
  String get aiSuggest3 => 'Как мне сэкономить?';

  @override
  String get aiSuggest4 => 'Сравни с прошлым месяцем';

  @override
  String get aiSuggest5 => 'Как мой бюджет?';

  @override
  String get aiSuggest6 => 'Есть необычные расходы?';

  @override
  String aiSuggestLimit(String category, String average, String suggested) {
    return 'В среднем вы тратите $average в месяц на «$category». Лимит $suggested в месяц поможет сэкономить.';
  }

  @override
  String get aiTipCreateGoal =>
      'Создайте цель накопления — с понятной целью копить проще.';

  @override
  String aiTipIncrease(String text) {
    return 'Обратите внимание на рост: $text';
  }

  @override
  String aiTipKeepSaving(String percent) {
    return 'В этом месяце вы сохраняете $percent% дохода — так держать.';
  }

  @override
  String get aiTipSaveMore =>
      'Вы откладываете меньше 10% дохода. Попробуйте переводить фиксированную сумму в цель сразу после получения дохода.';

  @override
  String aiTipTopCategory(String text) {
    return 'Начните с самой крупной категории. $text Лимит на неё обычно даёт наибольший эффект.';
  }

  @override
  String get aiTipsIntro => 'По вашим записям:';

  @override
  String aiTopCategory(
    String period,
    String category,
    String amount,
    String percent,
  ) {
    return 'Больше всего $period вы потратили на категорию «$category»: $amount, это $percent% всех расходов.';
  }

  @override
  String get aiUnknown =>
      'Не уверен, что понял. Я могу рассказать о расходах, доходах, накоплениях, бюджетах, целях и долгах — попробуйте «На что ушло больше всего денег в этом месяце?»';

  @override
  String get alertThresholds => 'Пороги уведомлений';

  @override
  String get all => 'Все';

  @override
  String get allCategories => 'Все категории';

  @override
  String get allExpenses => 'Все расходы';

  @override
  String get allTransactions => 'Все операции';

  @override
  String get amount => 'Сумма';

  @override
  String get anyDate => 'Любая дата';

  @override
  String get appTitle => 'HisobAI';

  @override
  String get appliesTo => 'Применяется к';

  @override
  String get apply => 'Применить';

  @override
  String get askAssistant => 'Спросить';

  @override
  String get askHint => 'Задайте вопрос…';

  @override
  String get assistantEmptyBody =>
      'Я анализирую ваши операции, бюджеты, цели и долги, чтобы отвечать на вопросы и давать советы.';

  @override
  String get assistantEmptyTitle => 'Спросите о своих финансах';

  @override
  String get assistantLocalNote =>
      'Ассистент работает полностью на устройстве по встроенным правилам. Он не использует онлайн-ИИ и никуда не отправляет ваши данные.';

  @override
  String get assistantSubtitle => 'Офлайн · по вашим записям';

  @override
  String get assistantTitle => 'AI-ассистент';

  @override
  String get assistantTyping => 'Ассистент печатает';

  @override
  String availableAmount(String amount) {
    return 'Доступно: $amount';
  }

  @override
  String get avgDailySpending => 'Средний расход в день';

  @override
  String get backupAndSync => 'Резервная копия';

  @override
  String get backupNow => 'Создать копию';

  @override
  String get backupSaved => 'Резервная копия сохранена';

  @override
  String get backupUnencryptedNote =>
      'Файлы копий не зашифрованы и содержат ваши финансовые записи.';

  @override
  String get balanceSeparateNote =>
      'Показано по валютам — добавьте курс USD/UZS для общей суммы';

  @override
  String budgetAlertBody(String name, int percent) {
    return '$name: использовано $percent% месячного лимита.';
  }

  @override
  String get budgetAlerts => 'Уведомления о бюджете';

  @override
  String get budgetExceededTitle => 'Бюджет превышен';

  @override
  String get budgetExplain =>
      'Месячный бюджет — это лимит расходов на каждый месяц. HisobAI сравнивает его с фактическими расходами.';

  @override
  String budgetLevelCritical(int percent) {
    return 'Использовано $percent% — вы близки к лимиту';
  }

  @override
  String get budgetLevelExceeded => 'Бюджет превышен';

  @override
  String budgetLevelWarning(int percent) {
    return 'Использовано $percent% — следите за расходами';
  }

  @override
  String get budgetSaved => 'Бюджет сохранён';

  @override
  String get budgetStandingNote =>
      'Лимит действует каждый месяц, пока вы его не измените или не удалите.';

  @override
  String get budgetUnconvertedNote =>
      'Часть расходов в другой валюте не учтена — добавьте курс.';

  @override
  String get budgetWarningTitle => 'Предупреждение о бюджете';

  @override
  String get budgets => 'Бюджеты';

  @override
  String get builtIn => 'Встроенная';

  @override
  String byDate(String date) {
    return 'До $date';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get catBusiness => 'Бизнес';

  @override
  String get catCommunication => 'Связь';

  @override
  String get catEducation => 'Образование';

  @override
  String get catEntertainment => 'Развлечения';

  @override
  String get catFood => 'Еда';

  @override
  String get catFreelance => 'Фриланс';

  @override
  String get catGift => 'Подарок';

  @override
  String get catHealth => 'Здоровье';

  @override
  String get catHousing => 'Жильё';

  @override
  String get catInvestment => 'Инвестиции';

  @override
  String get catOtherExpense => 'Другое';

  @override
  String get catOtherIncome => 'Другое';

  @override
  String get catPersonalCare => 'Уход за собой';

  @override
  String get catSalary => 'Зарплата';

  @override
  String get catShopping => 'Покупки';

  @override
  String get catTransport => 'Транспорт';

  @override
  String get catTravel => 'Путешествия';

  @override
  String get catUtilities => 'Коммунальные';

  @override
  String get categories => 'Категории';

  @override
  String categoriesSelected(int count) {
    return 'Категорий: $count';
  }

  @override
  String get category => 'Категория';

  @override
  String get categoryDeleted => 'Категория удалена';

  @override
  String get categoryDistribution => 'Распределение по категориям';

  @override
  String get categoryLimits => 'Лимиты по категориям';

  @override
  String get clear => 'Очистить';

  @override
  String get clearConversation => 'Очистить переписку';

  @override
  String get clearConversationBody =>
      'Все сообщения будут удалены с устройства.';

  @override
  String get close => 'Закрыть';

  @override
  String get cloudBackup => 'Облачная копия';

  @override
  String get cloudBackupDone => 'Облачная копия создана';

  @override
  String get cloudConsent => 'Я согласен хранить копию в облаке';

  @override
  String get cloudDeleted => 'Облачная копия удалена';

  @override
  String get cloudExplain =>
      'Хранит копию данных в Firebase (передача по шифрованному каналу) под анонимным идентификатором этой установки. После удаления приложения доступ к копии будет потерян — храните также файл копии.';

  @override
  String get cloudNotConfigured =>
      'Облачное копирование не настроено в этой сборке. Всё остальное работает офлайн; используйте файл копии.';

  @override
  String get color => 'Цвет';

  @override
  String get completed => 'Завершено';

  @override
  String get completedGoals => 'Выполненные';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get conversionPolicy =>
      'Политика конвертации: UZS и USD никогда не складываются напрямую. Каждая операция пересчитывается по последнему курсу, действовавшему на её дату; если операция раньше всех курсов — по самому раннему. Баланс пересчитывается по последнему курсу. Без курса суммы показываются по валютам.';

  @override
  String get conversionPolicyShort =>
      'Каждая операция пересчитана по курсу, действовавшему на её дату (по самому раннему курсу, если раньше всех).';

  @override
  String get created => 'Создано';

  @override
  String get criticalAt => 'Критично при';

  @override
  String get currency => 'Валюта';

  @override
  String get customRange => 'Свой период';

  @override
  String get daily => 'По дням';

  @override
  String get dailySpending => 'Расходы по дням';

  @override
  String get data => 'Данные';

  @override
  String get dataReset => 'Все данные удалены';

  @override
  String get date => 'Дата';

  @override
  String get debt => 'Долг';

  @override
  String get debtAccountingNote =>
      'Долги учитываются отдельно: создание долга и погашения не меняют баланс, доходы и расходы.';

  @override
  String get debtActive => 'Активные';

  @override
  String get debtCompleted => 'Закрытые';

  @override
  String get debtIOwe => 'Я должен';

  @override
  String get debtOverdue => 'Просроченные';

  @override
  String get debtOwedToMe => 'Мне должны';

  @override
  String get debtSaved => 'Долг сохранён';

  @override
  String get debts => 'Долги';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteBudgetBody => 'Ваши операции не будут затронуты.';

  @override
  String get deleteBudgetTitle => 'Удалить бюджет?';

  @override
  String get deleteCategoryBody => 'Эта категория не используется в операциях.';

  @override
  String deleteCategoryInUse(int count) {
    return 'Эту категорию используют операций: $count. Они будут перенесены в «Другое».';
  }

  @override
  String get deleteCategoryTitle => 'Удалить категорию?';

  @override
  String get deleteCloudBody => 'Локальные данные не затрагиваются.';

  @override
  String get deleteCloudCopy => 'Удалить из облака';

  @override
  String get deleteCloudTitle => 'Удалить облачную копию?';

  @override
  String get deleteDebtBody => 'Долг и все погашения будут удалены.';

  @override
  String get deleteDebtTitle => 'Удалить долг?';

  @override
  String get deleteEntryBody => 'Накопленная сумма будет пересчитана.';

  @override
  String get deleteEntryTitle => 'Удалить запись?';

  @override
  String get deleteGoalBody =>
      'Цель и её история будут удалены. Операции не затрагиваются.';

  @override
  String get deleteGoalTitle => 'Удалить цель?';

  @override
  String get deleteRateBody =>
      'Пересчитанные суммы будут обновлены по оставшимся курсам.';

  @override
  String get deleteRateTitle => 'Удалить курс?';

  @override
  String get deleteRecurringBody =>
      'Уже записанные операции сохранятся. Будущие платежи создаваться не будут.';

  @override
  String get deleteRecurringTitle => 'Удалить регулярный платёж?';

  @override
  String get deleteRepaymentBody => 'Остаток долга будет пересчитан.';

  @override
  String get deleteRepaymentTitle => 'Удалить погашение?';

  @override
  String get deleteTransactionBody =>
      'Балансы, бюджеты и статистика будут пересчитаны. Это действие нельзя отменить.';

  @override
  String get deleteTransactionTitle => 'Удалить операцию?';

  @override
  String get description => 'Описание';

  @override
  String get descriptionOptional => 'Описание (необязательно)';

  @override
  String get disclaimerBody =>
      'Подсказки и рекомендации носят информационный характер и не являются профессиональной финансовой консультацией.';

  @override
  String get disclaimerTitle => 'Не является финансовой консультацией';

  @override
  String get displayName => 'Имя';

  @override
  String get displayNameHint => 'Как к вам обращаться?';

  @override
  String get displayNameOptional => 'Ваше имя (необязательно)';

  @override
  String get dueDate => 'Срок';

  @override
  String get dueDateOptional => 'Срок (необязательно)';

  @override
  String dueOn(String date) {
    return 'до $date';
  }

  @override
  String get edit => 'Изменить';

  @override
  String get editBudget => 'Изменить бюджет';

  @override
  String get editCategory => 'Изменить категорию';

  @override
  String get editDebt => 'Изменить долг';

  @override
  String get editGoal => 'Изменить цель';

  @override
  String get editRate => 'Изменить курс';

  @override
  String get editRecurring => 'Изменить платёж';

  @override
  String get editTransaction => 'Изменить операцию';

  @override
  String get effectiveDate => 'Дата начала действия';

  @override
  String effectiveFrom(String date) {
    return 'С $date';
  }

  @override
  String get emptyDebtsBody =>
      'Отслеживайте взятые и выданные в долг деньги и записывайте погашения.';

  @override
  String get emptyDebtsTitle => 'Здесь пусто';

  @override
  String get emptyGoalsBody =>
      'Копите на ноутбук, поездку или резервный фонд? Создайте цель и следите за прогрессом.';

  @override
  String get emptyGoalsTitle => 'Целей пока нет';

  @override
  String get emptyRecurringBody =>
      'Добавьте аренду, подписки, коммунальные или регулярный доход — HisobAI запишет их автоматически в срок.';

  @override
  String get emptyRecurringTitle => 'Регулярных платежей нет';

  @override
  String get emptyStatsBody =>
      'Графики строятся только по вашим записям. Добавьте первую операцию.';

  @override
  String get emptyStatsTitle => 'Здесь появится ваша статистика';

  @override
  String get emptyTransactionsBody =>
      'Добавьте первый доход или расход, чтобы увидеть свой баланс.';

  @override
  String get emptyTransactionsTitle => 'Операций пока нет';

  @override
  String get endDateOptional => 'Дата окончания (необязательно)';

  @override
  String get ended => 'Завершено';

  @override
  String get errorGeneric => 'Попробуйте ещё раз. Ваши данные в безопасности.';

  @override
  String get errorSaving => 'Не удалось сохранить. Попробуйте ещё раз.';

  @override
  String get errorTitle => 'Что-то пошло не так';

  @override
  String get exceededAlwaysNote =>
      'О превышении бюджета (100%) вы получите уведомление всегда.';

  @override
  String get excelContents =>
      'Книга Excel с листами «Сводка», «Операции», «Категории» и «Бюджет».';

  @override
  String get exchangeRates => 'Курсы валют';

  @override
  String get expense => 'Расход';

  @override
  String get expenseOverview => 'Обзор расходов';

  @override
  String get expenses => 'Расходы';

  @override
  String get exportData => 'Экспорт';

  @override
  String get fileBackup => 'Файл резервной копии';

  @override
  String get fileBackupBody =>
      'Экспортируйте всё в JSON-файл, который можно сохранить или перенести на другой телефон, и импортируйте позже.';

  @override
  String get filterByCategory => 'Фильтр по категориям';

  @override
  String get finance => 'Финансы';

  @override
  String get format => 'Формат';

  @override
  String get freqDaily => 'Ежедневно';

  @override
  String get freqMonthly => 'Ежемесячно';

  @override
  String get freqWeekly => 'Еженедельно';

  @override
  String get freqYearly => 'Ежегодно';

  @override
  String get frequency => 'Периодичность';

  @override
  String get fromRecurring => 'Регулярный платёж';

  @override
  String get goal => 'Цель';

  @override
  String get goalCompleted => 'Цель отмечена выполненной';

  @override
  String get goalName => 'Название цели';

  @override
  String get goalNameHint => 'например, Новый ноутбук';

  @override
  String get goalReachedSnack => 'Поздравляем — цель достигнута!';

  @override
  String get goalReopened => 'Цель возобновлена';

  @override
  String get goalSaved => 'Цель сохранена';

  @override
  String get goodAfternoon => 'Добрый день';

  @override
  String get goodEvening => 'Добрый вечер';

  @override
  String get goodMorning => 'Доброе утро';

  @override
  String get guestUser => 'Пользователь HisobAI';

  @override
  String get hideAmounts => 'Скрыть суммы';

  @override
  String get hideAmountsHint => 'Скрывать балансы и суммы на экране';

  @override
  String get highestExpense => 'Самый крупный расход';

  @override
  String get history => 'История';

  @override
  String get icon => 'Иконка';

  @override
  String get importData => 'Импорт из файла';

  @override
  String get income => 'Доходы';

  @override
  String get incomeVsExpenses => 'Доходы и расходы';

  @override
  String get initialBalance => 'Начальный баланс';

  @override
  String get initialBalanceHint =>
      'Деньги, которые были до начала использования HisobAI. Добавляются к балансу, но не считаются доходом.';

  @override
  String get initialBalanceOptional => 'Начальный баланс (необязательно)';

  @override
  String get insights => 'Аналитика';

  @override
  String get insightsNotEnoughData =>
      'Добавьте ещё несколько операций — и здесь появится персональная аналитика.';

  @override
  String get insufficientDataBadge => 'Недостаточно данных';

  @override
  String get invalidBackup => 'Этот файл не является резервной копией HisobAI.';

  @override
  String get language => 'Язык';

  @override
  String get last3Months => 'Последние 3 месяца';

  @override
  String lastBackup(String date) {
    return 'Последняя копия: $date';
  }

  @override
  String get latest => 'Актуальный';

  @override
  String get limit => 'Лимит';

  @override
  String get localDataNote =>
      'Данные хранятся только на этом устройстве, пока вы их не экспортируете. Делайте резервные копии регулярно.';

  @override
  String get localProfileNote => 'Без аккаунта · данные на этом устройстве';

  @override
  String get lowestExpense => 'Самый маленький расход';

  @override
  String get manage => 'Управлять';

  @override
  String get markCompleted => 'Отметить выполненной';

  @override
  String get monthly => 'По месяцам';

  @override
  String get monthlyBudget => 'Месячный бюджет';

  @override
  String get monthlyExpenseTrend => 'Динамика расходов по месяцам';

  @override
  String get monthlyLimit => 'Месячный лимит';

  @override
  String get more => 'Ещё';

  @override
  String get name => 'Название';

  @override
  String get navAdd => 'Добавить операцию';

  @override
  String get navAssistant => 'Ассистент';

  @override
  String get navHome => 'Главная';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navStats => 'Статистика';

  @override
  String get netCashFlow => 'Чистый денежный поток';

  @override
  String get newCategory => 'Новая категория';

  @override
  String get newGoal => 'Новая цель';

  @override
  String get next => 'Далее';

  @override
  String nextDue(String date) {
    return 'Следующий: $date';
  }

  @override
  String get noBudgetBody => 'Задайте лимит, чтобы контролировать месяц';

  @override
  String get noBudgetTitle => 'Бюджет ещё не задан';

  @override
  String get noCategoryLimits =>
      'Лимитов по категориям пока нет. Добавьте, чтобы контролировать отдельные расходы.';

  @override
  String get noCloudBackup => 'Облачная копия не найдена';

  @override
  String get noDataForPeriod => 'За этот период операций нет';

  @override
  String get noDeadline => 'Без срока';

  @override
  String get noEntriesYet => 'Пополнений пока нет.';

  @override
  String get noRateShort => 'нет курса';

  @override
  String get noRatesBody =>
      'Без курса HisobAI показывает суммы в UZS и USD отдельно. Добавьте курс, чтобы видеть общие суммы.';

  @override
  String get noRatesTitle => 'Курсов нет';

  @override
  String get noRepaymentsYet => 'Погашений пока нет.';

  @override
  String get noResultsBody => 'Попробуйте другие слова или фильтры.';

  @override
  String get noResultsTitle => 'Ничего не найдено';

  @override
  String get notFound => 'Не найдено';

  @override
  String get notFoundBody => 'Эта запись больше не существует.';

  @override
  String get notSet => 'Не задано';

  @override
  String get noteOptional => 'Заметка (необязательно)';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationsHint => 'Напоминания о платежах и бюджете';

  @override
  String ofAmount(String amount) {
    return 'из $amount';
  }

  @override
  String get onbBudgetBody =>
      'Задавайте месячные лимиты и получайте предупреждения до перерасхода.';

  @override
  String get onbBudgetTitle => 'Управляйте бюджетом';

  @override
  String get onbGoalsBody =>
      'Копите на важное, учитывайте долги и регулярные платежи — всё в одном месте.';

  @override
  String get onbGoalsTitle => 'Достигайте целей';

  @override
  String get onbNoAccountNote =>
      'Email, телефон или аккаунт не нужны. Данные остаются на этом устройстве.';

  @override
  String get onbSetupBody => 'Всё это можно изменить позже в профиле.';

  @override
  String get onbSetupTitle => 'Давайте настроим';

  @override
  String get onbStart => 'Начать';

  @override
  String get onbUnderstandBody =>
      'Смотрите, куда уходит каждый сум и доллар, — наглядные графики и честная аналитика по вашим записям.';

  @override
  String get onbUnderstandTitle => 'Понимайте свои деньги';

  @override
  String get onbWelcomeBody =>
      'Спокойное и приватное место для ваших финансов. Без регистрации — начните за секунды.';

  @override
  String get onbWelcomeTitle => 'Добро пожаловать в HisobAI';

  @override
  String get openSourceLicenses => 'Лицензии открытого ПО';

  @override
  String get operationFailed => 'Операция не выполнена. Ничего не изменено.';

  @override
  String get original => 'Изначально';

  @override
  String get originalAmount => 'Исходная сумма';

  @override
  String get originalBelowPaid =>
      'Исходная сумма не может быть меньше уже погашенной.';

  @override
  String get overBudget => 'Перерасход';

  @override
  String get overview => 'Обзор';

  @override
  String get paid => 'Оплачено';

  @override
  String get paused => 'Приостановлено';

  @override
  String get payInFull => 'Погасить полностью';

  @override
  String get paymentMethod => 'Способ оплаты';

  @override
  String get pdfContents =>
      'PDF с брендингом: итоги, категории, бюджет и полный список операций.';

  @override
  String perMonthNeeded(String amount) {
    return 'нужно $amount в месяц';
  }

  @override
  String get periodLastMonth => 'в прошлом месяце';

  @override
  String get periodLastMonthTitle => 'Прошлый месяц';

  @override
  String get periodThisMonth => 'в этом месяце';

  @override
  String get periodThisMonthTitle => 'Этот месяц';

  @override
  String get personOrOrganization => 'Человек или организация';

  @override
  String get pmBankTransfer => 'Банковский перевод';

  @override
  String get pmCard => 'Карта';

  @override
  String get pmCash => 'Наличные';

  @override
  String get pmMobileWallet => 'Мобильный кошелёк';

  @override
  String get pmOther => 'Другое';

  @override
  String get preferences => 'Настройки';

  @override
  String get preview => 'Предпросмотр';

  @override
  String get previous => 'Назад';

  @override
  String get primaryCurrency => 'Основная валюта';

  @override
  String get privacyAiBody =>
      'Ассистент — встроенный аналитический модуль на основе правил. Он не подключён к внешнему ИИ и использует только ваши записи.';

  @override
  String get privacyAiTitle => 'Об AI-ассистенте';

  @override
  String get privacyAndAbout => 'Конфиденциальность и о приложении';

  @override
  String get privacyCloudBody =>
      'Облачное копирование выключено по умолчанию и работает, только если сборка подключена к Firebase. При включении создаётся анонимный идентификатор, а копия хранится в закрытой области, доступной только ему.';

  @override
  String get privacyCloudTitle => 'Облачная копия — по желанию';

  @override
  String get privacyLocalBody =>
      'Все записи хранятся в локальной базе на этом телефоне. HisobAI работает полностью офлайн. Локальные данные не копируются автоматически — используйте «Резервная копия».';

  @override
  String get privacyLocalTitle => 'Данные остаются на устройстве';

  @override
  String get privacyNoAccountBody =>
      'HisobAI не запрашивает email, номер телефона, аккаунт Google или Apple.';

  @override
  String get privacyNoAccountTitle => 'Без регистрации';

  @override
  String get privacySecurityBody =>
      'Данные защищены песочницей приложения и шифрованием устройства. Сама база приложения дополнительно не шифруется, а файлы резервных копий — обычный JSON; храните их в надёжном месте. Используйте блокировку экрана.';

  @override
  String get privacySecurityTitle => 'Безопасность';

  @override
  String get progress => 'Прогресс';

  @override
  String get rate => 'Курс';

  @override
  String get rateManualNote =>
      'Курсы вводятся вами; HisobAI не загружает курсы из интернета.';

  @override
  String get recentTransactions => 'Последние операции';

  @override
  String get recordRepayment => 'Записать погашение';

  @override
  String get recurringAutoNote =>
      'Платежи записываются автоматически при открытии приложения — ровно один раз на каждую дату. Напоминания планируются в системе и приходят, даже если приложение закрыто.';

  @override
  String get recurringBackfillNote =>
      'Дата начала в прошлом: платежи с этой даты будут записаны после сохранения.';

  @override
  String get recurringPayments => 'Регулярные платежи';

  @override
  String get recurringSaved => 'Регулярный платёж сохранён';

  @override
  String get recurringTitleHint => 'например, Аренда, Интернет';

  @override
  String get remaining => 'Осталось';

  @override
  String remainingAmount(String amount) {
    return 'Осталось: $amount';
  }

  @override
  String get reminder => 'Напоминание';

  @override
  String reminderBody(String title, String amount) {
    return '$title: сегодня платёж $amount.';
  }

  @override
  String get reminderHint => 'Напомнить в 9:00 в день платежа';

  @override
  String get reminderTitle => 'Платёж сегодня';

  @override
  String get reopenGoal => 'Возобновить цель';

  @override
  String get repaymentRecorded => 'Погашение записано';

  @override
  String get repaymentTooLarge => 'Сумма погашения больше остатка долга.';

  @override
  String get repayments => 'Погашения';

  @override
  String get reportEmptyHint =>
      'Выберите другой период или сначала добавьте операции.';

  @override
  String get reportFailed => 'Не удалось создать отчёт. Попробуйте ещё раз.';

  @override
  String get reportPeriodLabel => 'Период отчёта';

  @override
  String reportSaved(String name) {
    return 'Сохранено: $name';
  }

  @override
  String get reports => 'Отчёты';

  @override
  String get resetData => 'Сбросить все данные';

  @override
  String get resetDataBody =>
      'Все операции, бюджеты, цели, долги, регулярные платежи, курсы, переписка и настройки будут безвозвратно удалены с устройства. Сначала сделайте резервную копию, если данные могут понадобиться.';

  @override
  String get resetDataConfirm => 'Я понимаю, что это нельзя отменить';

  @override
  String get resetDataTitle => 'Удалить все данные?';

  @override
  String get restore => 'Восстановить';

  @override
  String restoreBackupBody(String date, int tx, int goals, int debts) {
    return 'Копия от $date: операций — $tx, целей — $goals, долгов — $debts. Все текущие данные на устройстве будут заменены.';
  }

  @override
  String get restoreBackupTitle => 'Заменить все данные?';

  @override
  String get restoreDone => 'Данные восстановлены';

  @override
  String get rptBudget => 'Бюджет';

  @override
  String get rptBudgetOverview => 'Обзор бюджета';

  @override
  String get rptCategoryBreakdown => 'Категории';

  @override
  String get rptCount => 'Кол-во';

  @override
  String get rptFinancialReport => 'Финансовый отчёт';

  @override
  String get rptGenerated => 'Создан';

  @override
  String get rptMetric => 'Показатель';

  @override
  String get rptPeriod => 'Период отчёта';

  @override
  String get rptRate => 'Курс';

  @override
  String get rptRatesUsed => 'Курсы валют';

  @override
  String get rptReport => 'Отчёт';

  @override
  String get rptShare => 'Доля';

  @override
  String get rptSummary => 'Сводка';

  @override
  String get rptTransactions => 'Операции';

  @override
  String get rptType => 'Тип';

  @override
  String get rptUnconverted => 'Не пересчитано';

  @override
  String get rptUnconvertedNote =>
      'Суммы в других валютах без курса показаны отдельно и не включены в итоги.';

  @override
  String get rptUsed => 'Использовано';

  @override
  String get save => 'Сохранить';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get saveToDevice => 'Сохранить';

  @override
  String get saved => 'Сохранено';

  @override
  String get savingsAccountingNote =>
      'Цели учитывают отложенные деньги. Пополнения и снятия не считаются доходами или расходами.';

  @override
  String get savingsGoals => 'Цели накопления';

  @override
  String get searchTransactions => 'Поиск по названию или заметке';

  @override
  String get send => 'Отправить';

  @override
  String get setBudget => 'Задать бюджет';

  @override
  String get share => 'Поделиться';

  @override
  String get showAmounts => 'Показать суммы';

  @override
  String get skip => 'Пропустить';

  @override
  String get sort => 'Сортировка';

  @override
  String get sortAmountHigh => 'Сумма: по убыванию';

  @override
  String get sortAmountLow => 'Сумма: по возрастанию';

  @override
  String get sortNewest => 'Сначала новые';

  @override
  String get sortOldest => 'Сначала старые';

  @override
  String get source => 'Источник';

  @override
  String get sourceManual => 'Введён вручную';

  @override
  String get spent => 'Потрачено';

  @override
  String get startDate => 'Дата начала';

  @override
  String get statistics => 'Статистика';

  @override
  String get statsMissingRateNote =>
      'Часть операций в другой валюте не учтена, пока вы не добавите курс.';

  @override
  String get target => 'Цель';

  @override
  String get targetAmount => 'Целевая сумма';

  @override
  String get targetDateOptional => 'Срок (необязательно)';

  @override
  String get theme => 'Тема';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeSystem => 'Системная';

  @override
  String get thisMonth => 'Этот месяц';

  @override
  String get thisMonthSuffix => 'за месяц';

  @override
  String get thisYear => 'Этот год';

  @override
  String thresholdsSummary(int warning, int critical) {
    return 'Предупреждать при $warning% и $critical%, а также при превышении';
  }

  @override
  String get title => 'Название';

  @override
  String get titleHintExpense => 'например, Продукты в магазине';

  @override
  String get titleHintIncome => 'например, Зарплата за октябрь';

  @override
  String get today => 'Сегодня';

  @override
  String get total => 'Итого';

  @override
  String get totalBalance => 'Общий баланс';

  @override
  String get totalForPeriod => 'Итого за период';

  @override
  String get totalIOwe => 'Я должен';

  @override
  String get totalMonthlyBudget => 'Общий месячный бюджет';

  @override
  String get totalOwedToMe => 'Мне должны';

  @override
  String get transactionAdded => 'Операция добавлена';

  @override
  String get transactionDeleted => 'Операция удалена';

  @override
  String get transactionDetails => 'Детали операции';

  @override
  String get transactionUpdated => 'Операция обновлена';

  @override
  String get updated => 'Обновлено';

  @override
  String get validationAmountInvalid => 'Введите корректное число';

  @override
  String get validationAmountPositive => 'Сумма должна быть больше нуля';

  @override
  String get validationAmountRequired => 'Введите сумму';

  @override
  String get validationCategoryRequired => 'Выберите категорию';

  @override
  String get validationEndBeforeStart =>
      'Дата окончания не может быть раньше даты начала';

  @override
  String get validationNameRequired => 'Введите название';

  @override
  String get validationTitleRequired => 'Введите название';

  @override
  String get version => 'Версия';

  @override
  String get viewAll => 'Все';

  @override
  String get vsLastMonth => 'к прошлому месяцу';

  @override
  String get warningAt => 'Предупреждение при';

  @override
  String get weekly => 'По неделям';

  @override
  String get weeklyComparison => 'Сравнение по неделям';

  @override
  String get withdraw => 'Снять';

  @override
  String get withdrawTooMuch => 'Нельзя снять больше, чем накоплено.';

  @override
  String get yesterday => 'Вчера';
}
