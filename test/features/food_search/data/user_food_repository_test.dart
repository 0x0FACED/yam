import 'dart:io';

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
}
