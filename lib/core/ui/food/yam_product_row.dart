import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';

class YamProductRow extends StatelessWidget {
  const YamProductRow({
    required this.name,
    required this.metadataLabel,
    required this.calorieLabel,
    required this.proteinLabel,
    required this.proteinValue,
    required this.fatLabel,
    required this.fatValue,
    required this.carbsLabel,
    required this.carbsValue,
    required this.onPressed,
    this.favorite = false,
    this.favoriteLabel,
    this.openKey,
    this.showDivider = true,
    super.key,
  });

  final String name;
  final String metadataLabel;
  final String calorieLabel;
  final String proteinLabel;
  final String proteinValue;
  final String fatLabel;
  final String fatValue;
  final String carbsLabel;
  final String carbsValue;
  final bool favorite;
  final String? favoriteLabel;
  final VoidCallback onPressed;
  final Key? openKey;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = AppSemanticColors.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 19;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: openKey,
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 72),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (favorite) ...[
                          Semantics(
                            label: favoriteLabel,
                            child: ExcludeSemantics(
                              child: Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Expanded(
                          child: Text(
                            name,
                            maxLines: largeText ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.productTitle.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      metadataLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
        if (showDivider) const Divider(height: 1),
      ],
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
