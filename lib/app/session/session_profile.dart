enum WeightGoal { lose, maintain, gain }

class SessionProfile {
  const SessionProfile({
    required this.goal,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.calorieTarget,
    required this.proteinTarget,
    required this.fatTarget,
    required this.carbsTarget,
  });

  final WeightGoal goal;
  final double? currentWeightKg;
  final double targetWeightKg;
  final int calorieTarget;
  final int proteinTarget;
  final int fatTarget;
  final int carbsTarget;
}
