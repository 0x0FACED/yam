import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/app/theme/app_scroll_behavior.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/core/ui/motion/yam_entrance_reveal.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/startup/presentation/startup_artwork.dart';
import 'package:yam/features/startup/presentation/startup_screen.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class YamApp extends StatefulWidget {
  const YamApp({this.startupArtwork, super.key});

  final StartupArtwork? startupArtwork;

  @override
  State<YamApp> createState() => _YamAppState();
}

class _YamAppState extends State<YamApp> {
  late final GoRouter _router;
  late final ValueNotifier<ThemeMode> _themeMode;
  late final ValueNotifier<SessionProfile?> _profile;
  late final YamDatabase _foodDatabase;
  late final UserFoodRepository _userFoods;
  late final DiaryRepository _diary;
  bool _startupComplete = false;
  int _entranceEpoch = 0;

  @override
  void initState() {
    super.initState();
    _themeMode = ValueNotifier(ThemeMode.system);
    _profile = ValueNotifier<SessionProfile?>(null);
    _foodDatabase = YamDatabase.open();
    _userFoods = UserFoodRepository(_foodDatabase);
    _diary = DiaryRepository(_foodDatabase);
    _router = createAppRouter(
      themeModeListenable: _themeMode,
      onThemeModeChanged: (mode) => _themeMode.value = mode,
      profileListenable: _profile,
      onProfileChanged: _saveProfile,
      userFoodRepository: _userFoods,
      diaryRepository: _diary,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    unawaited(_foodDatabase.close());
    _themeMode.dispose();
    _profile.dispose();
    widget.startupArtwork?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, themeMode, child) => MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appName,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        scrollBehavior: const AppScrollBehavior(),
        routerConfig: _router,
        builder: (context, child) {
          if (!_startupComplete) {
            return StartupScreen(
              key: const ValueKey('startup-screen'),
              semanticsLabel: AppLocalizations.of(context).startupLoadingLabel,
              artwork: widget.startupArtwork,
              onFinished: _finishStartup,
            );
          }
          return KeyedSubtree(
            key: const ValueKey('app-content'),
            child: YamEntranceScope(
              epoch: _entranceEpoch,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }

  void _finishStartup() {
    if (mounted) {
      setState(() {
        _startupComplete = true;
        _entranceEpoch++;
      });
    }
  }

  void _saveProfile(SessionProfile profile) {
    _profile.value = profile;
    if (mounted) setState(() => _entranceEpoch++);
  }
}
