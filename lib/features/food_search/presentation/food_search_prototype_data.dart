import 'package:flutter/widgets.dart';

const foodSearchRecentLimit = 4;

enum FoodSearchPrototypeUnit {
  grams,
  milliliters,
  pieces,
  servings,
  scoops,
  glasses,
}

enum FoodSearchPrototypeCategory {
  grains,
  dairy,
  sportsNutrition,
  fruit,
  poultry,
  eggs,
  bread,
  drinks,
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
    required this.presets,
  });

  final String id;
  final FoodSearchPrototypeUnit unit;

  /// Amount in the food's reference unit represented by one selected unit.
  final double baseAmount;
  final double defaultAmount;
  final List<double> presets;
}

@immutable
class FoodSearchPrototypeFood {
  const FoodSearchPrototypeFood({
    required this.id,
    required this.name,
    required this.category,
    required this.referenceAmount,
    required this.referenceUnit,
    required this.nutrition,
    required this.servings,
    required this.lastServingId,
    required this.lastAmount,
    this.brand,
    this.gramsPerReferenceUnit,
    this.source = FoodSearchPrototypeSource.localCatalog,
    this.favorite = false,
  });

  final String id;
  final String name;
  final FoodSearchPrototypeCategory category;
  final String? brand;

  /// Product-specific mass for one reference unit when nutrition is per piece.
  final double? gramsPerReferenceUnit;
  final double referenceAmount;
  final FoodSearchPrototypeUnit referenceUnit;
  final FoodSearchPrototypeNutrition nutrition;
  final List<FoodSearchPrototypeServing> servings;
  final String lastServingId;
  final double lastAmount;
  final FoodSearchPrototypeSource source;
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
    this.recentFoodIds = const [],
    this.favoriteOverrides = const {},
    this.onFoodAdded,
    this.onFavoritesChanged,
  });

  final String? initialMealId;
  final FoodSearchPrototypeCatalogState initialCatalogState;
  final List<String> recentFoodIds;
  final Set<String> favoriteOverrides;
  final VoidCallback Function(FoodAddPrototypeResult result)? onFoodAdded;
  final ValueChanged<Set<String>>? onFavoritesChanged;
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
      category: FoodSearchPrototypeCategory.grains,
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
          presets: [40, 50, 80, 100, 150],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 80,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 80,
      favorite: true,
    ),
    FoodSearchPrototypeFood(
      id: 'milk-25',
      name: russian ? 'Молоко 2,5%' : 'Milk 2.5%',
      category: FoodSearchPrototypeCategory.dairy,
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
          presets: [100, 150, 200, 250],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 150,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
        FoodSearchPrototypeServing(
          id: 'glass',
          unit: FoodSearchPrototypeUnit.glasses,
          baseAmount: 250,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'milliliters',
      lastAmount: 150,
    ),
    FoodSearchPrototypeFood(
      id: 'whey-protein',
      name: russian ? 'Сывороточный протеин' : 'Whey protein',
      category: FoodSearchPrototypeCategory.sportsNutrition,
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
          presets: [20, 30, 40, 60],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 30,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
        FoodSearchPrototypeServing(
          id: 'scoop',
          unit: FoodSearchPrototypeUnit.scoops,
          baseAmount: 30,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 30,
      favorite: true,
    ),
    FoodSearchPrototypeFood(
      id: 'banana',
      name: russian ? 'Банан свежий' : 'Fresh banana',
      category: FoodSearchPrototypeCategory.fruit,
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
          presets: [80, 100, 120, 160],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 120,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
        FoodSearchPrototypeServing(
          id: 'piece',
          unit: FoodSearchPrototypeUnit.pieces,
          baseAmount: 120,
          defaultAmount: 1,
          presets: [1, 2, 3],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 120,
    ),
    FoodSearchPrototypeFood(
      id: 'chicken-breast',
      name: russian ? 'Куриная грудка' : 'Chicken breast',
      category: FoodSearchPrototypeCategory.poultry,
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
          presets: [100, 150, 200, 250],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 200,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 220,
      favorite: true,
    ),
    FoodSearchPrototypeFood(
      id: 'rice-cooked',
      name: russian ? 'Рис отварной' : 'Cooked rice',
      category: FoodSearchPrototypeCategory.grains,
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
          presets: [150, 200, 250, 300],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 280,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 280,
    ),
    FoodSearchPrototypeFood(
      id: 'cottage-cheese',
      name: russian ? 'Творог 5%' : 'Cottage cheese 5%',
      category: FoodSearchPrototypeCategory.dairy,
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
          presets: [100, 150, 180, 200],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 180,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 180,
    ),
    FoodSearchPrototypeFood(
      id: 'eggs',
      name: russian ? 'Яйцо куриное С1' : 'Grade A chicken egg',
      category: FoodSearchPrototypeCategory.eggs,
      brand: russian ? 'Село Зелёное' : 'Green Village',
      gramsPerReferenceUnit: 55,
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
          id: 'grams',
          unit: FoodSearchPrototypeUnit.grams,
          baseAmount: 1 / 55,
          defaultAmount: 110,
          presets: [55, 83, 110, 165],
        ),
        FoodSearchPrototypeServing(
          id: 'pieces',
          unit: FoodSearchPrototypeUnit.pieces,
          baseAmount: 1,
          defaultAmount: 2,
          presets: [1, 2, 3, 4],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 2,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'pieces',
      lastAmount: 2,
      favorite: true,
    ),
    FoodSearchPrototypeFood(
      id: 'wholegrain-bread',
      name: russian ? 'Хлеб цельнозерновой' : 'Wholegrain bread',
      category: FoodSearchPrototypeCategory.bread,
      brand: russian ? 'Смак' : 'Smak',
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
          presets: [20, 40, 60, 80],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 40,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
        FoodSearchPrototypeServing(
          id: 'piece',
          unit: FoodSearchPrototypeUnit.pieces,
          baseAmount: 40,
          defaultAmount: 1,
          presets: [1, 2, 3, 4],
        ),
      ],
      lastServingId: 'grams',
      lastAmount: 40,
    ),
    FoodSearchPrototypeFood(
      id: 'americano',
      name: russian ? 'Кофе американо без сахара' : 'Americano without sugar',
      category: FoodSearchPrototypeCategory.drinks,
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
          presets: [100, 150, 200, 250],
        ),
        FoodSearchPrototypeServing(
          id: 'glass',
          unit: FoodSearchPrototypeUnit.glasses,
          baseAmount: 200,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
        FoodSearchPrototypeServing(
          id: 'serving',
          unit: FoodSearchPrototypeUnit.servings,
          baseAmount: 200,
          defaultAmount: 1,
          presets: [0.5, 1, 1.5, 2],
        ),
      ],
      lastServingId: 'milliliters',
      lastAmount: 200,
    ),
  ];
}
