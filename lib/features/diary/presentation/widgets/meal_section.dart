import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/diary/yam_diary_rows.dart';
import 'package:yam/features/diary/presentation/diary_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class MealSection extends StatelessWidget {
  const MealSection({
    required this.meal,
    required this.onAddFood,
    required this.onEntryPressed,
    this.highlightedEntryId,
    this.highlightedEntryKey,
    super.key,
  });

  final DiaryPrototypeMeal meal;
  final VoidCallback onAddFood;
  final ValueChanged<DiaryPrototypeEntry> onEntryPressed;
  final String? highlightedEntryId;
  final GlobalKey? highlightedEntryKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MealHeader(meal: meal, onAddFood: onAddFood),
              const SizedBox(height: AppSpacing.xxs),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              if (meal.entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    AppLocalizations.of(context).diaryNoFoods,
                    style: AppTypography.body.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (var index = 0; index < meal.entries.length; index++) ...[
                  _DiaryFoodRow(
                    key:
                        meal.entries[index].id == highlightedEntryId &&
                            highlightedEntryKey != null
                        ? highlightedEntryKey
                        : ValueKey(meal.entries[index].id),
                    entry: meal.entries[index],
                    highlighted: meal.entries[index].id == highlightedEntryId,
                    onPressed: () => onEntryPressed(meal.entries[index]),
                  ),
                  if (index < meal.entries.length - 1)
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MealHeader extends StatelessWidget {
  const _MealHeader({required this.meal, required this.onAddFood});

  final DiaryPrototypeMeal meal;
  final VoidCallback onAddFood;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final calories = NumberFormat.decimalPattern(locale).format(meal.calories);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      meal.time,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return YamMealSectionHeader(
      mealName: meal.name,
      timeLabel: time,
      calorieLabel: l10n.mealCalories(calories),
      addTooltip: l10n.diaryAddFoodToMeal(meal.name),
      onAdd: onAddFood,
    );
  }
}

class _DiaryFoodRow extends StatelessWidget {
  const _DiaryFoodRow({
    required this.entry,
    required this.highlighted,
    required this.onPressed,
    super.key,
  });

  final DiaryPrototypeEntry entry;
  final bool highlighted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final calories = NumberFormat.decimalPattern(locale).format(entry.calories);
    final details = [?entry.brand, entry.quantity].join(' · ');

    return YamDiaryFoodRow(
      name: entry.name,
      details: details,
      calorieLabel: l10n.mealCalories(calories),
      highlighted: highlighted,
      onPressed: onPressed,
    );
  }
}
