import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/features/diary/domain/day_details.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';

void main() {
  test('totals retain independently stored nutrition snapshot precision', () {
    final entries = [
      _entry(
        'first',
        kcal: 4.325155,
        protein: 0.260795,
        fat: 0.0516,
        carbs: 0.6192,
      ),
      _entry(
        'second',
        kcal: 10.001234,
        protein: 1.234567,
        fat: 2.345678,
        carbs: 3.456789,
      ),
    ];
    final snapshot = _snapshot(entries);

    expect(snapshot.totals.kcal, closeTo(14.326389, 0.000000001));
    expect(snapshot.totals.protein, closeTo(1.495362, 0.000000001));
    expect(snapshot.totals.fat, closeTo(2.397278, 0.000000001));
    expect(snapshot.totals.carbs, closeTo(4.075989, 0.000000001));
    expect(
      snapshot.totals.kcal,
      isNot(
        closeTo(
          snapshot.totals.protein * 4 +
              snapshot.totals.fat * 9 +
              snapshot.totals.carbs * 4,
          0.000000001,
        ),
      ),
    );
    expect(
      snapshot.totals.kcal,
      isNot(
        entries.fold<double>(
          0,
          (sum, entry) =>
              sum + entry.food.nutritionFor(entry.canonicalQuantity).kcal,
        ),
      ),
    );
    expect(snapshot.meals.single.totals.kcal, snapshot.totals.kcal);
    expect(snapshot.entries, orderedEquals(entries));
  });

  test('resolves historical goals by local calendar day then greatest id', () {
    final old = _goal('z', DateTime(2025, 12, 30), 1000);
    final earlierSameDay = _goal('a', DateTime(2026, 1, 1, 23), 2000);
    final latestSameDay = _goal('b', DateTime(2026, 1, 1), 3000);
    final future = _goal('zz', DateTime(2026, 1, 2), 9000);
    final goals = [future, latestSameDay, old, earlierSameDay];
    DayDetailsSnapshot snapshot(DateTime day) =>
        DayDetailsSnapshot(day: day, entries: const [], goals: goals);

    expect(snapshot(DateTime(2025, 12, 29)).goal, isNull);
    expect(snapshot(DateTime(2025, 12, 31)).goal, same(old));
    expect(snapshot(DateTime(2026, 1, 1, 1)).goal, same(latestSameDay));
    expect(snapshot(DateTime(2026, 1, 2)).goal, same(future));
    expect(
      DayDetailsSnapshot(
        day: DateTime(2026, 1, 1),
        entries: const [],
        goals: const [],
      ).goal,
      isNull,
    );
    expect(goals, [future, latestSameDay, old, earlierSameDay]);
  });

  test('calendar dates are not converted from UTC instants', () {
    final goal = _goal('same-day', DateTime.utc(2026, 1, 1, 23, 59), 2000);
    final snapshot = DayDetailsSnapshot(
      day: DateTime.utc(2026, 1, 1, 1),
      entries: const [],
      goals: [goal],
    );

    expect(snapshot.day, DateTime(2026, 1, 1));
    expect(snapshot.goal, same(goal));
  });

  test('groups nonempty meals in diary order and counts estimated entries', () {
    final dinnerFirst = _entry(
      'dinner-first',
      mealId: 'dinner',
      kcal: 120,
      protein: 2,
      isEstimated: true,
    );
    final breakfastFirst = _entry(
      'breakfast-first',
      mealId: 'breakfast',
      kcal: 50,
      protein: 4,
      fat: 3,
      carbs: 6,
    );
    final snack = _entry('snack', mealId: 'snacks', kcal: 0);
    final lunch = _entry('lunch', mealId: 'lunch', kcal: 150);
    final breakfastSecond = _entry(
      'breakfast-second',
      mealId: 'breakfast',
      kcal: 50,
      protein: 6,
      fat: 2,
      carbs: 4,
      isEstimated: true,
    );
    final dinnerSecond = _entry(
      'dinner-second',
      mealId: 'dinner',
      kcal: 30,
      isEstimated: true,
    );
    final entries = [
      dinnerFirst,
      breakfastFirst,
      snack,
      lunch,
      breakfastSecond,
      dinnerSecond,
    ];
    final snapshot = _snapshot(entries);

    expect(snapshot.entries, orderedEquals(entries));
    expect(snapshot.meals.map((meal) => meal.id), [
      'breakfast',
      'lunch',
      'dinner',
      'snacks',
    ]);
    expect(snapshot.meals[0].entries, [breakfastFirst, breakfastSecond]);
    expect(snapshot.meals[2].entries, [dinnerFirst, dinnerSecond]);
    expect(snapshot.meals[0].totals.kcal, 100);
    expect(snapshot.meals[0].totals.protein, 10);
    expect(snapshot.meals[0].totals.fat, 5);
    expect(snapshot.meals[0].totals.carbs, 10);
    expect(snapshot.meals.map((meal) => meal.totals.kcal), [100, 150, 150, 0]);
    expect(snapshot.meals.map((meal) => meal.calorieShare), [
      0.25,
      0.375,
      0.375,
      0,
    ]);
    expect(snapshot.largestMeal, same(snapshot.meals[1]));
    expect(snapshot.estimatedCount, 3);

    final oneMeal = _snapshot([dinnerFirst]);
    expect(oneMeal.meals.map((meal) => meal.id), ['dinner']);
    expect(oneMeal.largestMeal, same(oneMeal.meals.single));
    expect(oneMeal.meals.single.calorieShare, 1);
  });

  test(
    'ranks every entry stably for each metric against actual daily totals',
    () {
      final entries = [
        _entry('a', kcal: 200, protein: 10, fat: 1, carbs: 20),
        _entry('b', kcal: 100, protein: 30, fat: 3, carbs: 10),
        _entry('c', kcal: 200, protein: 20, fat: 2),
        _entry('d'),
        _entry('e', kcal: 50, protein: 10, fat: 4, carbs: 30),
      ];
      final snapshot = DayDetailsSnapshot(
        day: DateTime(2026, 1, 1),
        entries: entries,
        goals: [_goal('goal', DateTime(2025, 1, 1), 9999)],
      );
      final expectations =
          <DayDetailsMetric, (List<String>, List<double>, double)>{
            DayDetailsMetric.calories: (
              ['a', 'c', 'b', 'e', 'd'],
              [200, 200, 100, 50, 0],
              550,
            ),
            DayDetailsMetric.protein: (
              ['b', 'c', 'a', 'e', 'd'],
              [30, 20, 10, 10, 0],
              70,
            ),
            DayDetailsMetric.fat: (
              ['e', 'b', 'c', 'a', 'd'],
              [4, 3, 2, 1, 0],
              10,
            ),
            DayDetailsMetric.carbs: (
              ['e', 'a', 'b', 'c', 'd'],
              [30, 20, 10, 0, 0],
              60,
            ),
          };

      for (final metric in DayDetailsMetric.values) {
        final (ids, values, total) = expectations[metric]!;
        final ranked = snapshot.contributions(metric);
        expect(ranked.length, entries.length);
        expect(ranked.map((item) => item.entry.id), ids);
        expect(ranked.map((item) => item.value), values);
        for (var index = 0; index < ranked.length; index++) {
          expect(
            ranked[index].share,
            closeTo(values[index] / total, 0.000000001),
          );
        }
        expect(
          ranked.fold<double>(0, (sum, item) => sum + item.share!),
          closeTo(1, 0.000000001),
        );
      }
      expect(snapshot.entries, orderedEquals(entries));
      expect(
        snapshot.contributions(DayDetailsMetric.calories).first.entry,
        same(entries.first),
      );
    },
  );

  test(
    'logged zero is retained while empty days have no meals or rankings',
    () {
      final zero = _entry('zero', mealId: 'dinner', isEstimated: true);
      final logged = _snapshot([zero]);
      final empty = _snapshot([]);

      for (final snapshot in [logged, empty]) {
        expect(snapshot.totals.kcal, 0);
        expect(snapshot.totals.protein, 0);
        expect(snapshot.totals.fat, 0);
        expect(snapshot.totals.carbs, 0);
      }
      expect(logged.entries, [zero]);
      expect(logged.meals.single.entries, [zero]);
      expect(logged.meals.single.calorieShare, isNull);
      expect(logged.largestMeal, same(logged.meals.single));
      expect(logged.estimatedCount, 1);
      expect(empty.entries, isEmpty);
      expect(empty.meals, isEmpty);
      expect(empty.largestMeal, isNull);
      expect(empty.estimatedCount, 0);
      for (final metric in DayDetailsMetric.values) {
        expect(logged.contributions(metric).single.value, 0);
        expect(logged.contributions(metric).single.share, isNull);
        expect(empty.contributions(metric), isEmpty);
      }
    },
  );

  test('zero denominator is metric-specific rather than based on calories', () {
    final snapshot = _snapshot([_entry('energy-only', kcal: 25)]);

    expect(snapshot.contributions(DayDetailsMetric.calories).single.share, 1);
    for (final metric in [
      DayDetailsMetric.protein,
      DayDetailsMetric.fat,
      DayDetailsMetric.carbs,
    ]) {
      expect(snapshot.contributions(metric).single.share, isNull);
    }
    final proteinOnly = _snapshot([_entry('protein-only', protein: 5)]);
    expect(
      proteinOnly.contributions(DayDetailsMetric.calories).single.share,
      isNull,
    );
    expect(proteinOnly.contributions(DayDetailsMetric.protein).single.share, 1);
    expect(proteinOnly.meals.single.calorieShare, isNull);
  });

  test('owns immutable entry, meal and cached contribution lists', () {
    final entry = _entry('first', kcal: 125);
    final entries = [entry];
    final goal = _goal('goal', DateTime(2025, 1, 1), 2000);
    final goals = [goal];
    final snapshot = DayDetailsSnapshot(
      day: DateTime(2026, 1, 1),
      entries: entries,
      goals: goals,
    );
    entries.clear();
    goals.clear();

    expect(snapshot.entries, [entry]);
    expect(snapshot.totals.kcal, 125);
    expect(snapshot.goal, same(goal));
    expect(snapshot.meals.single.entries, [entry]);
    expect(() => snapshot.entries.add(entry), throwsUnsupportedError);
    expect(() => snapshot.meals.clear(), throwsUnsupportedError);
    expect(() => snapshot.meals.single.entries.clear(), throwsUnsupportedError);
    for (final metric in DayDetailsMetric.values) {
      final ranked = snapshot.contributions(metric);
      expect(ranked.single.entry, same(entry));
      expect(() => ranked.clear(), throwsUnsupportedError);
    }
  });
}

