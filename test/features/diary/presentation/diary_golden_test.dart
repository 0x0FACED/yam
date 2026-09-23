import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  final today = DateTime(2026, 9, 19);

  testWidgets('compact light diary in Russian', (tester) async {
    await _pumpDiary(
      tester,
      size: const Size(390, 844),
      locale: const Locale('ru'),
      themeMode: ThemeMode.light,
      today: today,
    );

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/diary_compact_light_ru.png'),
    );
  });

  testWidgets('compact dark diary in English', (tester) async {
    await _pumpDiary(
      tester,
      size: const Size(390, 844),
      locale: const Locale('en'),
      themeMode: ThemeMode.dark,
      today: today,
    );

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/diary_compact_dark_en.png'),
    );
  });

  testWidgets('compact dark diary shows today while browsing yesterday', (
    tester,
  ) async {
    await _pumpDiary(
      tester,
      size: const Size(390, 844),
      locale: const Locale('ru'),
      themeMode: ThemeMode.dark,
      today: today,
    );
    await tester.tap(find.byTooltip('Предыдущий день'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/diary_compact_dark_ru_previous_day.png'),
    );
  });

  testWidgets('wide light diary in English', (tester) async {
    await _pumpDiary(
      tester,
      size: const Size(1280, 900),
      locale: const Locale('en'),
      themeMode: ThemeMode.light,
      today: today,
    );

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/diary_wide_light_en.png'),
    );
  });

  testWidgets('compact dark diary supports increased Russian text', (
    tester,
  ) async {
    await _pumpDiary(
      tester,
      size: const Size(390, 844),
      locale: const Locale('ru'),
      themeMode: ThemeMode.dark,
      textScaler: const TextScaler.linear(2),
      today: today,
    );

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/diary_compact_dark_ru_200.png'),
    );
  });
}

Future<void> _pumpDiary(
  WidgetTester tester, {
  required Size size,
  required Locale locale,
  required ThemeMode themeMode,
  required DateTime today,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final router = createAppRouter(diaryToday: today);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    _GoldenApp(
      router: router,
      locale: locale,
      themeMode: themeMode,
      textScaler: textScaler,
    ),
  );
  await tester.pumpAndSettle();
}

class _GoldenApp extends StatelessWidget {
  const _GoldenApp({
    required this.router,
    required this.locale,
    required this.themeMode,
    required this.textScaler,
  });

  final GoRouter router;
  final Locale locale;
  final ThemeMode themeMode;
  final TextScaler textScaler;

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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: RepaintBoundary(
            key: const ValueKey('golden-boundary'),
            child: child!,
          ),
        );
      },
    );
  }
}
