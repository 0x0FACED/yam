import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

List<FoodSearchPrototypeFood> adaptUserFoods(
  List<SavedUserFood> stored,
  AppLocalizations l10n,
) => [for (final food in stored) adaptUserFood(food, l10n)];

FoodSearchPrototypeFood adaptUserFood(
  SavedUserFood saved,
  AppLocalizations l10n,
) {
  final food = saved.food;
  final mass = food.basisUnit == CustomFoodBasis.grams.name;
  final baseUnit = mass
      ? FoodSearchPrototypeUnit.grams
      : FoodSearchPrototypeUnit.milliliters;
  final baseId = mass ? 'grams' : 'milliliters';
  final portions = [
    for (final serving in saved.servings)
      FoodSearchPrototypeServing(
        id: serving.id,
        unit: switch (CustomServingUnit.values.byName(serving.unit)) {
          CustomServingUnit.serving => FoodSearchPrototypeUnit.servings,
          CustomServingUnit.piece => FoodSearchPrototypeUnit.pieces,
          CustomServingUnit.glass => FoodSearchPrototypeUnit.glasses,
          CustomServingUnit.scoop => FoodSearchPrototypeUnit.scoops,
        },
        label: serving.label,
        baseAmount: serving.baseAmount,
        defaultAmount: serving.defaultAmount,
        presets: [0.5, 1, 1.5, 2],
      ),
  ];
  final primaryServing =
      food.displayBasis == CustomFoodDisplayBasis.perServing.name
      ? [
          for (final serving in portions)
            if (serving.unit == FoodSearchPrototypeUnit.servings &&
                serving.baseAmount == food.basisAmount)
              serving,
        ].firstOrNull
      : null;

  return FoodSearchPrototypeFood(
    id: food.id,
    name: food.name,
    category: food.category,
    brand: food.brand,
    referenceAmount: food.basisAmount,
    referenceUnit: baseUnit,
    referenceDescription: primaryServing == null
        ? null
        : primaryServing.label == null
        ? l10n.quantityServings(1)
        : '1 ${primaryServing.label}',
    nutrition: FoodSearchPrototypeNutrition(
      calories: food.energyKcal,
      protein: food.proteinG,
      fat: food.fatG,
      carbs: food.carbsG,
    ),
    servings: [
      FoodSearchPrototypeServing(
        id: baseId,
        unit: baseUnit,
        baseAmount: 1,
        defaultAmount: food.basisAmount,
        presets: [
          food.basisAmount / 2,
          food.basisAmount,
          food.basisAmount * 1.5,
          food.basisAmount * 2,
        ],
      ),
      ...portions,
    ],
    lastServingId: primaryServing?.id ?? baseId,
    lastAmount: primaryServing == null ? food.basisAmount : 1,
    source: FoodSearchPrototypeSource.userCreated,
    favorite: food.isFavorite,
    hasUsualAmount: false,
  );
}
