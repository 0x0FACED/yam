part of 'backup_repository.dart';

const _tableFiles = {
  'userFoods': 'user_foods.json',
  'userServings': 'user_servings.json',
  'diaryEntries': 'diary_entries.json',
  'goals': 'goal_versions.json',
  'weights': 'weight_entries.json',
  'remoteFoods': 'remote_foods.json',
};
const _serializer = _BackupSerializer();

// Keep isolate closures outside the repository's database-capturing scope.
Future<Uint8List> _encodeInBackground(_BackupData data) =>
    Isolate.run(() => _encodeBackup(data));

Future<_BackupData> _decodeInBackground(Uint8List bytes) =>
    Isolate.run(() => _decodeBackup(bytes));

class _BackupSerializer extends ValueSerializer {
  const _BackupSerializer();

  @override
  dynamic toJson<T>(T value) => value is DateTime
      ? value.toUtc().toIso8601String()
      : const ValueSerializer.defaults().toJson<T>(value);

  @override
  T fromJson<T>(dynamic json) =>
      const ValueSerializer.defaults().fromJson<T>(json);
}

Uint8List _encodeBackup(_BackupData data) {
  final tables = <String, List<Map<String, dynamic>>>{
    'userFoods': [
      for (final row in data.userFoods) row.toJson(serializer: _serializer),
    ],
    'userServings': [
      for (final row in data.userServings) row.toJson(serializer: _serializer),
    ],
    'diaryEntries': [
      for (final row in data.diaryEntries) row.toJson(serializer: _serializer),
    ],
    'goals': [
      for (final row in data.goals) row.toJson(serializer: _serializer),
    ],
    'weights': [
      for (final row in data.weights) row.toJson(serializer: _serializer),
    ],
    'remoteFoods': [
      for (final row in data.remoteFoods) row.toJson(serializer: _serializer),
    ],
  };
  _validateTables(tables);
  final archive = Archive();
  var totalBytes = 0;
  void addJson(String name, Object value) {
    final bytes = utf8.encode(jsonEncode(value));
    totalBytes += bytes.length;
    if (totalBytes > _maxUncompressedBytes) {
      throw const BackupException(BackupFailure.tooLarge);
    }
    archive.add(ArchiveFile.bytes(name, bytes));
  }

  addJson('manifest.json', {
    'format': 'yam-backup',
    'formatVersion': 1,
    'exportedAt': data.exportedAt.toUtc().toIso8601String(),
    'sourceDeviceId': data.sourceDeviceId,
    'counts': {
      for (final entry in tables.entries) entry.key: entry.value.length,
    },
  });
  for (final entry in tables.entries) {
    addJson(_tableFiles[entry.key]!, entry.value);
  }
  final bytes = ZipEncoder().encodeBytes(archive);
  if (bytes.length > maxBackupFileBytes) {
    throw const BackupException(BackupFailure.tooLarge);
  }
  return bytes;
}

