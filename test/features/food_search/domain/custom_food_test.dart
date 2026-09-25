import 'package:flutter_test/flutter_test.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';

void main() {
  test('energy is computed on the selected basis without rounding', () {
    for (final (basis, amount, displayBasis, servings) in [
      (
        CustomFoodBasis.grams,
        100.0,
        CustomFoodDisplayBasis.perHundredGrams,
        <CustomServingDraft>[],
      ),
      (
        CustomFoodBasis.milliliters,
        100.0,
        CustomFoodDisplayBasis.perHundredMilliliters,
        <CustomServingDraft>[],
      ),
      (
        CustomFoodBasis.grams,
        80.0,
        CustomFoodDisplayBasis.perServing,
        <CustomServingDraft>[
          const CustomServingDraft(
            unit: CustomServingUnit.serving,
            baseAmount: 80,
            defaultAmount: 1,
          ),
        ],
      ),
    ]) {
      final draft = CustomFoodDraft(
        name: 'Oats',
        category: 'grains',
        basis: basis,
        basisAmount: amount,
        displayBasis: displayBasis,
        proteinG: 9.84,
        fatG: 4.88,
        carbsG: 47.6,
        servings: servings,
      );
      draft.validate();
      expect(draft.energyKcal, closeTo(273.68, 0.000001));
    }
    expect(energyKcalFromMacros(proteinG: 0, fatG: 0, carbsG: 0), 0);
  });

  test('invalid or overflowing macros cannot be saved', () {
    for (final value in [-1.0, double.nan, double.infinity, 1e308]) {
      final draft = CustomFoodDraft(
        name: 'Oats',
        category: 'grains',
        basis: CustomFoodBasis.grams,
        basisAmount: 100,
        displayBasis: CustomFoodDisplayBasis.perHundredGrams,
        proteinG: value,
        fatG: 0,
        carbsG: 0,
        servings: const [],
      );
      expect(draft.validate, throwsArgumentError);
    }
  });
}
