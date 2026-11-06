import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/diary/presentation/diary_prototype_data.dart';
import 'package:yam/features/diary/presentation/widgets/edit_diary_entry_sheet.dart';
import 'package:yam/features/diary/presentation/widgets/meal_section.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  for (final language in ['en', 'ru']) {
    for (final estimated in [true, false]) {
      testWidgets('$language estimated=$estimated is visible in diary row and edit sheet', (tester) async {
        final entry = DiaryEntry(
          id: 'entry', day: DateTime(2026, 11, 6), mealId: 'dinner',
          food: const DiaryFoodSnapshot(
            foodId: 'food', name: 'Soup', baseUnit: DiaryBaseUnit.milliliters,
            basisAmount: 100,
            nutritionPerBasis: DiaryNutrition(kcal: 50, protein: 3, fat: 2, carbs: 5),
            servings: [DiaryServingSnapshot(id: 'milliliters', unit: 'milliliters', baseAmount: 1)],
          ),
          servingId: 'milliliters', amount: 150, canonicalQuantity: 150,
          nutrition: const DiaryNutrition(kcal: 75, protein: 4.5, fat: 3, carbs: 7.5),
          isEstimated: estimated,
        );
        late String label;
        await tester.pumpWidget(MaterialApp(
          locale: Locale(language), theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            label = l10n.assistantEstimatedLabel;
            return Scaffold(body: MealSection(
              meal: DiaryPrototypeMeal(id: 'dinner', name: l10n.mealDinner,
                entries: [DiaryPrototypeEntry(id: entry.id, name: entry.food.name,
                  quantity: '150 ml', calories: 75, storedEntry: entry)]),
              onAddFood: () {},
              onEntryPressed: (_) => showEditDiaryEntrySheet(context: context, entry: entry),
            ));
          }),
        ));
        expect(find.textContaining(label), estimated ? findsOneWidget : findsNothing);
        await tester.tap(find.text('Soup'));
        await tester.pumpAndSettle();
        expect(find.textContaining(label), estimated ? findsNWidgets(2) : findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
