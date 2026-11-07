import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/statistics/data/statistics_repository.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';
import 'package:yam/features/statistics/presentation/statistics_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  for (final source in ['goals', 'weights', 'nutrition', 'frequent']) {
    for (final afterPayload in [false, true]) {
      testWidgets(
        '$source read error recovers on retry, loaded=$afterPayload',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(1280, 1000);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final database = YamDatabase(NativeDatabase.memory());
          addTearDown(database.close);
          final repository = _ControlledStatisticsRepository(database);
          addTearDown(repository.close);
          await tester.pumpWidget(_statisticsApp(repository));
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.text('No food entries in this period'), findsNothing);
          if (afterPayload) {
            repository.emit();
            await tester.pumpAndSettle();
            expect(find.text('Recovered food'), findsOneWidget);
          }
          repository.fail(source);
          await tester.pumpAndSettle();
          expect(find.text('Statistics could not be loaded'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.text('Recovered food'), findsNothing);
          expect(find.text('No food entries in this period'), findsNothing);
          await tester.tap(find.text('Retry'));
          await tester.pump();
          expect(repository.goals.length, 2);
          expect(repository.weights.length, 2);
          expect(repository.nutrition.length, 2);
          expect(repository.frequent.length, 2);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          repository.emit();
          await tester.pumpAndSettle();
          expect(find.text('Recovered food'), findsOneWidget);
          expect(find.text('Statistics could not be loaded'), findsNothing);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }

  testWidgets('old range and repository errors cannot replace current data', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final old = _ControlledStatisticsRepository(database);
    final current = _ControlledStatisticsRepository(database);
    addTearDown(old.close);
    addTearDown(current.close);
    await tester.pumpWidget(_statisticsApp(old));
    old.emit();
    await tester.pumpAndSettle();
    final oldNutrition = old.nutrition.last;
    final oldFrequent = old.frequent.last;
    await tester.tap(find.text('7D'));
    await tester.pump();
    old.emit();
    oldNutrition.addError(StateError('old range'));
    oldFrequent.addError(StateError('old range'));
    await tester.pumpAndSettle();
    expect(find.text('Recovered food'), findsOneWidget);
    await tester.pumpWidget(_statisticsApp(current));
    current.emit();
    old.fail('goals');
    old.fail('weights');
    await tester.pumpAndSettle();
    expect(find.text('Recovered food'), findsOneWidget);
    expect(find.text('Statistics could not be loaded'), findsNothing);
    expect(current.periods.last, StatisticsPeriod.days7);
    current.fail('nutrition');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(current.periods.last, StatisticsPeriod.days7);
    current.emit();
    await tester.pumpAndSettle();
    expect(find.text('Recovered food'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('statistics refreshes when local goals and food are saved', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final statistics = StatisticsRepository(database);
    final diary = DiaryRepository(database);
    final day = DateTime(2020, 9, 25);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StatisticsScreen(repository: statistics, today: day),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('No food entries in this period'), findsWidgets);

    await statistics.saveOnboarding(
      const SessionProfile(
        goal: WeightGoal.maintain,
        currentWeightKg: 75,
        targetWeightKg: 74,
        calorieTarget: 2000,
        proteinTarget: 100,
        fatTarget: 50,
        carbsTarget: 250,
      ),
      day,
    );
    await diary.create(
      DiaryEntryDraft(
        day: day,
        mealId: 'breakfast',
        food: const DiaryFoodSnapshot(
          foodId: 'oats',
          name: 'Oats',
          baseUnit: DiaryBaseUnit.grams,
          basisAmount: 100,
          nutritionPerBasis: DiaryNutrition(
            kcal: 2000,
            protein: 100,
            fat: 50,
            carbs: 250,
          ),
          servings: [
            DiaryServingSnapshot(id: 'grams', unit: 'grams', baseAmount: 1),
          ],
        ),
        servingId: 'grams',
        amount: 100,
        canonicalQuantity: 100,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Oats'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

Widget _statisticsApp(StatisticsRepository repository) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: StatisticsScreen(repository: repository, today: DateTime(2020, 9, 25)),
);

class _ControlledStatisticsRepository extends StatisticsRepository {
  _ControlledStatisticsRepository(super.database);

  final goals = <StreamController<List<GoalVersion>>>[];
  final weights = <StreamController<List<WeightRecord>>>[];
  final nutrition = <StreamController<List<NutritionDay>>>[];
  final frequent = <StreamController<List<FrequentFood>>>[];
  final periods = <StatisticsPeriod>[];

  Stream<T> _watch<T>(List<StreamController<T>> controllers) {
    final controller = StreamController<T>.broadcast();
    controllers.add(controller);
    return controller.stream;
  }

  @override
  Stream<List<GoalVersion>> watchGoals() => _watch(goals);

  @override
  Stream<List<WeightRecord>> watchWeights() => _watch(weights);

  @override
  Stream<List<NutritionDay>> watchNutrition({
    required DateTime today,
    required StatisticsPeriod period,
  }) {
    periods.add(period);
    return _watch(nutrition);
  }

  @override
  Stream<List<FrequentFood>> watchFrequentFoods({
    required DateTime today,
    required StatisticsPeriod period,
  }) => _watch(frequent);

  void emit() {
    goals.last.add(const []);
    weights.last.add(const []);
    nutrition.last.add([
      NutritionDay(
        day: DateTime(2020, 9, 25),
        kcal: 100,
        protein: 5,
        fat: 2,
        carbs: 10,
      ),
    ]);
    frequent.last.add(const [
      FrequentFood(
        name: 'Recovered food',
        days: 1,
        averageAmount: 100,
        unit: DiaryBaseUnit.grams,
      ),
    ]);
  }

  void fail(String source) {
    final error = StateError('unavailable');
    switch (source) {
      case 'goals':
        goals.last.addError(error);
      case 'weights':
        weights.last.addError(error);
      case 'nutrition':
        nutrition.last.addError(error);
      case 'frequent':
        frequent.last.addError(error);
    }
  }

  Future<void> close() async {
    for (final controller in [
      ...goals,
      ...weights,
      ...nutrition,
      ...frequent,
    ]) {
      await controller.close();
    }
  }
}
