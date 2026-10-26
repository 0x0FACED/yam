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
import 'package:yam/features/statistics/presentation/widgets/statistics_charts.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('deleted selected weight does not leave stale inspection', (
    tester,
  ) async {
    final fixture = await _Fixture.create(tester);
    await fixture.statistics.addWeight(day: DateTime(2020, 9, 23), kg: 77);
    final selectedId = await fixture.statistics.addWeight(
      day: DateTime(2020, 9, 24),
      kg: 76,
    );
    await tester.pumpWidget(fixture.app());
    await tester.pumpAndSettle();
    final chart = find.byType(StatisticsWeightChart);
    final rect = tester.getRect(chart);
    await tester.tapAt(Offset(rect.right - 8, rect.top + 40));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(StatisticsInspectionDetails),
        matching: find.text('76 kg'),
      ),
      findsOneWidget,
    );

    await fixture.statistics.deleteWeight(selectedId);
    await tester.pumpAndSettle();
    expect(find.byType(StatisticsInspectionDetails), findsNothing);
    await tester.tapAt(Offset(rect.left + 8, rect.top + 40));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(StatisticsInspectionDetails),
        matching: find.text('75 kg'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

class _Fixture {
  _Fixture(this.statistics);
  final StatisticsRepository statistics;
  static final today = DateTime(2020, 9, 25);

  static Future<_Fixture> create(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final statistics = StatisticsRepository(database);
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
      DateTime(2020, 9, 20),
    );
    await DiaryRepository(database).create(
      DiaryEntryDraft(
        day: today,
        mealId: 'breakfast',
        food: const DiaryFoodSnapshot(
          foodId: 'oats',
          name: 'Oats',
          baseUnit: DiaryBaseUnit.grams,
          basisAmount: 100,
          nutritionPerBasis: DiaryNutrition(
            kcal: 1800,
            protein: 90,
            fat: 45,
            carbs: 225,
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
    return _Fixture(statistics);
  }

  Widget app() => MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: StatisticsScreen(repository: statistics, today: today),
  );
}
