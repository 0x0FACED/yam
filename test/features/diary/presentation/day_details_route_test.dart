import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/features/diary/presentation/day_details_route.dart';

void main() {
  testWidgets('closing details gradually reveals UI outside the summary', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final capture = GlobalKey();
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      RepaintBoundary(
        key: capture,
        child: MaterialApp(
          navigatorKey: navigator,
          theme: ThemeData(scaffoldBackgroundColor: Colors.white),
          home: const ColoredBox(color: Colors.black),
        ),
      ),
    );
    navigator.currentState!.push(
      DayDetailsRoute(
        sourceRect: () => const Rect.fromLTWH(100, 200, 200, 100),
        reduceMotion: false,
        builder: (_) => const ColoredBox(color: Colors.white),
      ),
    );
    await tester.pumpAndSettle();
    navigator.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final early = await _backgroundPixel(tester, capture);
    await tester.pump(const Duration(milliseconds: 100));
    final late = await _backgroundPixel(tester, capture);
    await tester.pumpAndSettle();
    final closed = await _backgroundPixel(tester, capture);
    // The top-left UI is outside the moving summary surface in both frames.
    // It must fade in, rather than appear fully as soon as the clip uncovers it.
    expect(early, inExclusiveRange(0, 255));
    expect(late, inExclusiveRange(0, early));
    expect(closed, 0);
  });
}

Future<int> _backgroundPixel(WidgetTester tester, GlobalKey key) async {
  return (await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      return bytes.getUint8((8 * image.width + 8) * 4);
    } finally {
      image.dispose();
    }
  }))!;
}
