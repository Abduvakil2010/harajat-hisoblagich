import '../../../data/local/app_database.dart';
import '../../../data/models/enums.dart';

/// What the user is asking about.
enum AssistantIntent {
  greeting,
  help,
  topCategory,
  spentTotal,
  categorySpend,
  savedThisMonth,
  savingTips,
  compareMonths,
  incomeVsExpense,
  budgetStatus,
  goals,
  debts,
  unusualSpending,
  largestExpense,
  balance,
  unknown,
}

enum AskedPeriod { thisMonth, lastMonth }

class ParsedQuestion {
  const ParsedQuestion(
    this.intent, {
    this.period = AskedPeriod.thisMonth,
    this.categoryId,
  });
  final AssistantIntent intent;
  final AskedPeriod period;
  final int? categoryId;
}

/// Keyword-based, multilingual (uz/ru/en) intent recognition. Works offline.
///
/// Matching is done on normalised lowercase text with word *stems*, so
/// inflected forms ("ovqatga", "продуктов", "spending") still match.
class IntentClassifier {
  const IntentClassifier();

  static String normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[ʻʼ‘’`´\']'), '')
      .replaceAll('ё', 'е')
      .replaceAll(RegExp(r'[?!.,;:()"«»]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static bool _any(String text, List<String> stems) => stems.any(text.contains);

  // Keyword stems (apostrophes removed by normalize, so "o'tgan" → "otgan").
  static const _lastMonth = [
    'otgan oy',
    'oldingi oy',
    'last month',
    'previous month',
    'прошл',
    'предыдущ',
  ];
  static const _greeting = [
    'salom',
    'assalom',
    'hello',
    ' hi ',
    ' hey ',
    'привет',
    'здравств',
    'добрый',
  ];
  static const _help = [
    'yordam',
    'nima qila olasan',
    'nimalar',
    'help',
    'what can you',
    'помощ',
    'что ты умеешь',
    'что умеешь',
  ];
  static const _most = [
    'eng kop',
    'eng katta',
    'kop pul',
    'qayerga ketdi',
    'nimaga ketdi',
    'most',
    'biggest',
    'top categ',
    'where did my money',
    'where does my money',
    'больше всего',
    'куда уход',
    'куда ушл',
    'самая больш',
    'самые больш',
  ];
  static const _largestTx = [
    'eng katta xarajat',
    'eng qimmat',
    'largest expense',
    'largest purchase',
    'biggest purchase',
    'biggest expense',
    'самая крупная',
    'самую крупную',
    'самая дорогая',
    'крупнейш',
  ];
  static const _saved = [
    'jamgardim',
    'jamladim',
    'tejadim',
    'qancha qoldi',
    'ortib qoldi',
    'saved',
    'save this month',
    'left over',
    'сэконом',
    'накопил',
    'отлож',
    'осталось',
  ];
  static const _howSave = [
    'qanday qilib',
    'qanday tejash',
    'tejash',
    'maslahat',
    'tavsiya',
    'how can i save',
    'how to save',
    'tips',
    'advice',
    'suggest',
    'recommend',
    'как сэконом',
    'как экономить',
    'совет',
    'рекоменд',
    'как накопить',
  ];
  static const _compare = [
    'otgan oy bilan',
    'solishtir',
    'taqqosla',
    'compare',
    'compared',
    'vs last',
    'сравн',
    'по сравнению',
  ];
  static const _incomeExpense = [
    'daromad va xarajat',
    'daromad',
    'income',
    'earn',
    'доход',
    'заработ',
  ];
  static const _spent = [
    'qancha sarfladim',
    'qancha pul sarf',
    'sarfladim',
    'sarflad',
    'xarajat',
    'how much did i spend',
    'how much have i spent',
    'spent',
    'spend',
    'expenses',
    'сколько потрат',
    'потратил',
    'расход',
    'траты',
  ];
  static const _budget = [
    'byudjet',
    'budjet',
    'limit',
    'budget',
    'бюджет',
    'лимит',
  ];
  static const _goals = [
    'maqsad',
    'jamgarma',
    'goal',
    'savings goal',
    'цель',
    'цели',
    'копилк',
  ];
  static const _debts = [
    'qarz',
    'debt',
    'loan',
    ' owe',
    'долг',
    'заём',
    'заем',
    'кредит',
  ];
  static const _unusual = [
    'gayrioddiy',
    'oshib ketdi',
    'oshdi',
    'kopayd',
    'unusual',
    'increase',
    'spike',
    'grew',
    'rising',
    'необычн',
    'вырос',
    'выросл',
    'увелич',
    'рост',
  ];
  static const _balance = [
    'balans',
    'qancha pulim',
    'hisobimda',
    'balance',
    'how much money do i have',
    'баланс',
    'сколько у меня денег',
    'сколько денег',
  ];

  /// Stems used to recognise built-in categories in questions.
  static const categoryStems = <String, List<String>>{
    'food': [
      'ovqat',
      'oziq',
      'taom',
      'restoran',
      'kafe',
      'food',
      'grocer',
      'restaurant',
      'cafe',
      'еда',
      'еду',
      'продукт',
      'питан',
      'ресторан',
      'кафе',
    ],
    'transport': [
      'transport',
      'taksi',
      'avtobus',
      'metro',
      'benzin',
      'taxi',
      'bus',
      'fuel',
      'gas',
      'транспорт',
      'такси',
      'бензин',
      'проезд',
    ],
    'shopping': [
      'xarid',
      'kiyim',
      'shopping',
      'clothes',
      'покупк',
      'шопинг',
      'одежд',
    ],
    'entertainment': [
      'kongil',
      'kino',
      'entertain',
      'movie',
      'развлеч',
      'кино',
    ],
    'health': [
      'salomat',
      'dori',
      'shifokor',
      'health',
      'medic',
      'doctor',
      'pharma',
      'здоров',
      'лекарств',
      'врач',
      'аптек',
    ],
    'education': [
      'talim',
      'oqish',
      'kurs',
      'education',
      'course',
      'school',
      'tuition',
      'образован',
      'учеб',
    ],
    'housing': [
      'uy-joy',
      'ijara',
      'kvartira',
      'housing',
      ' rent',
      'жиль',
      'аренд',
      'квартир',
    ],
    'utilities': [
      'kommunal',
      'elektr',
      'gaz',
      'suv',
      'utilit',
      'electric',
      'water',
      'коммунал',
      'электр',
    ],
    'communication': [
      'aloqa',
      'internet',
      'telefon',
      'mobil',
      'communication',
      'phone',
      'связь',
      'интернет',
      'телефон',
      'мобил',
    ],
    'travel': [
      'sayohat',
      'safar',
      'travel',
      'trip',
      'flight',
      'путешеств',
      'поездк',
      'отпуск',
    ],
    'personalCare': [
      'shaxsiy',
      'gozallik',
      'personal care',
      'beauty',
      'barber',
      'уход',
      'красот',
      'парикмах',
    ],
  };

  ParsedQuestion parse(String raw, List<CategoryRecord> categories) {
    final t = ' ${normalize(raw)} ';
    final period = _any(t, _lastMonth)
        ? AskedPeriod.lastMonth
        : AskedPeriod.thisMonth;
    final category = _findCategory(t, categories);

    AssistantIntent intent;
    if (_any(t, _howSave)) {
      intent = AssistantIntent.savingTips;
    } else if (_any(t, _compare)) {
      intent = AssistantIntent.compareMonths;
    } else if (_any(t, _largestTx)) {
      intent = AssistantIntent.largestExpense;
    } else if (_any(t, _most)) {
      intent = AssistantIntent.topCategory;
    } else if (_any(t, _unusual)) {
      intent = AssistantIntent.unusualSpending;
    } else if (_any(t, _budget)) {
      intent = AssistantIntent.budgetStatus;
    } else if (_any(t, _debts)) {
      intent = AssistantIntent.debts;
    } else if (_any(t, _goals)) {
      intent = AssistantIntent.goals;
    } else if (_any(t, _saved)) {
      intent = AssistantIntent.savedThisMonth;
    } else if (category != null) {
      intent = AssistantIntent.categorySpend;
    } else if (_any(t, _balance)) {
      intent = AssistantIntent.balance;
    } else if (_any(t, _incomeExpense)) {
      intent = AssistantIntent.incomeVsExpense;
    } else if (_any(t, _spent)) {
      intent = AssistantIntent.spentTotal;
    } else if (_any(t, _help)) {
      intent = AssistantIntent.help;
    } else if (_any(t, _greeting)) {
      intent = AssistantIntent.greeting;
    } else if (_any(t, _lastMonth)) {
      intent = AssistantIntent.spentTotal;
    } else {
      intent = AssistantIntent.unknown;
    }
    return ParsedQuestion(intent, period: period, categoryId: category);
  }

  int? _findCategory(String t, List<CategoryRecord> categories) {
    // Custom category names first (exact user wording).
    for (final c in categories) {
      final name = c.name;
      if (name != null &&
          name.trim().length >= 3 &&
          c.type == TransactionType.expense) {
        if (t.contains(normalize(name))) return c.id;
      }
    }
    for (final entry in categoryStems.entries) {
      if (_any(t, entry.value)) {
        final match = categories.where((c) => c.key == entry.key).firstOrNull;
        if (match != null) return match.id;
      }
    }
    return null;
  }
}
