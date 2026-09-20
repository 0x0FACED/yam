import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yam/app/theme/app_scroll_behavior.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/features/diary/presentation/diary_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('diary scroll stays within the frame budget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        scrollBehavior: const AppScrollBehavior(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DiaryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final scrollView = find.byKey(const ValueKey('diary-scroll-view'));
    expect(scrollView, findsOneWidget);

    await binding.watchPerformance(() async {
      for (var index = 0; index < 5; index++) {
        await tester.fling(scrollView, const Offset(0, -700), 5000);
        await tester.pumpAndSettle();
        await tester.fling(scrollView, const Offset(0, 700), 5000);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'diary_scroll');

    final report = binding.reportData!['diary_scroll']! as Map<String, dynamic>;
    expect(
      report['99th_percentile_frame_build_time_millis'],
      lessThan(8.33),
      reason: '99% of UI work must fit within a 120 Hz frame.',
    );
    expect(
      report['99th_percentile_frame_rasterizer_time_millis'],
      lessThan(8.33),
      reason: '99% of raster work must fit within a 120 Hz frame.',
    );
    expect(report['missed_frame_build_budget_count'], 0);
    expect(report['missed_frame_rasterizer_budget_count'], 0);
  });
}
