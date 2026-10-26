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

  test(
    'daily inspection separates missing days from logged zero and goals',
    () {
      final zero = _nutrition(DateTime(2025, 12, 30), 0);
      final logged = _nutrition(DateTime(2026, 1, 2), 2400);
      final firstGoal = _goal('1', DateTime(2025, 12, 30), 1000);
      final latestSameDayGoal = _goal('3', DateTime(2026, 1, 1), 2000);
      final snapshot = calculateStatistics(
        period: StatisticsPeriod.days7,
        today: DateTime(2026, 1, 4, 20),
        nutrition: [
          logged,
          _nutrition(DateTime(2026, 1, 5), 9000),
          zero,
          _nutrition(DateTime(2025, 12, 28), 9000),
        ],
        goals: [
          latestSameDayGoal,
          _goal('4', DateTime(2026, 1, 5), 9000),
          firstGoal,
          _goal('2', DateTime(2026, 1, 1), 4000),
        ],
        weightEntries: const [],
        frequentFoods: const [],
      );

      final dates = [for (var i = 0; i < 7; i++) DateTime(2025, 12, 29 + i)];
      expect(snapshot.calorieBuckets.map((bucket) => bucket.day), dates);
      expect(snapshot.calorieBuckets.map((bucket) => bucket.endDay), dates);
      expect(snapshot.calorieBuckets.map((bucket) => bucket.value), [
        null,
        0,
        null,
        null,
        2400,
        null,
        null,
      ]);
      expect(snapshot.calorieBuckets.map((bucket) => bucket.days), [
        0,
        1,
        0,
        0,
        1,
        0,
        0,
      ]);
      expect(snapshot.calorieBuckets.map((bucket) => bucket.calorieTarget), [
        null,
        1000,
        1000,
        2000,
        2000,
        2000,
        2000,
      ]);
      expect(snapshot.heatmap.map((cell) => cell.day), dates);
      expect(snapshot.heatmap.map((cell) => cell.status), [
        GoalDayStatus.noEntry,
        GoalDayStatus.below,
        GoalDayStatus.noEntry,
        GoalDayStatus.noEntry,
        GoalDayStatus.above,
        GoalDayStatus.noEntry,
        GoalDayStatus.noEntry,
      ]);
      expect(snapshot.heatmap.first.nutrition, isNull);
      expect(snapshot.heatmap.first.goal, isNull);
      expect(snapshot.heatmap[1].nutrition, same(zero));
      expect(snapshot.heatmap[1].goal, same(firstGoal));
      expect(snapshot.heatmap[2].nutrition, isNull);
      expect(snapshot.heatmap[2].goal, same(firstGoal));
      expect(snapshot.heatmap[4].nutrition, same(logged));
      expect(snapshot.heatmap.last.nutrition, isNull);
      expect(snapshot.heatmap.last.goal, same(latestSameDayGoal));
      expect(snapshot.latestGoal, same(latestSameDayGoal));
      expect(snapshot.days.length, 2);
      expect(snapshot.averageCalories, 1200);
      expect(snapshot.goalEvaluatedDays, 2);
      expect(snapshot.withinGoalDays, 0);
    },
  );

  test('30-day empty chart retains every date and effective daily targets', () {
    final snapshot = calculateStatistics(
      period: StatisticsPeriod.days30,
      today: DateTime(2024, 3, 1),
      nutrition: const [],
      goals: [
        _goal('2', DateTime(2024, 2, 29), 2500),
        _goal('1', DateTime(2024, 1, 1), 1000),
      ],
      weightEntries: const [],
      frequentFoods: const [],
    );

    expect(snapshot.calorieBuckets.length, 30);
    expect(snapshot.calorieBuckets.first.day, DateTime(2024, 2, 1));
    expect(snapshot.calorieBuckets.last.day, DateTime(2024, 3, 1));
    for (var i = 0; i < snapshot.calorieBuckets.length; i++) {
      final bucket = snapshot.calorieBuckets[i];
      expect(bucket.day, DateTime(2024, 2, i + 1));
      expect(bucket.endDay, bucket.day);
      expect(bucket.value, isNull);
      expect(bucket.days, 0);
      expect(bucket.calorieTarget, i < 28 ? 1000 : 2500);
    }
    expect(snapshot.days, isEmpty);
    expect(snapshot.averageCalories, isNull);
    expect(snapshot.averageProteinTarget, isNull);
  });

  test('90-day weekly ranges clip boundaries and omit partial goal means', () {
    final snapshot = calculateStatistics(
      period: StatisticsPeriod.months3,
      today: DateTime(2026, 4, 3),
      nutrition: [
        _nutrition(DateTime(2026, 4, 4), 9000),
        _nutrition(DateTime(2026, 1, 14), 4000),
        _nutrition(DateTime(2026, 1, 5), 400),
        _nutrition(DateTime(2026, 1, 3), 9000),
        _nutrition(DateTime(2026, 1, 10), 1800),
        _nutrition(DateTime(2026, 1, 4), 900),
        _nutrition(DateTime(2026, 4, 3), 3600),
        _nutrition(DateTime(2026, 1, 12), 0),
        _nutrition(DateTime(2026, 1, 7), 1200),
      ],
      goals: [
        _goal('3', DateTime(2026, 1, 13), 3000),
        _goal('1', DateTime(2026, 1, 6), 1000),
        _goal('2', DateTime(2026, 1, 10), 2000),
      ],
      weightEntries: const [],
      frequentFoods: const [],
    );

    final buckets = snapshot.calorieBuckets;
    expect(buckets.length, 14);
    expect(
      (buckets.first.day, buckets.first.endDay),
      (DateTime(2026, 1, 4), DateTime(2026, 1, 4)),
    );
    expect(buckets.first.value, 900);
    expect(buckets.first.days, 1);
    expect(buckets.first.calorieTarget, isNull);
    expect(
      (buckets[1].day, buckets[1].endDay),
      (DateTime(2026, 1, 5), DateTime(2026, 1, 11)),
    );
    expect(buckets[1].value, closeTo(3400 / 3, 0.000001));
    expect(buckets[1].days, 3);
    expect(buckets[1].calorieTarget, isNull);
    expect(
      (buckets[2].day, buckets[2].endDay),
      (DateTime(2026, 1, 12), DateTime(2026, 1, 18)),
    );
    expect(buckets[2].value, 2000);
    expect(buckets[2].days, 2);
    expect(buckets[2].calorieTarget, 2500);
    expect(
      (buckets[3].day, buckets[3].endDay),
      (DateTime(2026, 1, 19), DateTime(2026, 1, 25)),
    );
    expect(buckets[3].value, isNull);
    expect(buckets[3].days, 0);
    expect(buckets[3].calorieTarget, isNull);
    expect(
      (buckets.last.day, buckets.last.endDay),
      (DateTime(2026, 3, 30), DateTime(2026, 4, 3)),
    );
    expect(buckets.last.value, 3600);
    expect(buckets.last.days, 1);
    expect(buckets.last.calorieTarget, 3000);
    for (var i = 1; i < buckets.length; i++) {
      final previousEnd = buckets[i - 1].endDay;
      expect(
        buckets[i].day,
        DateTime(previousEnd.year, previousEnd.month, previousEnd.day + 1),
      );
    }
  });

  test('yearly monthly means use logged days and inclusive clipped ranges', () {
    final snapshot = calculateStatistics(
      period: StatisticsPeriod.year1,
      today: DateTime(2026, 2, 14),
      nutrition: [
        _nutrition(DateTime(2025, 2, 14), 9000),
        _nutrition(DateTime(2025, 2, 15), 1000),
        _nutrition(DateTime(2025, 3, 1), 2000),
        _nutrition(DateTime(2025, 3, 30), 4000),
        _nutrition(DateTime(2026, 2, 14), 5000),
        _nutrition(DateTime(2026, 2, 15), 9000),
      ],
      goals: [
        _goal('1', DateTime(2025, 2, 1), 1000),
        _goal('2', DateTime(2025, 3, 15), 3000),
        _goal('3', DateTime(2026, 2, 15), 9000),
      ],
      weightEntries: const [],
      frequentFoods: const [],
    );

    final buckets = snapshot.calorieBuckets;
    expect(buckets.length, 13);
    expect(
      (buckets.first.day, buckets.first.endDay),
      (DateTime(2025, 2, 15), DateTime(2025, 2, 28)),
    );
    expect(buckets.first.value, 1000);
    expect(buckets.first.days, 1);
    expect(buckets.first.calorieTarget, 1000);
    expect(
      (buckets[1].day, buckets[1].endDay),
      (DateTime(2025, 3, 1), DateTime(2025, 3, 31)),
    );
    expect(buckets[1].value, 3000);
    expect(buckets[1].days, 2);
    expect(buckets[1].calorieTarget, 2000);
    expect(
      (buckets[2].day, buckets[2].endDay),
      (DateTime(2025, 4, 1), DateTime(2025, 4, 30)),
    );
    expect(buckets[2].value, isNull);
    expect(buckets[2].days, 0);
    expect(buckets[2].calorieTarget, isNull);
    expect(
      (buckets.last.day, buckets.last.endDay),
      (DateTime(2026, 2, 1), DateTime(2026, 2, 14)),
    );
    expect(buckets.last.value, 5000);
    expect(buckets.last.days, 1);
    expect(buckets.last.calorieTarget, 3000);
  });

  test('all-period months start at the first real food or weight day', () {
    final firstDay = DateTime(2025, 11, 23, 15);
    final laterDay = DateTime(2026, 1, 3);
    for (final (foodDay, weightDay) in [
      (firstDay, laterDay),
      (laterDay, firstDay),
    ]) {
      final snapshot = calculateStatistics(
        period: StatisticsPeriod.all,
        today: DateTime(2026, 1, 9),
        nutrition: [
          _nutrition(foodDay, 1000),
          _nutrition(DateTime(2026, 1, 10), 9000),
        ],
        goals: [_goal('1', DateTime(2020, 1, 1), 1000)],
        weightEntries: [
          WeightRecord(id: '1', day: weightDay, kg: 70),
          WeightRecord(id: '2', day: DateTime(2026, 1, 10), kg: 71),
        ],
        frequentFoods: const [],
      );

      expect(
        snapshot.calorieBuckets.map((bucket) => (bucket.day, bucket.endDay)),
        [
          (DateTime(2025, 11, 23), DateTime(2025, 11, 30)),
          (DateTime(2025, 12, 1), DateTime(2025, 12, 31)),
          (DateTime(2026, 1, 1), DateTime(2026, 1, 9)),
        ],
      );
      expect(snapshot.calorieBuckets[1].value, isNull);
      expect(snapshot.calorieBuckets[1].days, 0);
      expect(snapshot.calorieBuckets[1].calorieTarget, isNull);
      final loggedBucket = snapshot.calorieBuckets.singleWhere(
        (bucket) => bucket.days > 0,
      );
      expect(loggedBucket.value, 1000);
      expect(loggedBucket.days, 1);
      expect(loggedBucket.calorieTarget, 1000);
    }
  });

  test('all-period calendar clips to the earliest real record day', () {
    final goal = _goal('1', DateTime(2026, 1, 1), 1000);
    final snapshot = calculateStatistics(
      period: StatisticsPeriod.all,
      today: DateTime(2026, 1, 9),
      nutrition: [_nutrition(DateTime(2026, 1, 8), 1000)],
      goals: [goal],
      weightEntries: [WeightRecord(id: '1', day: DateTime(2026, 1, 7), kg: 70)],
      frequentFoods: const [],
    );

    expect(snapshot.heatmap.map((cell) => cell.day), [
      DateTime(2026, 1, 7),
      DateTime(2026, 1, 8),
      DateTime(2026, 1, 9),
    ]);
    expect(snapshot.heatmap.first.nutrition, isNull);
    expect(snapshot.heatmap.first.goal, same(goal));
    expect(snapshot.heatmap[1].nutrition?.kcal, 1000);
    expect(snapshot.heatmap.last.nutrition, isNull);
    expect(snapshot.heatmap.last.goal, same(goal));
  });

  test('all-period goals and future records do not invent history', () {
    final snapshot = calculateStatistics(
      period: StatisticsPeriod.all,
      today: DateTime(2026, 1, 9),
      nutrition: [_nutrition(DateTime(2026, 1, 10), 1000)],
      goals: [_goal('1', DateTime(2020, 1, 1), 1000)],
      weightEntries: [
        WeightRecord(id: '1', day: DateTime(2026, 1, 10), kg: 70),
      ],
      frequentFoods: const [],
    );

    expect(snapshot.calorieBuckets, isEmpty);
    expect(snapshot.days, isEmpty);
    expect(snapshot.weights, isEmpty);
    expect(snapshot.averageCalories, isNull);
  });
}

NutritionDay _nutrition(DateTime day, double kcal) =>
    NutritionDay(day: day, kcal: kcal, protein: 20, fat: 10, carbs: 30);

GoalVersion _goal(String id, DateTime day, int kcal) => GoalVersion(
  id: id,
  day: day,
  goal: WeightGoal.maintain,
  calorieTarget: kcal,
  proteinTarget: 100,
  fatTarget: 50,
  carbsTarget: 120,
  targetWeightKg: 70,
);
