import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';

const example = CustomFoodDraft(
  name: 'Homemade oats',
  category: 'grains',
  basis: CustomFoodBasis.grams,
  basisAmount: 80,
  displayBasis: CustomFoodDisplayBasis.perServing,
  proteinG: 9.84,
  fatG: 4.88,
  carbsG: 47.6,
  servings: [
    CustomServingDraft(
      unit: CustomServingUnit.serving,
      baseAmount: 80,
      defaultAmount: 1,
    ),
    CustomServingDraft(
      unit: CustomServingUnit.piece,
      label: 'bar',
      baseAmount: 40,
      defaultAmount: 1,
    ),
  ],
  barcode: '00012345',
);

void main() {
  test(
    'food and portion metadata survive reopening the local database',
    () async {
      final dir = await Directory.systemTemp.createTemp('yam-food-test-');
      addTearDown(() => dir.delete(recursive: true));
      final path = '${dir.path}/foods.sqlite';
      final database = YamDatabase(NativeDatabase(File(path)));
      final repository = UserFoodRepository(database);

      final id = await repository.create(example);
      expect(id[14], '7');
      await repository.setFavorite(id, true);
      await database.close();

      final reopened = YamDatabase(NativeDatabase(File(path)));
      addTearDown(reopened.close);
      final foods = await UserFoodRepository(reopened).watchFoods().first;
      expect(foods, hasLength(1));
      expect(foods.single.food.name, 'Homemade oats');
      expect(foods.single.food.barcode, '00012345');
      expect(foods.single.food.isFavorite, isTrue);
      expect(foods.single.food.energyKcal, closeTo(273.68, 0.000001));
      expect(foods.single.food.basisAmount, 80);
      expect(foods.single.servings, hasLength(2));
      expect(foods.single.servings.first.foodId, id);
      expect(foods.single.food.deviceId, isNotEmpty);
      expect(foods.single.food.deletedAt, isNull);
      expect(
        (await reopened.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        4,
      );
    },
  );

  test('invalid equivalences cannot create a partial product', () async {
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserFoodRepository(database);
    final invalid = CustomFoodDraft(
      name: example.name,
      category: example.category,
      basis: example.basis,
      basisAmount: example.basisAmount,
      displayBasis: example.displayBasis,
      proteinG: example.proteinG,
      fatG: example.fatG,
      carbsG: example.carbsG,
      servings: const [],
    );

    await expectLater(repository.create(invalid), throwsArgumentError);
    expect(await repository.watchFoods().first, isEmpty);
  });

  test('soft delete hides food and servings and frees its barcode', () async {
    final dir = await Directory.systemTemp.createTemp('yam-delete-test-');
    addTearDown(() => dir.delete(recursive: true));
    final path = '${dir.path}/foods.sqlite';
    final database = YamDatabase(NativeDatabase(File(path)));
    final repository = UserFoodRepository(database);

    final id = await repository.create(example);
    await repository.setFavorite(id, true);
    await repository.delete(id);
    expect(await repository.loadFoods(), isEmpty);
    expect(await repository.update(id, example), isFalse);
    expect(await repository.barcodeExists(example.barcode!), isFalse);

    final deletedFood = await (database.select(
      database.userFoods,
    )..where((food) => food.id.equals(id))).getSingle();
    final deletedServings = await (database.select(
      database.userServings,
    )..where((serving) => serving.foodId.equals(id))).get();
    expect(deletedFood.deletedAt, isNotNull);
    expect(deletedFood.updatedAt, deletedFood.deletedAt);
    expect(deletedFood.barcode, isNull);
    expect(deletedServings, hasLength(2));
    expect(
      deletedServings.every((serving) => serving.deletedAt != null),
      isTrue,
    );
    expect(
      deletedServings.every(
        (serving) => serving.updatedAt == serving.deletedAt,
      ),
      isTrue,
    );

    final recreatedId = await repository.create(example);
    expect(recreatedId, isNot(id));
    await database.close();

    final reopened = YamDatabase(NativeDatabase(File(path)));
    addTearDown(reopened.close);
    final foods = await UserFoodRepository(reopened).loadFoods();
    expect(foods.map((saved) => saved.food.id), [recreatedId]);
    expect(foods.single.food.barcode, example.barcode);
  });

  test(
    'updates a food and servings atomically without replacing identity',
    () async {
      final database = YamDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = UserFoodRepository(database);
      final initialDraft = CustomFoodDraft(
        name: example.name,
        category: example.category,
        brand: 'Old brand',
        barcode: example.barcode,
        basis: example.basis,
        basisAmount: example.basisAmount,
        displayBasis: example.displayBasis,
        proteinG: example.proteinG,
        fatG: example.fatG,
        carbsG: example.carbsG,
        servings: [
          ...example.servings,
          const CustomServingDraft(
            unit: CustomServingUnit.glass,
            label: 'cup',
            baseAmount: 250,
            defaultAmount: 1,
          ),
        ],
      );
      final id = await repository.create(initialDraft);
      await repository.setFavorite(id, true);
      final original = (await repository.loadFoods()).single;
      final originalServings = {
        for (final serving in original.servings) serving.id: serving,
      };

      expect(
        await repository.barcodeExists(example.barcode!, excludingFoodId: id),
        isFalse,
      );

      final updatedDraft = CustomFoodDraft(
        name: 'Updated oats',
        category: 'breakfast',
        brand: 'New brand',
        barcode: example.barcode,
        basis: CustomFoodBasis.grams,
        basisAmount: 100,
        displayBasis: CustomFoodDisplayBasis.perHundredGrams,
        proteinG: 10.123,
        fatG: 4.4,
        carbsG: 30.5,
        servings: [
          CustomServingDraft(
            existingId: original.servings[1].id,
            unit: CustomServingUnit.piece,
            label: 'large bar',
            baseAmount: 42.75,
            defaultAmount: 2.25,
          ),
          CustomServingDraft(
            existingId: original.servings[2].id,
            unit: CustomServingUnit.glass,
            label: 'cup',
            baseAmount: 250,
            defaultAmount: 1,
          ),
          const CustomServingDraft(
            unit: CustomServingUnit.scoop,
            label: 'scoop',
            baseAmount: 13.333,
            defaultAmount: 1.5,
          ),
        ],
      );

      await Future<void>.delayed(const Duration(seconds: 1));
      expect(await repository.update(id, updatedDraft), isTrue);
      final updated = (await repository.loadFoods()).single;
      final allServings = await (database.select(
        database.userServings,
      )..where((serving) => serving.foodId.equals(id))).get();
      final updatedServings = {
        for (final serving in allServings) serving.id: serving,
      };
      final changedServing = updatedServings[original.servings[1].id]!;
      final untouchedServing = updatedServings[original.servings[2].id]!;
      final removedServing = updatedServings[original.servings[0].id]!;
      final newServing = updated.servings.singleWhere(
        (serving) => serving.unit == CustomServingUnit.scoop.name,
      );

      expect(updated.food.id, id);
      expect(updated.food.name, updatedDraft.name);
      expect(updated.food.category, updatedDraft.category);
      expect(updated.food.brand, updatedDraft.brand);
      expect(updated.food.barcode, example.barcode);
      expect(updated.food.basisAmount, 100);
      expect(
        updated.food.displayBasis,
        CustomFoodDisplayBasis.perHundredGrams.name,
      );
      expect(updated.food.proteinG, updatedDraft.proteinG);
      expect(updated.food.fatG, updatedDraft.fatG);
      expect(updated.food.carbsG, updatedDraft.carbsG);
      expect(updated.food.energyKcal, updatedDraft.energyKcal);
      expect(updated.food.createdAt, original.food.createdAt);
      expect(updated.food.deviceId, original.food.deviceId);
      expect(updated.food.isFavorite, isTrue);
      expect(updated.food.updatedAt, isNot(original.food.updatedAt));

      expect(changedServing.id, original.servings[1].id);
      expect(changedServing.label, 'large bar');
      expect(changedServing.baseAmount, 42.75);
      expect(changedServing.defaultAmount, 2.25);
      expect(
        changedServing.createdAt,
        originalServings[changedServing.id]!.createdAt,
      );
      expect(
        changedServing.deviceId,
        originalServings[changedServing.id]!.deviceId,
      );
      expect(
        changedServing.updatedAt,
        isNot(originalServings[changedServing.id]!.updatedAt),
      );
      expect(
        untouchedServing.createdAt,
        originalServings[untouchedServing.id]!.createdAt,
      );
      expect(
        untouchedServing.updatedAt,
        originalServings[untouchedServing.id]!.updatedAt,
      );
      expect(
        untouchedServing.deviceId,
        originalServings[untouchedServing.id]!.deviceId,
      );
      expect(removedServing.deletedAt, isNotNull);
      expect(removedServing.updatedAt, removedServing.deletedAt);
      expect(newServing.id[14], '7');
      expect(newServing.createdAt, newServing.updatedAt);
      expect(newServing.deviceId, updated.food.deviceId);

      final secondFoodId = await repository.create(
        CustomFoodDraft(
          name: 'Other food',
          category: 'other',
          barcode: '987654321',
          basis: CustomFoodBasis.grams,
          basisAmount: 100,
          displayBasis: CustomFoodDisplayBasis.perHundredGrams,
          proteinG: 1,
          fatG: 2,
          carbsG: 3,
          servings: const [
            CustomServingDraft(
              unit: CustomServingUnit.piece,
              baseAmount: 4,
              defaultAmount: 1,
            ),
          ],
        ),
      );
      expect(
        await repository.barcodeExists('987654321', excludingFoodId: id),
        isTrue,
      );

      final beforeConflict = (await repository.loadFoods()).firstWhere(
        (saved) => saved.food.id == id,
      );
      final servingsBeforeConflict = await (database.select(
        database.userServings,
      )..where((serving) => serving.foodId.equals(id))).get();
      final conflictDraft = CustomFoodDraft(
        name: 'Should roll back',
        category: updatedDraft.category,
        barcode: '987654321',
        basis: updatedDraft.basis,
        basisAmount: updatedDraft.basisAmount,
        displayBasis: updatedDraft.displayBasis,
        proteinG: updatedDraft.proteinG,
        fatG: updatedDraft.fatG,
        carbsG: updatedDraft.carbsG,
        servings: updated.servings
            .map(
              (serving) => CustomServingDraft(
                existingId: serving.id,
                unit: CustomServingUnit.values.byName(serving.unit),
                label: serving.label,
                baseAmount: serving.baseAmount + 1,
                defaultAmount: serving.defaultAmount,
              ),
            )
            .toList(),
      );
      await expectLater(
        repository.update(id, conflictDraft),
        throwsA(anything),
      );
      final afterConflict = (await repository.loadFoods()).firstWhere(
        (saved) => saved.food.id == id,
      );
      final servingsAfterConflict = await (database.select(
        database.userServings,
      )..where((serving) => serving.foodId.equals(id))).get();
      expect(afterConflict.food, beforeConflict.food);
      expect(servingsAfterConflict, servingsBeforeConflict);

      final repeatedServingDraft = CustomFoodDraft(
        name: updatedDraft.name,
        category: updatedDraft.category,
        basis: updatedDraft.basis,
        basisAmount: updatedDraft.basisAmount,
        displayBasis: updatedDraft.displayBasis,
        proteinG: updatedDraft.proteinG,
        fatG: updatedDraft.fatG,
        carbsG: updatedDraft.carbsG,
        servings: [updatedDraft.servings.first, updatedDraft.servings.first],
      );
      await expectLater(
        repository.update(id, repeatedServingDraft),
        throwsArgumentError,
      );
      final foreignServingDraft = CustomFoodDraft(
        name: updatedDraft.name,
        category: updatedDraft.category,
        basis: updatedDraft.basis,
        basisAmount: updatedDraft.basisAmount,
        displayBasis: updatedDraft.displayBasis,
        proteinG: updatedDraft.proteinG,
        fatG: updatedDraft.fatG,
        carbsG: updatedDraft.carbsG,
        servings: [
          CustomServingDraft(
            existingId: (await repository.loadFoods())
                .singleWhere((saved) => saved.food.id == secondFoodId)
                .servings
                .first
                .id,
            unit: CustomServingUnit.piece,
            baseAmount: 4,
            defaultAmount: 1,
          ),
        ],
      );
      await expectLater(
        repository.update(id, foreignServingDraft),
        throwsArgumentError,
      );
      expect(
        (await repository.loadFoods())
            .singleWhere((saved) => saved.food.id == id)
            .food,
        beforeConflict.food,
      );
    },
  );

  test(
    'brands from both local catalogs are normalized and prefix-matched',
    () async {
      final database = YamDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = UserFoodRepository(database);
      final now = DateTime.now().toUtc();

      Future<String> addUserBrand(String? brand) => repository.create(
        CustomFoodDraft(
          name: 'Food ${brand ?? 'empty'}',
          brand: brand,
          category: 'other',
          basis: CustomFoodBasis.grams,
          basisAmount: 100,
          displayBasis: CustomFoodDisplayBasis.perHundredGrams,
          proteinG: 1,
          fatG: 1,
          carbsG: 1,
          servings: const [],
        ),
      );

      Future<void> addRemoteBrand(
        String id,
        String? brand, {
        bool deleted = false,
      }) => database
          .into(database.remoteFoods)
          .insert(
            RemoteFoodsCompanion.insert(
              id: id,
              source: 'off',
              sourceCode: id,
              name: 'Cached $id',
              category: 'other',
              basisUnit: 'grams',
              basisAmount: 100,
              energyKcal: 40,
              proteinG: 1,
              fatG: 1,
              carbsG: 1,
              createdAt: now,
              updatedAt: now,
              deviceId: 'test-device',
              brand: Value(brand),
              deletedAt: Value(deleted ? now : null),
            ),
          );

      await addUserBrand('  Мистраль  ');
      await addUserBrand(' Nordic ');
      final removed = await addUserBrand('Removed');
      await repository.delete(removed);
      await addUserBrand('   ');
      await addRemoteBrand('1', 'nordic');
      await addRemoteBrand('2', 'Nora');
      await addRemoteBrand('3', '  ');
      await addRemoteBrand('4', 'No longer here', deleted: true);

      final brands = await repository.loadBrands();
      expect(brands, ['Nora', 'Nordic', 'Мистраль']);
      expect(UserFoodRepository.matchingBrands(brands, ' no '), [
        'Nora',
        'Nordic',
      ]);
      expect(UserFoodRepository.matchingBrands(brands, 'МИ'), ['Мистраль']);
      expect(UserFoodRepository.matchingBrands(brands, 'n', limit: 1), [
        'Nora',
      ]);
      expect(UserFoodRepository.matchingBrands(brands, ' '), isEmpty);
      expect(
        UserFoodRepository.matchingBrands([
          'N1',
          'N2',
          'N3',
          'N4',
          'N5',
          'N6',
        ], 'n'),
        ['N1', 'N2', 'N3', 'N4', 'N5'],
      );

      await addUserBrand('New Brand');
      expect(
        UserFoodRepository.matchingBrands(await repository.loadBrands(), 'new'),
        ['New Brand'],
      );
    },
  );
}
