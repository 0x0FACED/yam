import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/theme/app_scroll_behavior.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/food/yam_quantity_control.dart';
import 'package:yam/features/diary/presentation/widgets/daily_nutrition_summary.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/food_search_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('requires a meal before completing quick add', (tester) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_RouterTestApp(router: router));
    await tester.pumpAndSettle();

    unawaited(router.push<void>('/add-food'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(tester.testTextInput.hasAnyClients, isFalse);

    await tester.enterText(
      find.byKey(const ValueKey('food-search-field')),
      'oats',
    );
    await tester.pump();
    expect(find.text('Search results'), findsOneWidget);
    expect(find.text('Rolled oats'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('food-result-rolled-oats')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('quick-add-submit')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quick-add-submit')));
    await tester.pump();
    expect(find.text('Choose a meal first'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quick-add-meal')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Breakfast').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-add-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(find.text('Meal: Breakfast'), findsOneWidget);
    expect(find.byType(YamSnackBar), findsOneWidget);
  });

  testWidgets('meal entry point stays in search and supports Undo', (
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
    await tester.tap(find.byKey(const ValueKey('food-search-tab-favorites')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('food-result-rolled-oats')).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quick-add-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(find.byType(YamSnackBar), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back to diary'));
    await tester.pumpAndSettle();
    expect(find.text('Rolled oats'), findsNothing);
  });

  testWidgets('multiple foods can be added before returning to the diary', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_RouterTestApp(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add food to Breakfast'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('food-search-tab-favorites')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('food-result-rolled-oats')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-add-submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('food-result-whey-protein')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-add-submit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);

    await tester.tap(find.byTooltip('Back to diary'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DailyNutritionSummary>(find.byType(DailyNutritionSummary))
          .day
          .consumedCalories,
      2245,
    );

    await tester.tap(find.byTooltip('Add food to Breakfast'));
    await tester.pumpAndSettle();
    expect(find.text('Whey protein'), findsOneWidget);
    expect(find.text('Rolled oats'), findsOneWidget);
  });

  testWidgets('favorites toggle from the sheet stays visible on search', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_RouterTestApp(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add food to Breakfast'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('food-search-field')),
      'Milk',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('food-result-milk-25')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pump();
    expect(find.text('Milk 2.5% added to favorites'), findsOneWidget);
    await tester.tap(find.byTooltip('Close quick add'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('food-search-tab-favorites')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('food-result-milk-25')), findsOneWidget);
  });

  testWidgets('shows empty search and custom-food placeholder states', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_RouterTestApp(router: router));
    await tester.pumpAndSettle();

    unawaited(router.push<void>('/add-food'));
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
    await tester.pumpAndSettle();
    expect(
      find.text('Product creation will be implemented in a later slice.'),
      findsOneWidget,
    );
  });

  testWidgets('recent history is explicit and favorites show stars', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      const _ScreenTestApp(
        arguments: FoodSearchPrototypeArguments(
          initialMealId: 'breakfast',
          recentFoodIds: ['banana', 'rolled-oats'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent'), findsWidgets);
    expect(find.text('Fresh banana'), findsOneWidget);
    expect(find.text('Rolled oats'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.text('Grains'), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsNothing);
    await tester.tap(find.byKey(const ValueKey('food-search-tab-favorites')));
    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsWidgets);
    expect(find.text('Fresh banana'), findsNothing);
    expect(find.text('Rolled oats'), findsOneWidget);
  });

  testWidgets('recent and my dishes start empty without invented history', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(const _ScreenTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Nothing here yet'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('food-search-tab-myDishes')));
    await tester.pumpAndSettle();

    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('Cottage cheese 5%'), findsNothing);
  });

  testWidgets('renders catalog loading and error feedback states', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      const _ScreenTestApp(
        arguments: FoodSearchPrototypeArguments(
          initialCatalogState: FoodSearchPrototypeCatalogState.loading,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Loading foods'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      const _ScreenTestApp(
        arguments: FoodSearchPrototypeArguments(
          initialCatalogState: FoodSearchPrototypeCatalogState.error,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Foods could not be loaded'), findsOneWidget);
    expect(find.byKey(const ValueKey('food-search-retry')), findsOneWidget);
  });

  testWidgets('covers the navigation rail on a wide window', (tester) async {
    await _setWindowSize(tester, const Size(1280, 800));
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_RouterTestApp(router: router));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    await tester.tap(find.byTooltip('Add food to Breakfast'));
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
        arguments: FoodSearchPrototypeArguments(
          initialMealId: 'breakfast',
          recentFoodIds: ['rolled-oats'],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('food-result-rolled-oats')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('quick-add-submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick-add quantity controls update the nutrition preview', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      const _ScreenTestApp(
        arguments: FoodSearchPrototypeArguments(
          initialMealId: 'breakfast',
          recentFoodIds: ['rolled-oats'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('food-result-rolled-oats')));
    await tester.pumpAndSettle();

    expect(find.text('Quick select'), findsOneWidget);
    expect(find.text('Usually: 80 g'), findsOneWidget);
    expect(find.text('Add to Breakfast'), findsOneWidget);
    expect(
      tester
          .widget<YamNutritionSummary>(find.byType(YamNutritionSummary))
          .calorieValue,
      '293',
    );
    expect(
      tester.getTopRight(find.text('Usually: 80 g')).dx,
      closeTo(
        tester.getTopRight(find.byKey(const ValueKey('quick-add-submit'))).dx,
        0.1,
      ),
    );
    expect(tester.getSize(find.byTooltip('Decrease quantity')).height, 44);
    expect(tester.getSize(find.byTooltip('Close quick add')).height, 44);

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(find.text('81'), findsOneWidget);
    expect(
      tester
          .widget<YamNutritionSummary>(find.byType(YamNutritionSummary))
          .calorieValue,
      '296',
    );

    await tester.tap(find.text('50 g'));
    await tester.pump();
    expect(find.text('50'), findsOneWidget);
    expect(
      tester
          .widget<YamNutritionSummary>(find.byType(YamNutritionSummary))
          .calorieValue,
      '183',
    );

    await tester.tap(find.byKey(const ValueKey('quick-add-unit-grams')));
    await tester.pump();
    await tester.tap(find.text('serving'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('quick-add-unit-serving')),
      findsOneWidget,
    );
    expect(find.text('0.625'), findsOneWidget);
    expect(
      tester
          .widget<YamNutritionSummary>(find.byType(YamNutritionSummary))
          .calorieValue,
      '183',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('egg mass and pieces preserve nutrition through unit switches', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      const _ScreenTestApp(
        arguments: FoodSearchPrototypeArguments(
          initialMealId: 'breakfast',
          recentFoodIds: ['eggs'],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('food-result-eggs')));
    await tester.pumpAndSettle();

    final control = find.byType(YamQuantityControl);
    await tester.tap(find.descendant(of: control, matching: find.text('g')));
    await tester.pump();
    expect(find.text('110'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('quick-add-quantity')),
      '83',
    );
    await tester.pump();
    expect(
      tester
          .widget<YamNutritionSummary>(find.byType(YamNutritionSummary))
          .calorieValue,
      '118',
    );

    await tester.tap(find.descendant(of: control, matching: find.text('pcs')));
    await tester.pump();
    expect(find.text('1.509'), findsOneWidget);
    expect(
      tester
          .widget<YamNutritionSummary>(find.byType(YamNutritionSummary))
          .calorieValue,
      '118',
    );

    await tester.tap(find.descendant(of: control, matching: find.text('g')));
    await tester.pump();
    expect(find.text('83'), findsOneWidget);
    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(find.text('84'), findsOneWidget);
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
