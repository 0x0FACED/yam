import 'dart:typed_data';

import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';

enum AssistantConnectionMode { apiKey, chatgpt }

class AssistantModel {
  const AssistantModel({required this.id, required this.label});
  final String id;
  final String label;
}

class AssistantImage {
  const AssistantImage({required this.bytes, required this.mimeType});
  final Uint8List bytes;
  final String mimeType;
}

class AssistantTurn {
  const AssistantTurn({required this.output});
  final List<Map<String, dynamic>> output;

  String get text => output
      .where((item) => item['type'] == 'message')
      .expand((item) => (item['content'] as List?) ?? const [])
      .whereType<Map>()
      .where((part) => part['type'] == 'output_text')
      .map((part) => part['text'] as String? ?? '')
      .join('\n');
}

/// Only a completed response may be returned. Tool execution stays in YAM.
abstract class AssistantGateway {
  Future<List<AssistantModel>> listModels();
  Future<AssistantTurn> respond({
    required String model,
    required String instructions,
    required List<Map<String, dynamic>> input,
    required List<Map<String, dynamic>> tools,
    void Function(String delta)? onText,
  });
  void cancel();
  void close();
}

/// Stable codes are localized at the UI boundary; never display provider bodies.
class AssistantFailure implements Exception {
  const AssistantFailure(this.code);
  final String code;
  @override
  String toString() => 'AssistantFailure($code)';
}

class AssistantDraftItem {
  const AssistantDraftItem({
    required this.id,
    required this.food,
    required this.servingId,
    required this.amount,
    this.isEstimated = false,
    this.newFood,
    this.saveToCatalog = false,
    this.addToDiary = true,
  });

  final String id;
  final DiaryFoodSnapshot food;
  final String servingId;
  final double amount;
  final bool isEstimated;
  final CustomFoodDraft? newFood;
  final bool saveToCatalog;
  final bool addToDiary;

  double get canonicalQuantity => food.serving(servingId).baseAmount * amount;
  DiaryNutrition get nutrition => food.nutritionFor(canonicalQuantity);

  AssistantDraftItem copyWith({
    DiaryFoodSnapshot? food,
    String? servingId,
    double? amount,
    bool? isEstimated,
    CustomFoodDraft? newFood,
    bool? saveToCatalog,
    bool? addToDiary,
  }) => AssistantDraftItem(
    id: id,
    food: food ?? this.food,
    servingId: servingId ?? this.servingId,
    amount: amount ?? this.amount,
    isEstimated: isEstimated ?? this.isEstimated,
    newFood: newFood ?? this.newFood,
    saveToCatalog: saveToCatalog ?? this.saveToCatalog,
    addToDiary: addToDiary ?? this.addToDiary,
  );
}

class AssistantDraft {
  const AssistantDraft({
    required this.id,
    required this.day,
    required this.mealId,
    required this.items,
  });

  final String id;
  final DateTime day;
  final String mealId;
  final List<AssistantDraftItem> items;

  bool get hasDiaryItems => items.any((item) => item.addToDiary);
  DiaryNutrition get nutrition {
    var kcal = 0.0;
    var protein = 0.0;
    var fat = 0.0;
    var carbs = 0.0;
    for (final item in items.where((item) => item.addToDiary)) {
      final value = item.nutrition;
      kcal += value.kcal;
      protein += value.protein;
      fat += value.fat;
      carbs += value.carbs;
    }
    return DiaryNutrition(kcal: kcal, protein: protein, fat: fat, carbs: carbs);
  }

  AssistantDraft copyWith({
    DateTime? day,
    String? mealId,
    List<AssistantDraftItem>? items,
  }) => AssistantDraft(
    id: id,
    day: day ?? this.day,
    mealId: mealId ?? this.mealId,
    items: items ?? this.items,
  );
}

class AssistantMessage {
  const AssistantMessage({
    required this.isUser,
    required this.text,
    this.image,
  });
  final bool isUser;
  final String text;
  final AssistantImage? image;
}
