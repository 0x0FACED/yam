import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';

import '../../food_search/data/generated/schema.dart';

void main() {
  test('v1 foods and servings survive migration to diary schema v2', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(1);
    addTearDown(schema.close);
    schema.rawDatabase.execute(
      'INSERT INTO installation_values (key, value) VALUES (?, ?)',
      ['deviceId', 'existing-device'],
    );
    schema.rawDatabase.execute(
      'INSERT INTO user_foods (id, name, category, basis_unit, '
      'basis_amount, display_basis, energy_kcal, protein_g, fat_g, carbs_g, '
      'is_favorite, created_at, updated_at, device_id) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'food-v1',
        'Oats',
        'grains',
        'grams',
        100,
        'perHundredGrams',
        300,
        10,
        5,
        20,
        1,
        1,
        1,
        'existing-device',
      ],
    );
    schema.rawDatabase.execute(
      'INSERT INTO user_servings (id, food_id, unit, base_amount, '
      'default_amount, created_at, updated_at, device_id) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      ['serving-v1', 'food-v1', 'serving', 80, 1, 1, 1, 'existing-device'],
    );

    final db = YamDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    addTearDown(db.close);
    final foods = await UserFoodRepository(db).loadFoods();
    expect(foods, hasLength(1));
    expect(foods.single.food.energyKcal, 300);
    expect(foods.single.food.isFavorite, isTrue);
    expect(foods.single.servings.single.id, 'serving-v1');
    expect(await db.select(db.diaryEntries).get(), isEmpty);
    expect(
      (await db.select(db.installationValues).getSingle()).value,
      'existing-device',
    );
  });
}
