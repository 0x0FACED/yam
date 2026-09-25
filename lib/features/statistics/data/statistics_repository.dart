import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';

class StatisticsRepository {
  StatisticsRepository(this.database, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final YamDatabase database;
  final Uuid _uuid;

  Stream<List<GoalVersion>> watchGoals() {
    final query = database.select(database.goalVersions)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([
        (row) => OrderingTerm.asc(row.effectiveDay),
        (row) => OrderingTerm.asc(row.createdAt),
        (row) => OrderingTerm.asc(row.id),
      ]);
    return query.watch().map((rows) => [for (final row in rows) _goal(row)]);
  }

  Stream<List<WeightRecord>> watchWeights() {
    final query = database.select(database.weightEntries)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([
        (row) => OrderingTerm.asc(row.localDay),
        (row) => OrderingTerm.asc(row.createdAt),
        (row) => OrderingTerm.asc(row.id),
      ]);
    return query.watch().map((rows) => [for (final row in rows) _weight(row)]);
  }

  Stream<List<NutritionDay>> watchNutrition({
    required DateTime today,
    required StatisticsPeriod period,
  }) {
    final start = period.start(today);
    return database
        .customSelect(
          'SELECT diary_day, SUM(energy_kcal) AS kcal, '
          'SUM(protein_g) AS protein, SUM(fat_g) AS fat, '
          'SUM(carbs_g) AS carbs FROM diary_entries '
          'WHERE deleted_at IS NULL AND diary_day <= ? '
          '${start == null ? '' : 'AND diary_day >= ? '}'
          'GROUP BY diary_day ORDER BY diary_day',
          variables: [
            Variable.withString(diaryDayKey(today)),
            if (start != null) Variable.withString(diaryDayKey(start)),
          ],
          readsFrom: {database.diaryEntries},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              NutritionDay(
                day: DateTime.parse(row.read<String>('diary_day')),
                kcal: row.read<double>('kcal'),
                protein: row.read<double>('protein'),
                fat: row.read<double>('fat'),
                carbs: row.read<double>('carbs'),
              ),
          ],
        );
  }

