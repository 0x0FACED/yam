import 'package:flutter/widgets.dart';

enum FoodSearchPrototypeUnit {
  grams,
  milliliters,
  pieces,
  servings,
  scoops,
  glasses,
}

enum FoodSearchPrototypeSource { localCatalog, userCreated }

enum FoodSearchPrototypeCatalogState { ready, loading, error }

@immutable
class FoodSearchPrototypeNutrition {
  const FoodSearchPrototypeNutrition({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  FoodSearchPrototypeNutrition scale(double factor) {
    return FoodSearchPrototypeNutrition(
      calories: calories * factor,
      protein: protein * factor,
      fat: fat * factor,
      carbs: carbs * factor,
    );
  }
}

@immutable
class FoodSearchPrototypeServing {
  const FoodSearchPrototypeServing({
    required this.id,
    required this.unit,
    required this.baseAmount,
    required this.defaultAmount,
    required this.step,
    required this.presets,
  });

  final String id;
  final FoodSearchPrototypeUnit unit;

  /// Amount in the food's reference unit represented by one selected unit.
  final double baseAmount;
  final double defaultAmount;
  final double step;
  final List<double> presets;
}

@immutable
class FoodSearchPrototypeFood {
  const FoodSearchPrototypeFood({
    required this.id,
    required this.name,
    required this.referenceAmount,
    required this.referenceUnit,
    required this.nutrition,
    required this.servings,
    required this.lastServingId,
    required this.lastAmount,
    required this.frequentMealIds,
    this.brand,
    this.portionDescription,
    this.source = FoodSearchPrototypeSource.localCatalog,
    this.verified = true,
    this.recent = true,
    this.favorite = false,
  });

  final String id;
  final String name;
  final String? brand;
  final String? portionDescription;
  final double referenceAmount;
  final FoodSearchPrototypeUnit referenceUnit;
  final FoodSearchPrototypeNutrition nutrition;
  final List<FoodSearchPrototypeServing> servings;
  final String lastServingId;
  final double lastAmount;
  final Set<String> frequentMealIds;
  final FoodSearchPrototypeSource source;
  final bool verified;
  final bool recent;
  final bool favorite;

  FoodSearchPrototypeServing get lastServing =>
      servings.firstWhere((serving) => serving.id == lastServingId);

  FoodSearchPrototypeNutrition nutritionFor(
    FoodSearchPrototypeServing serving,
    double amount,
  ) {
    final referenceUnits = serving.baseAmount * amount;
    return nutrition.scale(referenceUnits / referenceAmount);
  }
}

@immutable
class FoodSearchPrototypeArguments {
  const FoodSearchPrototypeArguments({
    this.initialMealId,
    this.initialCatalogState = FoodSearchPrototypeCatalogState.ready,
  });

  final String? initialMealId;
  final FoodSearchPrototypeCatalogState initialCatalogState;
}

@immutable
class FoodAddPrototypeResult {
  const FoodAddPrototypeResult({
    required this.foodId,
    required this.name,
    required this.quantityLabel,
    required this.mealId,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.brand,
  });

  final String foodId;
  final String name;
  final String? brand;
  final String quantityLabel;
  final String mealId;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
}

List<FoodSearchPrototypeFood> buildFoodSearchPrototypeFoods(Locale locale) {
  final russian = locale.languageCode == 'ru';

  return [
    FoodSearchPrototypeFood(
      id: 'rolled-oats',
      name: russian ? 'Овсяные хлопья' : 'Rolled oats',
      brand: 'YAM Basics',
      referenceAmount: 100,
      referenceUnit: FoodSearchPrototypeUnit.grams,
      nutrition: const FoodSearchPrototypeNutrition(
        calories: 366,
        protein: 12.3,
        fat: 6.1,
        carbs: 59.5,
      ),
      servings: const [
        FoodSearchPrototypeServing(
          id: 'grams',
          unit: FoodSearchPrototypeUnit.grams,
          baseAmount: 1,
          defaultAmount: 80,
          step: 10,
          presets: [40, 50, 80, 100, 150],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 80,
          defaultAmount: 1,
          step: 0.5,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 80,
      frequentMealIds: {'breakfast'},
      favorite: true,
      recent: false,
    ),
    FoodSearchPrototypeFood(
      id: 'milk-25',
      name: russian ? 'Молоко 2,5%' : 'Milk 2.5%',
      brand: russian ? 'Домик в деревне' : 'Village Dairy',
      referenceAmount: 100,
      referenceUnit: FoodSearchPrototypeUnit.milliliters,
      nutrition: const FoodSearchPrototypeNutrition(
        calories: 52,
        protein: 2.8,
        fat: 2.5,
        carbs: 4.7,
      ),
      servings: const [
        FoodSearchPrototypeServing(
          id: 'milliliters',
          unit: FoodSearchPrototypeUnit.milliliters,
          baseAmount: 1,
          defaultAmount: 150,
          step: 10,
          presets: [100, 150, 200, 250],
        ),
        FoodSearchPrototypeServing(
          id: 'glass',
          unit: FoodSearchPrototypeUnit.glasses,
          baseAmount: 250,
          defaultAmount: 1,
          step: 0.5,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'milliliters',
      lastAmount: 150,
      frequentMealIds: {'breakfast', 'snacks'},
      recent: false,
    ),
    FoodSearchPrototypeFood(
      id: 'whey-protein',
      name: russian ? 'Сывороточный протеин' : 'Whey protein',
      brand: 'Neo High Protein',
      referenceAmount: 30,
      referenceUnit: FoodSearchPrototypeUnit.grams,
      nutrition: const FoodSearchPrototypeNutrition(
        calories: 112,
        protein: 23,
        fat: 1.6,
        carbs: 2.4,
      ),
      servings: const [
        FoodSearchPrototypeServing(
          id: 'grams',
          unit: FoodSearchPrototypeUnit.grams,
          baseAmount: 1,
          defaultAmount: 30,
          step: 10,
          presets: [20, 30, 40, 60],
        ),
        FoodSearchPrototypeServing(
          id: 'scoop',
          unit: FoodSearchPrototypeUnit.scoops,
          baseAmount: 30,
          defaultAmount: 1,
          step: 0.5,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 30,
      frequentMealIds: {'breakfast', 'snacks'},
      favorite: true,
      recent: false,
    ),
    FoodSearchPrototypeFood(
      id: 'banana',
      name: russian ? 'Банан свежий' : 'Fresh banana',
      brand: russian ? 'Базовые продукты' : 'Basic foods',
      portionDescription: russian ? '1 плод без кожуры' : '1 peeled fruit',
      referenceAmount: 100,
      referenceUnit: FoodSearchPrototypeUnit.grams,
      nutrition: const FoodSearchPrototypeNutrition(
        calories: 89,
        protein: 1.1,
        fat: 0.3,
        carbs: 21.8,
      ),
      servings: const [
        FoodSearchPrototypeServing(
          id: 'grams',
          unit: FoodSearchPrototypeUnit.grams,
          baseAmount: 1,
          defaultAmount: 120,
          step: 10,
          presets: [80, 100, 120, 160],
        ),
        FoodSearchPrototypeServing(
          id: 'piece',
          unit: FoodSearchPrototypeUnit.pieces,
          baseAmount: 120,
          defaultAmount: 1,
          step: 1,
          presets: [1, 2, 3],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 120,
      frequentMealIds: const {},
      verified: false,
    ),
    FoodSearchPrototypeFood(
      id: 'chicken-breast',
      name: russian ? 'Куриная грудка' : 'Chicken breast',
      referenceAmount: 100,
      referenceUnit: FoodSearchPrototypeUnit.grams,
      nutrition: const FoodSearchPrototypeNutrition(
        calories: 165,
        protein: 31,
        fat: 3.6,
        carbs: 0,
      ),
      servings: const [
        FoodSearchPrototypeServing(
          id: 'grams',
          unit: FoodSearchPrototypeUnit.grams,
          baseAmount: 1,
          defaultAmount: 220,
          step: 10,
          presets: [100, 150, 200, 250],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 200,
          defaultAmount: 1,
          step: 0.5,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 220,
      frequentMealIds: {'lunch', 'dinner'},
      favorite: true,
      recent: false,
    ),
    FoodSearchPrototypeFood(
      id: 'rice-cooked',
      name: russian ? 'Рис отварной' : 'Cooked rice',
      brand: 'YAM Basics',
      referenceAmount: 100,
      referenceUnit: FoodSearchPrototypeUnit.grams,
      nutrition: const FoodSearchPrototypeNutrition(
        calories: 124,
        protein: 2.7,
        fat: 0.3,
        carbs: 28.2,
      ),
      servings: const [
        FoodSearchPrototypeServing(
          id: 'grams',
          unit: FoodSearchPrototypeUnit.grams,
          baseAmount: 1,
          defaultAmount: 280,
          step: 10,
          presets: [150, 200, 250, 300],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 280,
      frequentMealIds: {'lunch', 'dinner'},
      recent: false,
    ),
    FoodSearchPrototypeFood(
      id: 'cottage-cheese',
      name: russian ? 'Творог 5%' : 'Cottage cheese 5%',
      brand: russian ? 'Простоквашино' : 'Farmhouse',
      referenceAmount: 100,
      referenceUnit: FoodSearchPrototypeUnit.grams,
      nutrition: const FoodSearchPrototypeNutrition(
        calories: 120,
        protein: 17,
        fat: 5,
        carbs: 1.8,
      ),
      servings: const [
        FoodSearchPrototypeServing(
          id: 'grams',
          unit: FoodSearchPrototypeUnit.grams,
          baseAmount: 1,
          defaultAmount: 180,
          step: 10,
          presets: [100, 150, 180, 200],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 180,
          defaultAmount: 1,
          step: 0.5,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 180,
      frequentMealIds: {'dinner'},
      source: FoodSearchPrototypeSource.userCreated,
      verified: false,
      recent: false,
    ),
    FoodSearchPrototypeFood(
      id: 'eggs',
      name: russian ? 'Яйцо куриное С1' : 'Grade A chicken egg',
      brand: russian ? 'Село Зелёное' : 'Green Village',
      portionDescription: russian ? '1 шт. ~ 55 г' : '1 pc ~ 55 g',
      referenceAmount: 1,
      referenceUnit: FoodSearchPrototypeUnit.pieces,
      nutrition: const FoodSearchPrototypeNutrition(
        calories: 78,
        protein: 6.5,
        fat: 5.5,
        carbs: 0.4,
      ),
      servings: const [
        FoodSearchPrototypeServing(
          id: 'pieces',
          unit: FoodSearchPrototypeUnit.pieces,
          baseAmount: 1,
          defaultAmount: 2,
          step: 1,
          presets: [1, 2, 3, 4],
        ),
      ],
      lastServingId: 'pieces',
      lastAmount: 2,
      frequentMealIds: {'breakfast'},
      favorite: true,
      verified: false,
      recent: false,
    ),
    FoodSearchPrototypeFood(
      id: 'wholegrain-bread',
      name: russian ? 'Хлеб цельнозерновой' : 'Wholegrain bread',
      brand: russian ? 'Смак' : 'Smak',
      portionDescription: russian ? '1 ломтик ~ 40 г' : '1 slice ~ 40 g',
      referenceAmount: 100,
      referenceUnit: FoodSearchPrototypeUnit.grams,
      nutrition: const FoodSearchPrototypeNutrition(
        calories: 210,
        protein: 8.5,
        fat: 1.8,
        carbs: 39,
      ),
      servings: const [
        FoodSearchPrototypeServing(
          id: 'grams',
          unit: FoodSearchPrototypeUnit.grams,
          baseAmount: 1,
          defaultAmount: 40,
          step: 10,
          presets: [20, 40, 60, 80],
        ),
        FoodSearchPrototypeServing(
          id: 'piece',
          unit: FoodSearchPrototypeUnit.pieces,
          baseAmount: 40,
          defaultAmount: 1,
          step: 1,
          presets: [1, 2, 3, 4],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 40,
      frequentMealIds: const {},
      verified: false,
    ),
    FoodSearchPrototypeFood(
      id: 'americano',
      name: russian ? 'Кофе американо без сахара' : 'Americano without sugar',
      brand: russian ? 'Напитки' : 'Drinks',
      portionDescription: russian ? 'Чашка 200 мл' : '200 ml cup',
      referenceAmount: 200,
      referenceUnit: FoodSearchPrototypeUnit.milliliters,
      nutrition: const FoodSearchPrototypeNutrition(
        calories: 2,
        protein: 0.2,
        fat: 0,
        carbs: 0.3,
      ),
      servings: const [
        FoodSearchPrototypeServing(
          id: 'milliliters',
          unit: FoodSearchPrototypeUnit.milliliters,
          baseAmount: 1,
          defaultAmount: 200,
          step: 50,
          presets: [100, 150, 200, 250],
        ),
      ],
      lastServingId: 'milliliters',
      lastAmount: 200,
      frequentMealIds: const {},
      verified: false,
    ),
  ];
}
