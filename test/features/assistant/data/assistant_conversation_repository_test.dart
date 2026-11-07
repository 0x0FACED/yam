import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/assistant/data/assistant_conversation_repository.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';

String _id(int value) =>
    '019a0000-0000-7000-8000-${value.toRadixString(16).padLeft(12, '0')}';

void main() {
  YamDatabase database() {
    final db = YamDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    return db;
  }

  test(
    'history watch emits saved metadata and removes deleted threads',
    () async {
      final db = database();
      final repository = AssistantConversationRepository(db);
      final history = StreamIterator(repository.watchConversations());
      addTearDown(history.cancel);
      expect(await history.moveNext(), isTrue);
      expect(history.current, isEmpty);
      await repository.save(
        id: _id(1),
        day: DateTime(2026, 11, 6),
        mealId: 'dinner',
        messages: const [AssistantMessage(isUser: true, text: 'A saved chat')],
      );
      expect(await history.moveNext(), isTrue);
      expect(history.current.single.id, _id(1));
      expect(history.current.single.title, 'A saved chat');
      await repository.delete(_id(1));
      expect(await history.moveNext(), isTrue);
      expect(history.current, isEmpty);
    },
  );

  test(
    'reopening restores text and image markers, never image bytes',
    () async {
      final dir = await Directory.systemTemp.createTemp('yam-chat-test-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/chats.sqlite');
      final db = YamDatabase(NativeDatabase(file));
      final repository = AssistantConversationRepository(db);
      final sentAt = DateTime.utc(2026, 11, 6, 12, 34, 56, 789);
      await repository.save(
        id: _id(1),
        day: DateTime(2026, 11, 6, 15),
        mealId: 'dinner',
        messages: [
          AssistantMessage(
            isUser: true,
            text: '',
            sentAt: sentAt,
            image: AssistantImage(
              bytes: Uint8List.fromList([101, 102, 103, 104]),
              mimeType: 'image/jpeg',
            ),
          ),
          const AssistantMessage(isUser: false, text: 'A bowl of oats. 🥣'),
          const AssistantMessage(isUser: true, text: '  Keep exact text\n  '),
        ],
      );
      final stored = await db.select(db.assistantConversations).getSingle();
      expect(stored.title, 'Keep exact text');
      expect(stored.deviceId, matches(RegExp(r'^[0-9a-f-]{36}$')));
      expect(stored.createdAt, stored.updatedAt);
      await db.close();

      final reopened = YamDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      final reader = AssistantConversationRepository(reopened);
      final chat = (await reader.load(_id(1)))!;
      expect(chat.day, DateTime(2026, 11, 6));
      expect(chat.mealId, 'dinner');
      expect(chat.messages, hasLength(3));
      expect(chat.messages.first.hasImage, isTrue);
      expect(chat.messages.first.sentAt, sentAt);
      expect(chat.messages[1].sentAt, isNull);
      expect(chat.messages.every((message) => message.image == null), isTrue);
      expect(chat.messages.last.text, '  Keep exact text\n  ');
      expect(() => chat.messages.clear(), throwsUnsupportedError);
      expect(await reader.load(_id(999)), isNull);
      expect(await reopened.select(reopened.diaryEntries).get(), isEmpty);

      // Saving reloaded placeholders preserves their marker without media.
      await reader.save(
        id: chat.id,
        day: chat.day,
        mealId: chat.mealId,
        messages: chat.messages,
      );
      expect((await reader.load(chat.id))!.messages.first.hasImage, isTrue);
      expect((await reader.load(chat.id))!.messages.first.sentAt, sentAt);
    },
  );

  test(
    'save preserves creation and device metadata; delete scrubs tombstone',
    () async {
      final db = database();
      final repository = AssistantConversationRepository(db);
      await repository.save(
        id: _id(1),
        day: DateTime(2026, 11, 6),
        mealId: 'breakfast',
        messages: const [AssistantMessage(isUser: true, text: 'Private text')],
      );
      final original = await db.select(db.assistantConversations).getSingle();
      final created = DateTime.utc(2020);
      await db
          .update(db.assistantConversations)
          .write(
            AssistantConversationsCompanion(
              createdAt: Value(created),
              updatedAt: Value(created),
              deviceId: Value(_id(500)),
            ),
          );
      await repository.save(
        id: _id(1),
        day: DateTime(2026, 11, 5),
        mealId: 'lunch',
        messages: const [
          AssistantMessage(isUser: true, text: 'Changed private text'),
        ],
      );
      final updated = await db.select(db.assistantConversations).getSingle();
      expect(updated.createdAt.toUtc(), created);
      expect(updated.deviceId, _id(500));
      expect(updated.updatedAt.isAfter(created), isTrue);
      expect(updated.id, original.id);
      expect(updated.day, '2026-11-05');
      expect(updated.mealId, 'lunch');
      await repository.delete(_id(1));
      final deleted = await db.select(db.assistantConversations).getSingle();
      expect(deleted.title, isEmpty);
      expect(jsonDecode(deleted.messages), isEmpty);
      expect(deleted.deletedAt, deleted.updatedAt);
      expect(deleted.createdAt.toUtc(), created);
      expect(deleted.deviceId, _id(500));
      expect(await repository.load(_id(1)), isNull);
      expect(await repository.watchConversations().first, isEmpty);
      await repository.delete(_id(1));
      await repository.delete(_id(999));
      expect(
        (await db.select(db.assistantConversations).getSingle()).toJson(),
        deleted.toJson(),
      );
      await expectLater(
        repository.save(
          id: _id(1),
          day: DateTime(2026, 11, 6),
          mealId: 'dinner',
          messages: const [AssistantMessage(isUser: true, text: 'Late save')],
        ),
        throwsStateError,
      );
      expect(
        (await db.select(db.assistantConversations).getSingle()).toJson(),
        deleted.toJson(),
      );
    },
  );

  test(
    'history orders updated times then IDs; photo-only title is empty',
    () async {
      final db = database();
      final repository = AssistantConversationRepository(db);
      for (final value in [2, 1, 3]) {
        await repository.save(
          id: _id(value),
          day: DateTime(2026, 11, 6),
          mealId: 'snacks',
          messages: const [
            AssistantMessage(isUser: true, text: '', hasImage: true),
          ],
        );
      }
      final sameTime = DateTime.utc(2026, 1, 1);
      await db
          .update(db.assistantConversations)
          .write(AssistantConversationsCompanion(updatedAt: Value(sameTime)));
      expect(
        (await repository.watchConversations().first).map((chat) => chat.id),
        [_id(1), _id(2), _id(3)],
      );
      expect((await repository.load(_id(1)))!.title, isEmpty);
      await (db.update(
        db.assistantConversations,
      )..where((chat) => chat.id.equals(_id(3)))).write(
        AssistantConversationsCompanion(
          updatedAt: Value(DateTime.utc(2026, 2)),
        ),
      );
      expect(
        (await repository.watchConversations().first).map((chat) => chat.id),
        [_id(3), _id(1), _id(2)],
      );
      await repository.delete(_id(2));
      expect(
        (await repository.watchConversations().first).map((chat) => chat.id),
        [_id(3), _id(1)],
      );
    },
  );

  test(
    'title uses first nonempty user text and does not split Unicode runes',
    () async {
      final db = database();
      final repository = AssistantConversationRepository(db);
      final text = List.filled(81, '🥣').join();
      await repository.save(
        id: _id(1),
        day: DateTime(2026, 11, 6),
        mealId: 'breakfast',
        messages: [
          const AssistantMessage(isUser: false, text: 'Not a title'),
          const AssistantMessage(isUser: true, text: '   '),
          AssistantMessage(isUser: true, text: text),
          const AssistantMessage(isUser: true, text: 'Not first'),
        ],
      );
      final chat = (await repository.load(_id(1)))!;
      expect(chat.title, List.filled(80, '🥣').join());
      expect(chat.messages[2].text, text);
    },
  );
}
