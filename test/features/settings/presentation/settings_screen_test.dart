import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/app.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/features/settings/presentation/settings_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('changes the app theme for the current session', (tester) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(const YamApp());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(AppMotion.logoIntro);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(tester.getTopRight(find.text('Metric')).dx, closeTo(358, 0.1));

    await tester.tap(find.byKey(const ValueKey('settings-theme')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-theme-dark')));
    await tester.pumpAndSettle();

    final settingsContext = tester.element(find.byType(SettingsScreen));
    expect(Theme.of(settingsContext).brightness, Brightness.dark);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('supports large text and exposes only implemented actions', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      _SettingsTestApp(textScaler: const TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Goals & nutrition'), findsOneWidget);
    expect(find.text('Metric'), findsOneWidget);
    expect(find.text('Unavailable'), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byKey(const ValueKey('settings-about')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-about')));
    await tester.pumpAndSettle();

    expect(find.text('A fast, local-first nutrition tracker.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _SettingsTestApp extends StatelessWidget {
  const _SettingsTestApp({required this.textScaler});

  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: SettingsScreen(
        themeMode: ThemeMode.system,
        onThemeModeChanged: (_) {},
      ),
    );
  }
}

Future<void> _setWindowSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
