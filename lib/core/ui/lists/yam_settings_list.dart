import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';

enum YamSettingsRowTone { normal, destructive }

class YamSettingsSection extends StatelessWidget {
  const YamSettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxs,
            0,
            AppSpacing.xxs,
            AppSpacing.xs,
          ),
          child: Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              style: AppTypography.caption.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        Material(
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1)
                  Divider(
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                    color: theme.colorScheme.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class YamSettingsRow extends StatelessWidget {
  const YamSettingsRow({
    required this.title,
    this.subtitle,
    this.value,
    this.onPressed,
    this.showChevron = false,
    this.tone = YamSettingsRowTone.normal,
    this.minHeight = 52,
    this.mutedValue = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onPressed;
  final bool showChevron;
  final YamSettingsRowTone tone;
  final double minHeight;
  final bool mutedValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(13) > 18;
    final foreground = tone == YamSettingsRowTone.destructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTypography.productTitle.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: AppTypography.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFeatures: AppTypography.tabularFigures,
            ),
          ),
        ],
      ],
    );
    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value != null)
          Flexible(
            child: Text(
              value!,
              textAlign: TextAlign.end,
              style: (mutedValue ? AppTypography.caption : AppTypography.body)
                  .copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: mutedValue ? FontWeight.w500 : null,
                  ),
            ),
          ),
        if (value != null && showChevron) const SizedBox(width: AppSpacing.xxs),
        if (showChevron)
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: tone == YamSettingsRowTone.destructive
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
      ],
    );
    final content = largeText
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              details,
              if (value != null || showChevron) ...[
                const SizedBox(height: AppSpacing.xs),
                Align(alignment: Alignment.centerRight, child: trailing),
              ],
            ],
          )
        : Row(
            children: [
              Expanded(child: details),
              if (value != null || showChevron) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
                ),
              ],
            ],
          );
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: subtitle == null ? AppSpacing.xs : 10,
        ),
        child: content,
      ),
    );

    return Semantics(
      button: onPressed != null,
      enabled: onPressed == null ? null : true,
      child: onPressed == null ? row : InkWell(onTap: onPressed, child: row),
    );
  }
}
