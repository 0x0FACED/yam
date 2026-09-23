import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yam/app/theme/app_breakpoints.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/features/diary/presentation/diary_prototype_data.dart';
import 'package:yam/features/diary/presentation/widgets/daily_nutrition_summary.dart';
import 'package:yam/features/diary/presentation/widgets/diary_day_selector.dart';
import 'package:yam/features/diary/presentation/widgets/meal_section.dart';
import 'package:yam/features/food_search/presentation/food_search_meals.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({this.today, super.key});

  final DateTime? today;

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _scrollController = ScrollController();
  final Map<DateTime, Map<String, List<DiaryPrototypeEntry>>>
  _prototypeAdditions = {};
  final List<({String entryId, String foodId})> _recentFoodAdditions = [];

  late final DateTime _today;
  late DateTime _selectedDay;
  Timer? _highlightTimer;
  String? _highlightedEntryId;
  GlobalKey? _highlightedEntryKey;
  var _nextPrototypeEntryId = 0;

  @override
  void initState() {
    super.initState();
    final now = widget.today ?? DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _selectedDay = _today;
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final day = buildDiaryPrototypeDay(
      l10n,
      includeEntries: _isSameDay(_selectedDay, _today),
      additionalEntries: _prototypeAdditions[_selectedDay] ?? const {},
    );

    return Scaffold(
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

            return ScrollConfiguration(
              behavior: const MaterialScrollBehavior(),
              child: CustomScrollView(
                key: const ValueKey('diary-scroll-view'),
                controller: _scrollController,
                slivers: [
                  _buildHeaderSliver(horizontalPadding),
                  if (constraints.maxWidth >= AppBreakpoints.wideDiary)
                    ..._buildWideSlivers(day, horizontalPadding)
                  else
                    ..._buildCompactSlivers(day, horizontalPadding),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

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
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          AppSpacing.xs,
          horizontalPadding,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: RepaintBoundary(
            child: _ConstrainedDiaryContent(child: _buildDaySelector()),
          ),
        ),
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
              child: DailyNutritionSummary(day: day),
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
            return _ConstrainedDiaryContent(
              child: MealSection(
                key: ValueKey(meal.id),
                meal: meal,
                onAddFood: () => _openFoodSearch(mealId: meal.id),
                onEntryPressed: _previewEntrySelection,
                highlightedEntryId: _highlightedEntryId,
                highlightedEntryKey: _highlightedEntryKey,
              ),
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
                _buildDaySelector(),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 360,
                      child: DailyNutritionSummary(day: day),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: _MealList(
                        day: day,
                        onAddFood: (mealId) => _openFoodSearch(mealId: mealId),
                        onEntryPressed: _previewEntrySelection,
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

  Widget _buildDaySelector() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: DiaryDaySelector(
          selectedDay: _selectedDay,
          today: _today,
          onDaySelected: _selectDay,
          onCalendarPressed: _openCalendar,
        ),
      ),
    );
  }

  void _selectDay(DateTime day) {
    setState(() => _selectedDay = DateTime(day.year, day.month, day.day));
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
    final recentFoodIds = <String>[];
    for (final addition in _recentFoodAdditions.reversed) {
      if (!recentFoodIds.contains(addition.foodId)) {
        recentFoodIds.add(addition.foodId);
        if (recentFoodIds.length == foodSearchRecentLimit) break;
      }
    }
    final result = await context.push<FoodAddPrototypeResult>(
      '/add-food',
      extra: FoodSearchPrototypeArguments(
        initialMealId: mealId,
        recentFoodIds: recentFoodIds,
      ),
    );
    if (!mounted || result == null) {
      return;
    }

    final entryId = 'prototype-addition-${_nextPrototypeEntryId++}';
    final entry = DiaryPrototypeEntry(
      id: entryId,
      name: result.name,
      brand: result.brand,
      quantity: result.quantityLabel,
      calories: result.calories,
      protein: result.protein,
      fat: result.fat,
      carbs: result.carbs,
    );
    final entryKey = GlobalKey();

    setState(() {
      final additionsForDay = Map<String, List<DiaryPrototypeEntry>>.from(
        _prototypeAdditions[targetDay] ?? const {},
      );
      additionsForDay[result.mealId] = [
        ...(additionsForDay[result.mealId] ?? const []),
        entry,
      ];
      _prototypeAdditions[targetDay] = additionsForDay;
      _recentFoodAdditions.add((entryId: entryId, foodId: result.foodId));
      _highlightedEntryId = entryId;
      _highlightedEntryKey = entryKey;
    });

    _scheduleHighlightClear(entryId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealAddedEntry(entryKey);
    });

    final l10n = AppLocalizations.of(context);
    showYamUndoSnackBar(
      context: context,
      message: l10n.foodAdded(
        result.name,
        foodSearchPrototypeMealName(l10n, result.mealId),
      ),
      undoLabel: l10n.actionUndo,
      onUndo: () => _undoPrototypeAddition(
        day: targetDay,
        mealId: result.mealId,
        entryId: entryId,
      ),
    );
  }

  void _previewEntrySelection(DiaryPrototypeEntry entry) {
    setState(() {
      _highlightedEntryId = entry.id;
      _highlightedEntryKey = null;
    });
    _scheduleHighlightClear(entry.id);
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

  void _undoPrototypeAddition({
    required DateTime day,
    required String mealId,
    required String entryId,
  }) {
    setState(() {
      final additionsForDay = Map<String, List<DiaryPrototypeEntry>>.from(
        _prototypeAdditions[day] ?? const {},
      );
      additionsForDay[mealId] = [
        for (final entry in additionsForDay[mealId] ?? const [])
          if (entry.id != entryId) entry,
      ];
      _prototypeAdditions[day] = additionsForDay;
      _recentFoodAdditions.removeWhere(
        (addition) => addition.entryId == entryId,
      );
      if (_highlightedEntryId == entryId) {
        _highlightedEntryId = null;
        _highlightedEntryKey = null;
      }
    });
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
    required this.onAddFood,
    required this.onEntryPressed,
    required this.highlightedEntryId,
    required this.highlightedEntryKey,
  });

  final DiaryPrototypeDay day;
  final ValueChanged<String> onAddFood;
  final ValueChanged<DiaryPrototypeEntry> onEntryPressed;
  final String? highlightedEntryId;
  final GlobalKey? highlightedEntryKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final meal in day.meals)
          MealSection(
            key: ValueKey(meal.id),
            meal: meal,
            onAddFood: () => onAddFood(meal.id),
            onEntryPressed: onEntryPressed,
            highlightedEntryId: highlightedEntryId,
            highlightedEntryKey: highlightedEntryKey,
          ),
      ],
    );
  }
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
