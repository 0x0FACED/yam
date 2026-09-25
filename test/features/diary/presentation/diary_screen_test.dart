import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/theme/app_scroll_behavior.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/features/diary/presentation/diary_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('shows an empty current day and empty adjacent day', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      _DiaryTestApp(locale: const Locale('ru'), today: DateTime(2026, 9, 23)),
    );

    expect(find.text('Сегодня'), findsOneWidget);
    expect(find.text('Завтрак'), findsOneWidget);
    expect(find.text('Яйца куриные вареные'), findsNothing);
    expect(find.text('Пока ничего нет'), findsWidgets);
    expect(find.byKey(const ValueKey('diary-today-marker')), findsOneWidget);
    final summaryTop = tester.getTopLeft(find.text('Съедено')).dy;

    await tester.tap(find.byTooltip('Предыдущий день'));
    await tester.pump();

    expect(find.text('Яйца куриные вареные'), findsNothing);
    expect(find.text('Пока ничего нет'), findsWidgets);
    expect(find.byKey(const ValueKey('diary-today-marker')), findsOneWidget);
    expect(tester.getTopLeft(find.text('Съедено')).dy, summaryTop);

    await tester.tap(find.byTooltip('Вернуться к сегодняшнему дню'));
    await tester.pump();

    expect(find.text('Яйца куриные вареные'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Съедено')).dy, summaryTop);
  });

  testWidgets('today remains reachable outside the selected week', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      _DiaryTestApp(locale: const Locale('en'), today: DateTime(2026, 9, 23)),
    );

    for (var index = 0; index < 7; index++) {
      await tester.tap(find.byTooltip('Previous day'));
      await tester.pump();
    }

    expect(find.byKey(const ValueKey('diary-today-marker')), findsNothing);
    await tester.tap(find.byTooltip('Return to today'));
    await tester.pump();
    expect(find.byKey(const ValueKey('diary-today-marker')), findsOneWidget);
    expect(find.text('Boiled eggs'), findsNothing);
  });

  testWidgets('diary restores the native Android stretch overscroll', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      _DiaryTestApp(locale: const Locale('en'), today: DateTime(2026, 9, 23)),
    );

    expect(find.byType(StretchingOverscrollIndicator), findsOneWidget);
  });

  testWidgets('floating add does not cover the last meal at the bottom', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      _DiaryTestApp(locale: const Locale('en'), today: DateTime(2026, 9, 23)),
    );

    await tester.drag(
      find.byKey(const ValueKey('diary-scroll-view')),
      const Offset(0, -4000),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byKey(const ValueKey('snacks'))).bottom,
      lessThanOrEqualTo(
        tester.getRect(find.byKey(const ValueKey('diary-add-food'))).top,
      ),
    );
  });

  testWidgets('add food action opens a task screen above navigation', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _DiaryRouterTestApp(router: router, locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('diary-add-food')), findsOneWidget);
    await tester.tap(find.byTooltip('Добавить еду в раздел «Завтрак»'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(find.text('Приём: Завтрак'), findsOneWidget);
    expect(find.text('Недавние'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('floating add opens food search without a preselected meal', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter(diaryToday: DateTime(2026, 9, 23));
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _DiaryRouterTestApp(router: router, locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('diary-add-food')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(find.text('Выбрать приём пищи'), findsOneWidget);
    expect(find.text('Недавние'), findsOneWidget);
  });

  testWidgets('supports large text without overflow', (tester) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      const _DiaryTestApp(
        locale: Locale('en'),
        textScaler: TextScaler.linear(2),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Breakfast'),
      200,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('diary-scroll-view')),
        matching: find.byType(Scrollable),
      ),
    );

    expect(find.text('Breakfast'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the wide approved hierarchy in dark theme', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(1280, 900));
    await tester.pumpWidget(
      _DiaryTestApp(locale: const Locale('en'), theme: AppTheme.dark),
    );

    expect(find.text('YAM'), findsOneWidget);
    expect(find.text('Consumed'), findsOneWidget);
    expect(find.text('Buckwheat porridge'), findsNothing);
    expect(find.text('Water'), findsNothing);
    expect(find.byIcon(Icons.person), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _DiaryRouterTestApp extends StatelessWidget {
  const _DiaryRouterTestApp({required this.router, required this.locale});

  final GoRouter router;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      locale: locale,
      theme: AppTheme.light,
      scrollBehavior: const AppScrollBehavior(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class _DiaryTestApp extends StatelessWidget {
  const _DiaryTestApp({
    required this.locale,
    this.today,
    this.textScaler,
    this.theme,
  });

  final Locale locale;
  final DateTime? today;
  final TextScaler? textScaler;
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      theme: theme ?? AppTheme.light,
      scrollBehavior: const AppScrollBehavior(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final textScaler = this.textScaler;
        if (textScaler == null) {
          return child!;
        }
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        );
      },
      home: DiaryScreen(today: today),
    );
  }
}

Future<void> _setWindowSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
