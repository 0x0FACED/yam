import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/nutrition/yam_progress_bar.dart';
import 'package:yam/features/diary/presentation/diary_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class DailyNutritionSummary extends StatelessWidget {
  const DailyNutritionSummary({required this.day, super.key});

  final DiaryPrototypeDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = AppSemanticColors.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final numbers = NumberFormat.decimalPattern(locale);
    final consumed = numbers.format(day.consumedCalories);
    final target = numbers.format(day.calorieTarget);
    final difference = day.calorieTarget - day.consumedCalories;
    final differenceLabel = difference >= 0
        ? l10n.diaryCaloriesRemaining(numbers.format(difference))
        : l10n.diaryCaloriesOverTarget(numbers.format(-difference));
    final progress = day.calorieTarget == 0
        ? 0.0
        : day.consumedCalories / day.calorieTarget;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
            style: AppTypography.label.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: consumed,
                  style: AppTypography.prominentMetric.copyWith(fontSize: 24),
                ),
                TextSpan(
                  text: ' ${l10n.diaryCalorieGoalSuffix(target)}',
                  style: AppTypography.productTitle.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            differenceLabel,
            style: AppTypography.label.copyWith(
              color: difference >= 0
                  ? theme.colorScheme.primary
                  : semanticColors.warning,
              fontWeight: FontWeight.w700,
              fontFeatures: AppTypography.tabularFigures,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          YamProgressBar(
            height: 8,
            value: progress,
            color: theme.colorScheme.primary,
            trackColor: theme.colorScheme.surfaceContainer,
            semanticValue: '$consumed ${l10n.diaryCalorieGoalSuffix(target)}',
          ),
          const SizedBox(height: AppSpacing.sm),
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
                  color: semanticColors.protein,
                ),
                _MacroProgress(
                  label: l10n.macroFat,
                  consumed: day.fat,
                  target: day.fatTarget,
                  color: semanticColors.fat,
                ),
                _MacroProgress(
                  label: l10n.macroCarbs,
                  consumed: day.carbs,
                  target: day.carbsTarget,
                  color: semanticColors.carbs,
                ),
              ];

              if (vertical) {
                return Column(
                  children: [
                    for (var index = 0; index < macros.length; index++) ...[
                      if (index > 0) const SizedBox(height: AppSpacing.sm),
                      macros[index],
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < macros.length; index++) ...[
                    if (index > 0) const SizedBox(width: AppSpacing.sm),
                    Expanded(child: macros[index]),
                  ],
                ],
              );
            },
          ),
        ],
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
    final value = target == 0 ? 0.0 : consumed / target;
    final progressLabel = l10n.macroGramsProgress(
      numbers.format(consumed),
      numbers.format(target),
    );

    return Semantics(
      container: true,
      label: '$label, $progressLabel',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              progressLabel,
              style: AppTypography.label.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            YamProgressBar(
              height: 5,
              value: value,
              color: color,
              trackColor: color.withValues(alpha: 0.18),
              semanticValue: progressLabel,
            ),
          ],
        ),
      ),
    );
  }
}
