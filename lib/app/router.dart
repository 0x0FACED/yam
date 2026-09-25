import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/navigation/adaptive_navigation_shell.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/presentation/diary_screen.dart';
import 'package:yam/features/food_search/presentation/create_product_stub_screen.dart';
import 'package:yam/features/food_search/presentation/create_product_screen.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/food_search_screen.dart';
import 'package:yam/features/onboarding/presentation/onboarding_screen.dart';
import 'package:yam/features/settings/presentation/settings_screen.dart';
import 'package:yam/features/statistics/data/statistics_repository.dart';
import 'package:yam/features/statistics/presentation/statistics_screen.dart';

GoRouter createAppRouter({
  DateTime? diaryToday,
  ValueListenable<ThemeMode>? themeModeListenable,
  ValueChanged<ThemeMode>? onThemeModeChanged,
  ValueListenable<SessionProfile?>? profileListenable,
  FutureOr<void> Function(SessionProfile)? onProfileChanged,
  ValueListenable<double?>? weightListenable,
  UserFoodRepository? userFoodRepository,
  DiaryRepository? diaryRepository,
  StatisticsRepository? statisticsRepository,
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
                builder: (context, state) =>
                    StatisticsScreen(repository: statisticsRepository),
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
                    ?weightListenable,
                  ];
                  return ListenableBuilder(
                    listenable: Listenable.merge(listenables),
                    builder: (context, child) => SettingsScreen(
                      themeMode: themeModeListenable?.value ?? ThemeMode.system,
                      onThemeModeChanged: changeTheme,
                      profile: profileListenable?.value,
                      currentWeightKg:
                          weightListenable?.value ??
                          profileListenable?.value?.currentWeightKg,
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
          initialProfile: profileListenable?.value,
          initialWeightKg: weightListenable?.value,
          onCompleted: (profile) async {
            await onProfileChanged?.call(profile);
            if (context.mounted) context.pop();
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
