part of 'food_library_repository.dart';

// Top-level closures must not capture a repository or its database connection.
Future<Uint8List> _encodeLibraryInBackground(_FoodLibrarySnapshot snapshot) =>
    Isolate.run(() => _encodeLibrary(snapshot));

Future<_FoodLibraryData> _decodeLibraryInBackground(Uint8List bytes) =>
    Isolate.run(() => _decodeLibrary(bytes));

Uint8List _encodeLibrary(_FoodLibrarySnapshot snapshot) {
  _checkLibraryCounts(snapshot.foods.length, snapshot.servings.length);
  final servingsByFood = <String, List<StoredUserServing>>{};
  for (final serving in snapshot.servings) {
    (servingsByFood[serving.foodId] ??= []).add(serving);
  }
  final data = _readLibrary({
    'format': 'yam-foods',
    'version': 1,
    'foods': [
      for (var index = 0; index < snapshot.foods.length; index++)
        _storedFoodJson(
          snapshot.foods[index],
          servingsByFood[snapshot.foods[index].id] ?? const [],
          '\$.foods[$index]',
        ),
    ],
  });
  final bytes = utf8.encode(
    const JsonEncoder.withIndent('  ').convert({
      'format': 'yam-foods',
      'version': 1,
      'foods': [for (final food in data.foods) food.toJson()],
    }),
  );
  if (bytes.length > maxFoodLibraryFileBytes) {
    throw const FoodLibraryException(FoodLibraryFailure.tooLarge);
  }
  return bytes;
}

Map<String, Object?> _storedFoodJson(
  StoredUserFood food,
  List<StoredUserServing> servings,
  String path,
) {
  final unit = switch (food.basisUnit) {
    'grams' => 'g',
    'milliliters' => 'ml',
    _ => _invalidLibrary('$path.unit'),
  };
  final displayBasis = switch (food.displayBasis) {
    'perServing' => 'perServing',
    'perHundredGrams' when unit == 'g' => 'per100',
    'perHundredMilliliters' when unit == 'ml' => 'per100',
    _ => _invalidLibrary('$path.displayBasis'),
  };
  return {
    'name': food.name,
    'category': food.category,
    'unit': unit,
    'basisAmount': food.basisAmount,
    'kcal': food.energyKcal,
    'protein': food.proteinG,
    'fat': food.fatG,
    'carbs': food.carbsG,
    'brand': food.brand,
    'barcode': food.barcode,
    'description': food.description,
    'displayBasis': displayBasis,
    'servings': [
      for (final serving in servings)
        {
          'unit': serving.unit,
          'baseAmount': serving.baseAmount,
          'defaultAmount': serving.defaultAmount,
          'label': serving.label,
        },
    ],
  };
}

_FoodLibraryData _decodeLibrary(Uint8List bytes) {
  try {
    var text = utf8.decode(bytes);
    if (text.startsWith('\uFEFF')) text = text.substring(1);
    return _readLibrary(jsonDecode(text));
  } on FoodLibraryException {
    rethrow;
  } catch (_) {
    // Do not expose parser messages: they can contain the supplied recipe text.
    throw const FoodLibraryException(
      FoodLibraryFailure.invalidFile,
      path: '\$',
    );
  }
}

_FoodLibraryData _readLibrary(Object? value) {
  final root = _libraryObject(value, '\$');
  if (root['format'] != 'yam-foods') _invalidLibrary('\$.format');
  final version = root['version'];
  if (version is! int || version <= 0) _invalidLibrary('\$.version');
  if (version != 1) {
    throw const FoodLibraryException(
      FoodLibraryFailure.unsupportedVersion,
      path: '\$.version',
    );
  }
  final values = root['foods'];
  if (values is! List) _invalidLibrary('\$.foods');
  _checkLibraryCounts(values.length, 0);
  final foods = <_LibraryFood>[];
  var servingCount = 0;
  for (var index = 0; index < values.length; index++) {
    final food = _readLibraryFood(values[index], '\$.foods[$index]');
    servingCount += food.servings.length;
    _checkLibraryCounts(values.length, servingCount);
    foods.add(food);
  }
  return _FoodLibraryData(foods);
}

