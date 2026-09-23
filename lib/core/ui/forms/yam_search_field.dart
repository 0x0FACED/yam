import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_typography.dart';

class YamSearchField extends StatelessWidget {
  const YamSearchField({
    required this.controller,
    required this.hintText,
    required this.clearTooltip,
    this.focusNode,
    required this.onChanged,
    required this.onClear,
    this.fieldKey,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final String clearTooltip;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([controller, focusNode]),
      builder: (context, child) {
        final focused = focusNode?.hasFocus ?? false;
        final iconColor = focused
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant;

        return SizedBox(
          height: 44,
          child: TextField(
            key: fieldKey,
            controller: controller,
            focusNode: focusNode,
            textInputAction: TextInputAction.search,
            style: AppTypography.body.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTypography.body.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 19,
                color: iconColor,
              ),
              prefixIconConstraints: const BoxConstraints.tightFor(
                width: 40,
                height: 44,
              ),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: clearTooltip,
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
              suffixIconConstraints: const BoxConstraints.tightFor(
                width: 44,
                height: 44,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainer,
              contentPadding: const EdgeInsets.only(right: 12),
              border: _border(Colors.transparent),
              enabledBorder: _border(Colors.transparent),
              focusedBorder: _border(theme.colorScheme.primary),
            ),
            onChanged: onChanged,
          ),
        );
      },
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      borderSide: BorderSide(color: color),
    );
  }
}
