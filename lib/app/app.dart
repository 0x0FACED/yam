import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/onboarding_access.dart';
import 'package:yam/app/router.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/app/theme/app_theme.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/core/ui/motion/yam_entrance_reveal.dart';
import 'package:yam/features/app_update/data/android_update_installer.dart';
import 'package:yam/features/app_update/data/github_update_client.dart';
import 'package:yam/features/app_update/presentation/app_update_controller.dart';
import 'package:yam/features/backup/data/backup_file_service.dart';
import 'package:yam/features/backup/data/backup_repository.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/startup/presentation/startup_artwork.dart';
import 'package:yam/features/startup/presentation/startup_screen.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/data/open_food_facts_client.dart';
import 'package:yam/features/food_search/data/remote_food_repository.dart';
import 'package:yam/features/statistics/data/statistics_repository.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class YamApp extends StatefulWidget {
  const YamApp({
    required this.appVersion,
    this.startupArtwork,
    this.database,
    this.backupFiles,
    this.appUpdates,
    super.key,
  });

  final String appVersion;
  final StartupArtwork? startupArtwork;
  final YamDatabase? database;
  final BackupFileService? backupFiles;
  final AppUpdateController? appUpdates;

  @override
  State<YamApp> createState() => _YamAppState();
}

class _YamAppState extends State<YamApp> {
  late GoRouter _router;
  late final ValueNotifier<ThemeMode> _themeMode;
  late final ValueNotifier<SessionProfile?> _profile;
  late final ValueNotifier<double?> _currentWeight;
  late final ValueNotifier<OnboardingAccess> _onboardingAccess;
  late final YamDatabase _foodDatabase;
  late final UserFoodRepository _userFoods;
  late final RemoteFoodRepository _remoteFoods;
  late final OpenFoodFactsHttpClient _openFoodFacts;
  late final DiaryRepository _diary;
  late final StatisticsRepository _statistics;
  late final BackupRepository _backup;
  late final AppUpdateController? _appUpdates;
  StreamSubscription<List<GoalVersion>>? _goalsSubscription;
  StreamSubscription<List<WeightRecord>>? _weightsSubscription;
  List<GoalVersion> _goals = const [];
  List<WeightRecord> _weights = const [];
  bool _goalsLoaded = false;
  bool _weightsLoaded = false;
  int _profileEpoch = 0;
  bool _startupComplete = false;
  int _entranceEpoch = 0;

  @override
  void initState() {
    super.initState();
    _themeMode = ValueNotifier(ThemeMode.system);
    _profile = ValueNotifier<SessionProfile?>(null);
    _currentWeight = ValueNotifier<double?>(null);
    _onboardingAccess = ValueNotifier(OnboardingAccess.loading);
    _foodDatabase = widget.database ?? YamDatabase.open();
    _userFoods = UserFoodRepository(_foodDatabase);
    _remoteFoods = RemoteFoodRepository(_foodDatabase);
    _openFoodFacts = OpenFoodFactsHttpClient();
    _diary = DiaryRepository(_foodDatabase);
    _statistics = StatisticsRepository(_foodDatabase);
    _backup = BackupRepository(_foodDatabase);
    _appUpdates =
        widget.appUpdates ??
        (!kIsWeb && Platform.isAndroid
            ? AppUpdateController(
                installedVersion: widget.appVersion,
                client: GitHubUpdateClient(),
                installer: const AndroidUpdateInstaller(),
              )
            : null);
    _listenToProfile();
    _router = _createRouter();
  }

  GoRouter _createRouter() => createAppRouter(
    appVersion: widget.appVersion,
    themeModeListenable: _themeMode,
    onThemeModeChanged: (mode) => _themeMode.value = mode,
    profileListenable: _profile,
    onboardingAccessListenable: _onboardingAccess,
    onRetryProfileLoad: _listenToProfile,
    weightListenable: _currentWeight,
    onProfileChanged: _saveProfile,
    userFoodRepository: _userFoods,
    remoteFoodRepository: _remoteFoods,
    openFoodFactsClient: _openFoodFacts,
    diaryRepository: _diary,
    statisticsRepository: _statistics,
    backupRepository: _backup,
    backupFiles: widget.backupFiles,
    onBackupImported: _reloadAfterImport,
    appUpdates: _appUpdates,
  );

