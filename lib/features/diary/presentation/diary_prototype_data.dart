import 'package:flutter/foundation.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

@immutable
class DiaryPrototypeDay {
  const DiaryPrototypeDay({
    required this.calorieTarget,
    required this.protein,
    required this.proteinTarget,
    required this.fat,
    required this.fatTarget,
    required this.carbs,
    required this.carbsTarget,
    required this.meals,
  });

  final int calorieTarget;
  final int protein;
  final int proteinTarget;
  final int fat;
  final int fatTarget;
  final int carbs;
  final int carbsTarget;
  final List<DiaryPrototypeMeal> meals;

  int get consumedCalories =>
      meals.fold(0, (total, meal) => total + meal.calories);
}

@immutable
class DiaryPrototypeMeal {
  const DiaryPrototypeMeal({
    required this.id,
    required this.name,
    required this.entries,
  });

  final String id;
  final String name;
  final List<DiaryPrototypeEntry> entries;

  int get calories => entries.fold(0, (total, entry) => total + entry.calories);
}

@immutable
class DiaryPrototypeEntry {
  const DiaryPrototypeEntry({
    required this.id,
    required this.name,
    required this.quantity,
    required this.calories,
    this.brand,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
  });

  final String id;
  final String name;
  final String? brand;
  final String quantity;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
}

DiaryPrototypeDay buildDiaryPrototypeDay(
  AppLocalizations l10n, {
  required bool includeEntries,
  Map<String, List<DiaryPrototypeEntry>> additionalEntries = const {},
}) {
  final baseEntries = includeEntries
      ? _buildEntries(l10n)
      : const <String, List<DiaryPrototypeEntry>>{};
  final addedEntries = additionalEntries.values.expand((entries) => entries);

  List<DiaryPrototypeEntry> entriesFor(String mealId) {
    return [
      ...(baseEntries[mealId] ?? const []),
      ...(additionalEntries[mealId] ?? const []),
    ];
  }

  return DiaryPrototypeDay(
    calorieTarget: 2200,
    protein:
        (includeEntries ? 126 : 0) +
        addedEntries
            .fold<double>(0, (total, entry) => total + entry.protein)
            .round(),
    proteinTarget: 160,
    fat:
        (includeEntries ? 61 : 0) +
        addedEntries
            .fold<double>(0, (total, entry) => total + entry.fat)
            .round(),
    fatTarget: 75,
    carbs:
        (includeEntries ? 184 : 0) +
        addedEntries
            .fold<double>(0, (total, entry) => total + entry.carbs)
            .round(),
    carbsTarget: 230,
    meals: [
      DiaryPrototypeMeal(
        id: 'breakfast',
        name: l10n.mealBreakfast,
        entries: entriesFor('breakfast'),
      ),
      DiaryPrototypeMeal(
        id: 'lunch',
        name: l10n.mealLunch,
        entries: entriesFor('lunch'),
      ),
      DiaryPrototypeMeal(
        id: 'dinner',
        name: l10n.mealDinner,
        entries: entriesFor('dinner'),
      ),
      DiaryPrototypeMeal(
        id: 'snacks',
        name: l10n.mealSnacks,
        entries: entriesFor('snacks'),
      ),
    ],
  );
}

Map<String, List<DiaryPrototypeEntry>> _buildEntries(AppLocalizations l10n) {
  return {
    'breakfast': [
      DiaryPrototypeEntry(
        id: 'eggs',
        name: l10n.demoEggs,
        quantity: l10n.quantityPieces(3),
        calories: 216,
      ),
      DiaryPrototypeEntry(
        id: 'bread',
        name: l10n.demoBread,
        quantity: l10n.quantityGrams(80),
        calories: 190,
      ),
      DiaryPrototypeEntry(
        id: 'milk',
        name: l10n.demoMilk,
        quantity: l10n.quantityMilliliters(150),
        calories: 76,
      ),
    ],
    'lunch': [
      DiaryPrototypeEntry(
        id: 'chicken',
        name: l10n.demoChickenBreast,
        quantity: l10n.quantityGrams(220),
        calories: 363,
      ),
      DiaryPrototypeEntry(
        id: 'rice',
        name: l10n.demoRice,
        quantity: l10n.quantityGrams(280),
        calories: 348,
      ),
    ],
    'dinner': [
      DiaryPrototypeEntry(
        id: 'cottage-cheese',
        name: l10n.demoCottageCheese,
        quantity: l10n.quantityGrams(180),
        calories: 216,
      ),
      DiaryPrototypeEntry(
        id: 'banana',
        name: l10n.demoBanana,
        quantity: l10n.quantityGrams(160),
        calories: 142,
      ),
      DiaryPrototypeEntry(
        id: 'yogurt',
        name: l10n.demoYogurt,
        quantity: l10n.quantityGrams(140),
        calories: 73,
      ),
    ],
    'snacks': [
      DiaryPrototypeEntry(
        id: 'protein',
        name: l10n.demoProtein,
        brand: 'Neo High Protein',
        quantity: l10n.quantityGrams(30),
        calories: 112,
      ),
      DiaryPrototypeEntry(
        id: 'apple',
        name: l10n.demoApple,
        quantity: l10n.quantityGrams(200),
        calories: 104,
      ),
    ],
  };
}
