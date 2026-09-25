import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';

class YamDropdownOption<T> {
  const YamDropdownOption({
    required this.value,
    required this.label,
    this.icon,
    this.key,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Key? key;
}

typedef YamDropdownTriggerBuilder =
    Widget Function(
      BuildContext context,
      VoidCallback toggle,
      FocusNode focusNode,
      bool isOpen,
    );

class YamDropdown<T> extends StatefulWidget {
  const YamDropdown({
    required this.value,
    required this.options,
    required this.onSelected,
    required this.triggerBuilder,
    super.key,
  });

  final T? value;
  final List<YamDropdownOption<T>> options;
  final ValueChanged<T> onSelected;
  final YamDropdownTriggerBuilder triggerBuilder;

  @override
  State<YamDropdown<T>> createState() => _YamDropdownState<T>();
}

class _YamDropdownState<T> extends State<YamDropdown<T>> {
  static const _maxWidth = 280.0;
  static const _itemHeight = 44.0;
  static const _maxHeight = _itemHeight * 7 + AppSpacing.xs;

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_focusChanged)
      ..dispose();
    super.dispose();
  }

  void _focusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? math.min(constraints.maxWidth, _maxWidth)
            : _maxWidth;
        return MenuAnchor(
          childFocusNode: _focusNode,
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(colors.surfaceContainer),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            elevation: const WidgetStatePropertyAll(0),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
            ),
            side: WidgetStatePropertyAll(
              BorderSide(color: colors.outlineVariant),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.all(AppSpacing.xxs),
            ),
            minimumSize: WidgetStatePropertyAll(Size(width, 0)),
            maximumSize: WidgetStatePropertyAll(Size(width, _maxHeight)),
          ),
          menuChildren: [
            for (final option in widget.options)
              _menuItem(option, width, colors),
          ],
          builder: (context, controller, _) => widget.triggerBuilder(
            context,
            () {
              if (controller.isOpen) {
                controller.close();
              } else {
                _focusNode.requestFocus();
                controller.open();
              }
            },
            _focusNode,
            controller.isOpen,
          ),
        );
      },
    );
  }

  Widget _menuItem(
    YamDropdownOption<T> option,
    double width,
    ColorScheme colors,
  ) {
    final selected = option.value == widget.value;
    final color = selected ? colors.primary : colors.onSurface;
    return Semantics(
      selected: selected,
      child: MenuItemButton(
        key: option.key,
        onPressed: () => widget.onSelected(option.value),
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, _itemHeight)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                selected ||
                    states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.focused)
                ? colors.primaryContainer
                : Colors.transparent,
          ),
          foregroundColor: WidgetStatePropertyAll(color),
          textStyle: const WidgetStatePropertyAll(AppTypography.label),
        ),
        child: SizedBox(
          width: math.max(0, width - AppSpacing.xs - AppSpacing.sm * 2),
          child: Row(
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 18, color: color),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  option.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.check_rounded, size: 18, color: colors.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
