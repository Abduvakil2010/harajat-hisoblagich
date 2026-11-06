import 'package:flutter/material.dart';

/// Raw colour tokens of the HisobAI design system.
abstract final class AppColors {
  // Dark
  static const darkBackground = Color(0xFF0B0D12);
  static const darkSurface = Color(0xFF141923);
  static const darkSurface2 = Color(0xFF1C2430);
  static const darkOutline = Color(0xFF262F3D);
  static const darkPrimary = Color(0xFF8B7CFF);
  static const darkAccent = Color(0xFF5DE1B5);
  static const darkText = Color(0xFFF5F6FA);
  static const darkTextSecondary = Color(0xFF929AAA);
  static const darkExpense = Color(0xFFFF647C);
  static const darkIncome = Color(0xFF43D9A3);
  static const darkWarning = Color(0xFFFFC266);

  // Light
  static const lightBackground = Color(0xFFF6F7FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurface2 = Color(0xFFEEF0F6);
  static const lightOutline = Color(0xFFE2E5EE);
  static const lightPrimary = Color(0xFF6957E8);
  static const lightAccent = Color(0xFF16B889);
  static const lightText = Color(0xFF171A25);
  static const lightTextSecondary = Color(0xFF7C8494);
  static const lightExpense = Color(0xFFE84F69);
  static const lightIncome = Color(0xFF149C71);
  static const lightWarning = Color(0xFFE49A1C);

  /// Palette offered for custom categories and goals.
  static const pickerColors = <int>[
    0xFF8B7CFF,
    0xFF5DE1B5,
    0xFF4FC3F7,
    0xFFFF8A65,
    0xFFF06292,
    0xFFFFB74D,
    0xFFBA68C8,
    0xFF7986CB,
    0xFF4DB6AC,
    0xFFE57373,
    0xFFA1887F,
    0xFF90A4AE,
  ];
}

/// Semantic colours not covered by [ColorScheme], available via
/// `Theme.of(context).extension<AppPalette>()!` or `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.income,
    required this.expense,
    required this.warning,
    required this.surface2,
    required this.textSecondary,
    required this.outline,
    required this.accent,
    required this.heroGradient,
  });

  final Color income;
  final Color expense;
  final Color warning;
  final Color surface2;
  final Color textSecondary;
  final Color outline;
  final Color accent;
  final Gradient heroGradient;

  static const dark = AppPalette(
    income: AppColors.darkIncome,
    expense: AppColors.darkExpense,
    warning: AppColors.darkWarning,
    surface2: AppColors.darkSurface2,
    textSecondary: AppColors.darkTextSecondary,
    outline: AppColors.darkOutline,
    accent: AppColors.darkAccent,
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2A2250), Color(0xFF17243A), Color(0xFF12302B)],
      stops: [0, 0.6, 1],
    ),
  );

  static const light = AppPalette(
    income: AppColors.lightIncome,
    expense: AppColors.lightExpense,
    warning: AppColors.lightWarning,
    surface2: AppColors.lightSurface2,
    textSecondary: AppColors.lightTextSecondary,
    outline: AppColors.lightOutline,
    accent: AppColors.lightAccent,
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6957E8), Color(0xFF5546C9), Color(0xFF2E7F9E)],
      stops: [0, 0.55, 1],
    ),
  );

  @override
  AppPalette copyWith({
    Color? income,
    Color? expense,
    Color? warning,
    Color? surface2,
    Color? textSecondary,
    Color? outline,
    Color? accent,
    Gradient? heroGradient,
  }) => AppPalette(
    income: income ?? this.income,
    expense: expense ?? this.expense,
    warning: warning ?? this.warning,
    surface2: surface2 ?? this.surface2,
    textSecondary: textSecondary ?? this.textSecondary,
    outline: outline ?? this.outline,
    accent: accent ?? this.accent,
    heroGradient: heroGradient ?? this.heroGradient,
  );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      heroGradient: Gradient.lerp(heroGradient, other.heroGradient, t)!,
    );
  }
}
