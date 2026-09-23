import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/theme/app_scroll_behavior.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/food_search_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('compact dark food search in Russian', (tester) async {
    await _pumpFoodSearch(
      tester,
      size: const Size(390, 844),
      locale: const Locale('ru'),
      themeMode: ThemeMode.dark,
    );

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/food_search_compact_dark_ru.png'),
    );
  });

  testWidgets('compact light food search in English', (tester) async {
    await _pumpFoodSearch(
      tester,
      size: const Size(390, 844),
      locale: const Locale('en'),
      themeMode: ThemeMode.light,
    );

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/food_search_compact_light_en.png'),
    );
  });

  testWidgets('wide dark food search in English', (tester) async {
    await _pumpFoodSearch(
      tester,
      size: const Size(1280, 900),
      locale: const Locale('en'),
      themeMode: ThemeMode.dark,
    );

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/food_search_wide_dark_en.png'),
    );
  });

  testWidgets('compact dark food search supports increased Russian text', (
    tester,
  ) async {
    await _pumpFoodSearch(
      tester,
      size: const Size(390, 844),
      locale: const Locale('ru'),
      themeMode: ThemeMode.dark,
      textScaler: const TextScaler.linear(2),
    );

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/food_search_compact_dark_ru_200.png'),
    );
  });

  testWidgets('compact light quick-add sheet in English', (tester) async {
    await _pumpFoodSearch(
      tester,
      size: const Size(390, 844),
      locale: const Locale('en'),
      themeMode: ThemeMode.light,
    );

    await tester.tap(find.byKey(const ValueKey('food-result-rolled-oats')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/food_quick_add_compact_light_en.png'),
    );
  });

  testWidgets('compact dark quick-add sheet in Russian', (tester) async {
    await _pumpFoodSearch(
      tester,
      size: const Size(390, 844),
      locale: const Locale('ru'),
      themeMode: ThemeMode.dark,
    );

    await tester.tap(find.byKey(const ValueKey('food-result-rolled-oats')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('golden-boundary')),
      matchesGoldenFile('goldens/food_quick_add_compact_dark_ru.png'),
    );
  });
}

Future<void> _pumpFoodSearch(
  WidgetTester tester, {
  required Size size,
  required Locale locale,
  required ThemeMode themeMode,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    _GoldenApp(locale: locale, themeMode: themeMode, textScaler: textScaler),
  );
  await tester.pumpAndSettle();
}

class _GoldenApp extends StatelessWidget {
  const _GoldenApp({
    required this.locale,
    required this.themeMode,
    required this.textScaler,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      scrollBehavior: const AppScrollBehavior(),
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
      home: const FoodSearchScreen(
        arguments: FoodSearchPrototypeArguments(initialMealId: 'breakfast'),
      ),
    );
  }
}
