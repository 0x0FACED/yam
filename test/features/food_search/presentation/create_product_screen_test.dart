import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';
import 'package:yam/features/food_search/presentation/custom_food_adapter.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/user_food_form_screen.dart';
import 'package:yam/features/food_search/presentation/widgets/food_quick_add_sheet.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('brand suggestions support taps, keyboard and free text', (
    tester,
  ) async {
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserFoodRepository(database);
    for (final brand in ['Nordic', 'Nora']) {
      await repository.create(
        CustomFoodDraft(
          name: brand,
          brand: brand,
          category: 'other',
          basis: CustomFoodBasis.grams,
          basisAmount: 100,
          displayBasis: CustomFoodDisplayBasis.perHundredGrams,
          proteinG: 1,
          fatG: 1,
          carbsG: 1,
          servings: const [],
        ),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: UserFoodFormScreen(repository: repository),
      ),
    );

    final brandField = find.byKey(const ValueKey('create-food-brand'));
    await tester.enterText(brandField, 'No');
    await tester.pumpAndSettle();
    expect(find.text('Nordic'), findsOneWidget);
    expect(find.text('Nora'), findsOneWidget);

    await tester.tap(find.text('Nora'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(brandField).controller!.text, 'Nora');

    await tester.enterText(brandField, 'No');
    await tester.pumpAndSettle();
    await tester.tap(brandField);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(brandField).controller!.text, 'Nordic');

    await tester.enterText(brandField, '  New Brand  ');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(brandField).controller!.text,
      '  New Brand  ',
    );
  });
  testWidgets('edit form pre-fills saved product and serving values', (
    tester,
  ) async {
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserFoodRepository(database);
    final id = await repository
        .create(
          const CustomFoodDraft(
            name: 'Oat cup',
            category: 'dairy',
            brand: 'Local brand',
            barcode: '000987654',
            description: 'Mix the oats.\nChill overnight.',
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
                defaultAmount: 0.5,
              ),
              CustomServingDraft(
                unit: CustomServingUnit.piece,
                label: 'bar',
                baseAmount: 40,
                defaultAmount: 2.5,
              ),
            ],
          ),
        )
        .timeout(const Duration(seconds: 10));
    final initialFood = SavedUserFood(
      await (database.select(
        database.userFoods,
      )..where((food) => food.id.equals(id))).getSingle(),
      await (database.select(
        database.userServings,
      )..where((serving) => serving.foodId.equals(id))).get(),
    );

    await tester
        .pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: UserFoodFormScreen(
              repository: repository,
              initialFood: initialFood,
            ),
          ),
        )
        .timeout(const Duration(seconds: 10));
    await tester.pump().timeout(const Duration(seconds: 10));

    String fieldValue(String key) =>
        tester.widget<TextField>(find.byKey(ValueKey(key))).controller!.text;

    expect(initialFood.food.id, id);
    expect(fieldValue('create-food-name'), 'Oat cup');
    expect(fieldValue('create-food-brand'), 'Local brand');
    expect(fieldValue('create-food-barcode'), '000987654');
    expect(
      fieldValue('create-food-description'),
      'Mix the oats.\nChill overnight.',
    );
    expect(fieldValue('create-serving-size'), '75.0');
    expect(fieldValue('create-food-protein'), '9.875');
    expect(fieldValue('create-food-fat'), '4.125');
    expect(fieldValue('create-food-carbs'), '16.75');
    expect(fieldValue('create-serving-0-amount'), '40.0');

    final l10n = AppLocalizations.of(
      tester.element(find.byKey(const ValueKey('create-food-name'))),
    );
    expect(find.text(l10n.foodCategoryDairy), findsOneWidget);
    expect(find.text(l10n.createProductEditTitle), findsOneWidget);
    expect(find.text(l10n.createProductUpdate), findsOneWidget);
  });

  testWidgets('editing a name preserves a stored custom category', (
    tester,
  ) async {
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserFoodRepository(database);
    final id = await repository.create(
      const CustomFoodDraft(
        name: 'Local meal',
        category: '  Custom pantry 🥣  ',
        basis: CustomFoodBasis.grams,
        basisAmount: 100,
        displayBasis: CustomFoodDisplayBasis.perHundredGrams,
        proteinG: 10,
        fatG: 5,
        carbsG: 20,
        servings: [],
      ),
    );
    final initialFood = (await repository.loadFoods()).single;
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SizedBox.shrink(),
      ),
    );
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (context) => UserFoodFormScreen(
          repository: repository,
          initialFood: initialFood,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('create-food-name')),
      'Renamed local meal',
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byKey(const ValueKey('create-food-name'))),
    );
    final save = find.text(l10n.createProductUpdate);
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    final saved = (await repository.loadFoods()).single.food;
    expect(saved.id, id);
    expect(saved.name, 'Renamed local meal');
    expect(saved.category, '  Custom pantry 🥣  ');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('custom categories save and become limited prefix suggestions', (
    tester,
  ) async {
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserFoodRepository(database);
    for (final suffix in ['A', 'B', 'C', 'D', 'E', 'F']) {
      await repository.create(_foodDraft(category: 'Pantry $suffix'));
    }
    final router = await _pumpForm(tester, repository);
    await _fillRequired(
      tester,
      name: 'Family lentil stew',
      category: '  Family recipes  ',
    );
    await _saveForm(tester);
    expect(
      (await repository.loadFoods())
          .singleWhere((saved) => saved.food.name == 'Family lentil stew')
          .food
          .category,
      'Family recipes',
    );

    router.push<void>('/form');
    await tester.pumpAndSettle();
    final categoryField = find.byKey(const ValueKey('create-food-category'));
    await tester.ensureVisible(categoryField);
    await tester.enterText(categoryField, '  fam');
    await tester.pumpAndSettle();
    expect(find.text('Family recipes'), findsOneWidget);
    await tester.tap(find.text('Family recipes'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(categoryField).controller!.text,
      'Family recipes',
    );

    await tester.enterText(categoryField, 'pantry');
    await tester.pumpAndSettle();
    for (final suffix in ['A', 'B', 'C', 'D', 'E']) {
      expect(find.text('Pantry $suffix'), findsOneWidget);
    }
    expect(find.text('Pantry F'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  for (final locale in [const Locale('en'), const Locale('ru')]) {
    testWidgets(
      'category keyboard selection stores canonical code in ${locale.languageCode}',
      (tester) async {
        final database = YamDatabase(NativeDatabase.memory());
        addTearDown(database.close);
        final repository = UserFoodRepository(database);
        await _pumpForm(tester, repository, locale: locale);
        final categoryField = find.byKey(
          const ValueKey('create-food-category'),
        );
        final l10n = AppLocalizations.of(tester.element(categoryField));
        final label = l10n.foodCategoryDairy;
        await tester.ensureVisible(categoryField);
        await tester.enterText(
          categoryField,
          label.substring(0, 2).toLowerCase(),
        );
        await tester.pumpAndSettle();
        expect(find.text(label), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(categoryField).controller!.text, label);
        await _fillRequired(tester);
        await _saveForm(tester);
        expect((await repository.loadFoods()).single.food.category, 'dairy');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      },
    );
  }

  testWidgets('a whitespace-only category is required before saving', (
    tester,
  ) async {
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserFoodRepository(database);
    await _pumpForm(tester, repository);
    await _fillRequired(tester, category: '   ');
    final l10n = AppLocalizations.of(
      tester.element(find.byKey(const ValueKey('create-food-category'))),
    );
    await _saveForm(tester);
    expect(find.text(l10n.createProductCategoryRequired), findsOneWidget);
    expect(await repository.loadFoods(), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('description saves, reopens and can be cleared', (tester) async {
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserFoodRepository(database);
    final router = await _pumpForm(tester, repository);
    await _fillRequired(tester);
    const description = '  Mix oats and milk.\nBake for 20 minutes.  ';
    final descriptionField = find.byKey(
      const ValueKey('create-food-description'),
    );
    await tester.ensureVisible(descriptionField);
    await tester.enterText(descriptionField, description);
    await _saveForm(tester);
    final saved = (await repository.loadFoods()).single;
    expect(saved.food.description, description);

    router.push<void>('/form', extra: saved);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(descriptionField).controller!.text,
      description,
    );
    await tester.ensureVisible(descriptionField);
    await tester.enterText(descriptionField, '');
    await _saveForm(tester, editing: true);
    expect((await repository.loadFoods()).single.food.description, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('long recipe notes scroll while add stays usable at large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final database = YamDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = UserFoodRepository(database);
    final description = List.generate(
      30,
      (index) => '${index + 1}. Mix the ingredients and simmer until tender.',
    ).join('\n');
    await repository.create(_foodDraft(description: description));
    final saved = (await repository.loadFoods()).single;
    Future<FoodAddPrototypeResult?>? addition;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                addition = showFoodQuickAddSheet(
                  context: context,
                  food: adaptUserFood(saved, AppLocalizations.of(context)),
                  initialMealId: 'breakfast',
                  favorite: false,
                  onFavoriteChanged: (favorite) =>
                      repository.setFavorite(saved.food.id, favorite),
                );
              },
              child: const Text('Open food'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open food'));
    await tester.pumpAndSettle();
    final notes = find.byKey(const ValueKey('quick-add-description'));
    final add = find.byKey(const ValueKey('quick-add-submit'));
    expect(tester.widget<SelectableText>(notes).data, description);
    expect(add.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    final content = find
        .ancestor(of: notes, matching: find.byType(SingleChildScrollView))
        .first;
    await tester.drag(content, const Offset(0, -4000));
    await tester.pumpAndSettle();
    expect(add.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect((await addition)!.name, saved.food.name);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

CustomFoodDraft _foodDraft({String category = 'other', String? description}) =>
    CustomFoodDraft(
      name: 'Family stew',
      category: category,
      description: description,
      basis: CustomFoodBasis.grams,
      basisAmount: 100,
      displayBasis: CustomFoodDisplayBasis.perHundredGrams,
      proteinG: 10,
      fatG: 5,
      carbsG: 20,
      servings: const [],
    );

Future<GoRouter> _pumpForm(
  WidgetTester tester,
  UserFoodRepository repository, {
  Locale locale = const Locale('en'),
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SizedBox.shrink()),
      GoRoute(
        path: '/form',
        builder: (context, state) => UserFoodFormScreen(
          repository: repository,
          initialFood: state.extra as SavedUserFood?,
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
  router.push<void>('/form');
  await tester.pumpAndSettle();
  return router;
}

Future<void> _fillRequired(
  WidgetTester tester, {
  String name = 'Family stew',
  String? category,
}) async {
  for (final field in {
    'create-food-name': name,
    'create-food-category': ?category,
    'create-food-protein': '10',
    'create-food-fat': '5',
    'create-food-carbs': '20',
  }.entries) {
    final finder = find.byKey(ValueKey(field.key));
    await tester.ensureVisible(finder);
    await tester.enterText(finder, field.value);
    await tester.pumpAndSettle();
  }
}

Future<void> _saveForm(WidgetTester tester, {bool editing = false}) async {
  final l10n = AppLocalizations.of(
    tester.element(find.byKey(const ValueKey('create-food-name'))),
  );
  final save = find.text(
    editing ? l10n.createProductUpdate : l10n.createProductSave,
  );
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}
