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

  static const example = SessionProfile(
    goal: WeightGoal.lose,
    currentWeightKg: 74.2,
    targetWeightKg: 72,
    calorieTarget: 1950,
    proteinTarget: 140,
    fatTarget: 65,
    carbsTarget: 210,
  );

  final WeightGoal goal;
  final double currentWeightKg;
  final double targetWeightKg;
  final int calorieTarget;
  final int proteinTarget;
  final int fatTarget;
  final int carbsTarget;
}
