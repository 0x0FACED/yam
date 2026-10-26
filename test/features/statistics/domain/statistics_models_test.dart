import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';

void main() {
  test(
    'calorie status keeps exact inclusive boundaries and empty-day states',
    () {
      for (final (kcal, target, expected) in <(double?, int?, GoalDayStatus)>[
        (null, null, GoalDayStatus.noEntry),
        (null, 1000, GoalDayStatus.noEntry),
        (0, null, GoalDayStatus.noGoal),
        (0, 1000, GoalDayStatus.below),
        (899.999999, 1000, GoalDayStatus.below),
        (900, 1000, GoalDayStatus.within),
        (1100, 1000, GoalDayStatus.within),
        (1100.000001, 1000, GoalDayStatus.above),
      ]) {
        expect(
          calorieGoalDayStatus(kcal: kcal, calorieTarget: target),
          expected,
          reason: '$kcal kcal with target $target',
        );
      }
    },
  );

  test('calendar statuses match Statistics across year and goal changes', () {
    final start = DateTime(2020, 12, 28);
    final end = DateTime(2021, 1, 3);
    final nutrition = [
      for (final (date, kcal) in [
        (DateTime(2020, 12, 27), 5000.0),
        (start, 1000.0),
        (DateTime(2020, 12, 29), 899.999999),
        (DateTime(2020, 12, 30), 900.0),
        (DateTime(2021, 1, 1), 2200.0),
        (DateTime(2021, 1, 2), 2200.000001),
        (end, 0.0),
        (DateTime(2021, 1, 4), 5000.0),
      ])
        NutritionDay(day: date, kcal: kcal, protein: 0, fat: 0, carbs: 0),
    ];
    GoalVersion goal(String id, DateTime date, int kcal) => GoalVersion(
      id: id,
      day: date,
      goal: WeightGoal.maintain,
      calorieTarget: kcal,
      proteinTarget: 100,
      fatTarget: 50,
      carbsTarget: 120,
      targetWeightKg: 70,
    );
    final goals = [
      goal('3', DateTime(2021, 1, 1), 2000),
      goal('1', DateTime(2020, 12, 29), 1000),
      goal('4', DateTime(2021, 1, 4), 5000),
      goal('2', DateTime(2021, 1, 1), 3000),
    ];
    final statuses = calculateGoalDayStatuses(
      start: start,
      end: end,
      nutrition: nutrition,
      goals: goals,
    );
    expect(statuses.keys, [
      for (var i = 0; i < 7; i++) DateTime(2020, 12, 28 + i),
    ]);
    expect(statuses.values, [
      GoalDayStatus.noGoal,
      GoalDayStatus.below,
      GoalDayStatus.within,
      GoalDayStatus.noEntry,
      GoalDayStatus.within,
      GoalDayStatus.above,
      GoalDayStatus.below,
    ]);
    final statistics = calculateStatistics(
      period: StatisticsPeriod.days7,
      today: end,
      nutrition: nutrition,
      goals: goals,
      weightEntries: const [],
      frequentFoods: const [],
    );
    for (final day in statistics.days) {
      expect(statuses[day.nutrition.day], day.status);
    }
    expect(statistics.heatmap.map((cell) => cell.status), statuses.values);
  });

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