  Stream<List<FrequentFood>> watchFrequentFoods({
    required DateTime today,
    required StatisticsPeriod period,
  }) {
    final start = period.start(today);
    return database
        .customSelect(
          'SELECT food_id, MAX(food_name) AS name, MAX(brand) AS brand, '
          'MAX(base_unit) AS unit, COUNT(DISTINCT diary_day) AS days, '
          'AVG(canonical_quantity) AS average_amount '
          'FROM diary_entries WHERE deleted_at IS NULL AND diary_day <= ? '
          '${start == null ? '' : 'AND diary_day >= ? '}'
          'GROUP BY food_id ORDER BY days DESC, MAX(created_at) DESC, '
          'food_id LIMIT 4',
          variables: [
            Variable.withString(diaryDayKey(today)),
            if (start != null) Variable.withString(diaryDayKey(start)),
          ],
          readsFrom: {database.diaryEntries},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              FrequentFood(
                name: row.read<String>('name'),
                brand: row.readNullable<String>('brand'),
                unit: DiaryBaseUnit.values.byName(row.read<String>('unit')),
                days: row.read<int>('days'),
                averageAmount: row.read<double>('average_amount'),
              ),
          ],
        );
  }

  Future<void> saveOnboarding(SessionProfile profile, DateTime day) async {
    if (profile.currentWeightKg == null ||
        !profile.currentWeightKg!.isFinite ||
        profile.currentWeightKg! <= 0 ||
        !profile.targetWeightKg.isFinite ||
        profile.targetWeightKg <= 0 ||
        profile.calorieTarget <= 0 ||
        [
          profile.proteinTarget,
          profile.fatTarget,
          profile.carbsTarget,
        ].any((value) => value < 0)) {
      throw ArgumentError('Invalid goals and weight');
    }
    final now = DateTime.now().toUtc();
    final key = diaryDayKey(day);
    await database.transaction(() async {
      final deviceId = await database.installationDeviceId(_uuid);
      final latestGoal =
          await (database.select(database.goalVersions)
                ..where((row) => row.deletedAt.isNull())
                ..orderBy([
                  (row) => OrderingTerm.desc(row.effectiveDay),
                  (row) => OrderingTerm.desc(row.createdAt),
                  (row) => OrderingTerm.desc(row.id),
                ])
                ..limit(1))
              .getSingleOrNull();
      if (latestGoal == null ||
          latestGoal.goal != profile.goal.name ||
          latestGoal.calorieTarget != profile.calorieTarget ||
          latestGoal.proteinTarget != profile.proteinTarget ||
          latestGoal.fatTarget != profile.fatTarget ||
          latestGoal.carbsTarget != profile.carbsTarget ||
          latestGoal.targetWeightKg != profile.targetWeightKg) {
        await database
            .into(database.goalVersions)
            .insert(
              GoalVersionsCompanion.insert(
                id: _uuid.v7(),
                effectiveDay: key,
                goal: profile.goal.name,
                calorieTarget: profile.calorieTarget,
                proteinTarget: profile.proteinTarget,
                fatTarget: profile.fatTarget,
                carbsTarget: profile.carbsTarget,
                targetWeightKg: profile.targetWeightKg,
                createdAt: now,
                updatedAt: now,
                deviceId: deviceId,
              ),
            );
      }
      final latestWeight =
          await (database.select(database.weightEntries)
                ..where((row) => row.deletedAt.isNull())
                ..orderBy([
                  (row) => OrderingTerm.desc(row.localDay),
                  (row) => OrderingTerm.desc(row.createdAt),
                  (row) => OrderingTerm.desc(row.id),
                ])
                ..limit(1))
              .getSingleOrNull();
      if (latestWeight == null ||
          latestWeight.weightKg != profile.currentWeightKg) {
        await database
            .into(database.weightEntries)
            .insert(
              WeightEntriesCompanion.insert(
                id: _uuid.v7(),
                localDay: key,
                weightKg: profile.currentWeightKg!,
                source: 'manual',
                createdAt: now,
                updatedAt: now,
                deviceId: deviceId,
              ),
            );
      }
    });
  }

  Future<String> addWeight({required DateTime day, required double kg}) async {
    _validateWeight(day, kg);
    final now = DateTime.now().toUtc();
    final id = _uuid.v7();
    await database.transaction(() async {
      final deviceId = await database.installationDeviceId(_uuid);
      await database
          .into(database.weightEntries)
          .insert(
            WeightEntriesCompanion.insert(
              id: id,
              localDay: diaryDayKey(day),
              weightKg: kg,
              source: 'manual',
              createdAt: now,
              updatedAt: now,
              deviceId: deviceId,
            ),
          );
    });
    return id;
  }

  Future<void> updateWeight(
    WeightRecord record, {
    required DateTime day,
    required double kg,
  }) async {
    _validateWeight(day, kg);
    final updated =
        await (database.update(database.weightEntries)..where(
              (row) => row.id.equals(record.id) & row.deletedAt.isNull(),
            ))
            .write(
              WeightEntriesCompanion(
                localDay: Value(diaryDayKey(day)),
                weightKg: Value(kg),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
    if (updated == 0) throw StateError('Weight entry no longer exists');
  }

  Future<void> deleteWeight(String id) async {
    final now = DateTime.now().toUtc();
    await (database.update(
      database.weightEntries,
    )..where((row) => row.id.equals(id) & row.deletedAt.isNull())).write(
      WeightEntriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<void> restoreWeight(WeightRecord record) async {
    await (database.update(
      database.weightEntries,
    )..where((row) => row.id.equals(record.id))).write(
      WeightEntriesCompanion(
        deletedAt: const Value(null),
        localDay: Value(diaryDayKey(record.day)),
        weightKg: Value(record.kg),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  void _validateWeight(DateTime day, double kg) {
    if (!kg.isFinite ||
        kg <= 0 ||
        diaryDayKey(day).compareTo(diaryDayKey(DateTime.now())) > 0) {
      throw ArgumentError('Weight and day must be valid');
    }
  }

  static GoalVersion _goal(StoredGoalVersion row) => GoalVersion(
    id: row.id,
    day: DateTime.parse(row.effectiveDay),
    goal: WeightGoal.values.byName(row.goal),
    calorieTarget: row.calorieTarget,
    proteinTarget: row.proteinTarget,
    fatTarget: row.fatTarget,
    carbsTarget: row.carbsTarget,
    targetWeightKg: row.targetWeightKg,
  );

  static WeightRecord _weight(StoredWeightEntry row) => WeightRecord(
    id: row.id,
    day: DateTime.parse(row.localDay),
    kg: row.weightKg,
  );
}
