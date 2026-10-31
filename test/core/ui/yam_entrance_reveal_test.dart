import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/ui/motion/yam_entrance_reveal.dart';

void main() {
  testWidgets('replays without fading out or losing child state', (
    tester,
  ) async {
    var epoch = 0;
    Widget app() => _app(
      epoch: epoch,
      child: const YamEntranceReveal(index: 0, child: TextField()),
    );
    await tester.pumpWidget(app());
    expect(_opacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 80));
    expect(_opacity(tester), inExclusiveRange(0, 1));
    await tester.enterText(find.byType(TextField), 'Retained input');
    await tester.pumpAndSettle();

    await tester.pumpWidget(app());
    expect(_opacity(tester), 1);
    epoch++;
    await tester.pumpWidget(app());
    expect(_opacity(tester), 0);
    expect(find.text('Retained input'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 80));
    expect(_opacity(tester), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
  });

  testWidgets(
    'waits for data and cancels stagger from interrupted selections',
    (tester) async {
      var selection = 0;
      var ready = false;
      Widget app() => _app(
        child: YamEntranceReveal(
          index: 3,
          replayKey: selection,
          ready: ready,
          child: const Text('Data'),
        ),
      );
      await tester.pumpWidget(app());
      await tester.pump(const Duration(seconds: 1));
      expect(_opacity(tester), 0);

      ready = true;
      await tester.pumpWidget(app());
      await tester.pump(const Duration(milliseconds: 100));
      selection++;
      await tester.pumpWidget(app());
      // The old selection's delay has elapsed; the current one's has not.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 20));
      expect(_opacity(tester), 0);
      await tester.pumpAndSettle();
      expect(_opacity(tester), 1);

      // A live update to the same selection must not replay the screen.
      await tester.pumpWidget(app());
      expect(_opacity(tester), 1);
    },
  );

  testWidgets('starts on branch activation and completes with reduced motion', (
    tester,
  ) async {
    var active = false;
    var reduceMotion = false;
    var epoch = 0;
    Widget app() => _app(
      epoch: epoch,
      active: active,
      reduceMotion: reduceMotion,
      child: const YamEntranceReveal(index: 0, child: Text('Data')),
    );
    await tester.pumpWidget(app());
    await tester.pump(const Duration(seconds: 1));
    active = true;
    await tester.pumpWidget(app());
    expect(_opacity(tester), 0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(_opacity(tester), inExclusiveRange(0, 1));

    reduceMotion = true;
    await tester.pumpWidget(app());
    expect(_opacity(tester), 1);
    epoch++;
    await tester.pumpWidget(app());
    expect(_opacity(tester), 1);
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
  });

  testWidgets('replays after a hidden route becomes active', (tester) async {
    var active = true;
    Widget app() => _app(
      active: active,
      child: const YamEntranceReveal(index: 0, child: Text('Data')),
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);

    active = false;
    await tester.pumpWidget(app());
    expect(_opacity(tester), 0);
    await tester.pump(const Duration(seconds: 1));
    expect(_opacity(tester), 0);

    active = true;
    await tester.pumpWidget(app());
    expect(_opacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 80));
    expect(_opacity(tester), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
  });
}

Widget _app({
  required Widget child,
  int epoch = 0,
  bool active = true,
  bool reduceMotion = false,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: TickerMode(
      enabled: active,
      child: YamEntranceScope(
        epoch: epoch,
        child: Scaffold(body: child),
      ),
    ),
  ),
);

double _opacity(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find
          .descendant(
            of: find.byType(YamEntranceReveal),
            matching: find.byType(FadeTransition),
          )
          .first,
    )
    .opacity
    .value;