_BackupData _decodeBackup(Uint8List bytes) {
  try {
    final members = _readZipMembers(bytes);
    final manifest = _object(
      jsonDecode(utf8.decode(members['manifest.json']!)),
    );
    _require(manifest['format'] == 'yam-backup');
    final version = manifest['formatVersion'];
    _require(version is int && version > 0);
    if (version != 1) {
      throw const BackupException(BackupFailure.unsupportedVersion);
    }
    _keys(manifest, {
      'format',
      'formatVersion',
      'exportedAt',
      'sourceDeviceId',
      'counts',
    });
    final exportedAt = _timestamp(manifest['exportedAt']);
    final sourceDeviceId = manifest['sourceDeviceId'];
    _require(sourceDeviceId is String && _uuid.hasMatch(sourceDeviceId));
    final counts = _object(manifest['counts']);
    _keys(counts, _tableFiles.keys.toSet());
    final tables = <String, List<Map<String, dynamic>>>{};
    var totalRows = 0;
    for (final entry in _tableFiles.entries) {
      final value = jsonDecode(utf8.decode(members[entry.value]!));
      _require(value is List);
      final rows = (value as List).map(_object).toList(growable: false);
      totalRows += rows.length;
      if (totalRows > _maxBackupRows) {
        throw const BackupException(BackupFailure.tooLarge);
      }
      _require(counts[entry.key] is int && counts[entry.key] == rows.length);
      tables[entry.key] = rows;
    }
    _validateTables(tables);
    return _BackupData(
      exportedAt: exportedAt,
      sourceDeviceId: sourceDeviceId as String,
      userFoods: [
        for (final row in tables['userFoods']!)
          StoredUserFood.fromJson(row, serializer: _serializer),
      ],
      userServings: [
        for (final row in tables['userServings']!)
          StoredUserServing.fromJson(row, serializer: _serializer),
      ],
      diaryEntries: [
        for (final row in tables['diaryEntries']!)
          StoredDiaryEntry.fromJson(row, serializer: _serializer),
      ],
      goals: [
        for (final row in tables['goals']!)
          StoredGoalVersion.fromJson(row, serializer: _serializer),
      ],
      weights: [
        for (final row in tables['weights']!)
          StoredWeightEntry.fromJson(row, serializer: _serializer),
      ],
      remoteFoods: [
        for (final row in tables['remoteFoods']!)
          StoredRemoteFood.fromJson(row, serializer: _serializer),
      ],
    );
  } on BackupException {
    rethrow;
  } catch (_) {
    throw const BackupException(BackupFailure.invalidFile);
  }
}

enum _Value {
  text,
  optionalText,
  number,
  integer,
  boolean,
  timestamp,
  optionalTimestamp,
}

const _metadata = {
  'id': _Value.text,
  'createdAt': _Value.timestamp,
  'updatedAt': _Value.timestamp,
  'deletedAt': _Value.optionalTimestamp,
  'deviceId': _Value.text,
};
const _nutrition = {
  'energyKcal': _Value.number,
  'proteinG': _Value.number,
  'fatG': _Value.number,
  'carbsG': _Value.number,
};
const _catalog = {
  'name': _Value.text,
  'category': _Value.text,
  'brand': _Value.optionalText,
  'basisUnit': _Value.text,
  'basisAmount': _Value.number,
  'isFavorite': _Value.boolean,
  ..._nutrition,
  ..._metadata,
};
const _schemas = {
  'userFoods': {
    ..._catalog,
    'barcode': _Value.optionalText,
    'displayBasis': _Value.text,
  },
  'userServings': {
    ..._metadata,
    'foodId': _Value.text,
    'unit': _Value.text,
    'label': _Value.optionalText,
    'baseAmount': _Value.number,
    'defaultAmount': _Value.number,
  },
  'diaryEntries': {
    ..._metadata,
    ..._nutrition,
    'diaryDay': _Value.text,
    'mealId': _Value.text,
    'foodId': _Value.text,
    'foodName': _Value.text,
    'brand': _Value.optionalText,
    'baseUnit': _Value.text,
    'basisAmount': _Value.number,
    'kcalPerBasis': _Value.number,
    'proteinPerBasis': _Value.number,
    'fatPerBasis': _Value.number,
    'carbsPerBasis': _Value.number,
    'servingsSnapshot': _Value.text,
    'servingId': _Value.text,
    'amount': _Value.number,
    'canonicalQuantity': _Value.number,
  },
  'goals': {
    ..._metadata,
    'effectiveDay': _Value.text,
    'goal': _Value.text,
    'calorieTarget': _Value.integer,
    'proteinTarget': _Value.integer,
    'fatTarget': _Value.integer,
    'carbsTarget': _Value.integer,
    'targetWeightKg': _Value.number,
  },
  'weights': {
    ..._metadata,
    'localDay': _Value.text,
    'weightKg': _Value.number,
    'source': _Value.text,
  },
  'remoteFoods': {
    ..._catalog,
    'source': _Value.text,
    'sourceCode': _Value.text,
    'lastAmount': _Value.number,
  },
};
final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);
final _barcode = RegExp(r'^\d+$');

