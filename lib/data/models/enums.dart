/// Domain enums. They are persisted by *name* (drift `textEnum`), so values
/// may be reordered safely but must never be renamed without a migration.
library;

enum TransactionType { income, expense }

enum PaymentMethod { cash, card, bankTransfer, mobileWallet, other }

enum RecurrenceFrequency { daily, weekly, monthly, yearly }

/// Direction of a debt record.
/// * [iOwe] – money the user owes someone (a liability).
/// * [owedToMe] – money someone owes the user (a receivable).
enum DebtDirection { iOwe, owedToMe }

enum DebtStatus { active, overdue, completed }

enum ChatRole { user, assistant }

enum AppThemePreference { system, light, dark }
