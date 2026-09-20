import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
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
              const SizedBox(height: AppSpacing.xs),
              Divider(color: theme.colorScheme.outlineVariant),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final calories = NumberFormat.decimalPattern(locale).format(meal.calories);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      meal.time,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;

    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            meal.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sectionTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              time,
              style: AppTypography.caption.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.mealCalories(calories),
          style: AppTypography.productTitle.copyWith(
            color: theme.colorScheme.onSurface,
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        IconButton.filledTonal(
          tooltip: l10n.diaryAddFoodToMeal(meal.name),
          onPressed: onAddFood,
          iconSize: 18,
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            minimumSize: const Size(44, 44),
            backgroundColor: theme.colorScheme.surfaceContainer,
            foregroundColor: theme.colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );

    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: AppSpacing.xxs),
          Align(alignment: Alignment.centerRight, child: actions),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        const SizedBox(width: AppSpacing.xs),
        actions,
      ],
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final calories = NumberFormat.decimalPattern(locale).format(entry.calories);
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.smallChange;
    final details = [?entry.brand, entry.quantity].join(' · ');

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.name,
          maxLines: largeText ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.productTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          details,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    final energy = Text(
      l10n.mealCalories(calories),
      maxLines: 1,
      style: AppTypography.productTitle.copyWith(
        color: theme.colorScheme.onSurface,
        fontFeatures: AppTypography.tabularFigures,
      ),
    );

    return AnimatedContainer(
      duration: duration,
      curve: AppMotion.standardCurve,
      decoration: BoxDecoration(
        color: highlighted
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: largeText
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        identity,
                        const SizedBox(height: AppSpacing.xxs),
                        Align(alignment: Alignment.centerRight, child: energy),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: identity),
                        const SizedBox(width: AppSpacing.md),
                        energy,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
