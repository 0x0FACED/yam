import 'package:flutter_test/flutter_test.dart';
import 'package:yam/features/diary/presentation/diary_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations_en.dart';

void main() {
  test('a new day has no invented entries', () {
    final day = buildDiaryPrototypeDay(AppLocalizationsEn());

    expect(day.meals, hasLength(4));
    expect(day.meals.every((meal) => meal.entries.isEmpty), isTrue);
    expect(day.consumedCalories, 0);
  });

  test('derived totals use exact stored nutrition before rounding', () {
    final day = buildDiaryPrototypeDay(
      AppLocalizationsEn(),
      entriesByMeal: const {
        'breakfast': [
          DiaryPrototypeEntry(
            id: 'first',
            name: 'Oats',
            quantity: '40 g',
            calories: 2,
            exactCalories: 1.6,
            protein: 1.4,
          ),
          DiaryPrototypeEntry(
            id: 'second',
            name: 'Milk',
            quantity: '20 ml',
            calories: 2,
            exactCalories: 1.6,
            protein: 1.4,
          ),
        ],
      },
    );

    expect(day.meals.first.calories, 3);
    expect(day.consumedCalories, 3);
    expect(day.protein, 3);
  });
}
