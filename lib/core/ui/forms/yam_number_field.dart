import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';

enum YamNumberFieldStyle { card, prominent, compact }

class YamNumberField extends StatefulWidget {
  const YamNumberField({
    required this.label,
    required this.unit,
    required this.controller,
    required this.onChanged,
    this.style = YamNumberFieldStyle.card,
    this.decimal = false,
    this.indicatorColor,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.fieldKey,
    super.key,
  });

  final String label;
  final String unit;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final YamNumberFieldStyle style;
  final bool decimal;
  final Color? indicatorColor;
  final String? errorText;
  final TextInputAction textInputAction;
  final Key? fieldKey;

  @override
  State<YamNumberField> createState() => _YamNumberFieldState();
}

class _YamNumberFieldState extends State<YamNumberField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final compact = widget.style == YamNumberFieldStyle.compact;
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.indicatorColor case final color?) ...[
          Container(
            width: AppSpacing.xs,
            height: AppSpacing.xs,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xxs),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (compact ? AppTypography.caption : AppTypography.label)
                .copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
    final editor = Row(
      children: [
        Expanded(
          child: Semantics(
            label: '${widget.label}, ${widget.unit}',
            child: TextField(
              key: widget.fieldKey,
              focusNode: _focusNode,
              controller: widget.controller,
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.decimal,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  widget.decimal ? RegExp(r'[0-9,.]') : RegExp(r'[0-9]'),
                ),
              ],
              textInputAction: widget.textInputAction,
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style:
                  (compact
                          ? AppTypography.screenTitle
                          : AppTypography.prominentMetric)
                      .copyWith(color: colors.onSurface),
              decoration: const InputDecoration.collapsed(hintText: '0'),
              onChanged: widget.onChanged,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          widget.unit,
          style: (compact ? AppTypography.label : AppTypography.productTitle)
              .copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
    final input = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focusNode.requestFocus,
      child: Container(
        constraints: BoxConstraints(
          minHeight: compact ? AppSpacing.xxl : AppSpacing.xxl + AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          border: Border.all(
            color: widget.errorText != null
                ? colors.error
                : _focusNode.hasFocus
                ? colors.primary
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.xs : AppSpacing.md,
          vertical: compact ? AppSpacing.xs : AppSpacing.sm,
        ),
        child: widget.style == YamNumberFieldStyle.card
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label,
                  const SizedBox(height: AppSpacing.xs),
                  editor,
                ],
              )
            : editor,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.style != YamNumberFieldStyle.card) ...[
          label,
          const SizedBox(height: AppSpacing.xs),
        ],
        input,
        if (widget.errorText case final error?) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            error,
            style: AppTypography.caption.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }
}
