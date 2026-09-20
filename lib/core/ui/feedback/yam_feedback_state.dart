import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';

class YamFeedbackState extends StatelessWidget {
  const YamFeedbackState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionKey,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.error = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Key? actionKey;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = error
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    final iconBackground = error
        ? theme.colorScheme.error.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainer;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(icon, size: 22, color: iconColor),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.productTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xs),
                YamTextButton(
                  key: actionKey,
                  label: actionLabel!,
                  icon: actionIcon,
                  onPressed: onAction,
                  tone: YamTextButtonTone.accent,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class YamProductRowSkeleton extends StatelessWidget {
  const YamProductRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.surfaceContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: 0.48,
                child: _SkeletonBar(height: 14, color: color),
              ),
              const SizedBox(height: AppSpacing.xs),
              FractionallySizedBox(
                widthFactor: 0.3,
                child: _SkeletonBar(
                  height: 10,
                  color: color.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              FractionallySizedBox(
                widthFactor: 0.64,
                child: _SkeletonBar(
                  height: 10,
                  color: color.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    );
  }
}
