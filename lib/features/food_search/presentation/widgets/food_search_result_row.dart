import 'package:flutter/material.dart';
import 'package:yam/core/ui/food/yam_product_row.dart';
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
    final sourceLabel =
        food.brand ??
        switch (food.source) {
          FoodSearchPrototypeSource.localCatalog => l10n.foodSearchSourceLocal,
          FoodSearchPrototypeSource.userCreated => l10n.foodSearchSourceUser,
        };

    return YamProductRow(
      name: food.name,
      sourceLabel: sourceLabel,
      portionDescription: food.portionDescription,
      calorieLabel: l10n.foodSearchCaloriesPerReference(
        formatFoodSearchNumber(context, food.nutrition.calories),
        referenceQuantity,
      ),
      proteinLabel: l10n.macroProteinShort,
      proteinValue: formatFoodSearchNumber(context, food.nutrition.protein),
      fatLabel: l10n.macroFatShort,
      fatValue: formatFoodSearchNumber(context, food.nutrition.fat),
      carbsLabel: l10n.macroCarbsShort,
      carbsValue: formatFoodSearchNumber(context, food.nutrition.carbs),
      quickAddLabel: l10n.foodSearchQuickAdd(lastQuantity),
      quickAddSemanticLabel: l10n.foodSearchQuickAddSemantics(
        food.name,
        lastQuantity,
      ),
      verified: food.verified,
      verifiedTooltip: l10n.foodSearchVerified,
      openKey: ValueKey('food-result-${food.id}'),
      quickAddKey: ValueKey('food-quick-add-${food.id}'),
      onPressed: onOpen,
      onQuickAdd: onQuickAdd,
    );
  }
}
