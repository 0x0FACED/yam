import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/app.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/data/yam_database.dart';

void main() {
  testWidgets('intro uses the system dark theme on cold start', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(YamApp(appVersion: '1.2.3+4', database: database));

    final background = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byKey(const ValueKey('startup-screen')),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(background.color, AppTheme.dark.scaffoldBackgroundColor);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('startup animation reveals app content', (tester) async {
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(YamApp(appVersion: '1.2.3+4', database: database));

    expect(find.byKey(const ValueKey('startup-screen')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-content')), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(AppMotion.logoIntro);
    await tester.pump();

    expect(find.byKey(const ValueKey('startup-screen')), findsNothing);
    expect(find.byKey(const ValueKey('app-content')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