void _validateTables(Map<String, List<Map<String, dynamic>>> tables) {
  if (tables.values.fold<int>(0, (sum, rows) => sum + rows.length) >
      _maxBackupRows) {
    throw const BackupException(BackupFailure.tooLarge);
  }
  for (final entry in tables.entries) {
    final ids = <String>{};
    for (final row in entry.value) {
      _validateFields(row, _schemas[entry.key]!);
      _require(_uuid.hasMatch(row['id'] as String));
      _require(_uuid.hasMatch(row['deviceId'] as String));
      _require(ids.add(row['id'] as String));
    }
  }
  final foods = {for (final row in tables['userFoods']!) row['id']: row};
  final servings = <String, List<Map<String, dynamic>>>{};
  for (final row in tables['userServings']!) {
    final food = foods[row['foodId']];
    _require(food != null);
    _require(row['deletedAt'] != null || food!['deletedAt'] == null);
    _enum(row['unit'], CustomServingUnit.values);
    _positive(row['baseAmount']);
    _positive(row['defaultAmount']);
    servings.putIfAbsent(row['foodId'] as String, () => []).add(row);
  }
  final barcodes = <String>{};
  for (final row in tables['userFoods']!) {
    _validateCatalog(row);
    final barcode = row['barcode'];
    if (barcode != null) {
      _require(_barcode.hasMatch(barcode as String) && barcodes.add(barcode));
    }
    _enum(row['displayBasis'], CustomFoodDisplayBasis.values);
    switch (row['displayBasis']) {
      case 'perHundredGrams':
        _require(row['basisUnit'] == 'grams' && row['basisAmount'] == 100);
      case 'perHundredMilliliters':
        _require(
          row['basisUnit'] == 'milliliters' && row['basisAmount'] == 100,
        );
      case 'perServing':
        _require(
          (servings[row['id']] ?? []).any(
            (serving) =>
                serving['unit'] == 'serving' &&
                serving['baseAmount'] == row['basisAmount'] &&
                (row['deletedAt'] != null || serving['deletedAt'] == null),
          ),
        );
    }
  }
  final remoteKeys = <(String, String)>{};
  for (final row in tables['remoteFoods']!) {
    _validateCatalog(row);
    _require(row['source'] == 'open_food_facts');
    _require(RegExp(r'^\d{3,30}$').hasMatch(row['sourceCode'] as String));
    _require(
      remoteKeys.add((row['source'] as String, row['sourceCode'] as String)),
    );
    _positive(row['lastAmount']);
  }
  for (final row in tables['goals']!) {
    _day(row['effectiveDay'] as String);
    _enum(row['goal'], WeightGoal.values);
    _positive(row['calorieTarget']);
    _positive(row['targetWeightKg']);
  }
  for (final row in tables['weights']!) {
    _day(row['localDay'] as String);
    _require(row['source'] == 'manual');
    _positive(row['weightKg']);
  }
  for (final row in tables['diaryEntries']!) {
    _validateDiary(row);
  }
}

void _validateFields(Map<String, dynamic> row, Map<String, _Value> schema) {
  _keys(row, schema.keys.toSet());
  for (final entry in schema.entries) {
    final value = row[entry.key];
    switch (entry.value) {
      case _Value.text:
        _require(value is String && value.trim().isNotEmpty);
      case _Value.optionalText:
        _require(value == null || value is String);
      case _Value.number:
        _require(value is num && value.isFinite && value >= 0);
      case _Value.integer:
        _require(value is int && value >= 0 && value <= 0x7fffffffffffffff);
      case _Value.boolean:
        _require(value is bool);
      case _Value.timestamp:
        _timestamp(value);
      case _Value.optionalTimestamp:
        if (value != null) _timestamp(value);
    }
  }
}

void _validateCatalog(Map<String, dynamic> row) {
  _enum(row['basisUnit'], CustomFoodBasis.values);
  _positive(row['basisAmount']);
}

