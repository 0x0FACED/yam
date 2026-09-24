import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';

class YamTextField extends StatelessWidget {
  const YamTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.fieldKey,
    super.key,
  });

  final String label;
  final String? hintText;
  final String? errorText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: AppTypography.productTitle.copyWith(color: colors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
          ),
        ),
      ],
    );
  }
}
