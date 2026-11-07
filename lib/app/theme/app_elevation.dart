import 'package:flutter/material.dart';

abstract final class AppElevation {
  static const floatingAction = 6.0;

  static Color floatingShadow(ColorScheme colors) =>
      colors.shadow.withValues(alpha: 0.28);
}
