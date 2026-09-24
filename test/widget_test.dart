import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/app.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_theme.dart';

void main() {
  testWidgets('intro uses the system dark theme on cold start', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const YamApp());

    final background = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byKey(const ValueKey('startup-screen')),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(background.color, AppTheme.dark.scaffoldBackgroundColor);
  });

  testWidgets('startup animation reveals app content', (tester) async {
    await tester.pumpWidget(const YamApp());

    expect(find.byKey(const ValueKey('startup-screen')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-content')), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(AppMotion.logoIntro);
    await tester.pump();

    expect(find.byKey(const ValueKey('startup-screen')), findsNothing);
    expect(find.byKey(const ValueKey('app-content')), findsOneWidget);
  });
}
