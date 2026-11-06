import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/ui/forms/yam_text_field.dart';

void main() {
  testWidgets(
    'quick taps at different positions move the caret',
    (tester) async {
      final controller = await _pumpField(tester);
      await _tapOffset(tester, 5);
      await tester.pump(const Duration(milliseconds: 80));
      await _tapOffset(tester, 9);
      await tester.pump();
      expect(controller.selection.isCollapsed, isTrue);
      if (defaultTargetPlatform != TargetPlatform.iOS) {
        expect(controller.selection.extentOffset, 9);
      }
    },
    variant: TargetPlatformVariant.all(),
  );

  testWidgets(
    'double tap still selects a word after relocating the caret',
    (tester) async {
      final controller = await _pumpField(tester);
      await _tapOffset(tester, 5);
      await tester.pump(const Duration(milliseconds: 80));
      await _tapOffset(tester, 9);
      await tester.pump(const Duration(milliseconds: 80));
      await _tapOffset(tester, 9);
      await tester.pump();
      expect(controller.selection.textInside(controller.text), 'хлопья');
    },
    variant: TargetPlatformVariant.all(),
  );

  testWidgets('long press still selects a word', (tester) async {
    final controller = await _pumpField(tester);
    tester
        .state<EditableTextState>(find.byType(EditableText))
        .widget
        .focusNode
        .unfocus();
    await tester.pumpAndSettle();
    final point = _point(tester, 9);
    await tester.longPressAt(point);
    await tester.pumpAndSettle();
    expect(controller.selection.textInside(controller.text), 'хлопья');
  }, variant: TargetPlatformVariant.mobile());

  testWidgets(
    'triple tap after relocating still selects the entire line',
    (tester) async {
      final controller = await _pumpField(tester);
      await _tapOffset(tester, 5);
      for (var tap = 0; tap < 3; tap++) {
        await tester.pump(const Duration(milliseconds: 80));
        await _tapOffset(tester, 9);
      }
      await tester.pump();
      expect(controller.selection.textInside(controller.text), controller.text);
    },
    variant: TargetPlatformVariant.all(),
  );

  testWidgets(
    'tap timeout starts at release, not initial contact',
    (tester) async {
      final controller = await _pumpField(tester);
      final first = await tester.startGesture(_point(tester, 5));
      await tester.pump(const Duration(milliseconds: 250));
      await first.up(timeStamp: const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 80));
      final second = await tester.createGesture();
      await second.down(
        _point(tester, 9),
        timeStamp: const Duration(milliseconds: 330),
      );
      await second.up(timeStamp: const Duration(milliseconds: 340));
      await tester.pump();
      expect(controller.selection.isCollapsed, isTrue);
    },
    variant: TargetPlatformVariant.mobile(),
  );

  testWidgets(
    'shift-click still extends a relocated caret',
    (tester) async {
      final controller = await _pumpField(tester);
      await _tapOffset(tester, 5);
      await tester.pump(const Duration(milliseconds: 80));
      await _tapOffset(tester, 9);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tapAt(_point(tester, 11), kind: PointerDeviceKind.mouse);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(controller.selection.start, 9);
      expect(controller.selection.end, 11);
    },
    variant: TargetPlatformVariant.desktop(),
  );

  testWidgets(
    'mouse dragging still selects a text range',
    (tester) async {
      final controller = await _pumpField(tester);
      final drag = await tester.startGesture(
        _point(tester, 5),
        kind: PointerDeviceKind.mouse,
      );
      await drag.moveTo(_point(tester, 11));
      await tester.pump();
      await drag.up();
      await tester.pump();
      expect(controller.selection.start, 5);
      expect(controller.selection.end, 11);
    },
    variant: TargetPlatformVariant.desktop(),
  );
}

Future<TextEditingController> _pumpField(WidgetTester tester) async {
  final controller = TextEditingController(text: 'Овсяные хлопья с молоком');
  final focus = FocusNode();
  addTearDown(controller.dispose);
  addTearDown(focus.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            child: YamTextField(
              label: 'Name',
              controller: controller,
              focusNode: focus,
            ),
          ),
        ),
      ),
    ),
  );
  focus.requestFocus();
  await tester.pumpAndSettle();
  controller.selection = const TextSelection.collapsed(offset: 0);
  await tester.pump();
  return controller;
}

Offset _point(WidgetTester tester, int offset) {
  final render = tester
      .state<EditableTextState>(find.byType(EditableText))
      .renderEditable;
  return render.localToGlobal(
    render.getLocalRectForCaret(TextPosition(offset: offset)).center,
  );
}

Future<void> _tapOffset(WidgetTester tester, int offset) =>
    tester.tapAt(_point(tester, offset), kind: PointerDeviceKind.touch);
