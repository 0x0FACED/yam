import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/food/yam_product_row.dart';
import 'package:yam/core/ui/forms/yam_search_field.dart';
import 'package:yam/core/ui/selection/yam_selection_controls.dart';

void main() {
  testWidgets('buttons and chips expose callbacks with touch-size targets', (
    tester,
  ) async {
    var primaryPressed = false;
    var filterPressed = false;

    await tester.pumpWidget(
      _TestApp(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            YamPrimaryButton(
              label: 'Add',
              onPressed: () => primaryPressed = true,
            ),
            YamFilterChip(
              label: 'Recent',
              selected: true,
              onPressed: () => filterPressed = true,
            ),
          ],
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(YamPrimaryButton)).height,
      greaterThanOrEqualTo(44),
    );
    expect(
      tester.getSize(find.byType(YamFilterChip)).height,
      greaterThanOrEqualTo(44),
    );

    await tester.tap(find.byType(YamPrimaryButton));
    await tester.tap(find.byType(YamFilterChip));

    expect(primaryPressed, isTrue);
    expect(filterPressed, isTrue);
  });

  testWidgets('search field clears text and reports the clear action', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var cleared = false;

    await tester.pumpWidget(
      _TestApp(
        child: YamSearchField(
          fieldKey: const ValueKey('search-field'),
          controller: controller,
          hintText: 'Search foods',
          clearTooltip: 'Clear search',
          onChanged: (_) {},
          onClear: () {
            controller.clear();
            cleared = true;
          },
        ),
      ),
    );

    await tester.enterText(find.byKey(const ValueKey('search-field')), 'oats');
    await tester.pump();
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(cleared, isTrue);
  });

  testWidgets('product row remains usable on a narrow large-text layout', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 500);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var opened = false;
    var added = false;

    await tester.pumpWidget(
      _TestApp(
        textScaler: const TextScaler.linear(2),
        child: YamProductRow(
          name: 'Rolled oats',
          sourceLabel: 'Local catalog',
          portionDescription: 'One usual serving',
          calorieLabel: '370 kcal / 100 g',
          proteinLabel: 'P',
          proteinValue: '13',
          fatLabel: 'F',
          fatValue: '7',
          carbsLabel: 'C',
          carbsValue: '62',
          quickAddLabel: '+ 80 g',
          quickAddSemanticLabel: 'Add 80 g of Rolled oats',
          openKey: const ValueKey('open-product'),
          quickAddKey: const ValueKey('quick-add-product'),
          onPressed: () => opened = true,
          onQuickAdd: () => added = true,
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('open-product')));
    await tester.tap(find.byKey(const ValueKey('quick-add-product')));

    expect(opened, isTrue);
    expect(added, isTrue);
  });

  testWidgets('undo snackbar uses the YAM surface and dismisses on action', (
    tester,
  ) async {
    var undone = false;

    await tester.pumpWidget(
      _TestApp(
        child: Builder(
          builder: (context) => YamPrimaryButton(
            label: 'Show',
            onPressed: () {
              showYamUndoSnackBar(
                context: context,
                message: 'Rolled oats added',
                undoLabel: 'Undo',
                onUndo: () => undone = true,
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.byType(YamSnackBar), findsOneWidget);
    expect(
      find.byKey(const ValueKey('yam-snack-bar-success-indicator')),
      findsOneWidget,
    );

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(undone, isTrue);
    expect(find.byType(YamSnackBar), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.textScaler});

  final Widget child;
  final TextScaler? textScaler;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      builder: (context, appChild) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: appChild!,
        );
      },
      home: Scaffold(body: Center(child: child)),
    );
  }
}
