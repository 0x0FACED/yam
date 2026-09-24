import 'package:flutter/material.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

@immutable
class DiaryPrototypeDay {
  const DiaryPrototypeDay({
    required this.calorieTarget,
    required this.proteinTarget,
    required this.fatTarget,
    required this.carbsTarget,
    required this.meals,
  });

  final int calorieTarget;
  final int proteinTarget;
  final int fatTarget;
  final int carbsTarget;
  final List<DiaryPrototypeMeal> meals;

  int get consumedCalories =>
      meals.fold(0, (total, meal) => total + meal.calories);

  int get protein =>
      meals.fold<double>(0, (total, meal) => total + meal.protein).round();

  int get fat =>
      meals.fold<double>(0, (total, meal) => total + meal.fat).round();

  int get carbs =>
      meals.fold<double>(0, (total, meal) => total + meal.carbs).round();
}

@immutable
class DiaryPrototypeMeal {
  const DiaryPrototypeMeal({
    required this.id,
    required this.name,
    required this.time,
    required this.entries,
  });

  final String id;
  final String name;
  final TimeOfDay time;
  final List<DiaryPrototypeEntry> entries;

  int get calories => entries.fold(0, (total, entry) => total + entry.calories);

  double get protein =>
      entries.fold<double>(0, (total, entry) => total + entry.protein);

  double get fat =>
      entries.fold<double>(0, (total, entry) => total + entry.fat);

  double get carbs =>
      entries.fold<double>(0, (total, entry) => total + entry.carbs);
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
  SessionProfile? profile,
}) {
  final baseEntries = includeEntries
      ? _buildEntries(l10n)
      : const <String, List<DiaryPrototypeEntry>>{};
  List<DiaryPrototypeEntry> entriesFor(String mealId) {
    return [
      ...(baseEntries[mealId] ?? const []),
      ...(additionalEntries[mealId] ?? const []),
    ];
  }

  return DiaryPrototypeDay(
    calorieTarget: profile?.calorieTarget ?? 2200,
    proteinTarget: profile?.proteinTarget ?? 160,
    fatTarget: profile?.fatTarget ?? 75,
    carbsTarget: profile?.carbsTarget ?? 230,
    meals: [
      DiaryPrototypeMeal(
        id: 'breakfast',
        name: l10n.mealBreakfast,
        time: const TimeOfDay(hour: 8, minute: 30),
        entries: entriesFor('breakfast'),
      ),
      DiaryPrototypeMeal(
        id: 'lunch',
        name: l10n.mealLunch,
        time: const TimeOfDay(hour: 13, minute: 15),
        entries: entriesFor('lunch'),
      ),
      DiaryPrototypeMeal(
        id: 'dinner',
        name: l10n.mealDinner,
        time: const TimeOfDay(hour: 19, minute: 20),
        entries: entriesFor('dinner'),
      ),
      DiaryPrototypeMeal(
        id: 'snacks',
        name: l10n.mealSnacks,
        time: const TimeOfDay(hour: 16, minute: 40),
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
        protein: 19,
        fat: 15,
        carbs: 1,
      ),
      DiaryPrototypeEntry(
        id: 'bread',
        name: l10n.demoBread,
        quantity: l10n.quantityGrams(80),
        calories: 190,
        protein: 7,
        fat: 2,
        carbs: 36,
      ),
      DiaryPrototypeEntry(
        id: 'milk',
        name: l10n.demoMilk,
        quantity: l10n.quantityMilliliters(150),
        calories: 76,
        protein: 4,
        fat: 3,
        carbs: 7,
      ),
    ],
    'lunch': [
      DiaryPrototypeEntry(
        id: 'chicken',
        name: l10n.demoChickenBreast,
        quantity: l10n.quantityGrams(180),
        calories: 297,
        protein: 42,
        fat: 5,
      ),
      DiaryPrototypeEntry(
        id: 'buckwheat',
        name: l10n.diaryDemoBuckwheat,
        quantity: l10n.quantityGrams(150),
        calories: 188,
        protein: 6,
        fat: 2,
        carbs: 33,
      ),
      DiaryPrototypeEntry(
        id: 'vegetable-salad',
        name: l10n.diaryDemoVegetableSalad,
        quantity: l10n.quantityGrams(200),
        calories: 110,
        protein: 3,
        fat: 4,
        carbs: 41,
      ),
      DiaryPrototypeEntry(
        id: 'olive-oil',
        name: l10n.diaryDemoOliveOil,
        quantity: l10n.quantityGrams(12),
        calories: 116,
        fat: 12,
      ),
    ],
    'dinner': [
      DiaryPrototypeEntry(
        id: 'salmon',
        name: l10n.diaryDemoSteamedSalmon,
        quantity: l10n.quantityGrams(160),
        calories: 324,
        protein: 30,
        fat: 12,
      ),
      DiaryPrototypeEntry(
        id: 'steamed-vegetables',
        name: l10n.diaryDemoSteamedVegetables,
        quantity: l10n.quantityGrams(200),
        calories: 98,
        protein: 5,
        fat: 1,
        carbs: 25,
      ),
      DiaryPrototypeEntry(
        id: 'avocado',
        name: l10n.diaryDemoAvocado,
        quantity: l10n.quantityGrams(50),
        calories: 90,
        protein: 2,
        fat: 5,
        carbs: 15,
      ),
    ],
    'snacks': [
      DiaryPrototypeEntry(
        id: 'yogurt',
        name: l10n.demoYogurt,
        quantity: l10n.quantityGrams(120),
        calories: 85,
        protein: 8,
        carbs: 12,
      ),
      DiaryPrototypeEntry(
        id: 'apple',
        name: l10n.demoApple,
        quantity: l10n.quantityGrams(100),
        calories: 50,
        carbs: 14,
      ),
    ],
  };
}
