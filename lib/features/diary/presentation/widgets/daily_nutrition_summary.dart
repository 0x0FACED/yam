import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_colors.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/features/diary/presentation/diary_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class DailyNutritionSummary extends StatelessWidget {
  const DailyNutritionSummary({required this.day, super.key});

  final DiaryPrototypeDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final numbers = NumberFormat.decimalPattern(locale);
    final consumed = numbers.format(day.consumedCalories);
    final target = numbers.format(day.calorieTarget);
    final remaining = numbers.format(
      math.max(0, day.calorieTarget - day.consumedCalories),
    );
    final progress = day.calorieTarget == 0
        ? 0.0
        : (day.consumedCalories / day.calorieTarget).clamp(0.0, 1.0);

    return Semantics(
      container: true,
      label: '$consumed ${l10n.diaryCalorieGoalSuffix(target)}',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.diaryConsumed,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: consumed,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  TextSpan(
                    text: ' ${l10n.diaryCalorieGoalSuffix(target)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.diaryCaloriesRemaining(remaining),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress,
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final textNeedsSpace =
                    MediaQuery.textScalerOf(context).scale(16) > 20;
                final vertical = constraints.maxWidth < 300 || textNeedsSpace;
                final macros = [
                  _MacroProgress(
                    label: l10n.macroProtein,
                    consumed: day.protein,
                    target: day.proteinTarget,
                    color: AppColors.protein,
                  ),
                  _MacroProgress(
                    label: l10n.macroFat,
                    consumed: day.fat,
                    target: day.fatTarget,
                    color: AppColors.fat,
                  ),
                  _MacroProgress(
                    label: l10n.macroCarbs,
                    consumed: day.carbs,
                    target: day.carbsTarget,
                    color: AppColors.carbs,
                  ),
                ];

                if (vertical) {
                  return Column(
                    children: [
                      for (var index = 0; index < macros.length; index++) ...[
                        if (index > 0) const SizedBox(height: AppSpacing.md),
                        macros[index],
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < macros.length; index++) ...[
                      if (index > 0) const SizedBox(width: AppSpacing.md),
                      Expanded(child: macros[index]),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroProgress extends StatelessWidget {
  const _MacroProgress({
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
  });

  final String label;
  final int consumed;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final numbers = NumberFormat.decimalPattern(locale);
    final progress = target == 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          l10n.macroGramsProgress(
            numbers.format(consumed),
            numbers.format(target),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            minHeight: 5,
            value: progress,
            color: color,
            backgroundColor: color.withValues(alpha: 0.18),
          ),
        ),
      ],
    );
  }
}
