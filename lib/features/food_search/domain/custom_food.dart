enum CustomFoodBasis { grams, milliliters }

enum CustomFoodDisplayBasis {
  perHundredGrams,
  perHundredMilliliters,
  perServing,
}

enum CustomServingUnit { serving, piece, glass, scoop }

double energyKcalFromMacros({
  required double proteinG,
  required double fatG,
  required double carbsG,
}) => proteinG * 4 + fatG * 9 + carbsG * 4;

class CustomServingDraft {
  const CustomServingDraft({
    required this.unit,
    required this.baseAmount,
    required this.defaultAmount,
    this.label,
  });

  final CustomServingUnit unit;
  final String? label;

  /// Grams or milliliters represented by one selected unit.
  final double baseAmount;
  final double defaultAmount;
}

class CustomFoodDraft {
  const CustomFoodDraft({
    required this.name,
    required this.category,
    required this.basis,
    required this.basisAmount,
    required this.displayBasis,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.servings,
    this.brand,
    this.barcode,
  });

  final String name;
  final String category;
  final String? brand;
  final String? barcode;
  final CustomFoodBasis basis;
  final double basisAmount;
  final CustomFoodDisplayBasis displayBasis;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final List<CustomServingDraft> servings;

  double get energyKcal =>
      energyKcalFromMacros(proteinG: proteinG, fatG: fatG, carbsG: carbsG);

  void validate() {
    if (name.trim().isEmpty ||
        category.isEmpty ||
        !basisAmount.isFinite ||
        basisAmount <= 0) {
      throw ArgumentError('Name, category and nutrition basis are required');
    }
    if (displayBasis == CustomFoodDisplayBasis.perHundredGrams &&
            (basis != CustomFoodBasis.grams || basisAmount != 100) ||
        displayBasis == CustomFoodDisplayBasis.perHundredMilliliters &&
            (basis != CustomFoodBasis.milliliters || basisAmount != 100)) {
      throw ArgumentError('Nutrition basis and canonical unit must agree');
    }
    if (displayBasis == CustomFoodDisplayBasis.perServing &&
        !servings.any(
          (serving) =>
              serving.unit == CustomServingUnit.serving &&
              serving.baseAmount == basisAmount,
        )) {
      throw ArgumentError('Nutrition per serving requires its equivalent');
    }
    if ([
      proteinG,
      fatG,
      carbsG,
      energyKcal,
    ].any((value) => !value.isFinite || value < 0)) {
      throw ArgumentError('Nutrition cannot be negative or non-finite');
    }
    if (barcode != null && !RegExp(r'^\d+$').hasMatch(barcode!)) {
      throw ArgumentError('Barcode must contain digits only');
    }
    for (final serving in servings) {
      if (!serving.baseAmount.isFinite ||
          serving.baseAmount <= 0 ||
          !serving.defaultAmount.isFinite ||
          serving.defaultAmount <= 0) {
        throw ArgumentError('Serving amounts must be positive and finite');
      }
    }
  }
}
