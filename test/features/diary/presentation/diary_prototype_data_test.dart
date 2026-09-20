import 'package:flutter_test/flutter_test.dart';
import 'package:yam/features/diary/presentation/diary_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations_en.dart';

void main() {
  test('derives summary and meal totals from visible entries', () {
    final day = buildDiaryPrototypeDay(
      AppLocalizationsEn(),
      includeEntries: true,
    );

    expect(day.meals.map((meal) => meal.calories), [482, 711, 512, 135]);
    expect(day.consumedCalories, 1840);
    expect(day.protein, 126);
    expect(day.fat, 61);
    expect(day.carbs, 184);
  });

  test('includes presentation additions in every derived total', () {
    final day = buildDiaryPrototypeDay(
      AppLocalizationsEn(),
      includeEntries: true,
      additionalEntries: const {
        'breakfast': [
          DiaryPrototypeEntry(
            id: 'added',
            name: 'Added food',
            quantity: '50 g',
            calories: 100,
            protein: 4.5,
            fat: 2.5,
            carbs: 8.5,
          ),
        ],
      },
    );

    expect(day.consumedCalories, 1940);
    expect(day.protein, 131);
    expect(day.fat, 64);
    expect(day.carbs, 193);
  });
}
