import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/assistant/application/assistant_controller.dart';
import 'package:yam/features/assistant/application/assistant_tools.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';

AssistantTurn _prepare(String name) => AssistantTurn(
  output: [
    {
      'type': 'function_call',
      'call_id': 'prepare-$name',
      'name': 'prepare_draft',
      'arguments': jsonEncode({
        'day': '2026-11-06',
        'mealId': 'breakfast',
        'items': [
          {
            'newProduct': {
              'name': name,
              'category': 'other',
              'basis': 'grams',
              'basisAmount': 100,
              'proteinG': 10,
              'fatG': 2,
              'carbsG': 20,
            },
            'servingId': 'grams',
            'amount': 25,
            'isEstimated': true,
          },
        ],
      }),
    },
  ],
);
const _finished = AssistantTurn(
  output: [
    {
      'type': 'message',
      'role': 'assistant',
      'content': [
        {'type': 'output_text', 'text': 'Review the prepared meal.'},
      ],
    },
  ],
);

class _ScriptedGateway implements AssistantGateway {
  final replies = Queue<Future<AssistantTurn> Function()>();
  @override
  Future<AssistantTurn> respond({
    required String model,
    required String instructions,
    required List<Map<String, dynamic>> input,
    required List<Map<String, dynamic>> tools,
    void Function(String delta)? onText,
  }) => replies.removeFirst()();
  @override
  Future<List<AssistantModel>> listModels() async => [
    const AssistantModel(id: 'fixture', label: 'Fixture'),
  ];
  @override
  void cancel() {}
  @override
  void close() {}
}

void main() {
  late YamDatabase database;
  late DiaryRepository diary;
  late AssistantController controller;
  late _ScriptedGateway gateway;
  final day = DateTime(2026, 11, 6);

  setUp(() {
    database = YamDatabase(NativeDatabase.memory());
    diary = DiaryRepository(database);
    gateway = _ScriptedGateway();
    controller = AssistantController(
      tools: AssistantTools(
        database: database,
        userFoods: UserFoodRepository(database),
        diary: diary,
        locale: const Locale('en'),
      ),
      gateway: () => gateway,
      model: () => 'fixture',
      day: day,
    );
  });
  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  test(
    'incomplete final response preserves reviewed draft and cannot resurrect discarded tool state',
    () async {
      gateway.replies.addAll([
        () async => _prepare('Reviewed food'),
        () async => _finished,
      ]);
      await controller.send('Prepare my breakfast');
      final reviewed = controller.draft!;
      gateway.replies.addAll([
        () async => _prepare('Unfinished replacement'),
        () async => throw const AssistantFailure('interrupted'),
      ]);
      await controller.send('Change the meal');
      expect(controller.draft!.id, reviewed.id);
      expect(controller.draft!.items.single.food.name, 'Reviewed food');
      expect(controller.failureCode, 'interrupted');
      expect(await diary.watchDay(day).first, isEmpty);
      controller.dismissDraft();
      gateway.replies.add(() async => _finished);
      await controller.send('Just answer a question');
      expect(controller.draft, isNull);
      expect(await diary.watchDay(day).first, isEmpty);
      expect(await database.select(database.userFoods).get(), isEmpty);
    },
  );

  test(
    'cancelled late tool response cannot prepare or write; retry and one confirmation save exactly once',
    () async {
      final late = Completer<AssistantTurn>();
      gateway.replies.add(() => late.future);
      final cancelled = controller.send('Prepare breakfast');
      controller.cancel();
      late.complete(_prepare('Cancelled food'));
      await cancelled;
      expect(controller.draft, isNull);
      expect(controller.canRetry, isTrue);
      expect(await diary.watchDay(day).first, isEmpty);
      gateway.replies.addAll([
        () async => _prepare('Confirmed food'),
        () async => _finished,
      ]);
      await controller.retry();
      expect(
        controller.messages.where((message) => message.isUser),
        hasLength(1),
      );
      expect(await diary.watchDay(day).first, isEmpty);
      final first = controller.confirm();
      final second = controller.confirm();
      expect(await first, isTrue);
      expect(await second, isFalse);
      final entry = (await diary.watchDay(day).first).single;
      expect(entry.food.name, 'Confirmed food');
      expect(entry.canonicalQuantity, 25);
      expect(entry.nutrition.kcal, (10 * 4 + 2 * 9 + 20 * 4) / 4);
      expect(entry.isEstimated, isTrue);
      expect(await database.select(database.userFoods).get(), isEmpty);
      expect(controller.draft, isNull);
    },
  );
}
