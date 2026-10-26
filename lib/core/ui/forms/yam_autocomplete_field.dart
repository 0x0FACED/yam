import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/forms/yam_text_field.dart';

class YamAutocompleteField<T extends Object> extends StatelessWidget {
  const YamAutocompleteField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.optionsBuilder,
    required this.displayStringForOption,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.onSelected,
    this.fieldKey,
    super.key,
  });

  final String label;
  final String? hintText;
  final String? errorText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final AutocompleteOptionsBuilder<T> optionsBuilder;
  final AutocompleteOptionToString<T> displayStringForOption;
  final ValueChanged<String>? onChanged;
  final AutocompleteOnSelected<T>? onSelected;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<T>(
        textEditingController: controller,
        focusNode: focusNode,
        displayStringForOption: displayStringForOption,
        optionsBuilder: optionsBuilder,
        onSelected: onSelected,
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
            YamTextField(
              fieldKey: fieldKey,
              label: label,
              hintText: hintText,
              errorText: errorText,
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted(),
            ),
        optionsViewBuilder: (context, onSelected, options) {
          final candidates = options.toList();
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth,
                  maxHeight: AppSpacing.xxl * 5,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = candidates[index];
                    final highlighted =
                        AutocompleteHighlightedOption.of(context) == index;
                    return Material(
                      color: highlighted
                          ? colors.primaryContainer
                          : Colors.transparent,
                      child: InkWell(
                        onTap: () => onSelected(candidate),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: AppSpacing.xxl,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Text(
                              displayStringForOption(candidate),
                              style: AppTypography.productTitle.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
