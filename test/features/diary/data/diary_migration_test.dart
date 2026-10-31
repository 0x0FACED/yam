import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';

import '../../food_search/data/generated/schema.dart';

void main() {
  test('v1 foods and servings survive migration to schema v6', () async {
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
    await verifier.migrateAndValidate(db, 6);
    addTearDown(db.close);
    final foods = await UserFoodRepository(db).loadFoods();
    expect(foods, hasLength(1));
    expect(foods.single.food.energyKcal, 300);
    expect(foods.single.food.isFavorite, isTrue);
    expect(foods.single.food.description, isNull);
    expect(foods.single.servings.single.id, 'serving-v1');
    expect(await db.select(db.diaryEntries).get(), isEmpty);
    expect(
      (await db.select(db.installationValues).getSingle()).value,
      'existing-device',
    );
  });

  test('v2 diary entries survive migration to schema v6', () async {
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
    await verifier.migrateAndValidate(db, 6);
    addTearDown(db.close);
    final entries = await db.select(db.diaryEntries).get();
    expect(entries.single.foodName, 'Oats');
    expect(entries.single.energyKcal, 125);
    expect(await db.select(db.weightEntries).get(), isEmpty);
    expect(await db.select(db.goalVersions).get(), isEmpty);
  });

  for (final version in [3, 4, 5]) {
    test('filled v$version database survives migration to v6', () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(version);
      addTearDown(schema.close);
      final raw = schema.rawDatabase;
      raw.execute(
        'INSERT INTO installation_values (key, value) VALUES (?, ?)',
        ['deviceId', 'existing-device-v3'],
      );
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
      if (version >= 4) {
        raw.execute(
          'INSERT INTO user_foods (id, name, category, brand, barcode, basis_unit, '
          'basis_amount, display_basis, energy_kcal, protein_g, fat_g, carbs_g, '
          'is_favorite, created_at, updated_at, deleted_at, device_id) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            'deleted-food-v4',
            'Deleted recipe',
            '  Homemade bowls 🥣  ',
            'Original brand',
            '0012345',
            'grams',
            100,
            'perHundredGrams',
            246.1234567890123,
            9.1234567890123,
            3.333333333333333,
            42.9876543210987,
            1,
            100,
            101,
            102,
            'existing-device-v4',
          ],
        );
        for (final deleted in [false, true]) {
          raw.execute(
            'INSERT INTO remote_foods (id, source, source_code, name, brand, '
            'category, basis_unit, basis_amount, energy_kcal, protein_g, fat_g, '
            'carbs_g, last_amount, is_favorite, created_at, updated_at, '
            'deleted_at, device_id) '
            'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              deleted ? 'deleted-remote-v4' : 'remote-v4',
              'open_food_facts',
              deleted ? '000222' : '000111',
              'Cached milk',
              'Milk brand',
              'Provider/custom',
              'milliliters',
              100,
              47.1234567890123,
              3.333333333333333,
              1.111111111111111,
              4.444444444444444,
              137.1234567890123,
              1,
              100,
              101,
              deleted ? 102 : null,
              'existing-device-v4',
            ],
          );
        }
      }
      if (version == 5) {
        raw.execute('UPDATE user_foods SET description = ?', [
          '  Existing recipe\nKeep precision and whitespace.  ',
        ]);
      }

      final oldTables = [
        'installation_values',
        'user_foods',
        'user_servings',
        'diary_entries',
        'goal_versions',
        'weight_entries',
        if (version >= 4) 'remote_foods',
      ];
      final before = {
        for (final table in oldTables)
          table: [
            for (final row in raw.select('SELECT * FROM $table'))
              Map<String, Object?>.from(row),
          ],
      };
      final db = YamDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, 6);
      addTearDown(db.close);
      for (final table in oldTables) {
        expect(
          [
            for (final row
                in await db.customSelect('SELECT * FROM $table').get())
              {
                for (final entry in row.data.entries)
                  if (table != 'user_foods' ||
                      version >= 5 ||
                      entry.key != 'description')
                    entry.key: entry.value,
              },
          ],
          before[table],
          reason: '$table changed in v$version→v6 migration',
        );
      }
      expect(
        (await db.select(db.userFoods).get()).every(
          (food) =>
              food.description ==
              (version < 5
                  ? null
                  : '  Existing recipe\nKeep precision and whitespace.  '),
        ),
        isTrue,
      );
      if (version == 3) {
        expect(await db.select(db.remoteFoods).get(), isEmpty);
      }
    });
  }

  for (final version in [1, 2, 3, 4, 5]) {
    test(
      'v$version rebuild preserves exact foods, servings, indexes and foreign keys',
      () async {
        final verifier = SchemaVerifier(GeneratedHelper());
        final schema = await verifier.schemaAt(version);
        addTearDown(schema.close);
        final raw = schema.rawDatabase;
        raw.execute('PRAGMA foreign_keys = ON');
        for (final deleted in [false, true]) {
          final values = <Object?>[
            deleted ? 'deleted-food' : 'active-food',
            '  Homemade oats 🥣  ',
            'Custom/category',
            'Original brand',
            deleted ? '0098765' : '0012345',
            if (version >= 5) '  Recipe\nKeep this exact.  ',
            'grams',
            80.1234567890123,
            'perServing',
            246.1234567890123,
            9.1234567890123,
            3.333333333333333,
            42.9876543210987,
            1,
            100,
            101,
            deleted ? 102 : null,
            'existing-device',
          ];
          raw.execute(
            'INSERT INTO user_foods (id, name, category, brand, barcode, '
            '${version >= 5 ? 'description, ' : ''}'
            'basis_unit, basis_amount, display_basis, energy_kcal, protein_g, '
            'fat_g, carbs_g, is_favorite, created_at, updated_at, deleted_at, '
            'device_id) VALUES (${List.filled(values.length, '?').join(', ')})',
            values,
          );
          raw.execute(
            'INSERT INTO user_servings (id, food_id, unit, label, base_amount, '
            'default_amount, created_at, updated_at, deleted_at, device_id) '
            'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              deleted ? 'deleted-serving' : 'active-serving',
              deleted ? 'deleted-food' : 'active-food',
              'serving',
              'Original bowl',
              80.1234567890123,
              1.375,
              100,
              101,
              deleted ? 102 : null,
              'existing-device',
            ],
          );
        }
        final before = {
          for (final table in ['user_foods', 'user_servings'])
            table: [
              for (final row in raw.select('SELECT * FROM $table ORDER BY id'))
                Map<String, Object?>.from(row),
            ],
        };

        final db = YamDatabase(schema.newConnection());
        addTearDown(db.close);
        await verifier.migrateAndValidate(db, 6);
        for (final table in before.keys) {
          expect([
            for (final row
                in await db
                    .customSelect('SELECT * FROM $table ORDER BY id')
                    .get())
              {
                for (final entry in row.data.entries)
                  if (table != 'user_foods' ||
                      version >= 5 ||
                      entry.key != 'description')
                    entry.key: entry.value,
              },
          ], before[table]);
        }
        final indexes = await db
            .customSelect('PRAGMA index_list(user_foods)')
            .get();
        expect(
          indexes.map((row) => row.read<String>('name')),
          containsAll([
            'user_foods_history',
            'user_foods_name',
            'user_foods_barcode',
          ]),
        );
        expect(
          indexes
              .singleWhere(
                (row) => row.read<String>('name') == 'user_foods_barcode',
              )
              .read<int>('unique'),
          0,
        );
        expect(
          (await db.customSelect('PRAGMA index_info(user_foods_barcode)').get())
              .map((row) => row.read<String>('name')),
          ['barcode', 'deleted_at'],
        );
        final foreignKey =
            (await db
                    .customSelect('PRAGMA foreign_key_list(user_servings)')
                    .get())
                .single;
        expect(foreignKey.read<String>('table'), 'user_foods');
        expect(foreignKey.read<String>('from'), 'food_id');
        expect(foreignKey.read<String>('to'), 'id');
        expect(
          await db.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
        final serving = (await db.select(db.userServings).get()).first;
        await expectLater(
          db
              .into(db.userServings)
              .insert(serving.copyWith(id: 'orphan', foodId: 'missing-food')),
          throwsA(anything),
        );

        final food = (await db.select(db.userFoods).get()).firstWhere(
          (food) => food.id == 'active-food',
        );
        await db
            .into(db.userFoods)
            .insert(food.copyWith(id: 'duplicate-barcode'));
        expect(await UserFoodRepository(db).barcodeExists('0012345'), isTrue);
        expect(
          await db.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      },
    );
  }
}
