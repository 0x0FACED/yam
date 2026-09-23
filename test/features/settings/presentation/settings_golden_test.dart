import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('compact dark settings in Russian', (tester) async {
    await _pumpSettings(
      tester,
      size: const Size(390, 844),
      locale: const Locale('ru'),
      themeMode: ThemeMode.dark,
    );

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/settings_compact_dark_ru.png'),
    );
  });

  testWidgets('wide light settings in English', (tester) async {
    await _pumpSettings(
      tester,
      size: const Size(1280, 900),
      locale: const Locale('en'),
      themeMode: ThemeMode.light,
    );

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/settings_wide_light_en.png'),
    );
  });
}

Future<void> _pumpSettings(
  WidgetTester tester, {
  required Size size,
  required Locale locale,
  required ThemeMode themeMode,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final router = createAppRouter();
  addTearDown(router.dispose);
  await tester.pumpWidget(
    _GoldenApp(router: router, locale: locale, themeMode: themeMode),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
}

class _GoldenApp extends StatelessWidget {
  const _GoldenApp({
    required this.router,
    required this.locale,
    required this.themeMode,
  });

  final GoRouter router;
  final Locale locale;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      locale: locale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => RepaintBoundary(
        key: const ValueKey('golden-boundary'),
        child: child!,
      ),
    );
  }
}