_LibraryFood _readLibraryFood(Object? value, String path) {
  final food = _libraryObject(value, path);
  final name = _libraryText(food['name'], '$path.name');
  final category = _libraryText(food['category'], '$path.category');
  final basis = switch (food['unit']) {
    'g' => CustomFoodBasis.grams,
    'ml' => CustomFoodBasis.milliliters,
    _ => _invalidLibrary('$path.unit'),
  };
  final basisAmount = _libraryNumber(
    food['basisAmount'],
    '$path.basisAmount',
    positive: true,
  );
  final kcal = _libraryNumber(food['kcal'], '$path.kcal');
  final protein = _libraryNumber(food['protein'], '$path.protein');
  final fat = _libraryNumber(food['fat'], '$path.fat');
  final carbs = _libraryNumber(food['carbs'], '$path.carbs');
  final brand = _optionalLibraryText(food['brand'], '$path.brand');
  final barcode = _optionalLibraryText(food['barcode'], '$path.barcode');
  if (barcode != null && !RegExp(r'^[0-9]+$').hasMatch(barcode)) {
    _invalidLibrary('$path.barcode');
  }
  final description = _optionalLibraryText(
    food['description'],
    '$path.description',
  );
  final display =
      food['displayBasis'] ?? (basisAmount == 100 ? 'per100' : 'perServing');
  final CustomFoodDisplayBasis displayBasis;
  switch (display) {
    case 'per100':
      if (basisAmount != 100) _invalidLibrary('$path.displayBasis');
      displayBasis = basis == CustomFoodBasis.grams
          ? CustomFoodDisplayBasis.perHundredGrams
          : CustomFoodDisplayBasis.perHundredMilliliters;
    case 'perServing':
      displayBasis = CustomFoodDisplayBasis.perServing;
    default:
      _invalidLibrary('$path.displayBasis');
  }

  final rawServings = food['servings'];
  if (rawServings != null && rawServings is! List) {
    _invalidLibrary('$path.servings');
  }
  final values = rawServings as List? ?? const [];
  if (values.length > _maxFoodLibraryServings) {
    throw FoodLibraryException(
      FoodLibraryFailure.tooLarge,
      path: '$path.servings',
    );
  }
  final servings = [
    for (var index = 0; index < values.length; index++)
      _readLibraryServing(values[index], '$path.servings[$index]'),
  ];
  if (displayBasis == CustomFoodDisplayBasis.perServing &&
      !servings.any(
        (serving) =>
            serving.unit == CustomServingUnit.serving &&
            serving.baseAmount == basisAmount,
      )) {
    if (servings.length == _maxFoodLibraryServings) {
      throw FoodLibraryException(
        FoodLibraryFailure.tooLarge,
        path: '$path.servings',
      );
    }
    servings.add(
      _LibraryServing(
        unit: CustomServingUnit.serving,
        baseAmount: basisAmount,
        defaultAmount: 1,
        label: null,
      ),
    );
  }
  return _LibraryFood(
    name: name,
    category: category,
    brand: brand,
    barcode: barcode,
    description: description,
    basis: basis,
    basisAmount: basisAmount,
    displayBasis: displayBasis,
    kcal: kcal,
    protein: protein,
    fat: fat,
    carbs: carbs,
    servings: servings,
  );
}

_LibraryServing _readLibraryServing(Object? value, String path) {
  final serving = _libraryObject(value, path);
  final unit = switch (serving['unit']) {
    'serving' => CustomServingUnit.serving,
    'piece' => CustomServingUnit.piece,
    'glass' => CustomServingUnit.glass,
    'scoop' => CustomServingUnit.scoop,
    _ => _invalidLibrary('$path.unit'),
  };
  return _LibraryServing(
    unit: unit,
    baseAmount: _libraryNumber(
      serving['baseAmount'],
      '$path.baseAmount',
      positive: true,
    ),
    defaultAmount: serving['defaultAmount'] == null
        ? 1
        : _libraryNumber(
            serving['defaultAmount'],
            '$path.defaultAmount',
            positive: true,
          ),
    label: _optionalLibraryText(serving['label'], '$path.label'),
  );
}

void _checkLibraryCounts(int foods, int servings) {
  if (foods > _maxFoodLibraryFoods || servings > _maxFoodLibraryServings) {
    throw const FoodLibraryException(
      FoodLibraryFailure.tooLarge,
      path: '\$.foods',
    );
  }
}

Map<String, dynamic> _libraryObject(Object? value, String path) {
  if (value is! Map<String, dynamic>) _invalidLibrary(path);
  return value;
}

String _libraryText(Object? value, String path) {
  if (value is! String || value.trim().isEmpty) _invalidLibrary(path);
  return value;
}

String? _optionalLibraryText(Object? value, String path) {
  if (value != null && value is! String) _invalidLibrary(path);
  return value as String?;
}

double _libraryNumber(Object? value, String path, {bool positive = false}) {
  if (value is! num || !value.isFinite || (positive ? value <= 0 : value < 0)) {
    _invalidLibrary(path);
  }
  final number = value.toDouble();
  if (!number.isFinite) _invalidLibrary(path);
  return number;
}

Never _invalidLibrary(String path) =>
    throw FoodLibraryException(FoodLibraryFailure.invalidFile, path: path);
