import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';
import 'package:yam/features/food_search/presentation/custom_food_adapter.dart';
import 'package:yam/features/food_search/presentation/diary_food_adapter.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/remote_food_adapter.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

/// Session-scoped, read/prepare-only model tools. Only [commit] writes data.
class AssistantTools {
  AssistantTools({
    required this.database,
    required this.userFoods,
    required this.diary,
    required this.locale,
  }) {
    if (!identical(database, userFoods.database) ||
        !identical(database, diary.database)) {
      throw ArgumentError('Assistant repositories must share one database');
    }
  }

  final YamDatabase database;
  final UserFoodRepository userFoods;
  final DiaryRepository diary;
  final Locale locale;
  static const _uuid = Uuid();
  final _issuedFoods = <String, DiaryFoodSnapshot>{};
  final _issuedDrafts = <String, AssistantDraft>{};
  final _commits = <String, Future<List<String>>>{};
  AssistantDraft? _draft;
  AssistantDraft? get draft => _draft;

  List<Map<String, dynamic>> get definitions => [
    _function(
      'search_foods',
      'Search the local food catalog by name or brand. Always look up real '
          'foods before preparing existing-food entries. Do not request or send '
          'the entire catalog. Results include exact serving coefficients.',
      {
        'query': {'type': 'string'},
        'limit': {'type': 'integer', 'minimum': 1, 'maximum': 20},
      },
      ['query'],
    ),
    _function(
      'get_food',
      'Read one local food and its exact nutrition/servings. Use returned '
          'foodId and servingId, never invent catalog nutrition or coefficients.',
      {
        'foodId': {'type': 'string'},
      },
      ['foodId'],
    ),
    _function(
      'read_diary',
      'Read only the requested local calendar day (YYYY-MM-DD). Do not read '
          'history unless the user requests it.',
      {
        'day': {'type': 'string', 'description': 'Local date YYYY-MM-DD'},
      },
      ['day'],
    ),
    _function(
      'prepare_draft',
      'Prepare an editable draft, never save. ONE user confirmation later '
          'saves all selected items atomically. Each item uses either a real '
          'foodId returned by search_foods/get_food, OR newProduct with macros '
          'per its basisAmount. Energy for new products is computed locally from '
          'macros. amount counts the chosen servingId, NOT canonical grams unless '
          'servingId is grams. Milliliters are not grams. New serving IDs are '
          'new-serving-0, new-serving-1, etc.; canonical IDs are grams/milliliters. '
          'For a non-100 nutrition basis include a serving matching basisAmount. '
          'Mark visual/uncertain estimates isEstimated. A new product can be '
          'catalog-only (saveToCatalog true, addToDiary false), or a diary-only '
          'snapshot (saveToCatalog false). Never silently add estimates to catalog.',
      {
        'day': {'type': 'string'},
        'mealId': {'type': 'string', 'enum': diaryMealIds.toList()},
        'items': {
          'type': 'array',
          'minItems': 1,
          'maxItems': 50,
          'items': {
            'type': 'object',
            'additionalProperties': false,
            'properties': {
              'foodId': {'type': 'string'},
              'newProduct': {
                'type': 'object',
                'additionalProperties': false,
                'properties': {
                  'name': {'type': 'string'},
                  'category': {'type': 'string'},
                  'brand': {'type': 'string'},
                  'barcode': {'type': 'string'},
                  'description': {'type': 'string'},
                  'basis': {
                    'type': 'string',
                    'enum': ['grams', 'milliliters'],
                  },
                  'basisAmount': {'type': 'number', 'exclusiveMinimum': 0},
                  'proteinG': {'type': 'number', 'minimum': 0},
                  'fatG': {'type': 'number', 'minimum': 0},
                  'carbsG': {'type': 'number', 'minimum': 0},
                  'servings': {
                    'type': 'array',
                    'maxItems': 20,
                    'items': {
                      'type': 'object',
                      'additionalProperties': false,
                      'properties': {
                        'unit': {
                          'type': 'string',
                          'enum': ['serving', 'piece', 'glass', 'scoop'],
                        },
                        'baseAmount': {'type': 'number', 'exclusiveMinimum': 0},
                        'defaultAmount': {
                          'type': 'number',
                          'exclusiveMinimum': 0,
                        },
                        'label': {'type': 'string'},
                      },
                      'required': ['unit', 'baseAmount'],
                    },
                  },
                },
                'required': [
                  'name',
                  'category',
                  'basis',
                  'basisAmount',
                  'proteinG',
                  'fatG',
                  'carbsG',
                ],
              },
              'servingId': {'type': 'string'},
              'amount': {'type': 'number', 'exclusiveMinimum': 0},
              'isEstimated': {'type': 'boolean'},
              'saveToCatalog': {'type': 'boolean'},
              'addToDiary': {'type': 'boolean'},
            },
            'required': ['servingId', 'amount'],
          },
        },
      },
      ['day', 'mealId', 'items'],
    ),
  ];

