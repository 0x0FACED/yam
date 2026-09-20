import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_colors.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';

abstract final class AppTheme {
  static final light = _build(
    brightness: Brightness.light,
    scaffoldBackground: AppColors.brandCream,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.brandPurple,
          brightness: Brightness.light,
          primary: AppColors.brandPurple,
          surface: AppColors.lightSurface,
          error: AppColors.lightError,
        ).copyWith(
          onPrimary: Colors.white,
          primaryContainer: AppColors.lightPrimaryContainer,
          onSurface: AppColors.brandInk,
          onSurfaceVariant: AppColors.lightTextSecondary,
          surfaceContainer: AppColors.lightSurfaceSecondary,
          outline: AppColors.lightBorder,
          outlineVariant: AppColors.lightBorder.withValues(alpha: 0.65),
        ),
    semanticColors: const AppSemanticColors(
      protein: AppColors.protein,
      fat: AppColors.fat,
      carbs: AppColors.carbs,
      success: AppColors.lightSuccess,
      warning: AppColors.lightWarning,
      goalWithin: AppColors.lightGoalWithin,
      goalBelow: AppColors.lightGoalBelow,
      goalAbove: AppColors.lightGoalAbove,
    ),
  );

  static final dark = _build(
    brightness: Brightness.dark,
    scaffoldBackground: AppColors.darkBackground,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.brandPurple,
          brightness: Brightness.dark,
          primary: AppColors.darkPrimary,
          surface: AppColors.darkSurface,
          error: AppColors.darkError,
        ).copyWith(
          onPrimary: AppColors.brandInk,
          primaryContainer: AppColors.darkPrimaryContainer,
          onSurface: AppColors.darkTextPrimary,
          onSurfaceVariant: AppColors.darkTextSecondary,
          surfaceContainer: AppColors.darkSurfaceSecondary,
          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkBorder.withValues(alpha: 0.72),
        ),
    semanticColors: const AppSemanticColors(
      protein: AppColors.protein,
      fat: AppColors.fat,
      carbs: AppColors.carbs,
      success: AppColors.darkSuccess,
      warning: AppColors.darkWarning,
      goalWithin: AppColors.darkGoalWithin,
      goalBelow: AppColors.darkGoalBelow,
      goalAbove: AppColors.darkGoalAbove,
    ),
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffoldBackground,
    required ColorScheme colorScheme,
    required AppSemanticColors semanticColors,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: colorScheme,
    );
    final textTheme = AppTypography.build(base.textTheme);
    final navigationLabelStyle = WidgetStateProperty.resolveWith<TextStyle?>(
      (states) => textTheme.labelMedium?.copyWith(
        color: states.contains(WidgetState.selected)
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w700
            : FontWeight.w500,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      extensions: [semanticColors],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainer,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: navigationLabelStyle,
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        focusElevation: 1,
        hoverElevation: 2,
        highlightElevation: 2,
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    );
  }
}
