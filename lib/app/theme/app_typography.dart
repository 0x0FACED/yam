import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const screenTitle = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static const sectionTitle = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  static const prominentMetric = TextStyle(
    fontSize: 28,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const productTitle = TextStyle(
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  static const body = TextStyle(fontSize: 13, height: 1.4);

  static const label = TextStyle(
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  static const caption = TextStyle(fontSize: 11, height: 1.3);

  static const tabularFigures = [FontFeature.tabularFigures()];

  static TextTheme build(TextTheme base) {
    return base.copyWith(
      headlineMedium: base.headlineMedium?.merge(prominentMetric),
      headlineSmall: base.headlineSmall?.merge(screenTitle),
      titleLarge: base.titleLarge?.merge(screenTitle),
      titleMedium: base.titleMedium?.merge(sectionTitle),
      bodyLarge: base.bodyLarge?.merge(productTitle),
      bodyMedium: base.bodyMedium?.merge(body),
      bodySmall: base.bodySmall?.merge(caption),
      labelLarge: base.labelLarge?.merge(label),
      labelMedium: base.labelMedium?.merge(label),
      labelSmall: base.labelSmall?.merge(caption),
    );
  }
}