  Future<Map<String, dynamic>> execute(
    String name,
    Map<String, dynamic> arguments,
  ) async {
    try {
      switch (name) {
        case 'search_foods':
          _keys(arguments, {'query', 'limit'});
          final query = _text(arguments['query']).toLowerCase();
          final limit = arguments['limit'] ?? 10;
          if (limit is! int || limit < 1 || limit > 20) _invalid();
          final matches = (await _catalog())
              .where(
                (food) => '${food.name} ${food.brand ?? ''}'
                    .toLowerCase()
                    .contains(query),
              )
              .take(limit)
              .toList();
          return {
            'foods': [for (final food in matches) _issue(food)],
          };
        case 'get_food':
          _keys(arguments, {'foodId'});
          final food = await _find(_text(arguments['foodId']));
          return {'food': _issue(food)};
        case 'read_diary':
          _keys(arguments, {'day'});
          final day = _day(arguments['day']);
          final entries = await diary.watchDay(day).first;
          return {
            'day': diaryDayKey(day),
            'entries': [
              for (final entry in entries)
                {
                  'id': entry.id,
                  'mealId': entry.mealId,
                  'food': _foodJson(entry.food),
                  'servingId': entry.servingId,
                  'amount': entry.amount,
                  'canonicalQuantity': entry.canonicalQuantity,
                  'isEstimated': entry.isEstimated,
                },
            ],
          };
        case 'prepare_draft':
          _keys(arguments, {'day', 'mealId', 'items'});
          final day = _day(arguments['day']);
          final mealId = _text(arguments['mealId']);
          if (!diaryMealIds.contains(mealId)) _invalid();
          final rawItems = arguments['items'];
          if (rawItems is! List || rawItems.isEmpty || rawItems.length > 50) {
            _invalid();
          }
          final items = <AssistantDraftItem>[];
          List<FoodSearchPrototypeFood>? catalog;
          for (final value in rawItems) {
            final item = _map(value);
            _keys(item, {
              'foodId',
              'newProduct',
              'servingId',
              'amount',
              'isEstimated',
              'saveToCatalog',
              'addToDiary',
            });
            final newProduct = item['newProduct'];
            if ((item['foodId'] == null) == (newProduct == null)) _invalid();
            final CustomFoodDraft? newFood = newProduct == null
                ? null
                : _newFood(_map(newProduct));
            final DiaryFoodSnapshot food;
            if (newFood != null) {
              food = snapshotForNewFood(newFood, foodId: _uuid.v7());
            } else {
              final id = _text(item['foodId']);
              if (!_issuedFoods.containsKey(id)) {
                throw const AssistantFailure('food_lookup_required');
              }
              food = diarySnapshotForFood(
                await _find(id, foods: catalog ??= await _catalog()),
              );
              _issuedFoods[id] = food;
            }
            final prepared = AssistantDraftItem(
              id: _uuid.v7(),
              food: food,
              servingId: _text(item['servingId']),
              amount: _number(item['amount']),
              newFood: newFood,
              isEstimated: _bool(item, 'isEstimated', false),
              saveToCatalog: _bool(item, 'saveToCatalog', false),
              addToDiary: _bool(item, 'addToDiary', true),
            );
            _validateItem(prepared, day, mealId);
            items.add(prepared);
          }
          final prepared = AssistantDraft(
            id: _uuid.v7(),
            day: day,
            mealId: mealId,
            items: List.unmodifiable(items),
          );
          _issuedDrafts[prepared.id] = prepared;
          _draft = prepared;
          return {
            'draftId': prepared.id,
            'requiresConfirmation': true,
            'day': diaryDayKey(day),
            'mealId': mealId,
            'items': [
              for (final item in items)
                {
                  'id': item.id,
                  'food': _foodJson(item.food),
                  'servingId': item.servingId,
                  'amount': item.amount,
                  'canonicalQuantity': item.canonicalQuantity,
                  'isEstimated': item.isEstimated,
                  'saveToCatalog': item.saveToCatalog,
                  'addToDiary': item.addToDiary,
                },
            ],
          };
        default:
          return {
            'error': {'code': 'unknown_tool'},
          };
      }
    } on AssistantFailure catch (error) {
      return {
        'error': {'code': error.code},
      };
    } on ArgumentError {
      return {
        'error': {'code': 'invalid_arguments'},
      };
    } on StateError {
      return {
        'error': {'code': 'invalid_arguments'},
      };
    } on FormatException {
      return {
        'error': {'code': 'invalid_arguments'},
      };
    } catch (_) {
      // Never expose provider, SQL, filesystem paths or raw exception text.
      return {
        'error': {'code': 'local_data_unavailable'},
      };
    }
  }

