import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_colors.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.brandCream,
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
          outline: AppColors.lightBorder,
        ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
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
          outline: AppColors.darkBorder,
        ),
  );
}
