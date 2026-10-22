import 'dart:convert';
import 'dart:io' as io;
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';

part 'backup_codec.dart';

const int maxBackupFileBytes = 64 * 1024 * 1024;

// The sum of all seven uncompressed ZIP members, enforced before inflation and
// again while streaming it. Limits also apply to locally generated exports.
const int _maxUncompressedBytes = 128 * 1024 * 1024;
const int _maxBackupRows = 250000;

enum BackupImportMode { replace, supplement }

enum BackupFailure { invalidFile, unsupportedVersion, tooLarge }

class BackupException implements Exception {
  const BackupException(this.failure);

  final BackupFailure failure;

  @override
  String toString() => 'BackupException(${failure.name})';
}

class BackupCounts {
  const BackupCounts({
    required this.userFoods,
    required this.userServings,
    required this.diaryEntries,
    required this.goals,
    required this.weights,
    required this.remoteFoods,
  });

  final int userFoods;
  final int userServings;
  final int diaryEntries;
  final int goals;
  final int weights;
  final int remoteFoods;

  int get total =>
      userFoods + userServings + diaryEntries + goals + weights + remoteFoods;

  BackupCounts _minus(BackupCounts other) => BackupCounts(
    userFoods: userFoods - other.userFoods,
    userServings: userServings - other.userServings,
    diaryEntries: diaryEntries - other.diaryEntries,
    goals: goals - other.goals,
    weights: weights - other.weights,
    remoteFoods: remoteFoods - other.remoteFoods,
  );
}

final class BackupPreview {
  BackupPreview._(this._data);

  final _BackupData _data;

  DateTime get exportedAt => _data.exportedAt;
  BackupCounts get counts => _data.counts;
}

class BackupImportResult {
  const BackupImportResult({required this.imported, required this.skipped});

  final BackupCounts imported;
  final BackupCounts skipped;
}

class BackupRepository {
  BackupRepository(this._database);

  final YamDatabase _database;

  Future<Uint8List> exportBackup() async {
    final data = await _database.transaction(() async {
      final deviceId = await _database.installationDeviceId(const Uuid());
      return _BackupData(
        exportedAt: DateTime.now().toUtc(),
        sourceDeviceId: deviceId,
        userFoods: await _database.select(_database.userFoods).get(),
        userServings: await _database.select(_database.userServings).get(),
        diaryEntries: await _database.select(_database.diaryEntries).get(),
        goals: await _database.select(_database.goalVersions).get(),
        weights: await _database.select(_database.weightEntries).get(),
        remoteFoods: await _database.select(_database.remoteFoods).get(),
      );
    });
    return _encodeInBackground(data);
  }

  Future<BackupPreview> inspectBackup(Uint8List bytes) async {
    if (bytes.length > maxBackupFileBytes) {
      throw const BackupException(BackupFailure.tooLarge);
    }
    final data = await _decodeInBackground(bytes);
    return BackupPreview._(data);
  }

