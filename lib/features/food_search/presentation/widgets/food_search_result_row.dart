import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/features/food_search/presentation/food_search_format.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class FoodSearchResultRow extends StatelessWidget {
  const FoodSearchResultRow({
    required this.food,
    required this.onOpen,
    required this.onQuickAdd,
    super.key,
  });

  final FoodSearchPrototypeFood food;
  final VoidCallback onOpen;
  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lastQuantity = formatFoodSearchQuantity(
      context,
      food.lastServing.unit,
      food.lastAmount,
    );
    final referenceQuantity = formatFoodSearchQuantity(
      context,
      food.referenceUnit,
      food.referenceAmount,
    );
    final calories = formatFoodSearchNumber(context, food.nutrition.calories);
    final semanticColors = AppSemanticColors.of(context);
    final metadata =
        food.brand ??
        switch (food.source) {
          FoodSearchPrototypeSource.localCatalog => l10n.foodSearchSourceLocal,
          FoodSearchPrototypeSource.userCreated => l10n.foodSearchSourceUser,
        };

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackAction =
            constraints.maxWidth < 420 ||
            MediaQuery.textScalerOf(context).scale(14) > 19;
        final quickAddButton = Semantics(
          button: true,
          label: l10n.foodSearchQuickAddSemantics(food.name, lastQuantity),
          excludeSemantics: true,
          child: OutlinedButton(
            key: ValueKey('food-quick-add-${food.id}'),
            onPressed: onQuickAdd,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
              backgroundColor: theme.colorScheme.surfaceContainer,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            child: Text(l10n.foodSearchQuickAdd(lastQuantity)),
          ),
        );

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    child: InkWell(
                      key: ValueKey('food-result-${food.id}'),
                      onTap: onOpen,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.sm,
                          AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    food.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (food.verified) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Tooltip(
                                    message: l10n.foodSearchVerified,
                                    child: Icon(
                                      Icons.verified_rounded,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              metadata,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xxs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  l10n.foodSearchCaloriesPerReference(
                                    calories,
                                    referenceQuantity,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                _MacroValue(
                                  label: l10n.macroProteinShort,
                                  value: formatFoodSearchNumber(
                                    context,
                                    food.nutrition.protein,
                                  ),
                                  color: semanticColors.protein,
                                ),
                                _MacroValue(
                                  label: l10n.macroFatShort,
                                  value: formatFoodSearchNumber(
                                    context,
                                    food.nutrition.fat,
                                  ),
                                  color: semanticColors.fat,
                                ),
                                _MacroValue(
                                  label: l10n.macroCarbsShort,
                                  value: formatFoodSearchNumber(
                                    context,
                                    food.nutrition.carbs,
                                  ),
                                  color: semanticColors.carbs,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (!stackAction)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: quickAddButton,
                  ),
              ],
            ),
            if (stackAction)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: quickAddButton,
                ),
              ),
            const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
          ],
        );
      },
    );
  }
}

class _MacroValue extends StatelessWidget {
  const _MacroValue({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: style?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: value,
            style: style?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
