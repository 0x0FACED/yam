import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';

void main() {
  test(
    'averages only logged days and evaluates the goal effective that day',
    () {
      final snapshot = calculateStatistics(
        period: StatisticsPeriod.days7,
        today: DateTime(2026, 9, 6),
        nutrition: [
          for (final (day, kcal) in [
            (1, 700.0),
            (2, 900.0),
            (3, 1100.0),
            (4, 900.0),
            (5, 2200.0),
          ])
            NutritionDay(
              day: DateTime(2026, 9, day),
              kcal: kcal,
              protein: 50,
              fat: 20,
              carbs: 100,
            ),
        ],
        goals: [
          GoalVersion(
            id: '1',
            day: DateTime(2026, 9, 2),
            goal: WeightGoal.lose,
            calorieTarget: 1000,
            proteinTarget: 100,
            fatTarget: 50,
            carbsTarget: 120,
            targetWeightKg: 70,
          ),
          GoalVersion(
            id: '2',
            day: DateTime(2026, 9, 4),
            goal: WeightGoal.maintain,
            calorieTarget: 2000,
            proteinTarget: 200,
            fatTarget: 80,
            carbsTarget: 200,
            targetWeightKg: 72,
          ),
        ],
        weightEntries: const [],
        frequentFoods: const [],
      );

      expect(snapshot.days.map((day) => day.status), [
        GoalDayStatus.noGoal,
        GoalDayStatus.within,
        GoalDayStatus.within,
        GoalDayStatus.below,
        GoalDayStatus.within,
      ]);
      expect(snapshot.goalEvaluatedDays, 4);
      expect(snapshot.withinGoalDays, 3);
      expect(snapshot.withinGoalPercent, 75);
      expect(snapshot.averageCalories, 1160);
      expect(snapshot.averageProteinTarget, isNull);
      expect(snapshot.heatmap.last.status, GoalDayStatus.noEntry);
      expect(snapshot.latestGoal?.calorieTarget, 2000);
      final afterGoal = calculateStatistics(
        period: StatisticsPeriod.days7,
        today: DateTime(2026, 9, 6),
        nutrition: [for (final day in snapshot.days.skip(1)) day.nutrition],
        goals: [
          GoalVersion(
            id: '1',
            day: DateTime(2026, 9, 2),
            goal: WeightGoal.lose,
            calorieTarget: 1000,
            proteinTarget: 100,
            fatTarget: 50,
            carbsTarget: 120,
            targetWeightKg: 70,
          ),
          GoalVersion(
            id: '2',
            day: DateTime(2026, 9, 4),
            goal: WeightGoal.maintain,
            calorieTarget: 2000,
            proteinTarget: 200,
            fatTarget: 80,
            carbsTarget: 200,
            targetWeightKg: 72,
          ),
        ],
        weightEntries: const [],
        frequentFoods: const [],
      );
      expect(afterGoal.averageProteinTarget, 150);
    },
  );
}
