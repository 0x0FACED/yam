import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/data/open_food_facts_client.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';

FoodSearchPrototypeFood adaptRemoteFood(
  OpenFoodFactsProduct product, {
  bool favorite = false,
  double lastAmount = 100,
}) => FoodSearchPrototypeFood(
  id: product.id,
  name: product.name,
  brand: product.brand,
  category: FoodSearchPrototypeCategory.values.byName(product.category),
  referenceAmount: 100,
  referenceUnit: FoodSearchPrototypeUnit.grams,
  nutrition: FoodSearchPrototypeNutrition(
    calories: product.energyKcal,
    protein: product.proteinG,
    fat: product.fatG,
    carbs: product.carbsG,
  ),
  servings: const [
    FoodSearchPrototypeServing(
      id: 'grams',
      unit: FoodSearchPrototypeUnit.grams,
      baseAmount: 1,
      defaultAmount: 100,
      presets: [50, 100, 150, 200],
    ),
  ],
  lastServingId: 'grams',
  lastAmount: lastAmount,
  source: FoodSearchPrototypeSource.openFoodFacts,
  favorite: favorite,
  hasUsualAmount: false,
);

OpenFoodFactsProduct productFromStoredRemoteFood(StoredRemoteFood row) =>
    OpenFoodFactsProduct(
      code: row.sourceCode,
      name: row.name,
      brand: row.brand,
      category: row.category,
      energyKcal: row.energyKcal,
      proteinG: row.proteinG,
      fatG: row.fatG,
      carbsG: row.carbsG,
    );
