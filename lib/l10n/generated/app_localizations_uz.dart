// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get about => 'Ilova haqida';

  @override
  String get aboutTagline =>
      'Pulingizni tushuning, tartibga soling va nazorat qiling.';

  @override
  String get active => 'Faol';

  @override
  String get activeHint => 'Faol bo‘lmagan to‘lovlar yozilmaydi';

  @override
  String get addBudget => 'Byudjet qo‘shish';

  @override
  String get addDebt => 'Qarz qo‘shish';

  @override
  String get addMoney => 'Pul qo‘shish';

  @override
  String get addRate => 'Kurs qo‘shish';

  @override
  String get addRecurring => 'Muntazam to‘lov qo‘shish';

  @override
  String get addTransaction => 'Tranzaksiya qo‘shish';

  @override
  String aiBalance(String amount) {
    return 'Joriy balansingiz: $amount.';
  }

  @override
  String aiBalanceSeparate(String list) {
    return 'Valyutalar bo‘yicha balansingiz: $list. Umumiy summani ko‘rish uchun kurs kiriting.';
  }

  @override
  String aiBudgetCritical(String name, String percent, String remaining) {
    return '$name: $percent% ishlatildi, atigi $remaining qoldi.';
  }

  @override
  String aiBudgetExceeded(String name, String percent, String amount) {
    return '$name: $percent% ishlatildi — limitdan $amount ga oshdi.';
  }

  @override
  String aiBudgetOk(
    String name,
    String percent,
    String remaining,
    String daily,
  ) {
    return '$name: byudjet doirasidasiz — $percent% ishlatildi, $remaining qoldi (kuniga taxminan $daily).';
  }

  @override
  String aiBudgetWarning(String name, String percent, String remaining) {
    return '$name: $percent% ishlatildi, $remaining qoldi.';
  }

  @override
  String aiCategoryIncrease(
    String category,
    String percent,
    String current,
    String baseline,
  ) {
    return '«$category» xarajatlari odatdagidan $percent foiz yuqori: hozircha $current, odatda $baseline.';
  }

  @override
  String aiCategorySpend(
    String category,
    String period,
    String amount,
    String percent,
    int count,
  ) {
    return '$period «$category» uchun $amount sarfladingiz — xarajatlarning $percent foizi, yozuvlar soni: $count.';
  }

  @override
  String aiCategorySpendNone(String category, String period) {
    return '$period «$category» bo‘yicha xarajatlar yo‘q.';
  }

  @override
  String aiCompareLess(
    int days,
    String current,
    String percent,
    String previous,
  ) {
    return 'Shu oyning dastlabki $days kunida $current sarfladingiz — bu o‘tgan oyning shu kunlaridagidan ($previous) $percent foiz kam.';
  }

  @override
  String aiCompareMore(
    int days,
    String current,
    String percent,
    String previous,
  ) {
    return 'Shu oyning dastlabki $days kunida $current sarfladingiz — bu o‘tgan oyning shu kunlaridagidan ($previous) $percent foiz ko‘p.';
  }

  @override
  String aiCompareNoPrevExpense(int days, String current) {
    return 'Shu oyning dastlabki $days kunida $current sarfladingiz. O‘tgan oyning shu kunlarida xarajat bo‘lmagan.';
  }

  @override
  String aiCompareSame(int days, String current, String previous) {
    return 'Shu oyning dastlabki $days kunida $current sarfladingiz — o‘tgan oy bilan deyarli bir xil ($previous).';
  }

  @override
  String aiDebtOverdue(int count) {
    return 'Muddati o‘tgan: $count.';
  }

  @override
  String aiDebtOverview(String owe, String owed, int active) {
    return 'Jami qarzingiz: $owe; sizga qarzdorlar: $owed. Ochiq qarzlar soni: $active.';
  }

  @override
  String get aiDisclaimer =>
      'ℹ Bu yozuvlaringiz asosidagi ma’lumot uchun tavsiya, professional moliyaviy maslahat emas.';

  @override
  String get aiError =>
      'Kechirasiz, hozir ma’lumotlarni tahlil qila olmadim. Qaytadan urinib ko‘ring.';

  @override
  String aiGoalMonthly(String amount) {
    return 'Oyiga $amount jamg‘arsangiz, o‘z vaqtida erishasiz.';
  }

  @override
  String aiGoalProgress(String name, String percent, String remaining) {
    return '«$name»: $percent% bajarildi, $remaining qoldi.';
  }

  @override
  String get aiGreeting =>
      'Salom! Xarajatlaringiz, byudjetlar, maqsadlar va qarzlaringizni tahlil qila olaman. Quyidagi savollardan birini sinab ko‘ring.';

  @override
  String get aiHelp =>
      'Quyidagi savollarga javob bera olaman:\n• Pulim eng ko‘p nimaga ketdi?\n• Bu oy ovqatga qancha sarfladim?\n• Qancha jamg‘ardim?\n• O‘tgan oy bilan solishtir\n• Byudjetim qanday?\n• G‘ayrioddiy xarajatlar bormi?\n• Maqsad va qarzlarim qanday?\n• Qanday tejashim mumkin?';

  @override
  String aiLargestExpense(
    String title,
    String amount,
    String date,
    String category,
  ) {
    return 'Eng katta xarajatingiz — «$title»: $amount, $date ($category).';
  }

  @override
  String aiNextCategories(String list) {
    return 'Keyingilari: $list.';
  }

  @override
  String get aiNoBudgets =>
      'Siz hali byudjet belgilamadingiz. «Byudjetlar» bo‘limida oylik limit belgilang, men uni kuzatib boraman.';

  @override
  String get aiNoDebts => 'Sizda qarz yozuvlari yo‘q.';

  @override
  String get aiNoExpenses => 'Bu davr uchun xarajatlar kiritilmagan.';

  @override
  String get aiNoGoals => 'Sizda faol jamg‘arma maqsadlari yo‘q.';

  @override
  String get aiNoIncome => 'Bu davr uchun daromad kiritilmagan.';

  @override
  String get aiNoPreviousMonth =>
      'Oldingi oylar uchun hali ma’lumot yo‘q, shuning uchun solishtira olmayman.';

  @override
  String get aiNoTransactions =>
      'Hozircha ma’lumot yetarli emas. Bir nechta tranzaksiya qo‘shing, shunda xarajatlaringizni tahlil qila olaman.';

  @override
  String get aiNoUnusual =>
      'Bu oyda xarajatlaringizda g‘ayrioddiy o‘sish ko‘rmayapman.';

  @override
  String aiOverspent(String period, String amount) {
    return '$period xarajatlaringiz daromaddan $amount ga oshib ketdi.';
  }

  @override
  String aiPeriodTotal(
    String period,
    String expense,
    String income,
    int count,
  ) {
    return '$period xarajatlar: $expense. Daromad: $income. Yozuvlar soni: $count.';
  }

  @override
  String aiRisingTrend(String category) {
    return '«$category» xarajatlari uch oy ketma-ket o‘smoqda.';
  }

  @override
  String aiSaved(String period, String amount) {
    return '$period daromadlaringiz va xarajatlaringiz orasidagi farq $amount.';
  }

  @override
  String aiSavingsRate(String percent) {
    return 'Bu daromadingizning $percent foizi.';
  }

  @override
  String get aiSuggest1 => 'Bu oyda eng ko‘p pulim nimaga ketdi?';

  @override
  String get aiSuggest2 => 'Bu oy qancha pul jamg‘ardim?';

  @override
  String get aiSuggest3 => 'Qanday qilib pul tejashim mumkin?';

  @override
  String get aiSuggest4 => 'O‘tgan oy bilan solishtir';

  @override
  String get aiSuggest5 => 'Byudjetim qanday?';

  @override
  String get aiSuggest6 => 'G‘ayrioddiy xarajatlar bormi?';

  @override
  String aiSuggestLimit(String category, String average, String suggested) {
    return '«$category» uchun oyiga o‘rtacha $average sarflaysiz. Oyiga $suggested limit belgilash tejashga yordam beradi.';
  }

  @override
  String get aiTipCreateGoal =>
      'Jamg‘arma maqsadini yarating — aniq maqsad bilan jamg‘arish osonroq.';

  @override
  String aiTipIncrease(String text) {
    return 'Bu o‘sishga e’tibor bering: $text';
  }

  @override
  String aiTipKeepSaving(String percent) {
    return 'Shu oyda daromadingizning $percent foizini saqlab qolyapsiz — shunday davom eting.';
  }

  @override
  String get aiTipSaveMore =>
      'Daromadingizning 10 foizidan kamini jamg‘aryapsiz. Daromad tushgan zahoti belgilangan summani maqsadga o‘tkazib ko‘ring.';

  @override
  String aiTipTopCategory(String text) {
    return 'Eng katta kategoriyadan boshlang. $text Unga limit qo‘yish odatda eng katta natija beradi.';
  }

  @override
  String get aiTipsIntro => 'Yozuvlaringizga ko‘ra:';

  @override
  String aiTopCategory(
    String period,
    String category,
    String amount,
    String percent,
  ) {
    return '$period eng ko‘p xarajatingiz «$category» kategoriyasiga to‘g‘ri keldi: $amount, bu umumiy xarajatlarning $percent foizi.';
  }

  @override
  String get aiUnknown =>
      'Savolingizni to‘liq tushunmadim. Xarajat, daromad, jamg‘arma, byudjet, maqsad va qarzlar haqida aytib bera olaman — «Bu oyda eng ko‘p pulim nimaga ketdi?» deb so‘rab ko‘ring.';

  @override
  String get alertThresholds => 'Ogohlantirish chegaralari';

  @override
  String get all => 'Hammasi';

  @override
  String get allCategories => 'Barcha kategoriyalar';

  @override
  String get allExpenses => 'Barcha xarajatlar';

  @override
  String get allTransactions => 'Barcha tranzaksiyalar';

  @override
  String get amount => 'Summa';

  @override
  String get anyDate => 'Istalgan sana';

  @override
  String get appTitle => 'HisobAI';

  @override
  String get appliesTo => 'Qaysi xarajatlarga';

  @override
  String get apply => 'Qo‘llash';

  @override
  String get askAssistant => 'Yordamchidan so‘rash';

  @override
  String get askHint => 'Savol bering…';

  @override
  String get assistantEmptyBody =>
      'Savollarga javob berish va tavsiyalar uchun tranzaksiyalar, byudjetlar, maqsadlar va qarzlaringizni tahlil qilaman.';

  @override
  String get assistantEmptyTitle => 'Moliyangiz haqida so‘rang';

  @override
  String get assistantLocalNote =>
      'Yordamchi to‘liq qurilmangizda, ichki qoidalar asosida ishlaydi. U onlayn sun’iy intellektdan foydalanmaydi va ma’lumotlaringizni hech qayerga yubormaydi.';

  @override
  String get assistantSubtitle => 'Oflayn · yozuvlaringiz asosida';

  @override
  String get assistantTitle => 'AI yordamchi';

  @override
  String get assistantTyping => 'Yordamchi yozmoqda';

  @override
  String availableAmount(String amount) {
    return 'Mavjud: $amount';
  }

  @override
  String get avgDailySpending => 'Kunlik o‘rtacha xarajat';

  @override
  String get backupAndSync => 'Zaxira nusxa';

  @override
  String get backupNow => 'Hozir zaxiralash';

  @override
  String get backupSaved => 'Zaxira nusxa saqlandi';

  @override
  String get backupUnencryptedNote =>
      'Zaxira fayllari shifrlanmagan va moliyaviy yozuvlaringizni o‘z ichiga oladi.';

  @override
  String get balanceSeparateNote =>
      'Valyutalar bo‘yicha ko‘rsatildi — umumlashtirish uchun USD/UZS kursini kiriting';

  @override
  String budgetAlertBody(String name, int percent) {
    return '$name: oylik limitning $percent foizi ishlatildi.';
  }

  @override
  String get budgetAlerts => 'Byudjet ogohlantirishlari';

  @override
  String get budgetExceededTitle => 'Byudjet oshib ketdi';

  @override
  String get budgetExplain =>
      'Oylik byudjet — har oy uchun xarajat limiti. HisobAI uni haqiqiy xarajatlaringiz bilan solishtiradi.';

  @override
  String budgetLevelCritical(int percent) {
    return '$percent% ishlatildi — limitga yaqinlashdingiz';
  }

  @override
  String get budgetLevelExceeded => 'Byudjet oshib ketdi';

  @override
  String budgetLevelWarning(int percent) {
    return '$percent% ishlatildi — xarajatlarga e’tibor bering';
  }

  @override
  String get budgetSaved => 'Byudjet saqlandi';

  @override
  String get budgetStandingNote =>
      'Limit siz uni o‘zgartirmaguningizcha yoki o‘chirmaguningizcha har oy amal qiladi.';

  @override
  String get budgetUnconvertedNote =>
      'Boshqa valyutadagi ayrim xarajatlar hisobga olinmadi — valyuta kursini kiriting.';

  @override
  String get budgetWarningTitle => 'Byudjet ogohlantirishi';

  @override
  String get budgets => 'Byudjetlar';

  @override
  String get builtIn => 'Standart';

  @override
  String byDate(String date) {
    return '$date gacha';
  }

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get catBusiness => 'Biznes';

  @override
  String get catCommunication => 'Aloqa';

  @override
  String get catEducation => 'Ta’lim';

  @override
  String get catEntertainment => 'Ko‘ngilochar';

  @override
  String get catFood => 'Oziq-ovqat';

  @override
  String get catFreelance => 'Frilans';

  @override
  String get catGift => 'Sovg‘a';

  @override
  String get catHealth => 'Salomatlik';

  @override
  String get catHousing => 'Uy-joy';

  @override
  String get catInvestment => 'Investitsiya';

  @override
  String get catOtherExpense => 'Boshqa';

  @override
  String get catOtherIncome => 'Boshqa';

  @override
  String get catPersonalCare => 'Shaxsiy parvarish';

  @override
  String get catSalary => 'Maosh';

  @override
  String get catShopping => 'Xaridlar';

  @override
  String get catTransport => 'Transport';

  @override
  String get catTravel => 'Sayohat';

  @override
  String get catUtilities => 'Kommunal xizmatlar';

  @override
  String get categories => 'Kategoriyalar';

  @override
  String categoriesSelected(int count) {
    return 'Kategoriyalar: $count';
  }

  @override
  String get category => 'Kategoriya';

  @override
  String get categoryDeleted => 'Kategoriya o‘chirildi';

  @override
  String get categoryDistribution => 'Kategoriyalar bo‘yicha taqsimot';

  @override
  String get categoryLimits => 'Kategoriya limitlari';

  @override
  String get clear => 'Tozalash';

  @override
  String get clearConversation => 'Suhbatni tozalash';

  @override
  String get clearConversationBody => 'Barcha xabarlar qurilmadan o‘chiriladi.';

  @override
  String get close => 'Yopish';

  @override
  String get cloudBackup => 'Bulutli zaxira';

  @override
  String get cloudBackupDone => 'Bulutli zaxira bajarildi';

  @override
  String get cloudConsent => 'Nusxani bulutda saqlashga roziman';

  @override
  String get cloudDeleted => 'Bulutli nusxa o‘chirildi';

  @override
  String get cloudExplain =>
      'Ma’lumotlar nusxasini Firebase da (shifrlangan kanal orqali) shu o‘rnatishga bog‘langan anonim identifikator ostida saqlaydi. Ilova o‘chirilsa, nusxaga kirish yo‘qoladi — zaxira faylini ham saqlang.';

  @override
  String get cloudNotConfigured =>
      'Bu versiyada bulutli zaxira sozlanmagan. Qolgan hammasi oflayn ishlaydi; nusxa uchun zaxira faylidan foydalaning.';

  @override
  String get color => 'Rang';

  @override
  String get completed => 'Bajarildi';

  @override
  String get completedGoals => 'Bajarilganlar';

  @override
  String get confirm => 'Tasdiqlash';

  @override
  String get conversionPolicy =>
      'Konvertatsiya qoidasi: UZS va USD hech qachon to‘g‘ridan-to‘g‘ri qo‘shilmaydi. Har bir tranzaksiya o‘z sanasida amalda bo‘lgan so‘nggi kurs bo‘yicha hisoblanadi; agar u barcha kurslardan oldin bo‘lsa — eng birinchi kurs qo‘llanadi. Balans so‘nggi kurs bo‘yicha hisoblanadi. Kurs bo‘lmasa, summalar valyutalar bo‘yicha alohida ko‘rsatiladi.';

  @override
  String get conversionPolicyShort =>
      'Har bir tranzaksiya o‘z sanasidagi kurs bo‘yicha hisoblangan (barcha kurslardan oldin bo‘lsa — eng birinchi kurs).';

  @override
  String get created => 'Yaratilgan';

  @override
  String get criticalAt => 'Jiddiy ogohlantirish';

  @override
  String get currency => 'Valyuta';

  @override
  String get customRange => 'Boshqa davr';

  @override
  String get daily => 'Kunlik';

  @override
  String get dailySpending => 'Kunlik xarajatlar';

  @override
  String get data => 'Ma’lumotlar';

  @override
  String get dataReset => 'Barcha ma’lumotlar o‘chirildi';

  @override
  String get date => 'Sana';

  @override
  String get debt => 'Qarz';

  @override
  String get debtAccountingNote =>
      'Qarzlar alohida hisoblanadi: qarz yaratish yoki to‘lovni yozish balans, daromad va xarajatlarni o‘zgartirmaydi.';

  @override
  String get debtActive => 'Faol';

  @override
  String get debtCompleted => 'Yopilgan';

  @override
  String get debtIOwe => 'Men qarzdorman';

  @override
  String get debtOverdue => 'Muddati o‘tgan';

  @override
  String get debtOwedToMe => 'Menga qarzdor';

  @override
  String get debtSaved => 'Qarz saqlandi';

  @override
  String get debts => 'Qarzlar';

  @override
  String get delete => 'O‘chirish';

  @override
  String get deleteBudgetBody => 'Tranzaksiyalaringizga ta’sir qilmaydi.';

  @override
  String get deleteBudgetTitle => 'Byudjet o‘chirilsinmi?';

  @override
  String get deleteCategoryBody =>
      'Bu kategoriya hech bir tranzaksiyada ishlatilmagan.';

  @override
  String deleteCategoryInUse(int count) {
    return 'Bu kategoriyadan $count ta tranzaksiya foydalanadi. Ular «Boshqa» ga ko‘chiriladi.';
  }

  @override
  String get deleteCategoryTitle => 'Kategoriya o‘chirilsinmi?';

  @override
  String get deleteCloudBody => 'Mahalliy ma’lumotlarga ta’sir qilmaydi.';

  @override
  String get deleteCloudCopy => 'Bulutdan o‘chirish';

  @override
  String get deleteCloudTitle => 'Bulutli nusxa o‘chirilsinmi?';

  @override
  String get deleteDebtBody => 'Qarz va uning barcha to‘lovlari o‘chiriladi.';

  @override
  String get deleteDebtTitle => 'Qarz o‘chirilsinmi?';

  @override
  String get deleteEntryBody => 'Jamg‘arilgan summa qayta hisoblanadi.';

  @override
  String get deleteEntryTitle => 'Yozuv o‘chirilsinmi?';

  @override
  String get deleteGoalBody =>
      'Maqsad va uning tarixi o‘chiriladi. Tranzaksiyalaringizga ta’sir qilmaydi.';

  @override
  String get deleteGoalTitle => 'Maqsad o‘chirilsinmi?';

  @override
  String get deleteRateBody =>
      'Umumiy summalar qolgan kurslar asosida qayta hisoblanadi.';

  @override
  String get deleteRateTitle => 'Kurs o‘chirilsinmi?';

  @override
  String get deleteRecurringBody =>
      'Yozilgan tranzaksiyalar saqlanadi. Kelgusi to‘lovlar yaratilmaydi.';

  @override
  String get deleteRecurringTitle => 'Muntazam to‘lov o‘chirilsinmi?';

  @override
  String get deleteRepaymentBody => 'Qolgan summa qayta hisoblanadi.';

  @override
  String get deleteRepaymentTitle => 'To‘lov o‘chirilsinmi?';

  @override
  String get deleteTransactionBody =>
      'Balans, byudjet va statistika qayta hisoblanadi. Bu amalni ortga qaytarib bo‘lmaydi.';

  @override
  String get deleteTransactionTitle => 'Tranzaksiya o‘chirilsinmi?';

  @override
  String get description => 'Izoh';

  @override
  String get descriptionOptional => 'Izoh (ixtiyoriy)';

  @override
  String get disclaimerBody =>
      'Tahlil va tavsiyalar faqat ma’lumot uchun, professional moliyaviy maslahat emas.';

  @override
  String get disclaimerTitle => 'Moliyaviy maslahat emas';

  @override
  String get displayName => 'Ism';

  @override
  String get displayNameHint => 'Sizga qanday murojaat qilaylik?';

  @override
  String get displayNameOptional => 'Ismingiz (ixtiyoriy)';

  @override
  String get dueDate => 'Muddat';

  @override
  String get dueDateOptional => 'Muddat (ixtiyoriy)';

  @override
  String dueOn(String date) {
    return 'muddati $date';
  }

  @override
  String get edit => 'Tahrirlash';

  @override
  String get editBudget => 'Byudjetni tahrirlash';

  @override
  String get editCategory => 'Kategoriyani tahrirlash';

  @override
  String get editDebt => 'Qarzni tahrirlash';

  @override
  String get editGoal => 'Maqsadni tahrirlash';

  @override
  String get editRate => 'Kursni tahrirlash';

  @override
  String get editRecurring => 'Muntazam to‘lovni tahrirlash';

  @override
  String get editTransaction => 'Tranzaksiyani tahrirlash';

  @override
  String get effectiveDate => 'Amal qilish sanasi';

  @override
  String effectiveFrom(String date) {
    return '$date dan';
  }

  @override
  String get emptyDebtsBody =>
      'Olgan yoki bergan qarzlaringizni kuzating va to‘lovlarni yozib boring.';

  @override
  String get emptyDebtsTitle => 'Bu yerda hech narsa yo‘q';

  @override
  String get emptyGoalsBody =>
      'Noutbuk, sayohat yoki zaxira jamg‘armasi uchun yig‘yapsizmi? Maqsad yarating va har qadamni kuzating.';

  @override
  String get emptyGoalsTitle => 'Hozircha maqsadlar yo‘q';

  @override
  String get emptyRecurringBody =>
      'Ijara, obunalar, kommunal to‘lovlar yoki muntazam daromadni qo‘shing — HisobAI ularni muddati kelganda avtomatik yozib qo‘yadi.';

  @override
  String get emptyRecurringTitle => 'Muntazam to‘lovlar yo‘q';

  @override
  String get emptyStatsBody =>
      'Grafiklar faqat sizning yozuvlaringiz asosida tuziladi. Birinchi tranzaksiyani qo‘shing.';

  @override
  String get emptyStatsTitle => 'Statistikangiz shu yerda paydo bo‘ladi';

  @override
  String get emptyTransactionsBody =>
      'Balansingizni ko‘rish uchun birinchi daromad yoki xarajatingizni kiriting.';

  @override
  String get emptyTransactionsTitle => 'Hozircha tranzaksiyalar yo‘q';

  @override
  String get endDateOptional => 'Tugash sanasi (ixtiyoriy)';

  @override
  String get ended => 'Tugagan';

  @override
  String get errorGeneric =>
      'Qaytadan urinib ko‘ring. Ma’lumotlaringiz xavfsiz.';

  @override
  String get errorSaving => 'Saqlab bo‘lmadi. Qaytadan urinib ko‘ring.';

  @override
  String get errorTitle => 'Xatolik yuz berdi';

  @override
  String get exceededAlwaysNote =>
      'Byudjet oshib ketganda (100%) har doim xabar beriladi.';

  @override
  String get excelContents =>
      'Excel fayl: «Umumiy», «Tranzaksiyalar», «Kategoriyalar» va «Byudjet» varaqlari.';

  @override
  String get exchangeRates => 'Valyuta kurslari';

  @override
  String get expense => 'Xarajat';

  @override
  String get expenseOverview => 'Xarajatlar sharhi';

  @override
  String get expenses => 'Xarajatlar';

  @override
  String get exportData => 'Eksport';

  @override
  String get fileBackup => 'Zaxira fayli';

  @override
  String get fileBackupBody =>
      'Hammasini JSON faylga eksport qiling — uni saqlash yoki boshqa telefonga ko‘chirish, keyin import qilish mumkin.';

  @override
  String get filterByCategory => 'Kategoriya bo‘yicha filtr';

  @override
  String get finance => 'Moliya';

  @override
  String get format => 'Format';

  @override
  String get freqDaily => 'Har kuni';

  @override
  String get freqMonthly => 'Har oy';

  @override
  String get freqWeekly => 'Har hafta';

  @override
  String get freqYearly => 'Har yil';

  @override
  String get frequency => 'Davriylik';

  @override
  String get fromRecurring => 'Muntazam to‘lov';

  @override
  String get goal => 'Maqsad';

  @override
  String get goalCompleted => 'Maqsad bajarildi deb belgilandi';

  @override
  String get goalName => 'Maqsad nomi';

  @override
  String get goalNameHint => 'masalan, Yangi noutbuk';

  @override
  String get goalReachedSnack => 'Tabriklaymiz — maqsadingizga erishdingiz!';

  @override
  String get goalReopened => 'Maqsad qayta ochildi';

  @override
  String get goalSaved => 'Maqsad saqlandi';

  @override
  String get goodAfternoon => 'Xayrli kun';

  @override
  String get goodEvening => 'Xayrli kech';

  @override
  String get goodMorning => 'Xayrli tong';

  @override
  String get guestUser => 'HisobAI foydalanuvchisi';

  @override
  String get hideAmounts => 'Summalarni yashirish';

  @override
  String get hideAmountsHint => 'Ekranda balans va summalarni yashirish';

  @override
  String get highestExpense => 'Eng katta xarajat';

  @override
  String get history => 'Tarix';

  @override
  String get icon => 'Belgi';

  @override
  String get importData => 'Fayldan import';

  @override
  String get income => 'Daromad';

  @override
  String get incomeVsExpenses => 'Daromad va xarajatlar';

  @override
  String get initialBalance => 'Boshlang‘ich balans';

  @override
  String get initialBalanceHint =>
      'HisobAI dan foydalanishdan oldin bo‘lgan pul. Balansga qo‘shiladi, lekin daromad hisoblanmaydi.';

  @override
  String get initialBalanceOptional => 'Boshlang‘ich balans (ixtiyoriy)';

  @override
  String get insights => 'Tahlillar';

  @override
  String get insightsNotEnoughData =>
      'Yana bir nechta tranzaksiya qo‘shing — HisobAI shu yerda shaxsiy tahlillarni ko‘rsata boshlaydi.';

  @override
  String get insufficientDataBadge => 'Ma’lumot yetarli emas';

  @override
  String get invalidBackup => 'Bu fayl HisobAI zaxira nusxasi emas.';

  @override
  String get language => 'Til';

  @override
  String get last3Months => 'Oxirgi 3 oy';

  @override
  String lastBackup(String date) {
    return 'Oxirgi zaxira: $date';
  }

  @override
  String get latest => 'Eng so‘nggi';

  @override
  String get limit => 'Limit';

  @override
  String get localDataNote =>
      'Ma’lumotlaringiz eksport qilmaguningizcha faqat shu qurilmada saqlanadi. Muntazam zaxira nusxa oling.';

  @override
  String get localProfileNote => 'Hisobsiz · ma’lumotlar shu qurilmada';

  @override
  String get lowestExpense => 'Eng kichik xarajat';

  @override
  String get manage => 'Boshqarish';

  @override
  String get markCompleted => 'Bajarildi deb belgilash';

  @override
  String get monthly => 'Oylik';

  @override
  String get monthlyBudget => 'Oylik byudjet';

  @override
  String get monthlyExpenseTrend => 'Oylik xarajatlar dinamikasi';

  @override
  String get monthlyLimit => 'Oylik limit';

  @override
  String get more => 'Yana';

  @override
  String get name => 'Nomi';

  @override
  String get navAdd => 'Tranzaksiya qo‘shish';

  @override
  String get navAssistant => 'Yordamchi';

  @override
  String get navHome => 'Asosiy';

  @override
  String get navProfile => 'Profil';

  @override
  String get navStats => 'Statistika';

  @override
  String get netCashFlow => 'Sof pul oqimi';

  @override
  String get newCategory => 'Yangi kategoriya';

  @override
  String get newGoal => 'Yangi maqsad';

  @override
  String get next => 'Keyingi';

  @override
  String nextDue(String date) {
    return 'Keyingisi: $date';
  }

  @override
  String get noBudgetBody =>
      'Oyni nazorat qilish uchun xarajat limitini belgilang';

  @override
  String get noBudgetTitle => 'Oylik byudjet hali belgilanmagan';

  @override
  String get noCategoryLimits =>
      'Hozircha kategoriya limitlari yo‘q. Muayyan xarajatni nazorat qilish uchun qo‘shing.';

  @override
  String get noCloudBackup => 'Bulutli nusxa topilmadi';

  @override
  String get noDataForPeriod => 'Bu davrda tranzaksiyalar yo‘q';

  @override
  String get noDeadline => 'Muddatsiz';

  @override
  String get noEntriesYet => 'Hozircha pul qo‘shilmagan.';

  @override
  String get noRateShort => 'kurs yo‘q';

  @override
  String get noRatesBody =>
      'Kurs bo‘lmasa, HisobAI UZS va USD summalarini alohida ko‘rsatadi. Umumiy summani ko‘rish uchun kurs kiriting.';

  @override
  String get noRatesTitle => 'Valyuta kurslari yo‘q';

  @override
  String get noRepaymentsYet => 'Hozircha to‘lovlar yo‘q.';

  @override
  String get noResultsBody => 'Boshqa so‘z yoki filtrlarni sinab ko‘ring.';

  @override
  String get noResultsTitle => 'Hech narsa topilmadi';

  @override
  String get notFound => 'Topilmadi';

  @override
  String get notFoundBody => 'Bu yozuv endi mavjud emas.';

  @override
  String get notSet => 'Belgilanmagan';

  @override
  String get noteOptional => 'Eslatma (ixtiyoriy)';

  @override
  String get notifications => 'Bildirishnomalar';

  @override
  String get notificationsHint =>
      'To‘lov eslatmalari va byudjet ogohlantirishlari';

  @override
  String ofAmount(String amount) {
    return '$amount dan';
  }

  @override
  String get onbBudgetBody =>
      'Oylik limitlar belgilang va ortiqcha sarflashdan oldin ogohlantirish oling.';

  @override
  String get onbBudgetTitle => 'Byudjetingizni boshqaring';

  @override
  String get onbGoalsBody =>
      'Muhim narsalar uchun jamg‘aring, qarzlar va muntazam to‘lovlarni kuzating — hammasi bir joyda.';

  @override
  String get onbGoalsTitle => 'Maqsadlaringizga erishing';

  @override
  String get onbNoAccountNote =>
      'Email, telefon raqami yoki hisob kerak emas. Ma’lumotlaringiz shu qurilmada qoladi.';

  @override
  String get onbSetupBody =>
      'Bularning barchasini keyinroq Profilda o‘zgartirishingiz mumkin.';

  @override
  String get onbSetupTitle => 'Keling, sozlaymiz';

  @override
  String get onbStart => 'Boshlash';

  @override
  String get onbUnderstandBody =>
      'Har bir so‘m va dollar qayerga ketayotganini aniq grafiklar va yozuvlaringizga asoslangan tahlillar bilan ko‘ring.';

  @override
  String get onbUnderstandTitle => 'Pulingizni tushuning';

  @override
  String get onbWelcomeBody =>
      'Pulingiz uchun qulay va shaxsiy joy. Ro‘yxatdan o‘tishsiz — bir necha soniyada boshlang.';

  @override
  String get onbWelcomeTitle => 'HisobAI ga xush kelibsiz';

  @override
  String get openSourceLicenses => 'Ochiq kodli litsenziyalar';

  @override
  String get operationFailed => 'Amal bajarilmadi. Hech narsa o‘zgarmadi.';

  @override
  String get original => 'Dastlabki';

  @override
  String get originalAmount => 'Dastlabki summa';

  @override
  String get originalBelowPaid =>
      'Dastlabki summa to‘langan summadan kam bo‘lishi mumkin emas.';

  @override
  String get overBudget => 'Limitdan oshdi';

  @override
  String get overview => 'Umumiy ko‘rinish';

  @override
  String get paid => 'To‘langan';

  @override
  String get paused => 'To‘xtatilgan';

  @override
  String get payInFull => 'To‘liq to‘lash';

  @override
  String get paymentMethod => 'To‘lov usuli';

  @override
  String get pdfContents =>
      'Brendli PDF: umumiy natijalar, kategoriyalar, byudjet va barcha tranzaksiyalar ro‘yxati.';

  @override
  String perMonthNeeded(String amount) {
    return 'oyiga $amount kerak';
  }

  @override
  String get periodLastMonth => 'o‘tgan oyda';

  @override
  String get periodLastMonthTitle => 'O‘tgan oy';

  @override
  String get periodThisMonth => 'shu oyda';

  @override
  String get periodThisMonthTitle => 'Shu oy';

  @override
  String get personOrOrganization => 'Shaxs yoki tashkilot';

  @override
  String get pmBankTransfer => 'Bank o‘tkazmasi';

  @override
  String get pmCard => 'Karta';

  @override
  String get pmCash => 'Naqd pul';

  @override
  String get pmMobileWallet => 'Mobil hamyon';

  @override
  String get pmOther => 'Boshqa';

  @override
  String get preferences => 'Sozlamalar';

  @override
  String get preview => 'Ko‘rib chiqish';

  @override
  String get previous => 'Oldingi';

  @override
  String get primaryCurrency => 'Asosiy valyuta';

  @override
  String get privacyAiBody =>
      'Yordamchi — ichki, qoidalarga asoslangan tahlil moduli. U tashqi sun’iy intellekt xizmatiga ulanmagan va faqat siz kiritgan yozuvlardan foydalanadi.';

  @override
  String get privacyAiTitle => 'AI yordamchi haqida';

  @override
  String get privacyAndAbout => 'Maxfiylik va ilova haqida';

  @override
  String get privacyCloudBody =>
      'Bulutli zaxira sukut bo‘yicha o‘chiq va faqat ilova Firebase ga ulangan bo‘lsa ishlaydi. Yoqilganda anonim identifikator yaratiladi va nusxa faqat unga ochiq yopiq joyda saqlanadi.';

  @override
  String get privacyCloudTitle => 'Bulutli zaxira — ixtiyoriy';

  @override
  String get privacyLocalBody =>
      'Barcha yozuvlar shu telefondagi mahalliy bazada saqlanadi. HisobAI to‘liq oflayn ishlaydi. Mahalliy ma’lumotlar avtomatik zaxiralanmaydi — «Zaxira nusxa» orqali nusxa oling.';

  @override
  String get privacyLocalTitle => 'Ma’lumotlaringiz qurilmangizda qoladi';

  @override
  String get privacyNoAccountBody =>
      'HisobAI email, telefon raqami, Google yoki Apple hisobini so‘ramaydi.';

  @override
  String get privacyNoAccountTitle => 'Ro‘yxatdan o‘tishsiz';

  @override
  String get privacySecurityBody =>
      'Ma’lumotlar ilova izolyatsiyasi va qurilma shifrlashi bilan himoyalangan. Ilova bazasi qo‘shimcha shifrlanmaydi, zaxira fayllari oddiy JSON — ularni xavfsiz joyda saqlang. Qurilmada ekran qulfidan foydalaning.';

  @override
  String get privacySecurityTitle => 'Xavfsizlik';

  @override
  String get progress => 'Jarayon';

  @override
  String get rate => 'Kurs';

  @override
  String get rateManualNote =>
      'Kurslarni o‘zingiz kiritasiz; HisobAI kurslarni internetdan yuklamaydi.';

  @override
  String get recentTransactions => 'So‘nggi tranzaksiyalar';

  @override
  String get recordRepayment => 'To‘lovni yozish';

  @override
  String get recurringAutoNote =>
      'Muddati kelgan to‘lovlar ilova ochilganda avtomatik yoziladi — har bir sana uchun faqat bir marta. Eslatmalar telefoningizda rejalashtiriladi va ilova yopiq bo‘lsa ham keladi.';

  @override
  String get recurringBackfillNote =>
      'Boshlanish sanasi o‘tgan kunda: saqlaganingizda shu sanadan beri bo‘lgan to‘lovlar yoziladi.';

  @override
  String get recurringPayments => 'Muntazam to‘lovlar';

  @override
  String get recurringSaved => 'Muntazam to‘lov saqlandi';

  @override
  String get recurringTitleHint => 'masalan, Ijara, Internet';

  @override
  String get remaining => 'Qoldi';

  @override
  String remainingAmount(String amount) {
    return 'Qoldi: $amount';
  }

  @override
  String get reminder => 'Eslatma';

  @override
  String reminderBody(String title, String amount) {
    return '$title: bugun $amount to‘lov kuni.';
  }

  @override
  String get reminderHint => 'To‘lov kuni soat 9:00 da eslatish';

  @override
  String get reminderTitle => 'Bugun to‘lov kuni';

  @override
  String get reopenGoal => 'Maqsadni qayta ochish';

  @override
  String get repaymentRecorded => 'To‘lov yozildi';

  @override
  String get repaymentTooLarge => 'To‘lov qolgan summadan katta.';

  @override
  String get repayments => 'To‘lovlar';

  @override
  String get reportEmptyHint =>
      'Boshqa davrni tanlang yoki avval tranzaksiya qo‘shing.';

  @override
  String get reportFailed => 'Hisobot yaratilmadi. Qaytadan urinib ko‘ring.';

  @override
  String get reportPeriodLabel => 'Hisobot davri';

  @override
  String reportSaved(String name) {
    return 'Saqlandi: $name';
  }

  @override
  String get reports => 'Hisobotlar';

  @override
  String get resetData => 'Barcha ma’lumotlarni o‘chirish';

  @override
  String get resetDataBody =>
      'Barcha tranzaksiyalar, byudjetlar, maqsadlar, qarzlar, muntazam to‘lovlar, kurslar, suhbat tarixi va sozlamalar qurilmadan butunlay o‘chiriladi. Kerak bo‘lishi mumkin bo‘lsa, avval zaxira nusxa oling.';

  @override
  String get resetDataConfirm => 'Buni ortga qaytarib bo‘lmasligini tushunaman';

  @override
  String get resetDataTitle => 'Barcha ma’lumotlar o‘chirilsinmi?';

  @override
  String get restore => 'Tiklash';

  @override
  String restoreBackupBody(String date, int tx, int goals, int debts) {
    return '$date dagi nusxa: $tx ta tranzaksiya, $goals ta maqsad, $debts ta qarz. Qurilmadagi barcha joriy ma’lumotlar almashtiriladi.';
  }

  @override
  String get restoreBackupTitle => 'Barcha ma’lumotlar almashtirilsinmi?';

  @override
  String get restoreDone => 'Ma’lumotlar tiklandi';

  @override
  String get rptBudget => 'Byudjet';

  @override
  String get rptBudgetOverview => 'Byudjet sharhi';

  @override
  String get rptCategoryBreakdown => 'Kategoriyalar';

  @override
  String get rptCount => 'Soni';

  @override
  String get rptFinancialReport => 'Moliyaviy hisobot';

  @override
  String get rptGenerated => 'Yaratilgan';

  @override
  String get rptMetric => 'Ko‘rsatkich';

  @override
  String get rptPeriod => 'Hisobot davri';

  @override
  String get rptRate => 'Kurs';

  @override
  String get rptRatesUsed => 'Valyuta kurslari';

  @override
  String get rptReport => 'Hisobot';

  @override
  String get rptShare => 'Ulushi';

  @override
  String get rptSummary => 'Umumiy';

  @override
  String get rptTransactions => 'Tranzaksiyalar';

  @override
  String get rptType => 'Turi';

  @override
  String get rptUnconverted => 'Konvertatsiya qilinmagan';

  @override
  String get rptUnconvertedNote =>
      'Kursi kiritilmagan boshqa valyutadagi summalar alohida ko‘rsatilgan va jamiga qo‘shilmagan.';

  @override
  String get rptUsed => 'Ishlatildi';

  @override
  String get save => 'Saqlash';

  @override
  String get saveChanges => 'O‘zgarishlarni saqlash';

  @override
  String get saveToDevice => 'Saqlash';

  @override
  String get saved => 'Saqlandi';

  @override
  String get savingsAccountingNote =>
      'Maqsadlar chetga qo‘yilgan pulni hisobga oladi. Qo‘shish va yechish daromad yoki xarajat hisoblanmaydi.';

  @override
  String get savingsGoals => 'Jamg‘arma maqsadlari';

  @override
  String get searchTransactions => 'Nomi yoki izoh bo‘yicha qidirish';

  @override
  String get send => 'Yuborish';

  @override
  String get setBudget => 'Byudjet belgilash';

  @override
  String get share => 'Ulashish';

  @override
  String get showAmounts => 'Summalarni ko‘rsatish';

  @override
  String get skip => 'O‘tkazib yuborish';

  @override
  String get sort => 'Saralash';

  @override
  String get sortAmountHigh => 'Summa: kattadan kichikka';

  @override
  String get sortAmountLow => 'Summa: kichikdan kattaga';

  @override
  String get sortNewest => 'Avval yangilari';

  @override
  String get sortOldest => 'Avval eskilari';

  @override
  String get source => 'Manba';

  @override
  String get sourceManual => 'Qo‘lda kiritilgan';

  @override
  String get spent => 'Sarflandi';

  @override
  String get startDate => 'Boshlanish sanasi';

  @override
  String get statistics => 'Statistika';

  @override
  String get statsMissingRateNote =>
      'Boshqa valyutadagi ayrim tranzaksiyalar kurs kiritilmaguncha hisobga olinmaydi.';

  @override
  String get target => 'Maqsad';

  @override
  String get targetAmount => 'Maqsad summasi';

  @override
  String get targetDateOptional => 'Muddat (ixtiyoriy)';

  @override
  String get theme => 'Mavzu';

  @override
  String get themeDark => 'Qorong‘i';

  @override
  String get themeLight => 'Yorug‘';

  @override
  String get themeSystem => 'Tizim';

  @override
  String get thisMonth => 'Shu oy';

  @override
  String get thisMonthSuffix => 'shu oyda';

  @override
  String get thisYear => 'Shu yil';

  @override
  String thresholdsSummary(int warning, int critical) {
    return '$warning% va $critical% da hamda limitdan oshganda ogohlantirish';
  }

  @override
  String get title => 'Nomi';

  @override
  String get titleHintExpense => 'masalan, Korzinkadan xarid';

  @override
  String get titleHintIncome => 'masalan, Oktabr maoshi';

  @override
  String get today => 'Bugun';

  @override
  String get total => 'Jami';

  @override
  String get totalBalance => 'Umumiy balans';

  @override
  String get totalForPeriod => 'Davr uchun jami';

  @override
  String get totalIOwe => 'Mening qarzim';

  @override
  String get totalMonthlyBudget => 'Umumiy oylik byudjet';

  @override
  String get totalOwedToMe => 'Menga qarzlar';

  @override
  String get transactionAdded => 'Tranzaksiya qo‘shildi';

  @override
  String get transactionDeleted => 'Tranzaksiya o‘chirildi';

  @override
  String get transactionDetails => 'Tranzaksiya tafsilotlari';

  @override
  String get transactionUpdated => 'Tranzaksiya yangilandi';

  @override
  String get updated => 'Yangilangan';

  @override
  String get validationAmountInvalid => 'To‘g‘ri son kiriting';

  @override
  String get validationAmountPositive => 'Summa noldan katta bo‘lishi kerak';

  @override
  String get validationAmountRequired => 'Summani kiriting';

  @override
  String get validationCategoryRequired => 'Kategoriyani tanlang';

  @override
  String get validationEndBeforeStart =>
      'Tugash sanasi boshlanish sanasidan oldin bo‘lishi mumkin emas';

  @override
  String get validationNameRequired => 'Nomini kiriting';

  @override
  String get validationTitleRequired => 'Nomini kiriting';

  @override
  String get version => 'Versiya';

  @override
  String get viewAll => 'Hammasi';

  @override
  String get vsLastMonth => 'o‘tgan oyga nisbatan';

  @override
  String get warningAt => 'Ogohlantirish';

  @override
  String get weekly => 'Haftalik';

  @override
  String get weeklyComparison => 'Haftalik taqqoslash';

  @override
  String get withdraw => 'Yechib olish';

  @override
  String get withdrawTooMuch => 'Jamg‘arilgandan ko‘p yechib bo‘lmaydi.';

  @override
  String get yesterday => 'Kecha';
}