void _validateDiary(Map<String, dynamic> row) {
  _day(row['diaryDay'] as String);
  _require(diaryMealIds.contains(row['mealId']));
  _enum(row['baseUnit'], DiaryBaseUnit.values);
  _positive(row['basisAmount']);
  _positive(row['amount']);
  _positive(row['canonicalQuantity']);
  final raw = jsonDecode(row['servingsSnapshot'] as String);
  _require(raw is List && raw.isNotEmpty);
  final ids = <String>{};
  Map<String, dynamic>? selected;
  for (final value in raw as List) {
    final serving = _object(value);
    _validateFields(serving, const {
      'id': _Value.text,
      'unit': _Value.text,
      'label': _Value.optionalText,
      'baseAmount': _Value.number,
    });
    _require(ids.add(serving['id'] as String));
    _enum(serving['unit'], FoodSearchPrototypeUnit.values);
    _positive(serving['baseAmount']);
    if (serving['unit'] == 'grams' || serving['unit'] == 'milliliters') {
      _require(
        serving['unit'] == row['baseUnit'] && serving['baseAmount'] == 1,
      );
    }
    if (serving['id'] == row['servingId']) selected = serving;
  }
  _require(selected != null);
  _near(
    row['canonicalQuantity'] as num,
    (row['amount'] as num) * (selected!['baseAmount'] as num),
  );
  final factor =
      (row['canonicalQuantity'] as num) / (row['basisAmount'] as num);
  for (final pair in const [
    ('energyKcal', 'kcalPerBasis'),
    ('proteinG', 'proteinPerBasis'),
    ('fatG', 'fatPerBasis'),
    ('carbsG', 'carbsPerBasis'),
  ]) {
    _near(row[pair.$1] as num, (row[pair.$2] as num) * factor);
  }
}

void _near(num stored, num expected) {
  _require(
    expected.isFinite &&
        (stored - expected).abs() <= math.max(1e-9, expected.abs() * 1e-9),
  );
}

void _enum(Object? value, List<Enum> values) =>
    _require(values.any((candidate) => candidate.name == value));

void _positive(dynamic value) =>
    _require(value is num && value.isFinite && value > 0);

DateTime _timestamp(dynamic value) {
  _require(value is String && value.endsWith('Z'));
  final date = DateTime.parse(value as String);
  _require(
    date.isUtc &&
        date.year >= 1 &&
        date.year <= 9999 &&
        date.toIso8601String() == value,
  );
  return date;
}

void _day(String value) {
  _require(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value));
  final date = DateTime.parse('${value}T00:00:00.000Z');
  _require(date.year >= 1 && diaryDayKey(date) == value);
}

Map<String, dynamic> _object(dynamic value) {
  _require(value is Map<String, dynamic>);
  return value as Map<String, dynamic>;
}

void _keys(Map<String, dynamic> value, Set<String> expected) => _require(
  value.length == expected.length && value.keys.every(expected.contains),
);

void _require(bool condition) {
  if (!condition) throw const BackupException(BackupFailure.invalidFile);
}

class _ZipMember {
  const _ZipMember(
    this.name,
    this.offset,
    this.end,
    this.dataOffset,
    this.compressedSize,
    this.size,
    this.crc,
    this.method,
  );

  final String name;
  final int offset;
  final int end;
  final int dataOffset;
  final int compressedSize;
  final int size;
  final int crc;
  final int method;
}

