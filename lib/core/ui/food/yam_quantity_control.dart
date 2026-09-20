import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';

class YamQuantityControl extends StatelessWidget {
  const YamQuantityControl({
    required this.controller,
    required this.unitLabels,
    required this.selectedUnitIndex,
    required this.amountSemanticLabel,
    required this.unitTooltip,
    required this.decreaseTooltip,
    required this.increaseTooltip,
    required this.onAmountChanged,
    required this.onUnitSelected,
    required this.onDecrease,
    required this.onIncrease,
    this.amountFieldKey,
    this.unitKey,
    this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final List<String> unitLabels;
  final int selectedUnitIndex;
  final String amountSemanticLabel;
  final String unitTooltip;
  final String decreaseTooltip;
  final String increaseTooltip;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<int> onUnitSelected;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final Key? amountFieldKey;
  final Key? unitKey;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    assert(unitLabels.isNotEmpty);
    assert(selectedUnitIndex >= 0 && selectedUnitIndex < unitLabels.length);
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 19;
    final amountField = Semantics(
      textField: true,
      label: amountSemanticLabel,
      child: SizedBox(
        width: largeText ? 116 : 82,
        child: TextField(
          key: amountFieldKey,
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          style: AppTypography.prominentMetric.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
          decoration: const InputDecoration.collapsed(hintText: '0'),
          onChanged: onAmountChanged,
        ),
      ),
    );
    final unitSelector = PopupMenuButton<int>(
      key: unitKey,
      initialValue: selectedUnitIndex,
      tooltip: unitTooltip,
      position: PopupMenuPosition.under,
      onSelected: onUnitSelected,
      itemBuilder: (context) => [
        for (var index = 0; index < unitLabels.length; index++)
          PopupMenuItem<int>(value: index, child: Text(unitLabels[index])),
      ],
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: largeText ? 132 : 112),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      unitLabels[selectedUnitIndex],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final editor = largeText
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              amountField,
              const SizedBox(height: AppSpacing.xxs),
              unitSelector,
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              amountField,
              const SizedBox(width: AppSpacing.xs),
              unitSelector,
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border.all(
              color: errorText == null
                  ? theme.colorScheme.outlineVariant
                  : theme.colorScheme.error,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                _QuantityStepButton(
                  icon: Icons.remove_rounded,
                  tooltip: decreaseTooltip,
                  onPressed: onDecrease,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Center(child: editor)),
                const SizedBox(width: AppSpacing.xs),
                _QuantityStepButton(
                  icon: Icons.add_rounded,
                  tooltip: increaseTooltip,
                  onPressed: onIncrease,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                errorText!,
                style: AppTypography.caption.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class YamQuickAmountPresets extends StatelessWidget {
  const YamQuickAmountPresets({
    required this.title,
    required this.usualAmountLabel,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final String title;
  final String usualAmountLabel;
  final List<String> labels;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(12) > 17;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.label.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                usualAmountLabel,
                textAlign: TextAlign.end,
                style: AppTypography.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = AppSpacing.xs;
            final availableItemWidth =
                (constraints.maxWidth - spacing * (labels.length - 1)) /
                labels.length;
            final itemWidth = largeText
                ? 104.0
                : availableItemWidth.clamp(64.0, 88.0).toDouble();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < labels.length; index++) ...[
                    SizedBox(
                      width: itemWidth,
                      child: _AmountPresetButton(
                        label: labels[index],
                        selected: selectedIndex == index,
                        onPressed: () => onSelected(index),
                      ),
                    ),
                    if (index < labels.length - 1)
                      const SizedBox(width: spacing),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class YamNutritionSummary extends StatelessWidget {
  const YamNutritionSummary({
    required this.calorieValue,
    required this.calorieUnit,
    required this.proteinLabel,
    required this.proteinValue,
    required this.fatLabel,
    required this.fatValue,
    required this.carbsLabel,
    required this.carbsValue,
    super.key,
  });

  final String calorieValue;
  final String calorieUnit;
  final String proteinLabel;
  final String proteinValue;
  final String fatLabel;
  final String fatValue;
  final String carbsLabel;
  final String carbsValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = AppSemanticColors.of(context);
    final energy = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: calorieValue,
            style: AppTypography.sectionTitle.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontFeatures: AppTypography.tabularFigures,
            ),
          ),
          TextSpan(
            text: ' $calorieUnit',
            style: AppTypography.label.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
    final macros = Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        _NutritionMacro(
          label: proteinLabel,
          value: proteinValue,
          color: semanticColors.protein,
        ),
        _NutritionMacro(
          label: fatLabel,
          value: fatValue,
          color: semanticColors.fat,
        ),
        _NutritionMacro(
          label: carbsLabel,
          value: carbsValue,
          color: semanticColors.carbs,
        ),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stack =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(12) > 17;
            if (stack) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  energy,
                  const SizedBox(height: AppSpacing.xs),
                  macros,
                ],
              );
            }
            return Row(
              children: [
                energy,
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Align(alignment: Alignment.centerRight, child: macros),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuantityStepButton extends StatelessWidget {
  const _QuantityStepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        minimumSize: const Size.square(48),
        maximumSize: const Size.square(48),
        foregroundColor: theme.colorScheme.onSurface,
        backgroundColor: theme.colorScheme.surfaceContainer,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    );
  }
}

class _AmountPresetButton extends StatelessWidget {
  const _AmountPresetButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? theme.colorScheme.primary
            : theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          side: BorderSide(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selected) ...[
                    Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 2),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTypography.label.copyWith(
                        color: selected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NutritionMacro extends StatelessWidget {
  const _NutritionMacro({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          '$label $value',
          style: AppTypography.label.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
      ],
    );
  }
}
