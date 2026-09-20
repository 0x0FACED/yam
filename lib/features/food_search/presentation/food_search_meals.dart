import 'package:flutter/material.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class FoodSearchPrototypeMeal {
  const FoodSearchPrototypeMeal({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final IconData icon;
}

List<FoodSearchPrototypeMeal> buildFoodSearchPrototypeMeals(
  AppLocalizations l10n,
) {
  return [
    FoodSearchPrototypeMeal(
      id: 'breakfast',
      name: l10n.mealBreakfast,
      icon: Icons.wb_sunny_outlined,
    ),
    FoodSearchPrototypeMeal(
      id: 'lunch',
      name: l10n.mealLunch,
      icon: Icons.lunch_dining_outlined,
    ),
    FoodSearchPrototypeMeal(
      id: 'dinner',
      name: l10n.mealDinner,
      icon: Icons.nights_stay_outlined,
    ),
    FoodSearchPrototypeMeal(
      id: 'snacks',
      name: l10n.mealSnacks,
      icon: Icons.apple_outlined,
    ),
  ];
}

String foodSearchPrototypeMealName(AppLocalizations l10n, String mealId) {
  return buildFoodSearchPrototypeMeals(
    l10n,
  ).firstWhere((meal) => meal.id == mealId).name;
}
