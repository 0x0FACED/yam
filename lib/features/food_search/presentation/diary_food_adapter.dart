import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';

DiaryFoodSnapshot diarySnapshotForFood(FoodSearchPrototypeFood food) {
  final massPerReference = food.referenceUnit == FoodSearchPrototypeUnit.pieces
      ? food.gramsPerReferenceUnit
      : null;
  if (food.referenceUnit == FoodSearchPrototypeUnit.pieces &&
      massPerReference == null) {
    throw ArgumentError('A piece needs a mass equivalent');
  }
  final baseUnit = food.referenceUnit == FoodSearchPrototypeUnit.milliliters
      ? DiaryBaseUnit.milliliters
      : DiaryBaseUnit.grams;
  final multiplier = massPerReference ?? 1.0;
  return DiaryFoodSnapshot(
    foodId: food.id,
    name: food.name,
    brand: food.brand,
    baseUnit: baseUnit,
    basisAmount: food.referenceAmount * multiplier,
    nutritionPerBasis: DiaryNutrition(
      kcal: food.nutrition.calories,
      protein: food.nutrition.protein,
      fat: food.nutrition.fat,
      carbs: food.nutrition.carbs,
    ),
    servings: [
      for (final serving in food.servings)
        DiaryServingSnapshot(
          id: serving.id,
          unit: serving.unit.name,
          label: serving.label,
          baseAmount: serving.baseAmount * multiplier,
        ),
    ],
  );
}
