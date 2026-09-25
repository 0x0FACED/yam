import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';

enum YamTextButtonTone { neutral, accent, destructive }

class YamPrimaryButton extends StatelessWidget {
  const YamPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary,
        disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
        disabledBackgroundColor: theme.colorScheme.surfaceContainer,
        textStyle: AppTypography.productTitle.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          else if (icon != null)
            Icon(icon, size: 18),
          if (loading || icon != null) const SizedBox(width: AppSpacing.xs),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
          if (trailingIcon != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(trailingIcon, size: 18),
          ],
        ],
      ),
    );

    return SizedBox(width: expanded ? double.infinity : null, child: button);
  }
}

class YamSecondaryButton extends StatelessWidget {
  const YamSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: theme.colorScheme.onSurface,
        backgroundColor: theme.colorScheme.surfaceContainer,
        disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
        disabledBackgroundColor: theme.scaffoldBackgroundColor,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        textStyle: AppTypography.label,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );

    return SizedBox(width: expanded ? double.infinity : null, child: button);
  }
}

class YamTextButton extends StatelessWidget {
  const YamTextButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = YamTextButtonTone.neutral,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final YamTextButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = switch (tone) {
      YamTextButtonTone.neutral => theme.colorScheme.onSurfaceVariant,
      YamTextButtonTone.accent => theme.colorScheme.primary,
      YamTextButtonTone.destructive => theme.colorScheme.error,
    };

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        textStyle: AppTypography.label.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 6)],
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class YamIconButton extends StatelessWidget {
  const YamIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
    this.surface = true,
    this.iconSize = 18,
    this.visualSize,
    this.visualBorderRadius,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;
  final bool surface;
  final double iconSize;
  final double? visualSize;
  final double? visualBorderRadius;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = selected
        ? theme.colorScheme.primaryContainer
        : surface
        ? theme.colorScheme.surfaceContainer
        : Colors.transparent;
    final border = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.4)
        : surface
        ? theme.colorScheme.outlineVariant
        : Colors.transparent;

    final visualSize = this.visualSize;
    final icon = visualSize == null
        ? Icon(this.icon)
        : Container(
            width: visualSize,
            height: visualSize,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(
                visualBorderRadius ?? AppRadius.small,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              this.icon,
              size: iconSize,
              color: destructive
                  ? theme.colorScheme.error
                  : onPressed == null
                  ? theme.colorScheme.onSurfaceVariant
                  : selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          );

    return Semantics(
      selected: selected,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        iconSize: iconSize,
        style: IconButton.styleFrom(
          minimumSize: const Size.square(44),
          maximumSize: const Size.square(44),
          foregroundColor: destructive
              ? theme.colorScheme.error
              : selected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
          backgroundColor: visualSize == null ? background : Colors.transparent,
          disabledBackgroundColor: visualSize == null && surface
              ? theme.scaffoldBackgroundColor
              : Colors.transparent,
          side: visualSize == null
              ? BorderSide(color: border)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
        icon: icon,
      ),
    );
  }
}
