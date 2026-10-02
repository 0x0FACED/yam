import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/core/ui/food/yam_product_row.dart';
import 'package:yam/features/food_search/presentation/food_search_format.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

enum _FoodRowAction { edit, delete }

class FoodSearchResultRow extends StatelessWidget {
  const FoodSearchResultRow({
    required this.food,
    required this.favorite,
    required this.onOpen,
    this.onDelete,
    this.onEdit,
    super.key,
  });

  final FoodSearchPrototypeFood food;
  final bool favorite;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

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
    final productRow = YamProductRow(
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
      onLongPress: onDelete,
      longPressLabel: onDelete == null ? null : l10n.createProductDeleteAction,
      showDivider: onEdit == null,
    );
    if (onEdit == null) return productRow;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: productRow),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: PopupMenuButton<_FoodRowAction>(
                key: ValueKey('food-actions-${food.id}'),
                tooltip: l10n.createProductMore,
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (action) {
                  switch (action) {
                    case _FoodRowAction.edit:
                      onEdit!();
                    case _FoodRowAction.delete:
                      onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _FoodRowAction.edit,
                    child: Text(l10n.createProductEdit),
                  ),
                  PopupMenuItem(
                    value: _FoodRowAction.delete,
                    child: Text(l10n.createProductDelete),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }
}
