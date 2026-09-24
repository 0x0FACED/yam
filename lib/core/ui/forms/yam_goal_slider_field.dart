import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/core/ui/forms/yam_number_field.dart';

/// A precise numeric field paired with a fast, stepped slider.
class YamGoalSliderField extends StatelessWidget {
  const YamGoalSliderField({
    required this.label,
    required this.unit,
    required this.controller,
    required this.value,
    required this.color,
    required this.baseMax,
    required this.onTextChanged,
    required this.onSliderChanged,
    this.errorText,
    this.fieldKey,
    this.sliderKey,
    this.step = 5,
    super.key,
  }) : assert(baseMax > 0),
       assert(step > 0);

  final String label;
  final String unit;
  final TextEditingController controller;
  final int? value;
  final Color color;
  final int baseMax;
  final int step;
  final String? errorText;
  final Key? fieldKey;
  final Key? sliderKey;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<int> onSliderChanged;

  @override
  Widget build(BuildContext context) {
    final current = value ?? 0;
    final limit = current > baseMax ? current + step * 10 : baseMax;
    final max = ((limit + step - 1) ~/ step) * step;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YamNumberField(
          fieldKey: fieldKey,
          label: label,
          unit: unit,
          controller: controller,
          onChanged: onTextChanged,
          style: YamNumberFieldStyle.prominent,
          indicatorColor: color,
          errorText: errorText,
          textInputAction: TextInputAction.done,
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.18),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.12),
            trackHeight: AppSpacing.xxs,
          ),
          child: Slider(
            key: sliderKey,
            min: 0,
            max: max.toDouble(),
            value: current.toDouble(),
            semanticFormatterCallback: (amount) => '${amount.round()} $unit',
            onChanged: (amount) =>
                onSliderChanged((amount / step).round() * step),
          ),
        ),
      ],
    );
  }
}
