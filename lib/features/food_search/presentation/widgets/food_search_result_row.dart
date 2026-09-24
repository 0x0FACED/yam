import 'package:flutter/material.dart';
import 'package:yam/core/ui/food/yam_product_row.dart';
import 'package:yam/features/food_search/presentation/food_search_format.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class FoodSearchResultRow extends StatelessWidget {
  const FoodSearchResultRow({
    required this.food,
    required this.favorite,
    required this.onOpen,
    super.key,
  });

  final FoodSearchPrototypeFood food;
  final bool favorite;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final referenceQuantity =
        food.referenceDescription ??
        formatFoodSearchQuantity(
          context,
          food.referenceUnit,
          food.referenceAmount,
        );
    return YamProductRow(
      name: food.name,
      metadataLabel: formatFoodSearchMetadata(l10n, food),
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
      favorite: favorite,
      favoriteLabel: l10n.foodSearchFavorites,
      openKey: ValueKey('food-result-${food.id}'),
      onPressed: onOpen,
    );
  }
}
