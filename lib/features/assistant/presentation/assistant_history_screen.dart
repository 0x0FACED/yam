import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/feedback/yam_feedback_state.dart';
import 'package:yam/core/ui/lists/yam_settings_list.dart';
import 'package:yam/features/assistant/data/assistant_conversation_repository.dart';
import 'package:yam/features/assistant/domain/assistant_conversation.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class AssistantHistoryScreen extends StatefulWidget {
  const AssistantHistoryScreen({required this.repository, super.key});

  final AssistantConversationRepository repository;

  @override
  State<AssistantHistoryScreen> createState() => _AssistantHistoryScreenState();
}

class _AssistantHistoryScreenState extends State<AssistantHistoryScreen> {
  late Stream<List<AssistantConversationSummary>> _conversations;
  String? _pendingDelete;
  bool _deleteFailed = false;

  @override
  void initState() {
    super.initState();
    _conversations = widget.repository.watchConversations();
  }

  @override
  void didUpdateWidget(AssistantHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _conversations = widget.repository.watchConversations();
      _deleteFailed = false;
    }
  }

  void _reload() {
    setState(() {
      _conversations = widget.repository.watchConversations();
    });
  }

  Future<void> _delete(AssistantConversationSummary conversation) async {
    if (_pendingDelete != null) return;
    final l10n = AppLocalizations.of(context);
    final title = conversation.title.trim().isEmpty
        ? l10n.assistantHistoryPhotoTitle
        : conversation.title;
    setState(() {
      _pendingDelete = conversation.id;
      _deleteFailed = false;
    });
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.assistantHistoryDeleteTitle),
          content: Text(l10n.assistantHistoryDeleteMessage(title)),
          scrollable: true,
          actions: [
            YamTextButton(
              label: l10n.backupCancel,
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            YamTextButton(
              label: l10n.assistantHistoryDelete,
              tone: YamTextButtonTone.destructive,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
      await widget.repository.delete(conversation.id);
    } catch (_) {
      if (mounted) setState(() => _deleteFailed = true);
    } finally {
      if (mounted) setState(() => _pendingDelete = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.assistantHistory)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_deleteFailed)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        l10n.assistantHistoryDeleteError,
                        style: AppTypography.body.copyWith(color: colors.error),
                      ),
                    ),
                  ),
                Expanded(
                  child: StreamBuilder<List<AssistantConversationSummary>>(
                    key: ObjectKey(_conversations),
                    stream: _conversations,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return YamFeedbackViewport(
                          child: YamFeedbackState(
                            icon: Icons.error_outline_rounded,
                            title: l10n.assistantHistoryLoadError,
                            message: l10n.assistantHistoryStorageError,
                            error: true,
                            actionLabel: l10n.assistantHistoryRetry,
                            actionIcon: Icons.refresh_rounded,
                            onAction: _reload,
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            semanticsLabel: l10n.assistantHistoryLoading,
                          ),
                        );
                      }
                      final conversations = snapshot.data!;
                      if (conversations.isEmpty) {
                        return YamFeedbackViewport(
                          child: YamFeedbackState(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: l10n.assistantHistoryEmpty,
                            message: l10n.assistantHistoryEmptyNote,
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: conversations.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.xs),
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          final title = conversation.title.trim().isEmpty
                              ? l10n.assistantHistoryPhotoTitle
                              : conversation.title;
                          final updatedAt = conversation.updatedAt.toLocal();
                          final material = MaterialLocalizations.of(context);
                          final subtitle = l10n.assistantHistoryUpdatedAt(
                            material.formatMediumDate(updatedAt),
                            material.formatTimeOfDay(
                              TimeOfDay.fromDateTime(updatedAt),
                              alwaysUse24HourFormat:
                                  MediaQuery.alwaysUse24HourFormatOf(context),
                            ),
                          );
                          return Material(
                            key: ValueKey(conversation.id),
                            color: colors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.control,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              children: [
                                Expanded(
                                  child: YamSettingsRow(
                                    title: title,
                                    subtitle: subtitle,
                                    onPressed: _pendingDelete == null
                                        ? () => Navigator.pop<String>(
                                            context,
                                            conversation.id,
                                          )
                                        : null,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.xs,
                                  ),
                                  child: _pendingDelete == conversation.id
                                      ? SizedBox.square(
                                          dimension: 44,
                                          child: Center(
                                            child: SizedBox.square(
                                              dimension: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                semanticsLabel: l10n
                                                    .assistantHistoryDeleting,
                                              ),
                                            ),
                                          ),
                                        )
                                      : YamIconButton(
                                          icon: Icons.delete_outline_rounded,
                                          tooltip: l10n
                                              .assistantHistoryDeleteAction(
                                                title,
                                              ),
                                          destructive: true,
                                          surface: false,
                                          onPressed: _pendingDelete == null
                                              ? () => _delete(conversation)
                                              : null,
                                        ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
