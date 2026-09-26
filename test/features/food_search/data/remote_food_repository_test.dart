import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/data/open_food_facts_client.dart';
import 'package:yam/features/food_search/data/remote_food_repository.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/presentation/diary_food_adapter.dart';
import 'package:yam/features/food_search/presentation/remote_food_adapter.dart';

const product = OpenFoodFactsProduct(
  code: '0012345678901',
  name: 'Yogurt',
  brand: 'Actual Dairy',
  energyKcal: 73.654321,
  proteinG: 4.12,
  fatG: 2.3,
  carbsG: 7.43,
);

void main() {
  test(
    'favorite and diary selection survive reopening; history is stable',
    () async {
      final dir = await Directory.systemTemp.createTemp('yam-off-test-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/yam.sqlite');
      final db = YamDatabase(NativeDatabase(file));
      final remote = RemoteFoodRepository(db);
      expect(await remote.loadFoods(), isEmpty);
      await remote.setFavorite(product, true);
      final draft = DiaryEntryDraft(
        day: DateTime(2026, 9, 25),
        mealId: 'breakfast',
        food: diarySnapshotForFood(adaptRemoteFood(product)),
        servingId: 'grams',
        amount: 125.5,
        canonicalQuantity: 125.5,
      );
      await remote.addToDiary(product, draft);
      expect(await UserFoodRepository(db).loadFoods(), isEmpty);
      expect(await remote.loadFoods(), hasLength(1));

      const updated = OpenFoodFactsProduct(
        code: '0012345678901',
        name: 'Updated yogurt',
        energyKcal: 90,
        proteinG: 5,
        fatG: 3,
        carbsG: 10,
      );
      await remote.setFavorite(updated, true);
      await db.close();

      final reopened = YamDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      final cached = await RemoteFoodRepository(reopened).loadFoods();
      expect(cached.single.sourceCode, product.code);
      expect(cached.single.id[14], '7');
      expect(cached.single.deviceId, isNotEmpty);
      expect(cached.single.name, updated.name);
      expect(cached.single.isFavorite, isTrue);
      expect(cached.single.lastAmount, 125.5);
      expect(await UserFoodRepository(reopened).loadFoods(), isEmpty);
      expect(await DiaryRepository(reopened).watchRecentFoodIds().first, [
        product.id,
      ]);
      final oldEntry = (await DiaryRepository(
        reopened,
      ).watchDay(DateTime(2026, 9, 25)).first).single;
      expect(oldEntry.food.name, product.name);
      expect(oldEntry.food.nutritionPerBasis.kcal, product.energyKcal);
      expect(
        oldEntry.nutrition.kcal,
        closeTo(product.energyKcal * 1.255, 1e-10),
      );
      expect(oldEntry.canonicalQuantity, 125.5);
    },
  );

  test(
    'failed diary draft does not create a selected remote product',
    () async {
      final db = YamDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final remote = RemoteFoodRepository(db);
      final invalid = DiaryEntryDraft(
        day: DateTime(2026, 9, 25),
        mealId: 'invalid-meal',
        food: diarySnapshotForFood(adaptRemoteFood(product)),
        servingId: 'grams',
        amount: 100,
        canonicalQuantity: 100,
      );
      await expectLater(
        remote.addToDiary(product, invalid),
        throwsArgumentError,
      );
      expect(await remote.loadFoods(), isEmpty);
    },
  );
}
