import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

String formatFoodSearchNumber(BuildContext context, num value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final formatter = NumberFormat.decimalPattern(locale)
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = 1;
  return formatter.format(value);
}

String editableFoodSearchNumber(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value
          .toStringAsFixed(3)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');

String formatFoodSearchQuantity(
  BuildContext context,
  FoodSearchPrototypeUnit unit,
  num value,
) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  final normalized = value is double && value == value.roundToDouble()
      ? value.toInt()
      : value is double && value.abs() >= 0.001
      ? double.parse(value.toStringAsFixed(3))
      : value;

  final translated = switch (unit) {
    FoodSearchPrototypeUnit.grams => l10n.quantityGrams(normalized),
    FoodSearchPrototypeUnit.milliliters => l10n.quantityMilliliters(normalized),
    FoodSearchPrototypeUnit.pieces => l10n.quantityPieces(normalized),
    FoodSearchPrototypeUnit.servings => l10n.quantityServings(normalized),
    FoodSearchPrototypeUnit.scoops => l10n.quantityScoops(normalized),
    FoodSearchPrototypeUnit.glasses => l10n.quantityGlasses(normalized),
  };
  final formatted = NumberFormat.decimalPattern(locale)
    ..maximumFractionDigits = 3;
  return translated.replaceFirst('$normalized', formatted.format(normalized));
}

String foodSearchUnitLabel(
  AppLocalizations l10n,
  FoodSearchPrototypeUnit unit,
) {
  return switch (unit) {
    FoodSearchPrototypeUnit.grams => l10n.unitGrams,
    FoodSearchPrototypeUnit.milliliters => l10n.unitMilliliters,
    FoodSearchPrototypeUnit.pieces => l10n.unitPieces,
    FoodSearchPrototypeUnit.servings => l10n.unitServings,
    FoodSearchPrototypeUnit.scoops => l10n.unitScoops,
    FoodSearchPrototypeUnit.glasses => l10n.unitGlasses,
  };
}

String formatFoodSearchMetadata(
  AppLocalizations l10n,
  FoodSearchPrototypeFood food,
) {
  final category = foodSearchCategoryLabel(l10n, food.category);
  final brand = food.brand;
  return brand == null || brand.isEmpty ? category : '$category · $brand';
}

String foodSearchCategoryLabel(AppLocalizations l10n, String category) =>
    switch (category) {
      'other' => l10n.foodCategoryOther,
      'grains' => l10n.foodCategoryGrains,
      'dairy' => l10n.foodCategoryDairy,
      'sportsNutrition' => l10n.foodCategorySportsNutrition,
      'fruit' => l10n.foodCategoryFruit,
      'poultry' => l10n.foodCategoryPoultry,
      'eggs' => l10n.foodCategoryEggs,
      'bread' => l10n.foodCategoryBread,
      'drinks' => l10n.foodCategoryDrinks,
      _ => category,
    };

String? foodSearchServingEquivalent(
  BuildContext context,
  FoodSearchPrototypeFood food,
  FoodSearchPrototypeServing serving,
) {
  final l10n = AppLocalizations.of(context);
  final massPerPiece = food.gramsPerReferenceUnit;
  if (food.referenceUnit == FoodSearchPrototypeUnit.pieces &&
      massPerPiece != null &&
      serving.unit == FoodSearchPrototypeUnit.grams) {
    return l10n.quickAddUnitEquivalent(
      formatFoodSearchQuantity(context, FoodSearchPrototypeUnit.pieces, 1),
      formatFoodSearchQuantity(
        context,
        FoodSearchPrototypeUnit.grams,
        massPerPiece,
      ),
    );
  }
  if (serving.unit == food.referenceUnit && massPerPiece == null) return null;

  final equivalent = massPerPiece == null
      ? formatFoodSearchQuantity(
          context,
          food.referenceUnit,
          serving.baseAmount,
        )
      : formatFoodSearchQuantity(
          context,
          FoodSearchPrototypeUnit.grams,
          serving.baseAmount * massPerPiece,
        );
  return l10n.quickAddUnitEquivalent(
    formatFoodSearchServingQuantity(context, serving, 1),
    equivalent,
  );
}

String foodSearchServingUnitLabel(
  AppLocalizations l10n,
  FoodSearchPrototypeServing serving,
) => serving.label ?? foodSearchUnitLabel(l10n, serving.unit);

String formatFoodSearchServingQuantity(
  BuildContext context,
  FoodSearchPrototypeServing serving,
  num value,
) {
  final label = serving.label;
  if (label == null) {
    return formatFoodSearchQuantity(context, serving.unit, value);
  }
  final locale = Localizations.localeOf(context).toLanguageTag();
  final formatted = NumberFormat.decimalPattern(locale)
    ..maximumFractionDigits = 3;
  return '${formatted.format(value)} $label';
}
