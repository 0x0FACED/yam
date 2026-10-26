import 'dart:async';

import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/food/yam_quantity_control.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/diary/presentation/widgets/daily_nutrition_summary.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';
import 'package:yam/features/food_search/presentation/custom_food_adapter.dart';
import 'package:yam/features/food_search/presentation/diary_food_adapter.dart';
import 'package:yam/features/food_search/presentation/food_search_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';
import 'package:yam/l10n/generated/app_localizations_en.dart';

void main() {
  testWidgets('requires a meal before completing quick add', (tester) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter(appVersion: '1.2.3+4');
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
    final router = createAppRouter(appVersion: '1.2.3+4');
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
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final router = createAppRouter(
      appVersion: '1.2.3+4',
      diaryRepository: DiaryRepository(database),
    );
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
      405,
    );

    await tester.tap(find.byTooltip('Add food to Breakfast'));
    await tester.pumpAndSettle();
    expect(find.text('Whey protein'), findsOneWidget);
    expect(find.text('Rolled oats'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('favorites toggle from the sheet stays visible on search', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    final router = createAppRouter(appVersion: '1.2.3+4');
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
    final router = createAppRouter(appVersion: '1.2.3+4');
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
    final router = createAppRouter(appVersion: '1.2.3+4');
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

  testWidgets('keyboard insets do not consume the quick-add bottom spacing', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    tester.view.padding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewInsets);
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

    final submit = find.byKey(const ValueKey('quick-add-submit'));
    final quantity = find.byKey(const ValueKey('quick-add-quantity'));
    final restingBottom = tester.getBottomLeft(submit).dy;
    await tester.tap(quantity);
    await tester.pump();
    for (final inset in [8.0, 16.0, 24.0, 80.0, 160.0, 240.0, 300.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      tester.view.padding = FakeViewPadding(bottom: (24 - inset).clamp(0, 24));
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        tester.getBottomLeft(submit).dy,
        closeTo(restingBottom - inset, 0.01),
        reason: 'The sheet must follow the IME without losing safe-area space.',
      );
    }
    await tester.pumpAndSettle();
    final settledQuantityTop = tester.getTopLeft(quantity).dy;
    expect(tester.getBottomLeft(quantity).dy, lessThan(544));
    expect(tester.getBottomLeft(submit).dy, lessThan(544));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getTopLeft(quantity).dy, settledQuantityTop);

    for (final inset in [240.0, 160.0, 80.0, 24.0, 16.0, 8.0, 0.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      tester.view.padding = FakeViewPadding(bottom: (24 - inset).clamp(0, 24));
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        tester.getBottomLeft(submit).dy,
        closeTo(restingBottom - inset, 0.01),
      );
    }
    await tester.pumpAndSettle();
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
  testWidgets(
    'own-food menus edit from search and delete without changing diary history',
    (tester) async {
      await _setWindowSize(tester, const Size(390, 844));
      final database = YamDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = UserFoodRepository(database);
      final id = await repository.create(
        const CustomFoodDraft(
          name: 'Oat cup',
          category: 'grains',
          brand: 'Old brand',
          basis: CustomFoodBasis.grams,
          basisAmount: 75,
          displayBasis: CustomFoodDisplayBasis.perServing,
          proteinG: 9.875,
          fatG: 4.125,
          carbsG: 16.75,
          servings: [
            CustomServingDraft(
              unit: CustomServingUnit.serving,
              baseAmount: 75,
              defaultAmount: 1,
            ),
            CustomServingDraft(
              unit: CustomServingUnit.piece,
              baseAmount: 40,
              defaultAmount: 2,
            ),
          ],
        ),
      );
      await repository.setFavorite(id, true);
      final diary = DiaryRepository(database);
      final day = DateTime(2026, 9, 28);
      final original = (await repository.loadFoods()).single;
      final oldEntryId = await diary.create(
        DiaryEntryDraft(
          day: day,
          mealId: 'breakfast',
          food: diarySnapshotForFood(
            adaptUserFood(original, AppLocalizationsEn()),
          ),
          servingId: original.servings
              .singleWhere((serving) => serving.unit == 'serving')
              .id,
          amount: 1,
          canonicalQuantity: 75,
        ),
      );
      final router = createAppRouter(
        appVersion: '1.2.3+4',
        userFoodRepository: repository,
        diaryRepository: diary,
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(_RouterTestApp(router: router));
      await tester.pumpAndSettle();
      unawaited(
        router.push<void>(
          '/add-food',
          extra: FoodSearchPrototypeArguments(
            initialMealId: 'breakfast',
            diaryDay: day,
            recentFoodIds: [id],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final menu = find.byKey(ValueKey('food-actions-$id'));
      final row = find.byKey(ValueKey('food-result-$id'));
      expect(row, findsOneWidget);
      expect(menu, findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('food-search-tab-myDishes')));
      await tester.pumpAndSettle();
      expect(menu, findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('food-search-field')),
        'oat',
      );
      await tester.pump();
      await tester.tap(menu);
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      String fieldValue(String key) =>
          tester.widget<TextField>(find.byKey(ValueKey(key))).controller!.text;
      expect(fieldValue('create-food-name'), 'Oat cup');
      expect(fieldValue('create-food-brand'), 'Old brand');
      expect(fieldValue('create-serving-size'), '75.0');
      expect(fieldValue('create-food-protein'), '9.875');
      expect(fieldValue('create-serving-0-amount'), '40.0');

      for (final entry in {
        'create-food-name': 'Updated oats',
        'create-food-brand': 'New brand',
        'create-food-protein': '10.125',
        'create-food-fat': '5.375',
        'create-food-carbs': '22.625',
        'create-serving-0-amount': '43.875',
      }.entries) {
        final field = find.byKey(ValueKey(entry.key));
        await tester.ensureVisible(field);
        await tester.enterText(field, entry.value);
      }
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('food-result-$id')), findsOneWidget);
      expect(find.text('Updated oats'), findsOneWidget);
      expect(find.text('Updated Updated oats'), findsOneWidget);
      expect(menu, findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('food-search-field')))
            .controller!
            .text,
        'oat',
      );

      await tester.longPress(row);
      await tester.pumpAndSettle();
      expect(find.text('Delete food?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(row, findsOneWidget);

      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('quick-add-submit')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('quick-add-submit')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('food-search-tab-favorites')));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('food-result-$id')), findsOneWidget);
      expect(menu, findsOneWidget);
      expect(
        find.byKey(const ValueKey('food-actions-rolled-oats')),
        findsNothing,
      );
      await tester.enterText(
        find.byKey(const ValueKey('food-search-field')),
        'Updated',
      );
      await tester.pump();
      expect(find.byKey(ValueKey('food-result-$id')), findsOneWidget);
      expect(menu, findsOneWidget);

      final saved = await (database.select(
        database.userFoods,
      )..where((food) => food.id.equals(id))).getSingle();
      expect(saved.name, 'Updated oats');
      expect(saved.brand, 'New brand');
      expect(saved.isFavorite, isTrue);
      expect(saved.proteinG, 10.125);
      expect(saved.fatG, 5.375);
      expect(saved.carbsG, 22.625);
      final servings = await (database.select(
        database.userServings,
      )..where((serving) => serving.foodId.equals(id))).get();
      expect(
        servings.singleWhere((serving) => serving.unit == 'piece').baseAmount,
        43.875,
      );
      final diaryRows = await (database.select(
        database.diaryEntries,
      )..where((entry) => entry.foodId.equals(id))).get();
      expect(diaryRows, hasLength(2));
      final historical = diaryRows.singleWhere(
        (entry) => entry.id == oldEntryId,
      );
      final added = diaryRows.singleWhere((entry) => entry.id != oldEntryId);
      expect(historical.foodName, 'Oat cup');
      expect(historical.brand, 'Old brand');
      expect(historical.energyKcal, 143.625);
      expect(added.foodName, 'Updated oats');
      expect(added.brand, 'New brand');
      expect(added.energyKcal, 179.375);

      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(row, findsNothing);
      expect(await repository.loadFoods(), isEmpty);
      expect(
        await (database.select(
          database.diaryEntries,
        )..where((entry) => entry.foodId.equals(id))).get(),
        hasLength(2),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
  testWidgets('Russian edit saves and invalid edit URLs return to search', (
    tester,
  ) async {
    await _setWindowSize(tester, const Size(390, 844));
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserFoodRepository(database);
    final id = await repository.create(
      const CustomFoodDraft(
        name: 'Молоко',
        category: 'dairy',
        basis: CustomFoodBasis.milliliters,
        basisAmount: 100,
        displayBasis: CustomFoodDisplayBasis.perHundredMilliliters,
        proteinG: 3,
        fatG: 2,
        carbsG: 5,
        servings: [],
      ),
    );
    final saved = (await repository.loadFoods()).single;
    final router = createAppRouter(
      appVersion: '1.2.3+4',
      userFoodRepository: repository,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _RouterTestApp(router: router, locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();
    unawaited(router.push<void>('/add-food'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('food-search-tab-myDishes')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('food-actions-$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Изменить'));
    await tester.pumpAndSettle();
    expect(find.text('Изменить продукт'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('create-food-name')),
      'Новое молоко',
    );
    await tester.tap(find.text('Сохранить изменения'));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('food-result-$id')), findsOneWidget);
    expect(find.text('Продукт «Новое молоко» обновлён'), findsOneWidget);

    router.go('/add-food/edit');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(find.text('Изменить продукт'), findsNothing);
    router.go('/add-food/edit', extra: 'invalid');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));

    final noRepositoryRouter = createAppRouter(appVersion: '1.2.3+4');
    addTearDown(noRepositoryRouter.dispose);
    await tester.pumpWidget(
      _RouterTestApp(router: noRepositoryRouter, locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();
    noRepositoryRouter.go('/add-food/edit', extra: saved);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    expect(find.text('Изменить продукт'), findsNothing);
  });
}

class _RouterTestApp extends StatelessWidget {
  const _RouterTestApp({required this.router, this.locale});

  final GoRouter router;
  final Locale? locale;

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