  Future<BackupImportResult> importBackup(
    BackupPreview preview,
    BackupImportMode mode,
  ) => _database.transaction(() async {
    final data = preview._data;
    if (mode == BackupImportMode.replace) {
      await _database.delete(_database.userServings).go();
      await _database.delete(_database.userFoods).go();
      await _database.delete(_database.diaryEntries).go();
      await _database.delete(_database.goalVersions).go();
      await _database.delete(_database.weightEntries).go();
      await _database.delete(_database.remoteFoods).go();
    }

    var foods = data.userFoods;
    var servings = data.userServings;
    var diary = data.diaryEntries;
    var goals = data.goals;
    var weights = data.weights;
    var remote = data.remoteFoods;
    if (mode == BackupImportMode.supplement) {
      // Include tombstones: supplement is deliberately not last-write-wins.
      final existingFoods = await _database.select(_database.userFoods).get();
      final foodIds = {for (final row in existingFoods) row.id};
      final barcodes = {
        for (final row in existingFoods)
          if (row.barcode != null) row.barcode!,
      };
      final servingIds = {
        for (final row in await _database.select(_database.userServings).get())
          row.id,
      };
      // Never create a partial catalog product when any of its serving IDs
      // belongs to an existing product (even a deleted one).
      final servingConflicts = {
        for (final row in servings)
          if (servingIds.contains(row.id)) row.foodId,
      };
      foods = [
        for (final row in foods)
          if (!foodIds.contains(row.id) &&
              !servingConflicts.contains(row.id) &&
              (row.barcode == null || !barcodes.contains(row.barcode)))
            row,
      ];
      final addedFoodIds = {for (final row in foods) row.id};
      servings = [
        for (final row in servings)
          if (addedFoodIds.contains(row.foodId)) row,
      ];
      final diaryIds = {
        for (final row in await _database.select(_database.diaryEntries).get())
          row.id,
      };
      diary = [
        for (final row in diary)
          if (!diaryIds.contains(row.id)) row,
      ];
      final goalIds = {
        for (final row in await _database.select(_database.goalVersions).get())
          row.id,
      };
      goals = [
        for (final row in goals)
          if (!goalIds.contains(row.id)) row,
      ];
      final weightIds = {
        for (final row in await _database.select(_database.weightEntries).get())
          row.id,
      };
      weights = [
        for (final row in weights)
          if (!weightIds.contains(row.id)) row,
      ];
      final existingRemote = await _database
          .select(_database.remoteFoods)
          .get();
      final remoteIds = {for (final row in existingRemote) row.id};
      final remoteKeys = {
        for (final row in existingRemote) (row.source, row.sourceCode),
      };
      remote = [
        for (final row in remote)
          if (!remoteIds.contains(row.id) &&
              !remoteKeys.contains((row.source, row.sourceCode)))
            row,
      ];
    }

    await _database.batch((batch) {
      batch.insertAll(_database.userFoods, foods);
      batch.insertAll(_database.userServings, servings);
      batch.insertAll(_database.diaryEntries, diary);
      batch.insertAll(_database.goalVersions, goals);
      batch.insertAll(_database.weightEntries, weights);
      batch.insertAll(_database.remoteFoods, remote);
    });
    final imported = BackupCounts(
      userFoods: foods.length,
      userServings: servings.length,
      diaryEntries: diary.length,
      goals: goals.length,
      weights: weights.length,
      remoteFoods: remote.length,
    );
    return BackupImportResult(
      imported: imported,
      skipped: data.counts._minus(imported),
    );
  });
}

class _BackupData {
  _BackupData({
    required this.exportedAt,
    required this.sourceDeviceId,
    required List<StoredUserFood> userFoods,
    required List<StoredUserServing> userServings,
    required List<StoredDiaryEntry> diaryEntries,
    required List<StoredGoalVersion> goals,
    required List<StoredWeightEntry> weights,
    required List<StoredRemoteFood> remoteFoods,
  }) : userFoods = List.unmodifiable(userFoods),
       userServings = List.unmodifiable(userServings),
       diaryEntries = List.unmodifiable(diaryEntries),
       goals = List.unmodifiable(goals),
       weights = List.unmodifiable(weights),
       remoteFoods = List.unmodifiable(remoteFoods);

  final DateTime exportedAt;
  final String sourceDeviceId;
  final List<StoredUserFood> userFoods;
  final List<StoredUserServing> userServings;
  final List<StoredDiaryEntry> diaryEntries;
  final List<StoredGoalVersion> goals;
  final List<StoredWeightEntry> weights;
  final List<StoredRemoteFood> remoteFoods;

  BackupCounts get counts => BackupCounts(
    userFoods: userFoods.length,
    userServings: userServings.length,
    diaryEntries: diaryEntries.length,
    goals: goals.length,
    weights: weights.length,
    remoteFoods: remoteFoods.length,
  );
}