  /// Reuses the manual custom-food and diary adapters for editable new foods.
  DiaryFoodSnapshot snapshotForNewFood(
    CustomFoodDraft food, {
    required String foodId,
  }) {
    food.validate();
    final now = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    return diarySnapshotForFood(
      adaptUserFood(
        SavedUserFood(
          StoredUserFood(
            id: foodId,
            name: food.name.trim(),
            category: food.category,
            brand: food.brand?.trim().isEmpty == true
                ? null
                : food.brand?.trim(),
            description: food.description,
            barcode: food.barcode,
            basisUnit: food.basis.name,
            basisAmount: food.basisAmount,
            displayBasis: food.displayBasis.name,
            energyKcal: food.energyKcal,
            proteinG: food.proteinG,
            fatG: food.fatG,
            carbsG: food.carbsG,
            isFavorite: false,
            createdAt: now,
            updatedAt: now,
            deviceId: '',
          ),
          [
            for (var index = 0; index < food.servings.length; index++)
              StoredUserServing(
                id: 'new-serving-$index',
                foodId: foodId,
                unit: food.servings[index].unit.name,
                label: food.servings[index].label?.trim().isEmpty == true
                    ? null
                    : food.servings[index].label?.trim(),
                baseAmount: food.servings[index].baseAmount,
                defaultAmount: food.servings[index].defaultAmount,
                createdAt: now,
                updatedAt: now,
                deviceId: '',
              ),
          ],
        ),
        lookupAppLocalizations(locale),
      ),
    );
  }

