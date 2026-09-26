import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';

import '../../food_search/data/generated/schema.dart';

void main() {
  test('v1 foods and servings survive migration to schema v4', () async {
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
    await verifier.migrateAndValidate(db, 4);
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

  test('v2 diary entries survive migration to schema v4', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(2);
    addTearDown(schema.close);
    schema.rawDatabase.execute(
      'INSERT INTO diary_entries (id, diary_day, meal_id, food_id, food_name, '
      'base_unit, basis_amount, kcal_per_basis, protein_per_basis, '
      'fat_per_basis, carbs_per_basis, servings_snapshot, serving_id, '
      'amount, canonical_quantity, energy_kcal, protein_g, fat_g, carbs_g, '
      'created_at, updated_at, device_id) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'entry-v2',
        '2026-09-24',
        'breakfast',
        'food-v2',
        'Oats',
        'grams',
        100,
        250.0,
        10.0,
        5.0,
        20.0,
        '[{"id":"grams","unit":"grams","baseAmount":1.0}]',
        'grams',
        50.0,
        50.0,
        125.0,
        5.0,
        2.5,
        10.0,
        1,
        1,
        'device-v2',
      ],
    );
    final db = YamDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);
    addTearDown(db.close);
    final entries = await db.select(db.diaryEntries).get();
    expect(entries.single.foodName, 'Oats');
    expect(entries.single.energyKcal, 125);
    expect(await db.select(db.weightEntries).get(), isEmpty);
    expect(await db.select(db.goalVersions).get(), isEmpty);
  });

  test('filled v3 database survives additive migration to v4', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(3);
    addTearDown(schema.close);
    final raw = schema.rawDatabase;
    raw.execute('INSERT INTO installation_values (key, value) VALUES (?, ?)', [
      'deviceId',
      'existing-device-v3',
    ]);
    raw.execute(
      'INSERT INTO user_foods (id, name, category, basis_unit, '
      'basis_amount, display_basis, energy_kcal, protein_g, fat_g, carbs_g, '
      'is_favorite, created_at, updated_at, device_id) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'food-v3',
        'Oats',
        'grains',
        'grams',
        100,
        'perHundredGrams',
        366.25,
        12.3,
        6.1,
        59.5,
        1,
        100,
        101,
        'existing-device-v3',
      ],
    );
    raw.execute(
      'INSERT INTO user_servings (id, food_id, unit, base_amount, '
      'default_amount, created_at, updated_at, device_id) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'portion-v3',
        'food-v3',
        'serving',
        80.5,
        1,
        100,
        101,
        'existing-device-v3',
      ],
    );
    raw.execute(
      'INSERT INTO diary_entries (id, diary_day, meal_id, food_id, food_name, '
      'base_unit, basis_amount, kcal_per_basis, protein_per_basis, '
      'fat_per_basis, carbs_per_basis, servings_snapshot, serving_id, '
      'amount, canonical_quantity, energy_kcal, protein_g, fat_g, carbs_g, '
      'created_at, updated_at, device_id) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'entry-v3',
        '2026-09-25',
        'breakfast',
        'food-v3',
        'Original oats',
        'grams',
        100,
        366.25,
        12.3,
        6.1,
        59.5,
        '[{"id":"grams","unit":"grams","baseAmount":1.0}]',
        'grams',
        50.5,
        50.5,
        184.95625,
        6.2115,
        3.0805,
        30.0475,
        102,
        103,
        'existing-device-v3',
      ],
    );
    raw.execute(
      'INSERT INTO goal_versions (id, effective_day, goal, calorie_target, '
      'protein_target, fat_target, carbs_target, target_weight_kg, '
      'created_at, updated_at, device_id) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        'goal-v3',
        '2026-09-25',
        'lose',
        1900,
        140,
        65,
        200,
        70.5,
        100,
        101,
        'existing-device-v3',
      ],
    );
    raw.execute(
      'INSERT INTO weight_entries (id, local_day, weight_kg, source, '
      'created_at, updated_at, device_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        'weight-v3',
        '2026-09-25',
        74.25,
        'manual',
        102,
        103,
        'existing-device-v3',
      ],
    );

    const oldTables = [
      'installation_values',
      'user_foods',
      'user_servings',
      'diary_entries',
      'goal_versions',
      'weight_entries',
    ];
    final before = {
      for (final table in oldTables)
        table: [
          for (final row in raw.select('SELECT * FROM $table'))
            Map<String, Object?>.from(row),
        ],
    };
    final db = YamDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);
    addTearDown(db.close);
    for (final table in oldTables) {
      expect(
        [
          for (final row in await db.customSelect('SELECT * FROM $table').get())
            row.data,
        ],
        before[table],
        reason: '$table changed in v3→v4 migration',
      );
    }
    expect(await db.select(db.remoteFoods).get(), isEmpty);
  });
}