DayDetailsSnapshot _snapshot(List<DiaryEntry> entries) => DayDetailsSnapshot(
  day: DateTime(2026, 1, 1),
  entries: entries,
  goals: const [],
);

DiaryEntry _entry(
  String id, {
  String mealId = 'breakfast',
  double kcal = 0,
  double protein = 0,
  double fat = 0,
  double carbs = 0,
  bool isEstimated = false,
}) => DiaryEntry(
  id: id,
  day: DateTime(2026, 1, 1),
  mealId: mealId,
  food: const DiaryFoodSnapshot(
    foodId: 'catalog-snapshot',
    name: 'Food',
    baseUnit: DiaryBaseUnit.grams,
    basisAmount: 100,
    nutritionPerBasis: DiaryNutrition(
      kcal: 9876,
      protein: 90,
      fat: 80,
      carbs: 70,
    ),
    servings: [DiaryServingSnapshot(id: 'g', unit: 'grams', baseAmount: 1)],
  ),
  servingId: 'g',
  amount: 2.15,
  canonicalQuantity: 2.15,
  nutrition: DiaryNutrition(
    kcal: kcal,
    protein: protein,
    fat: fat,
    carbs: carbs,
  ),
  isEstimated: isEstimated,
);

GoalVersion _goal(String id, DateTime day, int kcal) => GoalVersion(
  id: id,
  day: day,
  goal: WeightGoal.maintain,
  calorieTarget: kcal,
  proteinTarget: 999,
  fatTarget: 999,
  carbsTarget: 999,
  targetWeightKg: 70,
);
