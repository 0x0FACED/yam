import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/ui/navigation/yam_step_progress.dart';
import 'package:yam/features/diary/presentation/widgets/daily_nutrition_summary.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('onboarding applies session values without a restart', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final profile = ValueNotifier<SessionProfile?>(null);
    addTearDown(profile.dispose);
    final router = createAppRouter(
      profileListenable: profile,
      onProfileChanged: (value) => profile.value = value,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ru'),
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Настройки'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-onboarding')));
    await tester.pumpAndSettle();
    final headerTop = tester.getTopLeft(find.byType(YamStepProgress)).dy;

    await tester.tap(find.byKey(const ValueKey('onboarding-goal-maintain')));
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(YamStepProgress)).dy, headerTop);
    expect(find.text('Шаг 2 из 3'), findsOneWidget);
    expect(find.text('Цель по весу'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('onboarding-current-weight')),
      '',
    );
    await tester.tap(find.text('Продолжить'));
    await tester.pump();
    expect(find.text('Введите число больше нуля'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('onboarding-current-weight')),
      '80,5',
    );
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(YamStepProgress)).dy, headerTop);
    expect(find.text('Шаг 3 из 3'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('onboarding-protein-slider')),
      findsOneWidget,
    );
    expect(find.textContaining('По БЖУ:'), findsOneWidget);
    expect(find.textContaining('+35'), findsOneWidget);

    final proteinSlider = find.byKey(
      const ValueKey('onboarding-protein-slider'),
    );
    await tester.ensureVisible(proteinSlider);
    await tester.drag(proteinSlider, const Offset(36, 0));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('onboarding-protein')))
          .controller!
          .text,
      isNot('140'),
    );
    await tester.enterText(
      find.byKey(const ValueKey('onboarding-protein')),
      '140',
    );

    await tester.enterText(
      find.byKey(const ValueKey('onboarding-calories')),
      '2100',
    );
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();

    expect(profile.value?.goal, WeightGoal.maintain);
    expect(profile.value?.currentWeightKg, 80.5);
    expect(profile.value?.calorieTarget, 2100);
    expect(find.textContaining('80,5 кг'), findsOneWidget);

    await tester.tap(find.text('Дневник'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DailyNutritionSummary>(find.byType(DailyNutritionSummary))
          .day
          .calorieTarget,
      2100,
    );
  });
}
