import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/core/data/yam_database.dart';

class DiaryRepository {
  DiaryRepository(this.database, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final YamDatabase database;
  final Uuid _uuid;

  Stream<List<DiaryEntry>> watchDay(DateTime day) {
    final query = database.select(database.diaryEntries)
      ..where(
        (entry) =>
            entry.diaryDay.equals(diaryDayKey(day)) & entry.deletedAt.isNull(),
      )
      ..orderBy([
        (entry) => OrderingTerm.asc(entry.createdAt),
        (entry) => OrderingTerm.asc(entry.id),
      ]);
    return query.watch().map((rows) => rows.map(_decode).toList());
  }

  Stream<List<String>> watchRecentFoodIds() => database
      .customSelect(
        'SELECT food_id FROM diary_entries WHERE deleted_at IS NULL '
        'GROUP BY food_id ORDER BY MAX(created_at) DESC, MAX(id) DESC LIMIT 4',
        readsFrom: {database.diaryEntries},
      )
      .watch()
      .map((rows) => [for (final row in rows) row.read<String>('food_id')]);

  Future<String> create(DiaryEntryDraft draft) async {
    draft.validate();
    final id = _uuid.v7();
    final now = DateTime.now().toUtc();
    final nutrition = draft.food.nutritionFor(draft.canonicalQuantity);
    await database.transaction(() async {
      final deviceId = await database.installationDeviceId(_uuid);
      await database
          .into(database.diaryEntries)
          .insert(
            DiaryEntriesCompanion.insert(
              id: id,
              diaryDay: diaryDayKey(draft.day),
              mealId: draft.mealId,
              foodId: draft.food.foodId,
              foodName: draft.food.name,
              brand: Value(draft.food.brand),
              baseUnit: draft.food.baseUnit.name,
              basisAmount: draft.food.basisAmount,
              kcalPerBasis: draft.food.nutritionPerBasis.kcal,
              proteinPerBasis: draft.food.nutritionPerBasis.protein,
              fatPerBasis: draft.food.nutritionPerBasis.fat,
              carbsPerBasis: draft.food.nutritionPerBasis.carbs,
              servingsSnapshot: _encodeServings(draft.food.servings),
              servingId: draft.servingId,
              amount: draft.amount,
              canonicalQuantity: draft.canonicalQuantity,
              energyKcal: nutrition.kcal,
              proteinG: nutrition.protein,
              fatG: nutrition.fat,
              carbsG: nutrition.carbs,
              createdAt: now,
              updatedAt: now,
              deviceId: deviceId,
            ),
          );
    });
    return id;
  }

  Future<void> update(
    DiaryEntry entry, {
    required String mealId,
    required String servingId,
    required double amount,
    required double canonicalQuantity,
  }) async {
    final draft = DiaryEntryDraft(
      day: entry.day,
      mealId: mealId,
      food: entry.food,
      servingId: servingId,
      amount: amount,
      canonicalQuantity: canonicalQuantity,
    )..validate();
    final nutrition = draft.food.nutritionFor(canonicalQuantity);
    final count =
        await (database.update(
              database.diaryEntries,
            )..where((row) => row.id.equals(entry.id) & row.deletedAt.isNull()))
            .write(
              DiaryEntriesCompanion(
                mealId: Value(mealId),
                servingId: Value(servingId),
                amount: Value(amount),
                canonicalQuantity: Value(canonicalQuantity),
                energyKcal: Value(nutrition.kcal),
                proteinG: Value(nutrition.protein),
                fatG: Value(nutrition.fat),
                carbsG: Value(nutrition.carbs),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
    if (count == 0) throw StateError('Diary entry no longer exists');
  }

  Future<void> delete(String id) async {
    final now = DateTime.now().toUtc();
    await (database.update(
      database.diaryEntries,
    )..where((row) => row.id.equals(id) & row.deletedAt.isNull())).write(
      DiaryEntriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  /// Undo for a single entry, restoring its prior quantity and meal snapshot.
  Future<void> restore(DiaryEntry entry) async {
    await (database.update(
      database.diaryEntries,
    )..where((row) => row.id.equals(entry.id))).write(
      DiaryEntriesCompanion(
        deletedAt: const Value(null),
        mealId: Value(entry.mealId),
        servingId: Value(entry.servingId),
        amount: Value(entry.amount),
        canonicalQuantity: Value(entry.canonicalQuantity),
        energyKcal: Value(entry.nutrition.kcal),
        proteinG: Value(entry.nutrition.protein),
        fatG: Value(entry.nutrition.fat),
        carbsG: Value(entry.nutrition.carbs),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  DiaryEntry _decode(StoredDiaryEntry row) => DiaryEntry(
    id: row.id,
    day: DateTime.parse(row.diaryDay),
    mealId: row.mealId,
    food: DiaryFoodSnapshot(
      foodId: row.foodId,
      name: row.foodName,
      brand: row.brand,
      baseUnit: DiaryBaseUnit.values.byName(row.baseUnit),
      basisAmount: row.basisAmount,
      nutritionPerBasis: DiaryNutrition(
        kcal: row.kcalPerBasis,
        protein: row.proteinPerBasis,
        fat: row.fatPerBasis,
        carbs: row.carbsPerBasis,
      ),
      servings: _decodeServings(row.servingsSnapshot),
    ),
    servingId: row.servingId,
    amount: row.amount,
    canonicalQuantity: row.canonicalQuantity,
    nutrition: DiaryNutrition(
      kcal: row.energyKcal,
      protein: row.proteinG,
      fat: row.fatG,
      carbs: row.carbsG,
    ),
  );
}

String _encodeServings(List<DiaryServingSnapshot> servings) => jsonEncode([
  for (final serving in servings)
    {
      'id': serving.id,
      'unit': serving.unit,
      'label': serving.label,
      'baseAmount': serving.baseAmount,
    },
]);

List<DiaryServingSnapshot> _decodeServings(String text) => [
  for (final item in jsonDecode(text) as List<dynamic>)
    DiaryServingSnapshot(
      id: (item as Map<String, dynamic>)['id'] as String,
      unit: item['unit'] as String,
      label: item['label'] as String?,
      baseAmount: (item['baseAmount'] as num).toDouble(),
    ),
];
