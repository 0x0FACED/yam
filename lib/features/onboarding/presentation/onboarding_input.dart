import 'package:yam/app/session/session_profile.dart';

class OnboardingInput {
  OnboardingInput({
    required this.goal,
    required String currentWeight,
    required String targetWeight,
    required String calories,
    required String protein,
    required String fat,
    required String carbs,
  }) : currentWeightKg = _parseWeight(currentWeight),
       targetWeightKg = _parseWeight(targetWeight),
       calorieTarget = _parseInteger(calories, allowZero: false),
       proteinTarget = _parseInteger(protein, allowZero: true),
       fatTarget = _parseInteger(fat, allowZero: true),
       carbsTarget = _parseInteger(carbs, allowZero: true);

  final WeightGoal? goal;
  final double? currentWeightKg;
  final double? targetWeightKg;
  final int? calorieTarget;
  final int? proteinTarget;
  final int? fatTarget;
  final int? carbsTarget;

  bool get validWeight => currentWeightKg != null && targetWeightKg != null;

  bool get validNutrition =>
      calorieTarget != null &&
      proteinTarget != null &&
      fatTarget != null &&
      carbsTarget != null;

  int? get caloriesFromMacros => validNutrition
      ? proteinTarget! * 4 + fatTarget! * 9 + carbsTarget! * 4
      : null;

  int? get macroCalorieDifference =>
      validNutrition ? caloriesFromMacros! - calorieTarget! : null;

  double? get weightDifferenceKg =>
      validWeight ? targetWeightKg! - currentWeightKg! : null;

  SessionProfile? get profile {
    if (goal == null || !validWeight || !validNutrition) return null;
    return SessionProfile(
      goal: goal!,
      currentWeightKg: currentWeightKg!,
      targetWeightKg: targetWeightKg!,
      calorieTarget: calorieTarget!,
      proteinTarget: proteinTarget!,
      fatTarget: fatTarget!,
      carbsTarget: carbsTarget!,
    );
  }

  static double? _parseWeight(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    return value != null && value.isFinite && value > 0 ? value : null;
  }

  static int? _parseInteger(String text, {required bool allowZero}) {
    final value = int.tryParse(text.trim());
    return value != null && (allowZero ? value >= 0 : value > 0) ? value : null;
  }
}
