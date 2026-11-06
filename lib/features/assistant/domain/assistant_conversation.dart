import 'package:yam/features/assistant/domain/assistant_models.dart';

class AssistantConversationSummary {
  const AssistantConversationSummary({
    required this.id,
    required this.title,
    required this.mealId,
    required this.day,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String mealId;
  final DateTime day;
  final DateTime updatedAt;
}

class AssistantConversation extends AssistantConversationSummary {
  AssistantConversation({
    required super.id,
    required super.title,
    required super.mealId,
    required super.day,
    required super.updatedAt,
    required List<AssistantMessage> messages,
  }) : messages = List.unmodifiable(messages);

  final List<AssistantMessage> messages;
}
