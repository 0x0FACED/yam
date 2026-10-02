import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';
import 'package:yam/features/food_search/presentation/user_food_form_screen.dart';
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
}
