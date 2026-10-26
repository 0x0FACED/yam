import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';
import 'package:yam/features/food_search/presentation/custom_food_adapter.dart';
import 'package:yam/features/food_search/presentation/diary_food_adapter.dart';
import 'package:yam/l10n/generated/app_localizations_en.dart';

const oats = DiaryFoodSnapshot(
  foodId: 'local-oats',
  name: 'Oats',
  baseUnit: DiaryBaseUnit.grams,
  basisAmount: 100,
  nutritionPerBasis: DiaryNutrition(
    kcal: 366.25,
    protein: 12.3,
    fat: 6.1,
    carbs: 59.5,
  ),
  servings: [
    DiaryServingSnapshot(id: 'grams', unit: 'grams', baseAmount: 1),
    DiaryServingSnapshot(id: 'serving', unit: 'servings', baseAmount: 80),
  ],
);

void main() {
  test(
    'entry survives reopening, edit, meal move, deletion and Undo',
    () async {
      final dir = await Directory.systemTemp.createTemp('yam-diary-test-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/yam.sqlite');
      final db = YamDatabase(NativeDatabase(file));
      final repo = DiaryRepository(db);
      final day = DateTime(2026, 9, 25);

      final id = await repo.create(
        DiaryEntryDraft(
          day: day,
          mealId: 'breakfast',
          food: oats,
          servingId: 'grams',
          amount: 80,
          canonicalQuantity: 80,
        ),
      );
      expect(id[14], '7');
      await db.close();

      final reopened = YamDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      final stored = DiaryRepository(reopened);
      final original = (await stored.watchDay(day).first).single;
      expect(original.day, day);
      expect(original.nutrition.kcal, closeTo(293, 0.000001));
      expect(original.food.servings, hasLength(2));
      final metadata = await (reopened.select(
        reopened.diaryEntries,
      )..where((row) => row.id.equals(id))).getSingle();
      expect(metadata.deviceId, isNotEmpty);
      expect(metadata.deletedAt, isNull);
      expect(metadata.energyKcal, closeTo(293, 0.000001));

      await stored.update(
        original,
        mealId: 'lunch',
        servingId: 'serving',
        amount: 1.25,
        canonicalQuantity: 100,
      );
      final edited = (await stored.watchDay(day).first).single;
      expect(edited.mealId, 'lunch');
      expect(edited.servingId, 'serving');
      expect(edited.canonicalQuantity, 100);
      expect(edited.nutrition.kcal, 366.25);
      expect(await stored.watchRecentFoodIds().first, ['local-oats']);

      await stored.delete(id);
      expect(await stored.watchDay(day).first, isEmpty);
      expect(await stored.watchRecentFoodIds().first, isEmpty);
      await stored.restore(edited);
      expect((await stored.watchDay(day).first).single.mealId, 'lunch');
      await stored.restore(original);
      expect(
        (await stored.watchDay(day).first).single.nutrition.kcal,
        closeTo(293, 0.000001),
      );
    },
  );

  test('local calendar day stays separate from UTC instants', () async {
    final db = YamDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DiaryRepository(db);
    final localDay = DateTime(2026, 12, 31);
    await repo.create(
      DiaryEntryDraft(
        day: localDay,
        mealId: 'snacks',
        food: oats,
        servingId: 'grams',
        amount: 10,
        canonicalQuantity: 10,
      ),
    );
    expect((await repo.watchDay(localDay).first).single.day, localDay);
    expect(await repo.watchDay(DateTime(2027, 1, 1)).first, isEmpty);
  });

  test('food deletion does not change or disable its diary snapshot', () async {
    final db = YamDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final catalog = UserFoodRepository(db);
    final id = await catalog.create(
      const CustomFoodDraft(
        name: 'Homemade bar',
        category: 'other',
        basis: CustomFoodBasis.grams,
        basisAmount: 100,
        displayBasis: CustomFoodDisplayBasis.perHundredGrams,
        proteinG: 10,
        fatG: 5,
        carbsG: 20,
        servings: [],
      ),
    );
    final saved = (await catalog.loadFoods()).single;
    final snapshot = diarySnapshotForFood(
      adaptUserFood(saved, AppLocalizationsEn()),
    );
    final diary = DiaryRepository(db);
    final day = DateTime(2026, 9, 25);
    final entryId = await diary.create(
      DiaryEntryDraft(
        day: day,
        mealId: 'breakfast',
        food: snapshot,
        servingId: 'grams',
        amount: 50,
        canonicalQuantity: 50,
      ),
    );
    await catalog.delete(id);
    expect(await catalog.loadFoods(), isEmpty);
    final before = (await diary.watchDay(day).first).single;
    expect(before.id, entryId);
    expect(before.food.name, 'Homemade bar');
    expect(before.nutrition.kcal, 82.5);

    await diary.update(
      before,
      mealId: 'dinner',
      servingId: 'grams',
      amount: 75,
      canonicalQuantity: 75,
    );
    final after = (await diary.watchDay(day).first).single;
    expect(after.food.name, 'Homemade bar');
    expect(after.nutrition.kcal, 123.75);
    expect(after.mealId, 'dinner');
  });
  test(
    'editing a user food updates future entries, not diary snapshots',
    () async {
      final db = YamDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final catalog = UserFoodRepository(db);
      final diary = DiaryRepository(db);
      final foodId = await catalog.create(
        const CustomFoodDraft(
          name: 'Homemade bar',
          brand: 'Old brand',
          description: 'Original recipe\nRest overnight.',
          category: 'other',
          basis: CustomFoodBasis.grams,
          basisAmount: 80,
          displayBasis: CustomFoodDisplayBasis.perServing,
          proteinG: 10,
          fatG: 5,
          carbsG: 20,
          servings: [
            CustomServingDraft(
              unit: CustomServingUnit.serving,
              baseAmount: 80,
              defaultAmount: 1,
            ),
          ],
        ),
      );
      final oldSaved = (await catalog.loadFoods()).single;
      final servingId = oldSaved.servings.single.id;
      final day = DateTime(2026, 9, 28);
      final oldEntryId = await diary.create(
        DiaryEntryDraft(
          day: day,
          mealId: 'breakfast',
          food: diarySnapshotForFood(
            adaptUserFood(oldSaved, AppLocalizationsEn()),
          ),
          servingId: servingId,
          amount: 1,
          canonicalQuantity: 80,
        ),
      );
      final storedSnapshot = await db.select(db.diaryEntries).getSingle();

      expect(
        await catalog.update(
          foodId,
          CustomFoodDraft(
            name: 'Updated bar',
            brand: 'New brand',
            description: 'Changed recipe\nBake for 20 minutes.',
            category: 'other',
            basis: CustomFoodBasis.grams,
            basisAmount: 90,
            displayBasis: CustomFoodDisplayBasis.perServing,
            proteinG: 20,
            fatG: 7,
            carbsG: 30,
            servings: [
              CustomServingDraft(
                existingId: servingId,
                unit: CustomServingUnit.serving,
                baseAmount: 90,
                defaultAmount: 1,
              ),
            ],
          ),
        ),
        isTrue,
      );
      expect(await db.select(db.diaryEntries).getSingle(), storedSnapshot);
      final updatedSaved = (await catalog.loadFoods()).single;
      final newEntryId = await diary.create(
        DiaryEntryDraft(
          day: day,
          mealId: 'dinner',
          food: diarySnapshotForFood(
            adaptUserFood(updatedSaved, AppLocalizationsEn()),
          ),
          servingId: servingId,
          amount: 1,
          canonicalQuantity: 90,
        ),
      );
      final entries = await diary.watchDay(day).first;
      final oldEntry = entries.singleWhere((entry) => entry.id == oldEntryId);
      final newEntry = entries.singleWhere((entry) => entry.id == newEntryId);

      expect(oldEntry.food.foodId, foodId);
      expect(newEntry.food.foodId, foodId);
      expect(oldEntry.food.name, 'Homemade bar');
      expect(oldEntry.food.brand, 'Old brand');
      expect(oldEntry.food.basisAmount, 80);
      expect(
        oldEntry.food.servings
            .singleWhere((serving) => serving.id == servingId)
            .baseAmount,
        80,
      );
      expect(oldEntry.nutrition.kcal, 165);
      expect(oldEntry.nutrition.protein, 10);
      expect(oldEntry.nutrition.fat, 5);
      expect(oldEntry.nutrition.carbs, 20);
      expect(newEntry.food.name, 'Updated bar');
      expect(newEntry.food.brand, 'New brand');
      expect(newEntry.food.basisAmount, 90);
      expect(
        newEntry.food.servings
            .singleWhere((serving) => serving.id == servingId)
            .baseAmount,
        90,
      );
      expect(newEntry.nutrition.kcal, 263);
      expect(newEntry.nutrition.protein, 20);
      expect(newEntry.nutrition.fat, 7);
      expect(newEntry.nutrition.carbs, 30);
    },
  );
}
