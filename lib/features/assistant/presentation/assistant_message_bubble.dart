import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';
import 'package:yam/features/assistant/presentation/assistant_markdown.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({required this.message, super.key});

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final sentAt = message.sentAt?.toLocal();
    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (message.image case final image?) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Image.memory(
                image.bytes,
                height: 160,
                fit: BoxFit.contain,
                semanticLabel: l10n.assistantPhotoAttached,
              ),
            ),
            if (message.text.isNotEmpty) const SizedBox(height: AppSpacing.sm),
          ],
          if (message.image == null && message.hasImage) ...[
            Text(
              l10n.assistantPhotoNotStored,
              style: AppTypography.caption.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (message.text.isNotEmpty) const SizedBox(height: AppSpacing.sm),
          ],
          if (message.text.isNotEmpty)
            if (message.isUser)
              SelectableText(
                message.text,
                style: AppTypography.productTitle.copyWith(
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: colors.onSurface,
                ),
              )
            else
              AssistantMarkdown(text: message.text),
          if (sentAt != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              MaterialLocalizations.of(context).formatTimeOfDay(
                TimeOfDay.fromDateTime(sentAt),
                alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(
                  context,
                ),
              ),
              style: AppTypography.caption.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Align(
        alignment: message.isUser
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: message.isUser
            ? Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xl),
                child: content,
              )
            : content,
      ),
    );
  }
}
