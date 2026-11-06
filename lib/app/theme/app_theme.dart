import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the Material 3 themes for HisobAI.
abstract final class AppTheme {
  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surface2: AppColors.darkSurface2,
    outline: AppColors.darkOutline,
    primary: AppColors.darkPrimary,
    accent: AppColors.darkAccent,
    text: AppColors.darkText,
    textSecondary: AppColors.darkTextSecondary,
    error: AppColors.darkExpense,
    palette: AppPalette.dark,
  );

  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surface2: AppColors.lightSurface2,
    outline: AppColors.lightOutline,
    primary: AppColors.lightPrimary,
    accent: AppColors.lightAccent,
    text: AppColors.lightText,
    textSecondary: AppColors.lightTextSecondary,
    error: AppColors.lightExpense,
    palette: AppPalette.light,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surface2,
    required Color outline,
    required Color primary,
    required Color accent,
    required Color text,
    required Color textSecondary,
    required Color error,
    required AppPalette palette,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primary.withValues(alpha: isDark ? 0.22 : 0.12),
      onPrimaryContainer: isDark ? text : primary,
      secondary: accent,
      onSecondary: isDark ? AppColors.darkBackground : Colors.white,
      secondaryContainer: accent.withValues(alpha: 0.16),
      onSecondaryContainer: text,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      onSurfaceVariant: textSecondary,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surface2,
      surfaceContainerHighest: surface2,
      outline: outline,
      outlineVariant: outline,
      shadow: Colors.black,
      inverseSurface: isDark ? AppColors.lightSurface : AppColors.darkSurface,
      onInverseSurface: isDark ? AppColors.lightText : AppColors.darkText,
    );
    final textTheme = AppTypography.textTheme(text, textSecondary);
    final fieldBorder = OutlineInputBorder(
      borderRadius: Radii.field,
      borderSide: BorderSide(color: outline),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      extensions: [palette],
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        foregroundColor: text,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.card,
          side: BorderSide(
            color: isDark
                ? outline.withValues(alpha: 0.6)
                : outline.withValues(alpha: 0.7),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2.withValues(alpha: isDark ? 0.6 : 0.7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Insets.lg,
          vertical: 14,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: fieldBorder.copyWith(borderSide: BorderSide(color: error)),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: error, width: 1.6),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        prefixIconColor: textSecondary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(borderRadius: Radii.field),
          textStyle: textTheme.labelLarge,
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const RoundedRectangleBorder(borderRadius: Radii.field),
          side: BorderSide(color: outline),
          foregroundColor: text,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        selectedColor: primary.withValues(alpha: isDark ? 0.28 : 0.16),
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: Radii.chip),
        labelStyle: textTheme.labelMedium?.copyWith(color: text),
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.sm,
          vertical: Insets.xs,
        ),
        showCheckmark: false,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: Radii.field),
          ),
          side: WidgetStatePropertyAll(BorderSide(color: outline)),
          textStyle: WidgetStatePropertyAll(textTheme.labelMedium),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: textSecondary.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Radii.lg)),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? AppColors.darkSurface2
            : AppColors.darkSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkText,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.field),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: Insets.lg),
        shape: const RoundedRectangleBorder(borderRadius: Radii.field),
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? Colors.white : textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : surface2,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surface2,
        circularTrackColor: surface2,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: text,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
