import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/theme/app_breakpoints.dart';
import 'package:yam/app/session/session_profile.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/feedback/yam_feedback_state.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/motion/yam_entrance_reveal.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/day_details.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/diary/presentation/diary_prototype_data.dart';
import 'package:yam/features/diary/presentation/day_details_route.dart';
import 'package:yam/features/diary/presentation/day_details_screen.dart';
import 'package:yam/features/diary/presentation/widgets/edit_diary_entry_sheet.dart';
import 'package:yam/features/diary/presentation/widgets/daily_nutrition_summary.dart';
import 'package:yam/features/diary/presentation/widgets/diary_day_selector.dart';
import 'package:yam/features/diary/presentation/widgets/meal_section.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/features/food_search/presentation/food_search_format.dart';
import 'package:yam/features/statistics/data/statistics_repository.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({
    this.today,
    this.profile,
    this.repository,
    this.statisticsRepository,
    this.onOpenAssistant,
    super.key,
  });

  final DateTime? today;
  final SessionProfile? profile;
  final DiaryRepository? repository;
  final StatisticsRepository? statisticsRepository;
  final ValueChanged<DateTime>? onOpenAssistant;

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _scrollController = ScrollController();
  final _summaryKey = GlobalKey();
  final _summaryHeroTag = Object();
  late final ValueNotifier<AsyncSnapshot<DayDetailsSnapshot>> _dayDetails;
  bool _detailsOpen = false;
  List<DiaryEntry> _entries = const [];
  bool _entriesReady = false;
  bool _entriesError = false;
  int _dayEpoch = 0;
  Map<String, List<DiaryPrototypeEntry>> _displayEntriesByMeal = const {};
  Locale? _displayLocale;
  StreamSubscription<List<DiaryEntry>>? _daySubscription;
  StreamSubscription<List<GoalVersion>>? _goalsSubscription;
  StreamSubscription<List<NutritionDay>>? _weekSubscription;
  List<GoalVersion> _goals = const [];
  List<NutritionDay> _weekNutrition = const [];
  Map<DateTime, GoalDayStatus> _weekStatuses = const {};
  late DateTime _visibleWeekStart;
  bool _goalsReady = false;
  bool _weekNutritionReady = false;
  bool _goalsError = false;
  bool _weekError = false;

  bool get _readError => _entriesError || _goalsError || _weekError;
  bool get _calendarReady =>
      _goalsReady && _weekNutritionReady && !_goalsError && !_weekError;
  bool get _readReady => _entriesReady && _calendarReady && !_readError;
  int _goalsEpoch = 0;
  int _weekEpoch = 0;
  final Set<String> _favoriteOverrides = {};

  late final DateTime _today;
  late DateTime _selectedDay;
  Timer? _highlightTimer;
  String? _highlightedEntryId;
  GlobalKey? _highlightedEntryKey;

  @override
  void initState() {
    super.initState();
    final now = widget.today ?? DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _selectedDay = _today;
    _dayDetails = ValueNotifier(
      const AsyncSnapshot<DayDetailsSnapshot>.waiting(),
    );
    _watchSelectedDay();
    _watchCalendarGoals();
  }

  @override
  void didUpdateWidget(DiaryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) _watchSelectedDay();
    if (oldWidget.statisticsRepository != widget.statisticsRepository) {
      _watchCalendarGoals();
    }
    if (oldWidget.profile != widget.profile) _refreshDayDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_displayLocale != locale) {
      _displayLocale = locale;
      _prepareDisplayEntries();
    }
  }

  void _watchSelectedDay() {
    final epoch = ++_dayEpoch;
    _daySubscription?.cancel();
    _entries = const [];
    _displayEntriesByMeal = const {};
    _entriesError = false;
    _entriesReady = widget.repository == null;
    _refreshDayDetails();
    _daySubscription = widget.repository
        ?.watchDay(_selectedDay)
        .listen(
          (entries) {
            if (!mounted || epoch != _dayEpoch) return;
            setState(() {
              _entries = entries;
              _entriesError = false;
              _entriesReady = true;
              _prepareDisplayEntries();
              _refreshDayDetails();
            });
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!mounted || epoch != _dayEpoch) return;
            setState(() {
              _entriesError = true;
              _entriesReady = false;
              _entries = const [];
              _displayEntriesByMeal = const {};
              _refreshDayDetails();
            });
          },
        );
  }

  DateTime _weekStartFor(DateTime day) =>
      DateTime(day.year, day.month, day.day - day.weekday + DateTime.monday);

  void _watchCalendarGoals() {
    final epoch = ++_goalsEpoch;
    _goalsSubscription?.cancel();
    _goals = const [];
    _goalsError = false;
    final repository = widget.statisticsRepository;
    _goalsReady = repository == null;
    _goalsSubscription = repository?.watchGoals().listen(
      (goals) {
        if (!mounted || epoch != _goalsEpoch) return;
        setState(() {
          _goals = goals;
          _goalsError = false;
          _goalsReady = true;
        });
        _recalculateWeek();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted || epoch != _goalsEpoch) return;
        setState(() {
          _goalsError = true;
          _goalsReady = false;
          _goals = const [];
          _weekStatuses = const {};
          _refreshDayDetails();
        });
      },
    );
    _watchVisibleWeek();
  }

  void _watchVisibleWeek() {
    final epoch = ++_weekEpoch;
    _weekSubscription?.cancel();
    _visibleWeekStart = _weekStartFor(_selectedDay);
    _weekNutrition = const [];
    _weekStatuses = const {};
    _weekError = false;
    final repository = widget.statisticsRepository;
    _weekNutritionReady = repository == null;
    _refreshDayDetails();
    if (repository == null) return;
    _weekSubscription = repository
        .watchNutritionRange(
          start: _visibleWeekStart,
          end: DateTime(
            _visibleWeekStart.year,
            _visibleWeekStart.month,
            _visibleWeekStart.day + DateTime.daysPerWeek - 1,
          ),
        )
        .listen(
          (nutrition) {
            if (!mounted || epoch != _weekEpoch) return;
            _weekNutrition = nutrition;
            _weekError = false;
            _weekNutritionReady = true;
            _recalculateWeek();
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!mounted || epoch != _weekEpoch) return;
            setState(() {
              _weekError = true;
              _weekNutritionReady = false;
              _weekNutrition = const [];
              _weekStatuses = const {};
              _refreshDayDetails();
            });
          },
        );
  }

  void _recalculateWeek() {
    setState(() {
      if (_calendarReady) {
        _weekStatuses = calculateGoalDayStatuses(
          start: _visibleWeekStart,
          end: DateTime(
            _visibleWeekStart.year,
            _visibleWeekStart.month,
            _visibleWeekStart.day + DateTime.daysPerWeek - 1,
          ),
          nutrition: _weekNutrition,
          goals: _goals,
        );
      }
      _refreshDayDetails();
    });
  }

  void _refreshDayDetails() {
    if (_readError) {
      _dayDetails.value = AsyncSnapshot.withError(
        ConnectionState.done,
        StateError('Diary data unavailable'),
      );
      return;
    }
    if (!_readReady) {
      _dayDetails.value = const AsyncSnapshot.waiting();
      return;
    }
    final profile = widget.profile;
    final goals = widget.statisticsRepository == null && profile != null
        ? [
            GoalVersion(
              id: 'session',
              day: _today,
              goal: profile.goal,
              calorieTarget: profile.calorieTarget,
              proteinTarget: profile.proteinTarget,
              fatTarget: profile.fatTarget,
              carbsTarget: profile.carbsTarget,
              targetWeightKg: profile.targetWeightKg,
            ),
          ]
        : _goals;
    _dayDetails.value = AsyncSnapshot.withData(
      ConnectionState.done,
      DayDetailsSnapshot(day: _selectedDay, entries: _entries, goals: goals),
    );
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _daySubscription?.cancel();
    _goalsSubscription?.cancel();
    _weekSubscription?.cancel();
    _scrollController.dispose();
    _dayDetails.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final goal = _dayDetails.value.data?.goal;
    final meals = buildDiaryPrototypeDay(
      l10n,
      entriesByMeal: _displayEntriesByMeal,
    ).meals;
    final day = DiaryPrototypeDay(
      calorieTarget: goal?.calorieTarget,
      proteinTarget: goal?.proteinTarget,
      fatTarget: goal?.fatTarget,
      carbsTarget: goal?.carbsTarget,
      meals: meals,
    );

    return _buildScaffold(day, l10n);
  }

  void _prepareDisplayEntries() {
    if (_displayLocale == null) return;
    final entriesByMeal = <String, List<DiaryPrototypeEntry>>{};
    for (final entry in _entries) {
      final serving = entry.food.serving(entry.servingId);
      final quantity = formatFoodSearchServingQuantity(
        context,
        FoodSearchPrototypeServing(
          id: serving.id,
          unit: FoodSearchPrototypeUnit.values.byName(serving.unit),
          label: serving.label,
          baseAmount: serving.baseAmount,
          defaultAmount: 1,
          presets: const [],
        ),
        entry.amount,
      );
      (entriesByMeal[entry.mealId] ??= []).add(
        DiaryPrototypeEntry(
          id: entry.id,
          name: entry.food.name,
          brand: entry.food.brand,
          quantity: quantity,
          calories: entry.nutrition.kcal.round(),
          exactCalories: entry.nutrition.kcal,
          protein: entry.nutrition.protein,
          fat: entry.nutrition.fat,
          carbs: entry.nutrition.carbs,
          storedEntry: entry,
        ),
      );
    }
    _displayEntriesByMeal = entriesByMeal;
  }

  void _retryReads() {
    setState(() {
      _watchSelectedDay();
      _watchCalendarGoals();
    });
  }

  Widget _buildReadFeedback(AppLocalizations l10n) {
    if (_readError) {
      return YamFeedbackState(
        icon: Icons.error_outline_rounded,
        title: l10n.diaryReadErrorTitle,
        message: l10n.diaryReadErrorMessage,
        actionLabel: l10n.actionRetry,
        actionIcon: Icons.refresh_rounded,
        onAction: _retryReads,
        error: true,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Semantics(
          label: l10n.startupDataLoading,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildScaffold(DiaryPrototypeDay day, AppLocalizations l10n) =>
      Scaffold(
        floatingActionButton: FloatingActionButton(
          key: const ValueKey('diary-add-food'),
          tooltip: l10n.diaryAddFood,
          onPressed: _openFoodSearch,
          child: const Icon(Icons.add_rounded),
        ),
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth >= AppBreakpoints.navigationRail
                  ? AppSpacing.xl
                  : AppSpacing.md;

              return CustomScrollView(
                key: const ValueKey('diary-scroll-view'),
                controller: _scrollController,
                slivers: [
                  _buildHeaderSliver(horizontalPadding),
                  if (!_readReady)
                    SliverToBoxAdapter(
                      child: _ConstrainedDiaryContent(
                        child: Column(
                          children: [
                            if (_calendarReady) _buildDaySelector(),
                            _buildReadFeedback(l10n),
                          ],
                        ),
                      ),
                    )
                  else if (constraints.maxWidth >= AppBreakpoints.wideDiary)
                    ..._buildWideSlivers(day, horizontalPadding)
                  else
                    ..._buildCompactSlivers(day, horizontalPadding),
                ],
              );
            },
          ),
        ),
      );

  Widget _buildHeaderSliver(double horizontalPadding) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      primary: false,
      toolbarHeight: 48,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      shape: Border(
        bottom: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: _ConstrainedDiaryContent(
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    AppLocalizations.of(context).appName,
                    style: AppTypography.sectionTitle.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              if (widget.onOpenAssistant case final open?)
                YamIconButton(
                  key: const ValueKey('diary-assistant'),
                  icon: Icons.chat_bubble_outline_rounded,
                  tooltip: AppLocalizations.of(context).assistantTitle,
                  onPressed: () => open(_selectedDay),
                  surface: false,
                  iconSize: 22,
                  visualSize: 32,
                ),
              if (!_isSameDay(_selectedDay, _today))
                YamIconButton(
                  icon: Icons.today_rounded,
                  tooltip: AppLocalizations.of(context).diaryReturnToToday,
                  onPressed: _returnToToday,
                  surface: false,
                  iconSize: 22,
                  visualSize: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCompactSlivers(
    DiaryPrototypeDay day,
    double horizontalPadding,
  ) {
    final contentPadding = EdgeInsets.symmetric(horizontal: horizontalPadding);

    return [
      SliverLayoutBuilder(
        builder: (context, constraints) {
          final calendarPadding =
              ((constraints.crossAxisExtent - DateTime.daysPerWeek * 44) / 2)
                  .clamp(0.0, horizontalPadding);
          return SliverPadding(
            padding: EdgeInsets.fromLTRB(
              calendarPadding,
              AppSpacing.xs,
              calendarPadding,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: RepaintBoundary(
                child: _ConstrainedDiaryContent(
                  child: YamEntranceReveal(
                    index: 0,
                    child: _buildDaySelector(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          AppSpacing.xs,
          horizontalPadding,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: RepaintBoundary(
            child: _ConstrainedDiaryContent(
              child: YamEntranceReveal(
                index: 1,
                replayKey: _selectedDay,
                ready: _entriesReady,
                child: _buildSummary(day),
              ),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: contentPadding.copyWith(top: AppSpacing.sm),
        sliver: SliverList.builder(
          itemCount: day.meals.length,
          itemBuilder: (context, index) {
            final meal = day.meals[index];
            final section = MealSection(
              key: ValueKey(meal.id),
              meal: meal,
              onAddFood: () => _openFoodSearch(mealId: meal.id),
              onEntryPressed: _editEntry,
              highlightedEntryId: _highlightedEntryId,
              highlightedEntryKey: _highlightedEntryKey,
            );
            return _ConstrainedDiaryContent(
              child: index < 2
                  ? YamEntranceReveal(
                      key: ValueKey('diary-reveal-${meal.id}'),
                      index: index + 2,
                      replayKey: _selectedDay,
                      ready: _entriesReady,
                      child: section,
                    )
                  : section,
            );
          },
        ),
      ),
      const SliverToBoxAdapter(
        child: SizedBox(height: AppSpacing.xxl + AppSpacing.xl),
      ),
    ];
  }

  List<Widget> _buildWideSlivers(
    DiaryPrototypeDay day,
    double horizontalPadding,
  ) {
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          AppSpacing.xs,
          horizontalPadding,
          AppSpacing.xxl + AppSpacing.xl,
        ),
        sliver: SliverToBoxAdapter(
          child: _ConstrainedDiaryContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                YamEntranceReveal(index: 0, child: _buildDaySelector()),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 360,
                      child: YamEntranceReveal(
                        index: 1,
                        replayKey: _selectedDay,
                        ready: _entriesReady,
                        child: _buildSummary(day),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: _MealList(
                        day: day,
                        replayKey: _selectedDay,
                        ready: _entriesReady,
                        onAddFood: (mealId) => _openFoodSearch(mealId: mealId),
                        onEntryPressed: _editEntry,
                        highlightedEntryId: _highlightedEntryId,
                        highlightedEntryKey: _highlightedEntryKey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildSummary(DiaryPrototypeDay day) => Hero(
    tag: _summaryHeroTag,
    flightShuttleBuilder: DailyNutritionSummary.buildFlight,
    child: Material(
      key: _summaryKey,
      type: MaterialType.transparency,
      child: Semantics(
        button: true,
        label: AppLocalizations.of(context).dayDetailsOpen,
        child: Tooltip(
          message: AppLocalizations.of(context).dayDetailsOpen,
          child: InkWell(
            key: const ValueKey('diary-day-details'),
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: _entriesReady && _goalsReady ? _openDayDetails : null,
            child: Stack(
              children: [
                DailyNutritionSummary(day: day),
                PositionedDirectional(
                  top: AppSpacing.md,
                  end: AppSpacing.md,
                  child: Icon(
                    Icons.open_in_full_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _openDayDetails() async {
    if (_detailsOpen) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
    Rect sourceRect() {
      final box = _summaryKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) return Offset.zero & overlay.size;
      return box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
    }

    final route = DayDetailsRoute(
      sourceRect: sourceRect,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
      builder: (detailsContext) => DayDetailsScreen(
        snapshot: _dayDetails,
        onRetry: _retryReads,
        today: _today,
        summaryHeroTag: _summaryHeroTag,
        onEditEntry: (entry) =>
            _editStoredEntry(entry, feedbackContext: detailsContext),
      ),
    );
    _detailsOpen = true;
    unawaited(navigator.push(route));
    await route.completed;
    _detailsOpen = false;
  }

  Widget _buildDaySelector() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: DiaryDaySelector(
          selectedDay: _selectedDay,
          today: _today,
          dayStatuses: _weekStatuses,
          onDaySelected: _selectDay,
          onCalendarPressed: _openCalendar,
        ),
      ),
    );
  }

  void _selectDay(DateTime day) {
    final selectedDay = DateTime(day.year, day.month, day.day);
    if (_isSameDay(selectedDay, _selectedDay)) return;
    setState(() {
      _selectedDay = selectedDay;
      _entriesReady = widget.repository == null;
    });
    _watchSelectedDay();
    if (_goalsError) {
      _watchCalendarGoals();
    } else if (_weekError || _visibleWeekStart != _weekStartFor(_selectedDay)) {
      _watchVisibleWeek();
    }
  }

  void _returnToToday() {
    _selectDay(_today);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _openCalendar() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(_today.year - 10),
      lastDate: DateTime(_today.year + 1, 12, 31),
    );
    if (selected != null && mounted) {
      _selectDay(selected);
    }
  }

  Future<void> _openFoodSearch({String? mealId}) async {
    final targetDay = _selectedDay;
    String? lastEntryId;
    GlobalKey? lastEntryKey;
    await context.push<void>(
      '/add-food',
      extra: FoodSearchPrototypeArguments(
        initialMealId: mealId,
        diaryDay: targetDay,
        favoriteOverrides: Set.unmodifiable(_favoriteOverrides),
        onFavoritesChanged: (overrides) {
          if (!mounted) return;
          setState(() {
            _favoriteOverrides
              ..clear()
              ..addAll(overrides);
          });
        },
        onEntryCreated: (id) {
          lastEntryId = id;
          lastEntryKey = GlobalKey();
        },
      ),
    );
    if (!mounted || lastEntryId == null || lastEntryKey == null) return;
    final stored = await widget.repository?.watchDay(targetDay).first;
    if (!mounted ||
        stored == null ||
        !stored.any((entry) => entry.id == lastEntryId)) {
      return;
    }
    final highlightedId = lastEntryId!;
    final highlightedKey = lastEntryKey!;
    setState(() {
      _highlightedEntryId = highlightedId;
      _highlightedEntryKey = highlightedKey;
    });
    _scheduleHighlightClear(highlightedId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealAddedEntry(highlightedKey);
    });
  }

  Future<void> _editEntry(DiaryPrototypeEntry displayEntry) async {
    final entry = displayEntry.storedEntry;
    if (entry != null) await _editStoredEntry(entry);
  }

  Future<void> _editStoredEntry(
    DiaryEntry entry, {
    BuildContext? feedbackContext,
  }) async {
    final repository = widget.repository;
    if (repository == null) return;
    final targetContext = feedbackContext ?? context;
    final change = await showEditDiaryEntrySheet(
      context: targetContext,
      entry: entry,
    );
    if (!mounted || !targetContext.mounted || change == null) return;
    final l10n = AppLocalizations.of(targetContext);
    try {
      if (change.delete) {
        await repository.delete(entry.id);
      } else {
        await repository.update(
          entry,
          mealId: change.mealId!,
          servingId: change.servingId!,
          amount: change.amount!,
          canonicalQuantity: change.canonicalQuantity!,
        );
      }
      if (!mounted || !targetContext.mounted) return;
      showYamUndoSnackBar(
        context: targetContext,
        message: change.delete
            ? l10n.diaryEntryDeleted(entry.food.name)
            : l10n.diaryEntryUpdated(entry.food.name),
        undoLabel: l10n.actionUndo,
        onUndo: () => unawaited(_restoreEntry(repository, entry)),
      );
    } on Object {
      if (!mounted || !targetContext.mounted) return;
      ScaffoldMessenger.of(targetContext).showSnackBar(
        SnackBar(
          content: Text(
            change.delete ? l10n.diaryDeleteFailed : l10n.diarySaveFailed,
          ),
        ),
      );
    }
  }

  Future<void> _restoreEntry(
    DiaryRepository repository,
    DiaryEntry entry,
  ) async {
    try {
      await repository.restore(entry);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).diarySaveFailed)),
      );
    }
  }

  void _scheduleHighlightClear(String entryId) {
    _highlightTimer?.cancel();
    _highlightTimer = Timer(AppMotion.diaryEntryHighlight, () {
      if (mounted && _highlightedEntryId == entryId) {
        setState(() {
          _highlightedEntryId = null;
          _highlightedEntryKey = null;
        });
      }
    });
  }

  Future<void> _revealAddedEntry(GlobalKey entryKey) async {
    if (!mounted) {
      return;
    }
    var entryContext = entryKey.currentContext;
    if (entryContext == null && _scrollController.hasClients) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppMotion.smallChange,
          curve: AppMotion.standardCurve,
        );
      }
      await WidgetsBinding.instance.endOfFrame;
      entryContext = entryKey.currentContext;
    }
    if (!mounted || entryContext == null || !entryContext.mounted) {
      return;
    }
    await Scrollable.ensureVisible(
      entryContext,
      alignment: 0.65,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.smallChange,
      curve: AppMotion.standardCurve,
    );
  }
}

class _ConstrainedDiaryContent extends StatelessWidget {
  const _ConstrainedDiaryContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppBreakpoints.maxContentWidth,
        ),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class _MealList extends StatelessWidget {
  const _MealList({
    required this.day,
    required this.replayKey,
    required this.ready,
    required this.onAddFood,
    required this.onEntryPressed,
    required this.highlightedEntryId,
    required this.highlightedEntryKey,
  });

  final DiaryPrototypeDay day;
  final Object replayKey;
  final bool ready;
  final ValueChanged<String> onAddFood;
  final ValueChanged<DiaryPrototypeEntry> onEntryPressed;
  final String? highlightedEntryId;
  final GlobalKey? highlightedEntryKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < day.meals.length; index++)
          if (index < 2)
            YamEntranceReveal(
              key: ValueKey('diary-reveal-${day.meals[index].id}'),
              index: index + 2,
              replayKey: replayKey,
              ready: ready,
              child: _buildMeal(day.meals[index]),
            )
          else
            _buildMeal(day.meals[index]),
      ],
    );
  }

  Widget _buildMeal(DiaryPrototypeMeal meal) => MealSection(
    key: ValueKey(meal.id),
    meal: meal,
    onAddFood: () => onAddFood(meal.id),
    onEntryPressed: onEntryPressed,
    highlightedEntryId: highlightedEntryId,
    highlightedEntryKey: highlightedEntryKey,
  );
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
