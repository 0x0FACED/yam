import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';

void main() {
  test('scales prototype nutrition across equivalent serving units', () {
    final foods = buildFoodSearchPrototypeFoods(const Locale('en'));
    final oats = foods.firstWhere((food) => food.id == 'rolled-oats');
    final grams = oats.servings.firstWhere((serving) => serving.id == 'grams');
    final serving = oats.servings.firstWhere(
      (candidate) => candidate.id == 'serving',
    );

    final fromGrams = oats.nutritionFor(grams, 80);
    final fromServing = oats.nutritionFor(serving, 1);

    expect(fromGrams.calories, closeTo(292.8, 0.001));
    expect(fromServing.calories, closeTo(fromGrams.calories, 0.001));
    expect(fromServing.protein, closeTo(fromGrams.protein, 0.001));
    expect(fromServing.fat, closeTo(fromGrams.fat, 0.001));
    expect(fromServing.carbs, closeTo(fromGrams.carbs, 0.001));
  });

  test('keeps localized prototype food names in the demo catalog', () {
    final english = buildFoodSearchPrototypeFoods(const Locale('en'));
    final russian = buildFoodSearchPrototypeFoods(const Locale('ru'));

    expect(english.first.name, 'Rolled oats');
    expect(russian.first.name, 'Овсяные хлопья');
  });

  test('keeps catalog categories and favorites separate from user foods', () {
    final foods = buildFoodSearchPrototypeFoods(const Locale('en'));

    expect(foods.first.category, FoodSearchPrototypeCategory.grains);
    expect(foods.first.brand, isNull);
    expect(foods.where((food) => food.favorite).map((food) => food.id), [
      'rolled-oats',
      'whey-protein',
      'chicken-breast',
      'eggs',
    ]);
    expect(
      foods.where(
        (food) => food.source == FoodSearchPrototypeSource.userCreated,
      ),
      isEmpty,
    );
  });
}
