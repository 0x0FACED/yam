import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/features/diary/presentation/diary_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class MealSection extends StatelessWidget {
  const MealSection({
    required this.meal,
    required this.onAddFood,
    this.highlightedEntryId,
    this.highlightedEntryKey,
    super.key,
  });

  final DiaryPrototypeMeal meal;
  final VoidCallback onAddFood;
  final String? highlightedEntryId;
  final GlobalKey? highlightedEntryKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final calories = NumberFormat.decimalPattern(locale).format(meal.calories);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  meal.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                l10n.mealCalories(calories),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                tooltip: l10n.diaryAddFoodToMeal(meal.name),
                onPressed: onAddFood,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const Divider(height: 1),
          if (meal.entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                l10n.diaryNoFoods,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (var index = 0; index < meal.entries.length; index++) ...[
              _FoodEntryRow(
                key: meal.entries[index].id == highlightedEntryId
                    ? highlightedEntryKey
                    : ValueKey(meal.entries[index].id),
                entry: meal.entries[index],
                highlighted: meal.entries[index].id == highlightedEntryId,
              ),
              if (index < meal.entries.length - 1)
                Divider(
                  height: 1,
                  indent: AppSpacing.md,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.65,
                  ),
                ),
            ],
        ],
      ),
    );
  }
}

class _FoodEntryRow extends StatelessWidget {
  const _FoodEntryRow({
    required this.entry,
    required this.highlighted,
    super.key,
  });

  final DiaryPrototypeEntry entry;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final calories = NumberFormat.decimalPattern(locale).format(entry.calories);

    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.smallChange,
      curve: AppMotion.standardCurve,
      decoration: BoxDecoration(
        color: highlighted
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    [?entry.brand, entry.quantity].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              l10n.mealCalories(calories),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
