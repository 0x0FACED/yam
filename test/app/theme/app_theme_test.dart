import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/theme/app_colors.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_theme.dart';

void main() {
  test('provides canonical typography in both themes', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      expect(theme.textTheme.headlineMedium?.fontSize, 28);
      expect(theme.textTheme.titleLarge?.fontSize, 20);
      expect(theme.textTheme.titleMedium?.fontSize, 16);
      expect(theme.textTheme.bodyMedium?.fontSize, 13);
      expect(theme.textTheme.labelMedium?.fontSize, 12);
      expect(theme.textTheme.bodySmall?.fontSize, 11);
    }
  });

  test('keeps macro semantics fixed and status semantics theme-aware', () {
    final light = AppTheme.light.extension<AppSemanticColors>()!;
    final dark = AppTheme.dark.extension<AppSemanticColors>()!;

    expect(light.protein, AppColors.protein);
    expect(light.fat, AppColors.fat);
    expect(light.carbs, AppColors.carbs);
    expect(dark.protein, AppColors.protein);
    expect(dark.fat, AppColors.fat);
    expect(dark.carbs, AppColors.carbs);
    expect(light.success, isNot(dark.success));
    expect(light.warning, isNot(dark.warning));
  });
}
