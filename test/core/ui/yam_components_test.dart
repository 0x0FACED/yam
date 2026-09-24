import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAnimatedOpacity;
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/theme/app_colors.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/buttons/yam_repeat_icon_button.dart';
import 'package:yam/core/ui/diary/yam_diary_rows.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/food/yam_product_row.dart';
import 'package:yam/core/ui/forms/yam_search_field.dart';
import 'package:yam/core/ui/selection/yam_selection_controls.dart';

void main() {
  testWidgets('quantity button taps once and accelerates only while held', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      _TestApp(
        child: YamRepeatIconButton(
          icon: Icons.add_rounded,
          tooltip: 'Increase quantity',
          onPressed: () => presses++,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Increase quantity'));
    expect(presses, 1);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byTooltip('Increase quantity')),
    );
    await tester.pump(const Duration(milliseconds: 450));
    expect(presses, greaterThan(1));
    await tester.pump(const Duration(seconds: 2));
    final heldPresses = presses;
    expect(heldPresses, greaterThan(5));

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 300));
    expect(presses, heldPresses);
  });

  test('fat accent stays legible on light surfaces', () {
    final fat = AppTheme.light.extension<AppSemanticColors>()!.fat;
    for (final surface in [AppColors.lightSurface, AppColors.brandCream]) {
      final contrast =
          (surface.computeLuminance() + 0.05) / (fat.computeLuminance() + 0.05);
      expect(contrast, greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('meal add is visible without inflating the header', (
    tester,
  ) async {
    var added = false;
    await tester.pumpWidget(
      _TestApp(
        child: YamMealSectionHeader(
          mealName: 'Breakfast',
          timeLabel: '8:30',
          calorieValue: '482',
          calorieUnit: 'kcal',
          addTooltip: 'Add to breakfast',
          onAdd: () => added = true,
        ),
      ),
    );

    final add = find.descendant(
      of: find.byType(YamMealSectionHeader),
      matching: find.byType(YamIconButton),
    );
    expect(tester.widget<YamIconButton>(add).visualSize, 36);
    expect(tester.getSize(add).height, greaterThanOrEqualTo(44));
    expect(
      tester.getSize(find.byType(YamMealSectionHeader)).height,
      lessThanOrEqualTo(48),
    );
    await tester.tap(add);
    expect(added, isTrue);
  });

  testWidgets('buttons and chips expose callbacks with touch-size targets', (
    tester,
  ) async {
    var primaryPressed = false;
    var filterPressed = false;
    var compactIconPressed = false;

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
            YamIconButton(
              icon: Icons.add_rounded,
              tooltip: 'Add to meal',
              visualSize: 24,
              iconSize: 16,
              onPressed: () => compactIconPressed = true,
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
    expect(
      tester.getSize(find.byType(YamIconButton)).height,
      greaterThanOrEqualTo(44),
    );

    await tester.tap(find.byType(YamPrimaryButton));
    await tester.tap(find.byType(YamFilterChip));
    await tester.tap(find.byType(YamIconButton));

    expect(primaryPressed, isTrue);
    expect(filterPressed, isTrue);
    expect(compactIconPressed, isTrue);
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

    await tester.pumpWidget(
      _TestApp(
        textScaler: const TextScaler.linear(2),
        child: YamProductRow(
          name: 'Rolled oats',
          metadataLabel: 'Grains',
          calorieLabel: '370 kcal / 100 g',
          proteinLabel: 'P',
          proteinValue: '13',
          fatLabel: 'F',
          fatValue: '7',
          carbsLabel: 'C',
          carbsValue: '62',
          favorite: true,
          favoriteLabel: 'Favorites',
          openKey: const ValueKey('open-product'),
          onPressed: () => opened = true,
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('open-product')));

    expect(opened, isTrue);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
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
    await tester.pump();
    await tester.pump();

    double opacity() => tester
        .renderObject<RenderAnimatedOpacity>(find.byType(AnimatedOpacity))
        .opacity
        .value;
    expect(opacity(), 0);
    await tester.pump(AppMotion.snackBarEnter ~/ 2);
    expect(opacity(), greaterThan(0));
    expect(opacity(), lessThan(1));
    await tester.pumpAndSettle();

    expect(find.byType(YamSnackBar), findsOneWidget);
    expect(
      find.byKey(const ValueKey('yam-snack-bar-success-indicator')),
      findsOneWidget,
    );

    await tester.tap(find.text('Undo'));
    expect(undone, isTrue);
    await tester.pump();
    await tester.pump(AppMotion.snackBarExit ~/ 2);
    expect(opacity(), greaterThan(0));
    expect(opacity(), lessThan(1));
    await tester.pumpAndSettle();
    expect(find.byType(YamSnackBar), findsNothing);
  });

  testWidgets('snackbar skips fading when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        disableAnimations: true,
        child: Builder(
          builder: (context) => YamPrimaryButton(
            label: 'Show',
            onPressed: () => showYamUndoSnackBar(
              context: context,
              message: 'Added',
              undoLabel: 'Undo',
              onUndo: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    expect(
      tester
          .renderObject<RenderAnimatedOpacity>(find.byType(AnimatedOpacity))
          .opacity
          .value,
      1,
    );
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(find.byType(YamSnackBar), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.child,
    this.textScaler,
    this.disableAnimations = false,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      builder: (context, appChild) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: textScaler,
            disableAnimations: disableAnimations,
          ),
          child: appChild!,
        );
      },
      home: Scaffold(body: Center(child: child)),
    );
  }
}
