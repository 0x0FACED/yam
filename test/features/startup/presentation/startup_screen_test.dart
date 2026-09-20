import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/features/startup/presentation/startup_artwork.dart';
import 'package:yam/features/startup/presentation/startup_screen.dart';

void main() {
  testWidgets('keeps the full animation visible for its configured duration', (
    tester,
  ) async {
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StartupScreen(
          semanticsLabel: 'YAM is starting',
          onFinished: () => finished = true,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 700));
    expect(finished, isFalse);

    await tester.pump(AppMotion.logoIntro - const Duration(milliseconds: 700));
    expect(finished, isTrue);
  });

  testWidgets('preloads every startup picture', (tester) async {
    final artwork = await tester.runAsync(StartupArtwork.load);
    expect(artwork, isNotNull);
    final loadedArtwork = artwork!;
    addTearDown(loadedArtwork.dispose);

    expect(loadedArtwork.pictureFor(StartupArtwork.mascot), isNotNull);
    expect(loadedArtwork.pictureFor(StartupArtwork.fullLogo), isNotNull);
  });

  testWidgets('uses the short fade when animations are disabled', (
    tester,
  ) async {
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: StartupScreen(
            semanticsLabel: 'YAM is starting',
            onFinished: () => finished = true,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 149));
    expect(finished, isFalse);

    await tester.pump(const Duration(milliseconds: 1));
    expect(finished, isTrue);
  });

  testWidgets('exposes a single accessible startup label', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: StartupScreen(
          semanticsLabel: 'YAM is starting',
          onFinished: () {},
        ),
      ),
    );

    expect(find.bySemanticsLabel('YAM is starting'), findsOneWidget);
    semantics.dispose();
  });
}
