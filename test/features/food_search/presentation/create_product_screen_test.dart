import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';
import 'package:yam/features/food_search/presentation/create_product_screen.dart';
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
        home: CreateProductScreen(repository: repository),
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
}
