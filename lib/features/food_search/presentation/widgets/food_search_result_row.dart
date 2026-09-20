import 'package:flutter/material.dart';
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
    final macros = l10n.foodSearchMacrosSummary(
      formatFoodSearchNumber(context, food.nutrition.protein),
      formatFoodSearchNumber(context, food.nutrition.fat),
      formatFoodSearchNumber(context, food.nutrition.carbs),
    );
    final source = switch (food.source) {
      FoodSearchPrototypeSource.localCatalog => l10n.foodSearchSourceLocal,
      FoodSearchPrototypeSource.userCreated => l10n.foodSearchSourceUser,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackAction =
            constraints.maxWidth < 420 ||
            MediaQuery.textScalerOf(context).scale(14) > 19;
        final quickAdd = Semantics(
          button: true,
          label: l10n.foodSearchQuickAddSemantics(food.name, lastQuantity),
          excludeSemantics: true,
          child: OutlinedButton(
            key: ValueKey('food-quick-add-${food.id}'),
            onPressed: onQuickAdd,
            child: Text(l10n.foodSearchQuickAdd(lastQuantity)),
          ),
        );

        return Column(
          children: [
            InkWell(
              key: ValueKey('food-result-${food.id}'),
              onTap: onOpen,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      food.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  if (food.verified) ...[
                                    const SizedBox(width: AppSpacing.xs),
                                    Tooltip(
                                      message: l10n.foodSearchVerified,
                                      child: Icon(
                                        Icons.verified_rounded,
                                        size: 18,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (food.brand case final brand?) ...[
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  brand,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!stackAction) ...[
                          const SizedBox(width: AppSpacing.sm),
                          quickAdd,
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.foodSearchCaloriesPerReference(
                        calories,
                        referenceQuantity,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        Text(
                          macros,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          source,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (stackAction) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Align(alignment: Alignment.centerRight, child: quickAdd),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}
