import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/presentation/diary_food_adapter.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';

void main() {
  test('piece mass is explicit and other foods keep grams and ml separate', () {
    final eggs = buildFoodSearchPrototypeFoods(
      const Locale('en'),
    ).firstWhere((food) => food.id == 'eggs');
    final snapshot = diarySnapshotForFood(eggs);
    expect(snapshot.baseUnit, DiaryBaseUnit.grams);
    expect(snapshot.basisAmount, 55);
    expect(snapshot.serving('pieces').baseAmount, 55);
    expect(snapshot.serving('grams').baseAmount, closeTo(1, 0.0000001));
    expect(snapshot.nutritionFor(110).kcal, 156);

    final milk = buildFoodSearchPrototypeFoods(
      const Locale('en'),
    ).firstWhere((food) => food.id == 'milk-25');
    expect(diarySnapshotForFood(milk).baseUnit, DiaryBaseUnit.milliliters);
  });

  test('validated quantity does not round precision before storage', () {
    final food = DiaryFoodSnapshot(
      foodId: 'sample',
      name: 'Food',
      baseUnit: DiaryBaseUnit.grams,
      basisAmount: 100,
      nutritionPerBasis: const DiaryNutrition(
        kcal: 201.17,
        protein: 12.13,
        fat: 2.4,
        carbs: 28.8,
      ),
      servings: const [
        DiaryServingSnapshot(id: 'g', unit: 'grams', baseAmount: 1),
      ],
    );
    final draft = DiaryEntryDraft(
      day: DateTime(2026, 9, 25),
      mealId: 'lunch',
      food: food,
      servingId: 'g',
      amount: 2.15,
      canonicalQuantity: 2.15,
    );
    draft.validate();
    expect(
      food.nutritionFor(draft.canonicalQuantity).kcal,
      closeTo(4.325155, 0.00000001),
    );
    expect(
      () => DiaryEntryDraft(
        day: draft.day,
        mealId: 'lunch',
        food: food,
        servingId: 'g',
        amount: -1,
        canonicalQuantity: -1,
      ).validate(),
      throwsArgumentError,
    );
  });
}
