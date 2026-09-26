import 'package:flutter_test/flutter_test.dart';
import 'package:yam/features/food_search/data/open_food_facts_client.dart';

Map<String, Object?> hit({
  String code = '0001234567890',
  Object? kcal = 145.123456,
  Object? protein = 3.123456,
  Object? fat = 4.01234,
  Object? carbs = 18.54321,
}) => {
  'code': code,
  'product_name': ' Oats ',
  'brands': ['Actual Brand'],
  'categories_tags': ['en:cereals-and-their-products'],
  'nutriments': {
    'energy-kcal_100g': kcal,
    'proteins_100g': protein,
    'fat_100g': fat,
    'carbohydrates_100g': carbs,
  },
};

void main() {
  test('maps valid results with exact values and source-scoped identity', () {
    final results = parseOpenFoodFactsSearch({
      'hits': [hit(), hit()],
    });
    expect(results, hasLength(1));
    final food = results.single;
    expect(food.id, 'off:0001234567890');
    expect(food.name, 'Oats');
    expect(food.brand, 'Actual Brand');
    expect(food.category, 'grains');
    expect(food.energyKcal, 145.123456);
    expect(food.proteinG, 3.123456);
    expect(food.fatG, 4.01234);
    expect(food.carbsG, 18.54321);
  });

  test(
    'skips missing, malformed and negative nutrition; accepts real zero',
    () {
      expect(
        parseOpenFoodFactsSearch({
          'hits': [
            hit(kcal: null),
            hit(fat: -0.01),
            hit(protein: '0'),
            hit(carbs: double.nan),
            hit(code: 'bad-code'),
            {...hit(), 'product_name': ''},
            {...hit(), 'no_nutrition_data': 'on'},
            hit(code: '0001234567891', protein: 0, fat: 0, carbs: 0),
            1,
          ],
        }).map((food) => food.code),
        ['0001234567891'],
      );
      expect(
        () => parseOpenFoodFactsSearch({'hits': 'invalid'}),
        throwsFormatException,
      );
      expect(
        () => parseOpenFoodFactsSearch({'errors': []}),
        throwsFormatException,
      );
      expect(
        () => parseOpenFoodFactsSearch({'hits': [], 'timed_out': true}),
        throwsFormatException,
      );
    },
  );

  test('does not invent a ml to g conversion from a volume serving', () {
    expect(
      OpenFoodFactsProduct.fromJson({
        ...hit(),
        'nutrition_data_per': 'serving',
        'serving_quantity_unit': 'ml',
      }),
      isNull,
    );
    expect(
      OpenFoodFactsProduct.fromJson({
        ...hit(),
        'nutrition_data_per': 'serving',
      }),
      isNull,
    );
    expect(
      OpenFoodFactsProduct.fromJson({
        ...hit(),
        'nutrition_data_per': 'serving',
        'serving_quantity_unit': 'g',
      }),
      isNotNull,
    );
    final product = OpenFoodFactsProduct.fromJson({
      ...hit(),
      'serving_quantity': 250,
      'serving_quantity_unit': 'ml',
      'nutrition_data_per': '100g',
    });
    expect(product, isNotNull);
    expect(product!.energyKcal, 145.123456); // per 100 g, not 250 ml
  });
}