  void _reloadAfterImport() {
    if (!mounted) return;
    final previousRouter = _router;
    _goals = const [];
    _weights = const [];
    _profile.value = null;
    _currentWeight.value = null;
    _listenToProfile();
    setState(() {
      _router = _createRouter();
      _entranceEpoch++;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => previousRouter.dispose(),
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _openFoodFacts.close();
    if (widget.appUpdates == null) _appUpdates?.dispose();
    _goalsSubscription?.cancel();
    _weightsSubscription?.cancel();
    if (widget.database == null) unawaited(_foodDatabase.close());
    _themeMode.dispose();
    _profile.dispose();
    _currentWeight.dispose();
    _onboardingAccess.dispose();
    widget.startupArtwork?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, themeMode, child) => MaterialApp.router(
        key: ObjectKey(_router),
        onGenerateTitle: (context) => AppLocalizations.of(context).appName,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
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

  Future<void> _saveProfile(SessionProfile profile) async {
    await _statistics.saveOnboarding(profile, DateTime.now());
    if (!mounted) return;
    _profile.value = profile;
    _onboardingAccess.value = OnboardingAccess.ready;
    if (mounted) setState(() => _entranceEpoch++);
  }

  void _listenToProfile() {
    final epoch = ++_profileEpoch;
    _goalsSubscription?.cancel();
    _weightsSubscription?.cancel();
    _goalsLoaded = false;
    _weightsLoaded = false;
    _onboardingAccess.value = OnboardingAccess.loading;
    _goalsSubscription = _statistics.watchGoals().listen(
      (goals) {
        if (!mounted || epoch != _profileEpoch) return;
        _goals = goals;
        _goalsLoaded = true;
        _refreshProfile();
        _resolveOnboardingAccess();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (epoch == _profileEpoch) _profileLoadFailed(error, stackTrace);
      },
    );
    _weightsSubscription = _statistics.watchWeights().listen(
      (weights) {
        if (!mounted || epoch != _profileEpoch) return;
        _weights = weights;
        _weightsLoaded = true;
        _refreshProfile();
        _resolveOnboardingAccess();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (epoch == _profileEpoch) _profileLoadFailed(error, stackTrace);
      },
    );
  }

  void _profileLoadFailed(Object error, StackTrace stackTrace) {
    if (mounted) _onboardingAccess.value = OnboardingAccess.failure;
  }

  void _resolveOnboardingAccess() {
    if (!_goalsLoaded ||
        !_weightsLoaded ||
        _onboardingAccess.value == OnboardingAccess.failure) {
      return;
    }
    if (_goals.isNotEmpty) {
      _onboardingAccess.value = OnboardingAccess.ready;
    } else if (_onboardingAccess.value != OnboardingAccess.ready) {
      _onboardingAccess.value = OnboardingAccess.needsOnboarding;
    }
  }

  void _refreshProfile() {
    if (!mounted) return;
    final today = diaryDayKey(DateTime.now());
    final applicable = [
      for (final goal in _goals)
        if (diaryDayKey(goal.day).compareTo(today) <= 0) goal,
    ];
    final latest = applicable.isEmpty ? null : applicable.last;
    final weights = [
      for (final weight in _weights)
        if (diaryDayKey(weight.day).compareTo(today) <= 0) weight,
    ];
    final currentKg = weights.isEmpty ? null : weights.last.kg;
    _currentWeight.value = currentKg;
    _profile.value = latest == null
        ? null
        : SessionProfile(
            goal: latest.goal,
            currentWeightKg: currentKg,
            targetWeightKg: latest.targetWeightKg,
            calorieTarget: latest.calorieTarget,
            proteinTarget: latest.proteinTarget,
            fatTarget: latest.fatTarget,
            carbsTarget: latest.carbsTarget,
          );
  }
}