// Parse only the bounded v1 envelope. Do not call ZipDecoder.readBytes: its
// default inflater trusts member sizes and can allocate an unbounded ZIP bomb.
// No names are ever used as filesystem paths; only these seven members exist.
Map<String, Uint8List> _readZipMembers(Uint8List bytes) {
  if (bytes.length > maxBackupFileBytes) {
    throw const BackupException(BackupFailure.tooLarge);
  }
  _require(bytes.length >= 22);
  final data = ByteData.sublistView(bytes);
  int u16(int offset) => data.getUint16(offset, Endian.little);
  int u32(int offset) => data.getUint32(offset, Endian.little);
  var eocd = bytes.length - 22;
  final first = math.max(0, eocd - 65535);
  while (eocd >= first &&
      (u32(eocd) != 0x06054b50 || eocd + 22 + u16(eocd + 20) != bytes.length)) {
    eocd--;
  }
  _require(eocd >= first);
  _require(u16(eocd + 4) == 0 && u16(eocd + 6) == 0);
  _require(u16(eocd + 8) == 7 && u16(eocd + 10) == 7);
  final centralSize = u32(eocd + 12);
  final centralOffset = u32(eocd + 16);
  _require(centralOffset + centralSize == eocd);
  final expected = {'manifest.json', ..._tableFiles.values};
  final members = <_ZipMember>[];
  final directory = InputMemoryStream(
    Uint8List.sublistView(bytes, centralOffset, eocd),
  );
  final input = InputMemoryStream(bytes);
  var totalSize = 0;
  for (var index = 0; index < 7; index++) {
    _require(
      directory.length >= 46 &&
          directory.readUint32() == ZipFileHeader.signature,
    );
    final header = ZipFileHeader()..read(directory);
    final flags = header.generalPurposeBitFlag;
    final method = header.compressionMethod;
    _require(header.versionNeededToExtract <= 20 && flags & ~0x806 == 0);
    _require(method == 0 || method == 8);
    _require(header.diskNumberStart == 0);
    final mode = (header.externalFileAttributes >> 16) & 0xf000;
    _require(mode == 0 || mode == 0x8000);
    _require(header.externalFileAttributes & 0x10 == 0);
    final name = header.filename;
    _require(expected.remove(name));
    totalSize += header.uncompressedSize;
    if (totalSize > _maxUncompressedBytes) {
      throw const BackupException(BackupFailure.tooLarge);
    }
    if (name == 'manifest.json' && header.uncompressedSize > 64 * 1024) {
      throw const BackupException(BackupFailure.tooLarge);
    }
    final offset = header.localHeaderOffset;
    _require(
      offset + 30 <= centralOffset && u32(offset) == ZipFile.zipSignature,
    );
    // ZipFile deliberately replaces the local sizes with directory sizes.
    // Check those original fields too, so contradictory envelopes are rejected.
    _require(
      u32(offset + 18) == header.compressedSize &&
          u32(offset + 22) == header.uncompressedSize,
    );
    input.setPosition(offset);
    final local = ZipFile(header)..read(input);
    _require(
      local.version <= 20 &&
          local.flags == flags &&
          local.filename == name &&
          local.crc32 == header.crc32 &&
          local.compressionMethod ==
              (method == 0 ? CompressionType.none : CompressionType.deflate),
    );
    final end = input.position;
    final dataOffset = end - header.compressedSize;
    _require(dataOffset >= offset + 30 && end <= centralOffset);
    members.add(
      _ZipMember(
        name,
        offset,
        end,
        dataOffset,
        header.compressedSize,
        header.uncompressedSize,
        header.crc32,
        method,
      ),
    );
  }
  _require(directory.isEOS && expected.isEmpty);
  members.sort((a, b) => a.offset.compareTo(b.offset));
  var end = 0;
  for (final member in members) {
    _require(member.offset == end);
    end = member.end;
  }
  _require(end == centralOffset);
  final result = <String, Uint8List>{};
  for (final member in members) {
    final compressed = Uint8List.sublistView(
      bytes,
      member.dataOffset,
      member.dataOffset + member.compressedSize,
    );
    final Uint8List content;
    if (member.method == 0) {
      _require(compressed.length == member.size);
      content = compressed;
    } else {
      final sink = _BoundedInflateSink(member.size);
      final input = io.ZLibDecoder(raw: true).startChunkedConversion(sink);
      for (var start = 0; start < compressed.length; start += 1024) {
        input.add(
          Uint8List.sublistView(
            compressed,
            start,
            math.min(start + 1024, compressed.length),
          ),
        );
      }
      input.close();
      content = sink.takeBytes();
    }
    _require(content.length == member.size && getCrc32(content) == member.crc);
    result[member.name] = content;
  }
  return result;
}

class _BoundedInflateSink implements Sink<List<int>> {
  _BoundedInflateSink(this.limit);

  final int limit;
  final _builder = BytesBuilder(copy: false);

  @override
  void add(List<int> data) {
    _require(_builder.length + data.length <= limit);
    _builder.add(data);
  }

  @override
  void close() {}

  Uint8List takeBytes() => _builder.takeBytes();
}
