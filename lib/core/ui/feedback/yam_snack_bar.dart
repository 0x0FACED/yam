import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';

class YamSnackBar extends StatelessWidget {
  const YamSnackBar({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = AppSemanticColors.of(context);
    final stack = MediaQuery.textScalerOf(context).scale(12) > 17;
    final messageWidget = Row(
      children: [
        Container(
          key: const ValueKey('yam-snack-bar-success-indicator'),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: semanticColors.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            message,
            style: AppTypography.label.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
    final action = YamTextButton(
      label: actionLabel,
      onPressed: onAction,
      tone: YamTextButtonTone.accent,
    );

    return Semantics(
      liveRegion: true,
      container: true,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(AppRadius.control),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.42 : 0.16,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.xxs,
                AppSpacing.xxs,
                AppSpacing.xxs,
              ),
              child: stack
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xxs,
                            AppSpacing.xs,
                            AppSpacing.sm,
                            0,
                          ),
                          child: messageWidget,
                        ),
                        Align(alignment: Alignment.centerRight, child: action),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: messageWidget),
                        const SizedBox(width: AppSpacing.xs),
                        action,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

void showYamUndoSnackBar({
  required BuildContext context,
  required String message,
  required String undoLabel,
  required VoidCallback onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  void handleUndo() {
    messenger.hideCurrentSnackBar();
    onUndo();
  }

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        duration: const Duration(seconds: 4),
        dismissDirection: DismissDirection.down,
        content: YamSnackBar(
          message: message,
          actionLabel: undoLabel,
          onAction: handleUndo,
        ),
      ),
    );
}
