import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/statistics/data/statistics_repository.dart';
import 'package:yam/features/statistics/presentation/statistics_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
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
    expect(find.text('Days in goal'), findsOneWidget);
    expect(find.text('Oats'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
