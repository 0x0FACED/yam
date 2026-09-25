import 'package:flutter/material.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
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

  final int? calorieTarget;
  final int? proteinTarget;
  final int? fatTarget;
  final int? carbsTarget;
  final List<DiaryPrototypeMeal> meals;

  int get consumedCalories => meals
      .fold<double>(0, (total, meal) => total + meal.exactCalories)
      .round();
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

  double get exactCalories => entries.fold<double>(
    0,
    (total, entry) => total + entry.exactCaloriesValue,
  );
  int get calories => exactCalories.round();
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
    this.exactCalories,
    this.brand,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
    this.storedEntry,
  });

  final String id;
  final String name;
  final String? brand;
  final String quantity;
  final int calories;
  final double? exactCalories;
  final double protein;
  final double fat;
  final double carbs;
  final DiaryEntry? storedEntry;

  double get exactCaloriesValue => exactCalories ?? calories.toDouble();
}

DiaryPrototypeDay buildDiaryPrototypeDay(
  AppLocalizations l10n, {
  Map<String, List<DiaryPrototypeEntry>> entriesByMeal = const {},
  SessionProfile? profile,
}) => DiaryPrototypeDay(
  calorieTarget: profile?.calorieTarget,
  proteinTarget: profile?.proteinTarget,
  fatTarget: profile?.fatTarget,
  carbsTarget: profile?.carbsTarget,
  meals: [
    DiaryPrototypeMeal(
      id: 'breakfast',
      name: l10n.mealBreakfast,
      time: const TimeOfDay(hour: 8, minute: 30),
      entries: entriesByMeal['breakfast'] ?? const [],
    ),
    DiaryPrototypeMeal(
      id: 'lunch',
      name: l10n.mealLunch,
      time: const TimeOfDay(hour: 13, minute: 15),
      entries: entriesByMeal['lunch'] ?? const [],
    ),
    DiaryPrototypeMeal(
      id: 'dinner',
      name: l10n.mealDinner,
      time: const TimeOfDay(hour: 19, minute: 20),
      entries: entriesByMeal['dinner'] ?? const [],
    ),
    DiaryPrototypeMeal(
      id: 'snacks',
      name: l10n.mealSnacks,
      time: const TimeOfDay(hour: 16, minute: 40),
      entries: entriesByMeal['snacks'] ?? const [],
    ),
  ],
);
