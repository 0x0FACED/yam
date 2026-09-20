import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/theme/app_scroll_behavior.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/food_search_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('requires a meal and returns an in-memory diary entry', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_RouterTestApp(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('diary-add-food')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(tester.testTextInput.hasAnyClients, isTrue);

    await tester.enterText(
      find.byKey(const ValueKey('food-search-field')),
      'oats',
    );
    await tester.pump();
    expect(find.text('Search results'), findsOneWidget);
    expect(find.text('Rolled oats'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('food-result-rolled-oats')));
    await tester.pumpAndSettle();
    expect(find.text('Add to diary'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quick-add-submit')));
    await tester.pump();
    expect(find.text('Choose a meal first'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quick-add-meal')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Breakfast').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-add-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Rolled oats'), findsOneWidget);
    expect(find.textContaining('added to Breakfast'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Rolled oats'), findsNothing);
  });

  testWidgets('meal entry point supports one-tap last portion add', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_RouterTestApp(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add food to Breakfast'));
    await tester.pumpAndSettle();

    expect(find.text('Meal: Breakfast'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('food-quick-add-rolled-oats')).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Rolled oats'), findsOneWidget);
    expect(find.text('80 g'), findsOneWidget);
  });

  testWidgets('shows empty search and custom-food placeholder states', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(const _ScreenTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('food-search-field')),
      'not-a-food',
    );
    await tester.pump();
    expect(find.text('Nothing found'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('food-search-create-food')));
    await tester.pump();
    expect(
      find.text(
        'Custom food creation will be available in the functional version.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('covers the navigation rail on a wide window', (tester) async {
    await _setWindowSize(tester, const Size(1280, 800));
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_RouterTestApp(router: router));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('diary-add-food')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick-add sheet supports large text without overflow', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      const _ScreenTestApp(
        textScaler: TextScaler.linear(2),
        arguments: FoodSearchPrototypeArguments(initialMealId: 'breakfast'),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('food-result-rolled-oats')));
    await tester.pumpAndSettle();

    expect(find.text('Add to diary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _RouterTestApp extends StatelessWidget {
  const _RouterTestApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light,
      scrollBehavior: const AppScrollBehavior(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class _ScreenTestApp extends StatelessWidget {
  const _ScreenTestApp({
    this.textScaler,
    this.arguments = const FoodSearchPrototypeArguments(),
  });

  final TextScaler? textScaler;
  final FoodSearchPrototypeArguments arguments;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      scrollBehavior: const AppScrollBehavior(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        if (textScaler case final scaler?) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: scaler),
            child: child!,
          );
        }
        return child!;
      },
      home: FoodSearchScreen(arguments: arguments),
    );
  }
}

Future<void> _setWindowSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
