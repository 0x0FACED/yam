import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/statistics/data/statistics_repository.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';

void main() {
  test(
    'calendar range reacts to exact snapshot totals and Undo across years',
    () async {
      final database = YamDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final diary = DiaryRepository(database);
      final statistics = StatisticsRepository(database);
      final start = DateTime(2020, 12, 28);
      final end = DateTime(2021, 1, 3);
      Future<String> add(DateTime day, double amount) => diary.create(
        DiaryEntryDraft(
          day: day,
          mealId: 'breakfast',
          food: const DiaryFoodSnapshot(
            foodId: 'calendar-food',
            name: 'Calendar food',
            baseUnit: DiaryBaseUnit.grams,
            basisAmount: 1,
            nutritionPerBasis: DiaryNutrition(
              kcal: 1,
              protein: 0,
              fat: 0,
              carbs: 0,
            ),
            servings: [
              DiaryServingSnapshot(id: 'g', unit: 'grams', baseAmount: 1),
            ],
          ),
          servingId: 'g',
          amount: amount,
          canonicalQuantity: amount,
        ),
      );
      await add(DateTime(2020, 12, 27), 5000);
      await add(DateTime(2021, 1, 4), 5000);
      final changes = StreamIterator(
        statistics.watchNutritionRange(start: start, end: end),
      );
      addTearDown(changes.cancel);
      expect(await changes.moveNext(), isTrue);
      expect(changes.current, isEmpty);

      final firstId = await add(start, 450.125);
      expect(await changes.moveNext(), isTrue);
      expect(changes.current.single.day, start);
      expect(changes.current.single.kcal, 450.125);
      final secondId = await add(start, 449.875);
      expect(await changes.moveNext(), isTrue);
      expect(changes.current.single.kcal, 900);
      final originals = await diary.watchDay(start).first;
      final first = originals.singleWhere((entry) => entry.id == firstId);
      final second = originals.singleWhere((entry) => entry.id == secondId);

      await add(end, 1100);
      expect(await changes.moveNext(), isTrue);
      expect(changes.current.map((day) => day.day), [start, end]);
      expect(changes.current.map((day) => day.kcal), [900, 1100]);
      await diary.update(
        first,
        mealId: 'dinner',
        servingId: 'g',
        amount: 450.124999,
        canonicalQuantity: 450.124999,
      );
      expect(await changes.moveNext(), isTrue);
      expect(changes.current.first.kcal, closeTo(899.999999, 0.000000001));
      expect(
        calorieGoalDayStatus(
          kcal: changes.current.first.kcal,
          calorieTarget: 1000,
        ),
        GoalDayStatus.below,
      );

      await diary.delete(second.id);
      expect(await changes.moveNext(), isTrue);
      expect(changes.current.first.kcal, closeTo(450.124999, 0.000000001));
      await diary.restore(second);
      expect(await changes.moveNext(), isTrue);
      expect(changes.current.first.kcal, closeTo(899.999999, 0.000000001));
      await diary.restore(first);
      expect(await changes.moveNext(), isTrue);
      expect(changes.current.first.kcal, 900);
      await diary.delete(first.id);
      expect(await changes.moveNext(), isTrue);
      expect(changes.current.first.kcal, 449.875);
      await diary.delete(second.id);
      expect(await changes.moveNext(), isTrue);
      expect(changes.current.single.day, end);
      expect(changes.current.single.kcal, 1100);
    },
  );

  test(
    'goals and weight persist, changing a goal preserves its old version',
    () async {
      final dir = await Directory.systemTemp.createTemp('yam-stats-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/yam.sqlite');
      final database = YamDatabase(NativeDatabase(file));
      final repository = StatisticsRepository(database);
      final firstDay = DateTime(2020, 9, 20);
      const first = SessionProfile(
        goal: WeightGoal.lose,
        currentWeightKg: 74.2,
        targetWeightKg: 70,
        calorieTarget: 1900,
        proteinTarget: 140,
        fatTarget: 65,
        carbsTarget: 200,
      );
      await repository.saveOnboarding(first, firstDay);
      await repository.saveOnboarding(first, firstDay);
      await repository.saveOnboarding(first, DateTime(2020, 9, 21));
      expect(await repository.watchGoals().first, hasLength(1));
      expect(await repository.watchWeights().first, hasLength(1));

      const updated = SessionProfile(
        goal: WeightGoal.maintain,
        currentWeightKg: 73.1,
        targetWeightKg: 73,
        calorieTarget: 2200,
        proteinTarget: 150,
        fatTarget: 70,
        carbsTarget: 230,
      );
      await repository.saveOnboarding(updated, DateTime(2020, 9, 25));
      await database.close();
      final reopened = YamDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      final stored = StatisticsRepository(reopened);
      final goals = await stored.watchGoals().first;
      expect(goals.map((goal) => goal.calorieTarget), [1900, 2200]);
      final weights = await stored.watchWeights().first;
      expect(weights.map((weight) => weight.kg), [74.2, 73.1]);

      final id = await stored.addWeight(day: DateTime(2020, 9, 24), kg: 73.5);
      await stored.deleteWeight(id);
      expect((await stored.watchWeights().first).length, 2);
      await stored.restoreWeight(
        WeightRecord(id: id, day: DateTime(2020, 9, 24), kg: 73.5),
      );
      expect((await stored.watchWeights().first).length, 3);
      for (final weight in await stored.watchWeights().first) {
        await stored.deleteWeight(weight.id);
      }
      expect(await stored.watchWeights().first, isEmpty);
      expect(await stored.watchGoals().first, hasLength(2));
    },
  );

  test(
    'statistics queries use snapshots and ignore deleted diary entries',
    () async {
      final database = YamDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final diary = DiaryRepository(database);
      final statistics = StatisticsRepository(database);
      const food = DiaryFoodSnapshot(
        foodId: 'oats',
        name: 'Oats',
        baseUnit: DiaryBaseUnit.grams,
        basisAmount: 100,
        nutritionPerBasis: DiaryNutrition(
          kcal: 200,
          protein: 10,
          fat: 4,
          carbs: 30,
        ),
        servings: [DiaryServingSnapshot(id: 'g', unit: 'grams', baseAmount: 1)],
      );
      final firstId = await diary.create(
        DiaryEntryDraft(
          day: DateTime(2020, 9, 20),
          mealId: 'breakfast',
          food: food,
          servingId: 'g',
          amount: 50,
          canonicalQuantity: 50,
        ),
      );
      await diary.create(
        DiaryEntryDraft(
          day: DateTime(2020, 9, 20),
          mealId: 'dinner',
          food: food,
          servingId: 'g',
          amount: 25,
          canonicalQuantity: 25,
        ),
      );
      await diary.create(
        DiaryEntryDraft(
          day: DateTime(2020, 9, 21),
          mealId: 'lunch',
          food: food,
          servingId: 'g',
          amount: 100,
          canonicalQuantity: 100,
        ),
      );
      const period = StatisticsPeriod.days7;
      var totals = await statistics
          .watchNutrition(today: DateTime(2020, 9, 22), period: period)
          .first;
      expect(totals.map((entry) => entry.kcal), [150, 200]);
      var frequent = await statistics
          .watchFrequentFoods(today: DateTime(2020, 9, 22), period: period)
          .first;
      expect(frequent.single.days, 2);
      expect(frequent.single.averageAmount, closeTo(58.3333, 0.001));

      await diary.delete(firstId);
      totals = await statistics
          .watchNutrition(today: DateTime(2020, 9, 22), period: period)
          .first;
      frequent = await statistics
          .watchFrequentFoods(today: DateTime(2020, 9, 22), period: period)
          .first;
      expect(totals.map((entry) => entry.kcal), [50, 200]);
      expect(frequent.single.days, 2);
      expect(frequent.single.averageAmount, 62.5);
    },
  );
}
