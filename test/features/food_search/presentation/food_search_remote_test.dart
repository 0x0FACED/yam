import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/data/open_food_facts_client.dart';
import 'package:yam/features/food_search/data/remote_food_repository.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/diary_food_adapter.dart';
import 'package:yam/features/food_search/presentation/remote_food_adapter.dart';
import 'package:yam/features/food_search/presentation/food_search_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

const remoteFood = OpenFoodFactsProduct(
  code: '0001234567890',
  name: 'Yogurt from OFF',
  brand: 'Real Dairy',
  energyKcal: 80.75,
  proteinG: 3.5,
  fatG: 4,
  carbsG: 7.25,
);

class FakeOffClient implements OpenFoodFactsSearchClient {
  final queries = <String>[];
  final pending = <Completer<List<OpenFoodFactsProduct>>>[];

  @override
  Future<List<OpenFoodFactsProduct>> search(String query, String language) {
    queries.add(query);
    final request = Completer<List<OpenFoodFactsProduct>>();
    pending.add(request);
    return request.future;
  }
}

Widget screen(
  FakeOffClient client, {
  RemoteFoodRepository? remote,
  DiaryRepository? diary,
  FoodSearchPrototypeArguments arguments = const FoodSearchPrototypeArguments(),
}) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: FoodSearchScreen(
    arguments: arguments,
    remoteFoodRepository: remote,
    diaryRepository: diary,
    openFoodFactsClient: client,
  ),
);

void main() {
  testWidgets('local results stay usable through debounce, error and retry', (
    tester,
  ) async {
    final client = FakeOffClient();
    await tester.pumpWidget(screen(client));
    await tester.enterText(
      find.byKey(const ValueKey('food-search-field')),
      'oa',
    );
    await tester.pump(const Duration(milliseconds: 800));
    expect(client.queries, isEmpty);
    expect(find.text('Nothing found'), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('food-search-field')),
      'oat',
    );
    await tester.pump();
    expect(find.text('Rolled oats'), findsOneWidget);
    expect(find.text('Open Food Facts'), findsOneWidget);
    expect(find.text('Nothing found'), findsNothing);
    await tester.pump(const Duration(milliseconds: 649));
    expect(client.queries, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(client.queries, ['oat']);

    await tester.enterText(
      find.byKey(const ValueKey('food-search-field')),
      'milk',
    );
    await tester.pump();
    client.pending.first.complete([remoteFood]);
    await tester.pump();
    expect(find.text('Yogurt from OFF'), findsNothing);
    expect(find.text('Milk 2.5%'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 650));
    expect(client.queries, ['oat', 'milk']);
    client.pending[1].completeError(Exception('offline'));
    await tester.pumpAndSettle();
    expect(find.text('Milk 2.5%'), findsOneWidget);
    expect(find.byKey(const ValueKey('food-search-off-retry')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('food-search-off-retry')));
    await tester.pump();
    expect(client.queries, ['oat', 'milk', 'milk']);
    client.pending[2].complete([remoteFood]);
    await tester.pump();
    expect(find.text('Yogurt from OFF'), findsOneWidget);
    expect(find.text('Other · Real Dairy'), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsNothing);
    expect(
      find.byKey(const ValueKey('food-search-tab-myDishes')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('food-search-field')),
      'zzzz-unmatched',
    );
    await tester.pump();
    expect(find.text('Nothing found'), findsNothing);
    await tester.pump(const Duration(milliseconds: 650));
    client.pending.last.complete([]);
    await tester.pumpAndSettle();
    expect(
      find.text('No addable products found on Open Food Facts.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'cached OFF food appears in favorites and recent, not my dishes',
    (tester) async {
      final db = YamDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final remote = RemoteFoodRepository(db);
      final diary = DiaryRepository(db);
      await remote.setFavorite(remoteFood, true);
      await remote.addToDiary(
        remoteFood,
        DiaryEntryDraft(
          day: DateTime(2026, 9, 25),
          mealId: 'breakfast',
          food: diarySnapshotForFood(adaptRemoteFood(remoteFood)),
          servingId: 'grams',
          amount: 100,
          canonicalQuantity: 100,
        ),
      );
      await tester.pumpWidget(
        screen(FakeOffClient(), remote: remote, diary: diary),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('food-result-off:0001234567890')),
        findsOneWidget,
      );
      expect(find.text('Data: Open Food Facts'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('food-search-tab-favorites')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('food-result-off:0001234567890')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('food-search-tab-myDishes')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('food-result-off:0001234567890')),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('OFF result uses existing sheet and persists a selected food', (
    tester,
  ) async {
    final db = YamDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final client = FakeOffClient();
    await tester.pumpWidget(
      screen(
        client,
        remote: RemoteFoodRepository(db),
        diary: DiaryRepository(db),
        arguments: const FoodSearchPrototypeArguments(
          initialMealId: 'breakfast',
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const ValueKey('food-search-field')),
      'yogurt',
    );
    await tester.pump(const Duration(milliseconds: 650));
    client.pending.single.complete([remoteFood]);
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('food-result-off:0001234567890')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('quick-add-submit')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quick-add-favorite')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quick-add-submit')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('food-search-field')), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('food-result-off:0001234567890')),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
