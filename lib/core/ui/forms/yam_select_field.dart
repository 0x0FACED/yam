import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/selection/yam_dropdown.dart';

class YamSelectField<T> extends StatelessWidget {
  const YamSelectField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.fieldKey,
    super.key,
  });

  final String label;
  final T value;
  final List<YamDropdownOption<T>> items;
  final ValueChanged<T> onChanged;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedLabel = items.firstWhere((item) => item.value == value).label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        YamDropdown<T>(
          value: value,
          options: items,
          onSelected: onChanged,
          triggerBuilder: (context, toggle, focusNode, isOpen) => Semantics(
            button: true,
            label: label,
            value: selectedLabel,
            onTap: toggle,
            child: ExcludeSemantics(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.control),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: fieldKey,
                  focusNode: focusNode,
                  onTap: toggle,
                  child: InputDecorator(
                    isFocused: focusNode.hasFocus || isOpen,
                    isEmpty: false,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.control),
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.productTitle.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            isOpen
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
