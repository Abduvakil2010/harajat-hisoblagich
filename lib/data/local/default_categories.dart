import '../models/enums.dart';

/// Seed definition of a built-in category. Built-in categories are identified
/// by a stable [key]; their display name comes from localization.
class DefaultCategory {
  const DefaultCategory(this.key, this.type, this.iconKey, this.color);

  final String key;
  final TransactionType type;
  final String iconKey;
  final int color;
}

const defaultExpenseCategories = <DefaultCategory>[
  DefaultCategory('food', TransactionType.expense, 'restaurant', 0xFFFF8A65),
  DefaultCategory(
    'transport',
    TransactionType.expense,
    'directions_car',
    0xFF4FC3F7,
  ),
  DefaultCategory(
    'shopping',
    TransactionType.expense,
    'shopping_bag',
    0xFFBA68C8,
  ),
  DefaultCategory(
    'entertainment',
    TransactionType.expense,
    'movie',
    0xFFFFB74D,
  ),
  DefaultCategory('health', TransactionType.expense, 'favorite', 0xFFE57373),
  DefaultCategory('education', TransactionType.expense, 'school', 0xFF7986CB),
  DefaultCategory('housing', TransactionType.expense, 'home', 0xFFA1887F),
  DefaultCategory('utilities', TransactionType.expense, 'bolt', 0xFFFFD54F),
  DefaultCategory('communication', TransactionType.expense, 'wifi', 0xFF4DB6AC),
  DefaultCategory('travel', TransactionType.expense, 'flight', 0xFF64B5F6),
  DefaultCategory('personalCare', TransactionType.expense, 'spa', 0xFFF06292),
  DefaultCategory(
    'otherExpense',
    TransactionType.expense,
    'category',
    0xFF90A4AE,
  ),
];

const defaultIncomeCategories = <DefaultCategory>[
  DefaultCategory('salary', TransactionType.income, 'payments', 0xFF43D9A3),
  DefaultCategory('freelance', TransactionType.income, 'laptop', 0xFF4FC3F7),
  DefaultCategory('business', TransactionType.income, 'store', 0xFF8B7CFF),
  DefaultCategory('gift', TransactionType.income, 'redeem', 0xFFF06292),
  DefaultCategory(
    'investment',
    TransactionType.income,
    'trending_up',
    0xFFFFB74D,
  ),
  DefaultCategory(
    'otherIncome',
    TransactionType.income,
    'category',
    0xFF90A4AE,
  ),
];

/// Keys of the fallback categories used when a custom category is deleted.
const fallbackCategoryKey = {
  TransactionType.expense: 'otherExpense',
  TransactionType.income: 'otherIncome',
};
