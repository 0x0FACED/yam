enum DiaryBaseUnit { grams, milliliters }

class DiaryNutrition {
  const DiaryNutrition({
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final double kcal;
  final double protein;
  final double fat;
  final double carbs;

  DiaryNutrition scale(double factor) => DiaryNutrition(
    kcal: kcal * factor,
    protein: protein * factor,
    fat: fat * factor,
    carbs: carbs * factor,
  );

  bool get isValid => [
    kcal,
    protein,
    fat,
    carbs,
  ].every((value) => value.isFinite && value >= 0);
}

class DiaryServingSnapshot {
  const DiaryServingSnapshot({
    required this.id,
    required this.unit,
    required this.baseAmount,
    this.label,
  });

  final String id;
  final String unit;
  final double baseAmount;
  final String? label;
}

class DiaryFoodSnapshot {
  const DiaryFoodSnapshot({
    required this.foodId,
    required this.name,
    required this.baseUnit,
    required this.basisAmount,
    required this.nutritionPerBasis,
    required this.servings,
    this.brand,
  });

  final String foodId;
  final String name;
  final String? brand;
  final DiaryBaseUnit baseUnit;
  final double basisAmount;
  final DiaryNutrition nutritionPerBasis;
  final List<DiaryServingSnapshot> servings;

  DiaryServingSnapshot serving(String id) =>
      servings.firstWhere((candidate) => candidate.id == id);

  DiaryNutrition nutritionFor(double canonicalQuantity) =>
      nutritionPerBasis.scale(canonicalQuantity / basisAmount);

  void validate() {
    if (foodId.isEmpty ||
        name.trim().isEmpty ||
        !basisAmount.isFinite ||
        basisAmount <= 0 ||
        !nutritionPerBasis.isValid ||
        servings.isEmpty ||
        servings.any(
          (serving) =>
              serving.id.isEmpty ||
              !serving.baseAmount.isFinite ||
              serving.baseAmount <= 0,
        )) {
      throw ArgumentError('Invalid diary food snapshot');
    }
  }
}

class DiaryEntryDraft {
  const DiaryEntryDraft({
    required this.day,
    required this.mealId,
    required this.food,
    required this.servingId,
    required this.amount,
    required this.canonicalQuantity,
  });

  final DateTime day;
  final String mealId;
  final DiaryFoodSnapshot food;
  final String servingId;
  final double amount;
  final double canonicalQuantity;

  void validate() {
    food.validate();
    if (!diaryMealIds.contains(mealId) ||
        !amount.isFinite ||
        amount <= 0 ||
        !canonicalQuantity.isFinite ||
        canonicalQuantity <= 0 ||
        !food.nutritionFor(canonicalQuantity).isValid) {
      throw ArgumentError('Invalid diary entry');
    }
    food.serving(servingId);
  }
}

const diaryMealIds = {'breakfast', 'lunch', 'dinner', 'snacks'};

class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.day,
    required this.mealId,
    required this.food,
    required this.servingId,
    required this.amount,
    required this.canonicalQuantity,
    required this.nutrition,
  });

  final String id;
  final DateTime day;
  final String mealId;
  final DiaryFoodSnapshot food;
  final String servingId;
  final double amount;
  final double canonicalQuantity;
  final DiaryNutrition nutrition;
}

String diaryDayKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';
