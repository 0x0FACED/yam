import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/app/onboarding_access.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'required onboarding blocks other routes and settings rerun cancels',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final access = ValueNotifier(OnboardingAccess.needsOnboarding);
      final profile = ValueNotifier<SessionProfile?>(null);
      addTearDown(access.dispose);
      addTearDown(profile.dispose);
      final router = createAppRouter(
        onboardingAccessListenable: access,
        profileListenable: profile,
        onProfileChanged: (value) {
          profile.value = value;
          access.value = OnboardingAccess.ready;
        },
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('onboarding-goal-maintain')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('diary-add-food')), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(
        find.byKey(const ValueKey('onboarding-goal-maintain')),
        findsOneWidget,
      );
      router.go('/settings');
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('onboarding-goal-maintain')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('onboarding-goal-maintain')));
      await tester.tap(find.byKey(const ValueKey('onboarding-continue')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('onboarding-current-weight')),
        '80.5',
      );
      await tester.enterText(
        find.byKey(const ValueKey('onboarding-target-weight')),
        '79',
      );
      await tester.tap(find.byKey(const ValueKey('onboarding-continue')));
      await tester.pumpAndSettle();
      for (final (key, value) in [
        ('onboarding-calories', '2100'),
        ('onboarding-protein', '140'),
        ('onboarding-fat', '65'),
        ('onboarding-carbs', '210'),
      ]) {
        await tester.enterText(find.byKey(ValueKey(key)), value);
      }
      await tester.tap(find.byKey(const ValueKey('onboarding-continue')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('diary-add-food')), findsOneWidget);

      router.go('/settings');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('settings-onboarding')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('settings-onboarding')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      final reopenedRouter = createAppRouter(
        onboardingAccessListenable: access,
        profileListenable: profile,
      );
      addTearDown(reopenedRouter.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: reopenedRouter,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('diary-add-food')), findsOneWidget);
      reopenedRouter.go('/onboarding');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('diary-add-food')), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('database read error offers retry rather than onboarding', (
    tester,
  ) async {
    final access = ValueNotifier(OnboardingAccess.failure);
    addTearDown(access.dispose);
    var retried = false;
    final router = createAppRouter(
      onboardingAccessListenable: access,
      onRetryProfileLoad: () {
        retried = true;
        access.value = OnboardingAccess.loading;
      },
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('startup-data-retry')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('onboarding-goal-maintain')),
      findsNothing,
    );
    await tester.tap(find.byKey(const ValueKey('startup-data-retry')));
    await tester.pump();
    expect(retried, isTrue);
    access.value = OnboardingAccess.needsOnboarding;
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('onboarding-goal-maintain')),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
