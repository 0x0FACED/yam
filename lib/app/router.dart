import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/navigation/adaptive_navigation_shell.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/presentation/diary_screen.dart';
import 'package:yam/features/food_search/presentation/create_product_stub_screen.dart';
import 'package:yam/features/food_search/presentation/create_product_screen.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/food_search_screen.dart';
import 'package:yam/features/onboarding/presentation/onboarding_screen.dart';
import 'package:yam/features/settings/presentation/settings_screen.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

GoRouter createAppRouter({
  DateTime? diaryToday,
  ValueListenable<ThemeMode>? themeModeListenable,
  ValueChanged<ThemeMode>? onThemeModeChanged,
  ValueListenable<SessionProfile?>? profileListenable,
  ValueChanged<SessionProfile>? onProfileChanged,
  UserFoodRepository? userFoodRepository,
  DiaryRepository? diaryRepository,
}) {
  return GoRouter(
    initialLocation: '/diary',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diary',
                builder: (context, state) {
                  if (profileListenable case final listenable?) {
                    return ValueListenableBuilder<SessionProfile?>(
                      valueListenable: listenable,
                      builder: (context, profile, child) => DiaryScreen(
                        today: diaryToday,
                        profile: profile,
                        repository: diaryRepository,
                      ),
                    );
                  }
                  return DiaryScreen(
                    today: diaryToday,
                    repository: diaryRepository,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return _SectionPlaceholder(
                    icon: Icons.bar_chart_rounded,
                    title: l10n.statisticsTitle,
                    message: l10n.statisticsPrototypeMessage,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) {
                  final changeTheme = onThemeModeChanged ?? (_) {};
                  final listenables = <Listenable>[
                    ?themeModeListenable,
                    ?profileListenable,
                  ];
                  return ListenableBuilder(
                    listenable: Listenable.merge(listenables),
                    builder: (context, child) => SettingsScreen(
                      themeMode: themeModeListenable?.value ?? ThemeMode.system,
                      onThemeModeChanged: changeTheme,
                      profile: profileListenable?.value,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          initialProfile: profileListenable?.value ?? SessionProfile.example,
          onCompleted: (profile) {
            onProfileChanged?.call(profile);
            context.pop();
          },
        ),
      ),
      GoRoute(
        path: '/add-food',
        builder: (context, state) {
          final arguments = state.extra is FoodSearchPrototypeArguments
              ? state.extra! as FoodSearchPrototypeArguments
              : const FoodSearchPrototypeArguments();
          return FoodSearchScreen(
            arguments: arguments,
            userFoodRepository: userFoodRepository,
            diaryRepository: diaryRepository,
          );
        },
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => userFoodRepository == null
                ? const CreateProductStubScreen()
                : CreateProductScreen(repository: userFoodRepository),
          ),
        ],
      ),
    ],
  );
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
