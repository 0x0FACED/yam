import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/app.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/core/ui/motion/yam_entrance_reveal.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/diary/presentation/widgets/daily_nutrition_summary.dart';
import 'package:yam/features/diary/presentation/widgets/diary_day_selector.dart';
import 'package:yam/features/statistics/data/statistics_repository.dart';
import 'package:yam/features/statistics/presentation/statistics_screen.dart';

void main() {
  testWidgets('date, period and route changes replay without losing state', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final statistics = StatisticsRepository(database);
    await statistics.saveOnboarding(
      const SessionProfile(
        goal: WeightGoal.maintain,
        currentWeightKg: 75,
        targetWeightKg: 75,
        calorieTarget: 2000,
        proteinTarget: 100,
        fatTarget: 60,
        carbsTarget: 260,
      ),
      yesterday,
    );
    final diary = DiaryRepository(database);
    await diary.create(_entry(today, 'Today food', 300));
    await diary.create(_entry(yesterday, 'Yesterday food', 500));
    await tester.pumpWidget(YamApp(appVersion: '0.4.0+8', database: database));
    await tester.pumpAndSettle();
    expect(find.text('Today food'), findsOneWidget);
    expect(_diaryOpacity(tester), 1);

    await tester.tap(find.byTooltip('Previous day'));
    await tester.pump();
    expect(_diaryOpacity(tester), 0);
    expect(_opacityAbove(tester, find.byType(DiaryDaySelector)), 1);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pump(const Duration(milliseconds: 60));
    expect(_diaryOpacity(tester), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(find.text('Yesterday food'), findsOneWidget);
    expect(find.text('Today food'), findsNothing);

    await diary.create(_entry(yesterday, 'Live update', 150));
    for (
      var frame = 0;
      frame < 100 && find.text('Live update').evaluate().isEmpty;
      frame++
    ) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    expect(find.text('Live update'), findsOneWidget);
    expect(_diaryOpacity(tester), 1);

    await tester.tap(find.byTooltip('Next day'));
    await tester.pump();
    await tester.tap(find.byTooltip('Previous day'));
    await tester.pumpAndSettle();
    expect(find.text('Yesterday food'), findsOneWidget);
    expect(find.text('Today food'), findsNothing);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('stats-period-days7')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    final summary = find.descendant(
      of: find.byType(StatisticsScreen),
      matching: find.byWidgetPredicate(
        (widget) => widget is YamEntranceReveal && widget.index == 1,
      ),
    );
    for (var frame = 0; frame < 100 && summary.evaluate().isEmpty; frame++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    expect(summary, findsOneWidget);
    expect(_revealOpacity(tester, summary), 0);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pump(const Duration(milliseconds: 60));
    expect(_revealOpacity(tester, summary), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Diary'));
    await tester.pump();
    expect(_diaryOpacity(tester), 0);
    expect(
      tester
          .widget<DiaryDaySelector>(find.byType(DiaryDaySelector))
          .selectedDay,
      yesterday,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diary'));
    await tester.pump();
    expect(_diaryOpacity(tester), 1);

    await tester.tap(find.byKey(const ValueKey('diary-add-food')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('food-search-create-food')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('create-food-name')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(_diaryOpacity(tester), 0);
    await tester.pumpAndSettle();
    expect(_diaryOpacity(tester), 1);
    expect(find.text('Yesterday food'), findsOneWidget);

    // Returning from search must not disable later date transitions.
    await tester.tap(find.byTooltip('Next day'));
    await tester.pump();
    expect(_diaryOpacity(tester), 0);
    await tester.pumpAndSettle();
    expect(find.text('Today food'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(
      _opacityAbove(tester, find.byKey(const ValueKey('settings-onboarding'))),
      0,
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

DiaryEntryDraft _entry(DateTime day, String name, double kcal) =>
    DiaryEntryDraft(
      day: day,
      mealId: 'breakfast',
      food: DiaryFoodSnapshot(
        foodId: name,
        name: name,
        baseUnit: DiaryBaseUnit.grams,
        basisAmount: 100,
        nutritionPerBasis: DiaryNutrition(
          kcal: kcal,
          protein: 10,
          fat: 5,
          carbs: 40,
        ),
        servings: const [
          DiaryServingSnapshot(id: 'grams', unit: 'grams', baseAmount: 1),
        ],
      ),
      servingId: 'grams',
      amount: 100,
      canonicalQuantity: 100,
    );

double _diaryOpacity(WidgetTester tester) =>
    _opacityAbove(tester, find.byType(DailyNutritionSummary));

double _opacityAbove(WidgetTester tester, Finder child) => _revealOpacity(
  tester,
  find.ancestor(of: child, matching: find.byType(YamEntranceReveal)).first,
);

double _revealOpacity(WidgetTester tester, Finder reveal) => tester
    .widget<FadeTransition>(
      find.descendant(of: reveal, matching: find.byType(FadeTransition)).first,
    )
    .opacity
    .value;
