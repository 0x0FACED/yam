import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/theme/app_colors.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/features/startup/presentation/startup_artwork.dart';
import 'package:yam/features/startup/presentation/startup_screen.dart';

void main() {
  testWidgets('intro background follows the active theme', (tester) async {
    Future<void> pumpIntro(ThemeMode mode) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        home: StartupScreen(
          semanticsLabel: 'YAM is starting',
          onFinished: () {},
        ),
      ),
    );

    Color introColor() => tester
        .widget<ColoredBox>(
          find
              .descendant(
                of: find.byType(StartupScreen),
                matching: find.byType(ColoredBox),
              )
              .first,
        )
        .color;

    await pumpIntro(ThemeMode.dark);
    expect(introColor(), AppTheme.dark.scaffoldBackgroundColor);

    await pumpIntro(ThemeMode.light);
    await tester.pump(const Duration(milliseconds: 250));
    expect(introColor(), AppTheme.light.scaffoldBackgroundColor);
  });

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
    expect(
      loadedArtwork.pictureFor(
        StartupArtwork.letterY,
        brightness: Brightness.dark,
      ),
      isNotNull,
    );
    expect(
      loadedArtwork.pictureFor(
        StartupArtwork.fullLogo,
        brightness: Brightness.dark,
      ),
      isNotNull,
    );
    expect(
      StartupArtwork.darkColorMapper.substitute(
        null,
        'path',
        'fill',
        const Color(0xFF17141C),
      ),
      AppColors.darkTextPrimary,
    );
    expect(
      StartupArtwork.darkColorMapper.substitute(
        null,
        'path',
        'fill',
        AppColors.brandPurple,
      ),
      AppColors.brandPurple,
    );
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