  /// UI-only capability: the model's tool dispatcher never invokes this method.
  /// Concurrent/repeated confirmations share a future; rollback permits retry.
  Future<List<String>> commit(AssistantDraft draft) {
    final existing = _commits[draft.id];
    if (existing != null) return existing;
    final pending = _commit(draft);
    _commits[draft.id] = pending;
    pending.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {
        if (identical(_commits[draft.id], pending)) _commits.remove(draft.id);
      },
    );
    return pending;
  }

  Future<List<String>> _commit(AssistantDraft draft) async {
    try {
      final issued = _issuedDrafts[draft.id];
      if (issued == null ||
          draft.items.isEmpty ||
          draft.items.length > 50 ||
          !diaryMealIds.contains(draft.mealId) ||
          draft.day.isUtc ||
          diaryDayKey(_day(diaryDayKey(draft.day))) != diaryDayKey(draft.day)) {
        _invalid();
      }
      final originals = {for (final item in issued.items) item.id: item};
      final seen = <String>{};
      return await database.transaction(() async {
        final ids = <String>[];
        List<FoodSearchPrototypeFood>? catalog;
        for (final item in draft.items) {
          final original = originals[item.id];
          if (original == null ||
              !seen.add(item.id) ||
              (original.newFood == null) != (item.newFood == null)) {
            _invalid();
          }
          _validateItem(item, draft.day, draft.mealId);
          var food = item.food;
          if (item.newFood == null) {
            final current = diarySnapshotForFood(
              await _find(
                original.food.foodId,
                foods: catalog ??= await _catalog(),
              ),
            );
            if (!_sameFood(item.food, original.food) ||
                !_sameFood(item.food, current)) {
              throw const AssistantFailure('food_changed');
            }
          } else {
            if (item.food.foodId != original.food.foodId ||
                !_sameFood(
                  item.food,
                  snapshotForNewFood(
                    item.newFood!,
                    foodId: original.food.foodId,
                  ),
                )) {
              _invalid();
            }
            if (item.saveToCatalog) {
              final id = await userFoods.create(item.newFood!);
              // Keep the confirmed snapshot/serving identifiers, but link the
              // snapshot to the newly saved catalog product.
              food = DiaryFoodSnapshot(
                foodId: id,
                name: food.name,
                brand: food.brand,
                baseUnit: food.baseUnit,
                basisAmount: food.basisAmount,
                nutritionPerBasis: food.nutritionPerBasis,
                servings: food.servings,
              );
            }
          }
          if (item.addToDiary) {
            ids.add(
              await diary.create(
                DiaryEntryDraft(
                  day: draft.day,
                  mealId: draft.mealId,
                  food: food,
                  servingId: item.servingId,
                  amount: item.amount,
                  canonicalQuantity: item.canonicalQuantity,
                  isEstimated: item.isEstimated,
                ),
              ),
            );
          }
        }
        return List<String>.unmodifiable(ids);
      });
    } on AssistantFailure {
      rethrow;
    } on ArgumentError {
      throw const AssistantFailure('invalid_draft');
    } on StateError {
      throw const AssistantFailure('invalid_draft');
    } catch (_) {
      throw const AssistantFailure('commit_failed');
    }
  }

  Future<List<FoodSearchPrototypeFood>> _catalog() async {
    final l10n = lookupAppLocalizations(locale);
    final remote = await (database.select(
      database.remoteFoods,
    )..where((row) => row.deletedAt.isNull())).get();
    return [
      ...buildFoodSearchPrototypeFoods(locale),
      ...adaptUserFoods(await userFoods.loadFoods(), l10n),
      for (final row in remote)
        adaptRemoteFood(
          productFromStoredRemoteFood(row),
          favorite: row.isFavorite,
          lastAmount: row.lastAmount,
        ),
    ];
  }

  Future<FoodSearchPrototypeFood> _find(
    String id, {
    List<FoodSearchPrototypeFood>? foods,
  }) async {
    for (final food in foods ?? await _catalog()) {
      if (food.id == id) return food;
    }
    throw const AssistantFailure('food_not_found');
  }

  Map<String, dynamic> _issue(FoodSearchPrototypeFood food) {
    final snapshot = diarySnapshotForFood(food);
    _issuedFoods[food.id] = snapshot;
    return {
      ..._foodJson(snapshot),
      'description': food.description,
      'defaultServingId': food.lastServingId,
      'defaultAmount': food.lastAmount,
    };
  }

  static Map<String, dynamic> _foodJson(DiaryFoodSnapshot food) => {
    'foodId': food.foodId,
    'name': food.name,
    'brand': food.brand,
    'baseUnit': food.baseUnit.name,
    'basisAmount': food.basisAmount,
    'nutritionPerBasis': {
      'kcal': food.nutritionPerBasis.kcal,
      'proteinG': food.nutritionPerBasis.protein,
      'fatG': food.nutritionPerBasis.fat,
      'carbsG': food.nutritionPerBasis.carbs,
    },
    'servings': [
      for (final serving in food.servings)
        {
          'id': serving.id,
          'unit': serving.unit,
          'label': serving.label,
          'baseAmount': serving.baseAmount,
        },
    ],
  };

  static bool _sameFood(DiaryFoodSnapshot a, DiaryFoodSnapshot b) {
    if (a.foodId != b.foodId ||
        a.name != b.name ||
        a.brand != b.brand ||
        a.baseUnit != b.baseUnit ||
        a.basisAmount != b.basisAmount ||
        a.nutritionPerBasis.kcal != b.nutritionPerBasis.kcal ||
        a.nutritionPerBasis.protein != b.nutritionPerBasis.protein ||
        a.nutritionPerBasis.fat != b.nutritionPerBasis.fat ||
        a.nutritionPerBasis.carbs != b.nutritionPerBasis.carbs ||
        a.servings.length != b.servings.length) {
      return false;
    }
    for (var index = 0; index < a.servings.length; index++) {
      final left = a.servings[index];
      final right = b.servings[index];
      if (left.id != right.id ||
          left.unit != right.unit ||
          left.label != right.label ||
          left.baseAmount != right.baseAmount) {
        return false;
      }
    }
    return true;
  }

  static void _validateItem(
    AssistantDraftItem item,
    DateTime day,
    String mealId,
  ) {
    if ((!item.addToDiary && !item.saveToCatalog) ||
        (item.newFood == null && item.saveToCatalog)) {
      _invalid();
    }
    item.newFood?.validate();
    DiaryEntryDraft(
      day: day,
      mealId: mealId,
      food: item.food,
      servingId: item.servingId,
      amount: item.amount,
      canonicalQuantity: item.canonicalQuantity,
      isEstimated: item.isEstimated,
    ).validate();
  }

  static CustomFoodDraft _newFood(Map<String, dynamic> value) {
    _keys(value, {
      'name',
      'category',
      'brand',
      'barcode',
      'description',
      'basis',
      'basisAmount',
      'proteinG',
      'fatG',
      'carbsG',
      'servings',
    });
    final basis = CustomFoodBasis.values.byName(_text(value['basis']));
    final amount = _number(value['basisAmount']);
    final rawServings = value['servings'] ?? const [];
    if (rawServings is! List || rawServings.length > 20) _invalid();
    final food = CustomFoodDraft(
      name: _text(value['name']),
      category: _text(value['category']),
      brand: _optionalText(value['brand']),
      barcode: _optionalText(value['barcode']),
      description: _optionalText(value['description']),
      basis: basis,
      basisAmount: amount,
      displayBasis: amount == 100
          ? (basis == CustomFoodBasis.grams
                ? CustomFoodDisplayBasis.perHundredGrams
                : CustomFoodDisplayBasis.perHundredMilliliters)
          : CustomFoodDisplayBasis.perServing,
      proteinG: _number(value['proteinG']),
      fatG: _number(value['fatG']),
      carbsG: _number(value['carbsG']),
      servings: [for (final raw in rawServings) _newServing(_map(raw))],
    );
    food.validate();
    return food;
  }

  static CustomServingDraft _newServing(Map<String, dynamic> value) {
    _keys(value, {'unit', 'baseAmount', 'defaultAmount', 'label'});
    return CustomServingDraft(
      unit: CustomServingUnit.values.byName(_text(value['unit'])),
      baseAmount: _number(value['baseAmount']),
      defaultAmount: value.containsKey('defaultAmount')
          ? _number(value['defaultAmount'])
          : 1,
      label: _optionalText(value['label']),
    );
  }

  static Map<String, dynamic> _function(
    String name,
    String description,
    Map<String, dynamic> properties,
    List<String> required,
  ) => {
    'type': 'function',
    'name': name,
    'description': description,
    'strict': false,
    'parameters': {
      'type': 'object',
      'additionalProperties': false,
      'properties': properties,
      'required': required,
    },
  };

  static Never _invalid() => throw const AssistantFailure('invalid_arguments');
  static void _keys(Map<String, dynamic> value, Set<String> allowed) {
    if (value.keys.any((key) => !allowed.contains(key))) _invalid();
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is! Map<String, dynamic>) _invalid();
    return value;
  }

  static String _text(dynamic value) {
    if (value is! String || value.trim().isEmpty || value.length > 10000) {
      _invalid();
    }
    return value.trim();
  }

  static String? _optionalText(dynamic value) =>
      value == null ? null : _text(value);
  static double _number(dynamic value) {
    if (value is! num || !value.isFinite) _invalid();
    return value.toDouble();
  }

  static bool _bool(Map<String, dynamic> value, String key, bool fallback) {
    if (!value.containsKey(key)) return fallback;
    if (value[key] is! bool) _invalid();
    return value[key] as bool;
  }

  static DateTime _day(dynamic value) {
    final text = _text(value);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) _invalid();
    final parsed = DateTime.tryParse(text);
    if (parsed == null || diaryDayKey(parsed) != text) _invalid();
    return parsed;
  }
}
