import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/features/diary/presentation/diary_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('shows the populated current day and empty adjacent day', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(const _DiaryTestApp(locale: Locale('ru')));

    expect(find.text('Сегодня'), findsOneWidget);
    expect(find.text('Завтрак'), findsOneWidget);
    expect(find.text('Яйца куриные вареные'), findsOneWidget);

    await tester.tap(find.byTooltip('Следующий день'));
    await tester.pump();

    expect(find.text('Яйца куриные вареные'), findsNothing);
    expect(find.text('Пока ничего нет'), findsWidgets);

    await tester.tap(find.text('Вернуться к сегодняшнему дню'));
    await tester.pump();

    expect(find.text('Яйца куриные вареные'), findsOneWidget);
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

    expect(find.byKey(const ValueKey('diary-add-food')), findsNothing);
    await tester.tap(find.byTooltip('Добавить еду в раздел «Завтрак»'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(find.text('Часто на завтрак'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
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
    expect(find.text('Buckwheat porridge'), findsOneWidget);
    expect(find.text('Water'), findsNothing);
    expect(find.byIcon(Icons.person), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('diary rows expose a visible pressed selection state', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(const _DiaryTestApp(locale: Locale('en')));

    final entry = find.text('Boiled eggs');
    await tester.scrollUntilVisible(
      entry,
      200,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('diary-scroll-view')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(entry);
    await tester.pump();

    final highlighted = tester.widget<AnimatedContainer>(
      find.ancestor(of: entry, matching: find.byType(AnimatedContainer)).first,
    );
    final decoration = highlighted.decoration! as BoxDecoration;
    expect(decoration.color, AppTheme.light.colorScheme.primaryContainer);
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class _DiaryTestApp extends StatelessWidget {
  const _DiaryTestApp({required this.locale, this.textScaler, this.theme});

  final Locale locale;
  final TextScaler? textScaler;
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      theme: theme ?? AppTheme.light,
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
      home: const DiaryScreen(),
    );
  }
}

Future<void> _setWindowSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
