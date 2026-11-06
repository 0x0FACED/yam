import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/assistant/domain/assistant_conversation.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';

class AssistantConversationRepository {
  AssistantConversationRepository(this._database);

  final YamDatabase _database;

  Stream<List<AssistantConversationSummary>> watchConversations() {
    final table = _database.assistantConversations;
    final query = _database.selectOnly(table)
      ..addColumns([
        table.id,
        table.title,
        table.day,
        table.mealId,
        table.updatedAt,
      ])
      ..where(table.deletedAt.isNull())
      ..orderBy([
        OrderingTerm.desc(table.updatedAt),
        OrderingTerm.asc(table.id),
      ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          AssistantConversationSummary(
            id: row.read(table.id)!,
            title: row.read(table.title)!,
            day: _localDay(row.read(table.day)!),
            mealId: row.read(table.mealId)!,
            updatedAt: row.read(table.updatedAt)!,
          ),
      ],
    );
  }

  Future<AssistantConversation?> load(String id) async {
    final table = _database.assistantConversations;
    final row =
        await (_database.select(
              table,
            )..where((entry) => entry.id.equals(id) & entry.deletedAt.isNull()))
            .getSingleOrNull();
    if (row == null) return null;
    final messages = jsonDecode(row.messages) as List;
    return AssistantConversation(
      id: row.id,
      title: row.title,
      day: _localDay(row.day),
      mealId: row.mealId,
      updatedAt: row.updatedAt,
      messages: [
        for (final value in messages)
          AssistantMessage(
            isUser: value['isUser'] as bool,
            text: value['text'] as String,
            hasImage: value['hasImage'] as bool,
          ),
      ],
    );
  }

  Future<void> save({
    required String id,
    required DateTime day,
    required String mealId,
    required List<AssistantMessage> messages,
  }) async {
    final encoded = jsonEncode([
      for (final message in messages)
        {
          'isUser': message.isUser,
          'text': message.text,
          'hasImage': message.image != null || message.hasImage,
        },
    ]);
    final firstText = messages
        .where((message) => message.isUser && message.text.trim().isNotEmpty)
        .firstOrNull
        ?.text
        .trim();
    final title = firstText == null
        ? ''
        : String.fromCharCodes(firstText.runes.take(80));
    await _database.transaction(() async {
      final table = _database.assistantConversations;
      final existing = await (_database.select(
        table,
      )..where((entry) => entry.id.equals(id))).getSingleOrNull();
      // A late save must never resurrect a user-deleted conversation.
      if (existing?.deletedAt != null) {
        throw StateError('Cannot save a deleted conversation');
      }
      final now = DateTime.now().toUtc();
      if (existing == null) {
        final deviceId = await _database.installationDeviceId(const Uuid());
        await _database
            .into(table)
            .insert(
              AssistantConversationsCompanion.insert(
                id: id,
                title: title,
                day: diaryDayKey(day),
                mealId: mealId,
                messages: encoded,
                createdAt: now,
                updatedAt: now,
                deviceId: deviceId,
              ),
            );
      } else {
        await (_database.update(
          table,
        )..where((entry) => entry.id.equals(id))).write(
          AssistantConversationsCompanion(
            title: Value(title),
            day: Value(diaryDayKey(day)),
            mealId: Value(mealId),
            messages: Value(encoded),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  Future<void> delete(String id) async {
    final now = DateTime.now().toUtc();
    final table = _database.assistantConversations;
    await (_database.update(
      table,
    )..where((entry) => entry.id.equals(id) & entry.deletedAt.isNull())).write(
      AssistantConversationsCompanion(
        title: const Value(''),
        messages: const Value('[]'),
        updatedAt: Value(now),
        deletedAt: Value(now),
      ),
    );
  }

  static DateTime _localDay(String value) {
    final date = DateTime.parse(value);
    return DateTime(date.year, date.month, date.day);
  }
}
