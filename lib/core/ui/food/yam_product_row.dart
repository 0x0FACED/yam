import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';

class YamProductRow extends StatelessWidget {
  const YamProductRow({
    required this.name,
    required this.sourceLabel,
    required this.calorieLabel,
    required this.proteinLabel,
    required this.proteinValue,
    required this.fatLabel,
    required this.fatValue,
    required this.carbsLabel,
    required this.carbsValue,
    required this.quickAddLabel,
    required this.quickAddSemanticLabel,
    required this.onPressed,
    required this.onQuickAdd,
    this.portionDescription,
    this.verified = false,
    this.verifiedTooltip,
    this.openKey,
    this.quickAddKey,
    this.showDivider = true,
    super.key,
  });

  final String name;
  final String sourceLabel;
  final String? portionDescription;
  final String calorieLabel;
  final String proteinLabel;
  final String proteinValue;
  final String fatLabel;
  final String fatValue;
  final String carbsLabel;
  final String carbsValue;
  final String quickAddLabel;
  final String quickAddSemanticLabel;
  final bool verified;
  final String? verifiedTooltip;
  final VoidCallback onPressed;
  final VoidCallback onQuickAdd;
  final Key? openKey;
  final Key? quickAddKey;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = AppSemanticColors.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackAction =
            constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(14) > 19;
        final quickAddButton = YamQuickAddButton(
          buttonKey: quickAddKey,
          label: quickAddLabel,
          semanticLabel: quickAddSemanticLabel,
          onPressed: onQuickAdd,
        );

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    child: InkWell(
                      key: openKey,
                      onTap: onPressed,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.sm,
                          AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.productTitle.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (verified) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Tooltip(
                                    message: verifiedTooltip ?? '',
                                    child: Icon(
                                      Icons.verified_rounded,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: sourceLabel),
                                  if (portionDescription != null) ...[
                                    TextSpan(
                                      text: '  •  ',
                                      style: TextStyle(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                    TextSpan(text: portionDescription),
                                  ],
                                ],
                                style: AppTypography.caption.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xxs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  calorieLabel,
                                  style: AppTypography.caption.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: AppTypography.tabularFigures,
                                  ),
                                ),
                                Text(
                                  '•',
                                  style: AppTypography.caption.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                _MacroValue(
                                  label: proteinLabel,
                                  value: proteinValue,
                                  color: semanticColors.protein,
                                ),
                                _MacroValue(
                                  label: fatLabel,
                                  value: fatValue,
                                  color: semanticColors.fat,
                                ),
                                _MacroValue(
                                  label: carbsLabel,
                                  value: carbsValue,
                                  color: semanticColors.carbs,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (!stackAction)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: quickAddButton,
                  ),
              ],
            ),
            if (stackAction)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: quickAddButton,
                ),
              ),
            if (showDivider) const Divider(height: 1),
          ],
        );
      },
    );
  }
}

class YamQuickAddButton extends StatelessWidget {
  const YamQuickAddButton({
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    this.buttonKey,
    super.key,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: TextButton(
        key: buttonKey,
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          minimumSize: const Size(0, 44),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: AppTypography.label.copyWith(fontWeight: FontWeight.w700),
        ),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroValue extends StatelessWidget {
  const _MacroValue({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: value,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontFeatures: AppTypography.tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}
