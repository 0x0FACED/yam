import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';

class YamMealSectionHeader extends StatelessWidget {
  const YamMealSectionHeader({
    required this.mealName,
    required this.timeLabel,
    required this.calorieLabel,
    required this.addTooltip,
    required this.onAdd,
    super.key,
  });

  final String mealName;
  final String timeLabel;
  final String calorieLabel;
  final String addTooltip;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            mealName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sectionTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              timeLabel,
              style: AppTypography.caption.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ),
        ),
      ],
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          calorieLabel,
          style: AppTypography.productTitle.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        YamIconButton(
          icon: Icons.add_rounded,
          tooltip: addTooltip,
          onPressed: onAdd,
        ),
      ],
    );

    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: AppSpacing.xxs),
          Align(alignment: Alignment.centerRight, child: actions),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        const SizedBox(width: AppSpacing.xs),
        actions,
      ],
    );
  }
}

class YamDiaryFoodRow extends StatelessWidget {
  const YamDiaryFoodRow({
    required this.name,
    required this.details,
    required this.calorieLabel,
    this.macroLabel,
    required this.highlighted,
    required this.onPressed,
    super.key,
  });

  final String name;
  final String details;
  final String calorieLabel;
  final String? macroLabel;
  final bool highlighted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.smallChange;
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: largeText ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.productTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          details,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    final nutrition = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          calorieLabel,
          maxLines: 1,
          style: AppTypography.label.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
        if (macroLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            macroLabel!,
            maxLines: 1,
            style: AppTypography.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFeatures: AppTypography.tabularFigures,
            ),
          ),
        ],
      ],
    );

    return AnimatedContainer(
      duration: duration,
      curve: AppMotion.standardCurve,
      decoration: BoxDecoration(
        color: highlighted
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: largeText
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        identity,
                        const SizedBox(height: AppSpacing.xxs),
                        Align(
                          alignment: Alignment.centerRight,
                          child: nutrition,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: identity),
                        const SizedBox(width: AppSpacing.md),
                        nutrition,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
