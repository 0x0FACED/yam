import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_radius.dart';

class YamProgressBar extends StatelessWidget {
  const YamProgressBar({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.semanticValue,
    this.height = 6,
    super.key,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final String semanticValue;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: semanticValue,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            minHeight: height,
            value: value.clamp(0.0, 1.0),
            color: color,
            backgroundColor: trackColor,
          ),
        ),
      ),
    );
  }
}
