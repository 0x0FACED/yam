import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_breakpoints.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/feedback/yam_snack_bar.dart';
import 'package:yam/core/ui/nutrition/yam_progress_bar.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/statistics/data/statistics_repository.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';
import 'package:yam/features/statistics/presentation/widgets/statistics_charts.dart';
import 'package:yam/features/statistics/presentation/widgets/statistics_regularity_calendar.dart';
import 'package:yam/features/statistics/presentation/widgets/weight_entry_sheet.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({this.repository, this.today, super.key});

  final StatisticsRepository? repository;
  final DateTime? today;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with WidgetsBindingObserver {
  StatisticsPeriod _period = StatisticsPeriod.days30;
  late DateTime _today;
  StreamSubscription<List<GoalVersion>>? _goalsSubscription;
  StreamSubscription<List<WeightRecord>>? _weightsSubscription;
  StreamSubscription<List<NutritionDay>>? _nutritionSubscription;
  StreamSubscription<List<FrequentFood>>? _frequentSubscription;
  List<GoalVersion> _goals = const [];
  List<WeightRecord> _weights = const [];
  List<NutritionDay> _nutrition = const [];
  List<FrequentFood> _frequent = const [];
  bool _goalsReady = false;
  bool _weightsReady = false;
  bool _nutritionReady = false;
  bool _frequentReady = false;
  int _rangeEpoch = 0;
  StatisticsSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final now = widget.today ?? DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _subscribe();
  }

  @override
  void didUpdateWidget(StatisticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _goalsSubscription?.cancel();
      _weightsSubscription?.cancel();
      _goalsReady = false;
      _weightsReady = false;
      _subscribe();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || widget.today != null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (today != _today) {
      _today = today;
      _subscribePeriod();
    }
  }

  void _subscribe() {
    final repository = widget.repository;
    if (repository == null) {
      _goalsReady = _weightsReady = true;
      _goals = const [];
      _weights = const [];
      _subscribePeriod();
      return;
    }
    _goalsSubscription = repository.watchGoals().listen((goals) {
      if (!mounted) return;
      _goals = goals;
      _goalsReady = true;
      _recalculate();
    });
    _weightsSubscription = repository.watchWeights().listen((weights) {
      if (!mounted) return;
      _weights = weights;
      _weightsReady = true;
      _recalculate();
    });
    _subscribePeriod();
  }

  void _subscribePeriod() {
    _nutritionSubscription?.cancel();
    _frequentSubscription?.cancel();
    final epoch = ++_rangeEpoch;
    _nutritionReady = _frequentReady = false;
    _snapshot = null;
    final repository = widget.repository;
    if (repository == null) {
      _nutrition = const [];
      _frequent = const [];
      _nutritionReady = _frequentReady = true;
      _recalculate();
      return;
    }
    _nutritionSubscription = repository
        .watchNutrition(today: _today, period: _period)
        .listen((days) {
          if (!mounted || epoch != _rangeEpoch) return;
          _nutrition = days;
          _nutritionReady = true;
          _recalculate();
        });
    _frequentSubscription = repository
        .watchFrequentFoods(today: _today, period: _period)
        .listen((foods) {
          if (!mounted || epoch != _rangeEpoch) return;
          _frequent = foods;
          _frequentReady = true;
          _recalculate();
        });
  }

  void _recalculate() {
    if (!mounted ||
        !_goalsReady ||
        !_weightsReady ||
        !_nutritionReady ||
        !_frequentReady) {
      return;
    }
    setState(
      () => _snapshot = calculateStatistics(
        period: _period,
        today: _today,
        nutrition: _nutrition,
        goals: _goals,
        weightEntries: _weights,
        frequentFoods: _frequent,
      ),
    );
  }

  void _selectPeriod(StatisticsPeriod period) {
    if (period == _period) return;
    setState(() => _period = period);
    _subscribePeriod();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _goalsSubscription?.cancel();
    _weightsSubscription?.cancel();
    _nutritionSubscription?.cancel();
    _frequentSubscription?.cancel();
    super.dispose();
  }

  Future<void> _editWeight(WeightRecord? record) async {
    final repository = widget.repository;
    if (repository == null) return;
    final change = await showWeightEntrySheet(
      context: context,
      today: _today,
      record: record,
    );
    if (change == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    try {
      if (change.delete && record != null) {
        await repository.deleteWeight(record.id);
        if (!mounted) return;
        showYamUndoSnackBar(
          context: context,
          message: l10n.statsWeightDeleted,
          undoLabel: l10n.actionUndo,
          onUndo: () => _undoWeight(() => repository.restoreWeight(record)),
        );
      } else if (!change.delete && record == null) {
        final id = await repository.addWeight(day: change.day!, kg: change.kg!);
        if (!mounted) return;
        showYamUndoSnackBar(
          context: context,
          message: l10n.statsWeightSaved,
          undoLabel: l10n.actionUndo,
          onUndo: () => _undoWeight(() => repository.deleteWeight(id)),
        );
      } else if (!change.delete && record != null) {
        await repository.updateWeight(record, day: change.day!, kg: change.kg!);
        if (!mounted) return;
        showYamUndoSnackBar(
          context: context,
          message: l10n.statsWeightSaved,
          undoLabel: l10n.actionUndo,
          onUndo: () => _undoWeight(
            () =>
                repository.updateWeight(record, day: record.day, kg: record.kg),
          ),
        );
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.statsWeightFailed)));
      }
    }
  }

  void _undoWeight(Future<void> Function() action) {
    unawaited(() async {
      try {
        await action();
      } on Object {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).statsWeightFailed),
            ),
          );
        }
      }
    }());
  }

  String _format(num? value, {int decimals = 0}) {
    if (value == null) return '—';
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = NumberFormat.decimalPattern(locale)
      ..maximumFractionDigits = decimals;
    return formatter.format(value);
  }

  String _date(DateTime day) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return (day.year == _today.year
            ? DateFormat.MMMd(locale)
            : DateFormat.yMMMd(locale))
        .format(day);
  }

  String _fullDate(DateTime day) => DateFormat.yMMMMEEEEd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(day);

  String _calories(num value) =>
      '${_format(value)} ${AppLocalizations.of(context).unitKilocalories}';

  String _goalDifference(num value, num target, AppLocalizations l10n) {
    final difference = value - target;
    return l10n.statsGoalDifference(
      '${difference > 0 ? '+' : ''}${_calories(difference)}',
    );
  }

  Widget _calorieDetails(ChartBucket bucket) {
    final l10n = AppLocalizations.of(context);
    final daily =
        _period == StatisticsPeriod.days7 || _period == StatisticsPeriod.days30;
    final value = bucket.value;
    final target = bucket.calorieTarget;
    return StatisticsInspectionDetails(
      title: daily
          ? _fullDate(bucket.day)
          : '${_date(bucket.day)} — ${_date(bucket.endDay)}',
      lines: [
        if (value == null)
          l10n.statsNoEntry
        else ...[
          _calories(value),
          if (!daily) l10n.statsBucketAverage,
        ],
        if (!daily) l10n.statsLoggedDays(_format(bucket.days)),
        if (target == null)
          l10n.statsNoGoal
        else ...[
          daily
              ? l10n.statsGoal(_calories(target))
              : l10n.statsAverageGoal(_calories(target)),
          if (value != null) _goalDifference(value, target, l10n),
        ],
      ],
    );
  }

  Widget _regularityDetails(RegularityCell cell) {
    final l10n = AppLocalizations.of(context);
    final nutrition = cell.nutrition;
    final goal = cell.goal;
    return StatisticsInspectionDetails(
      title: _fullDate(cell.day),
      lines: [
        if (nutrition == null)
          l10n.statsNoEntry
        else ...[
          _calories(nutrition.kcal),
          l10n.statsNutritionDetails(
            _format(nutrition.protein, decimals: 1),
            _format(nutrition.fat, decimals: 1),
            _format(nutrition.carbs, decimals: 1),
          ),
        ],
        goal == null
            ? l10n.statsNoGoal
            : l10n.statsGoal(_calories(goal.calorieTarget)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final snapshot = _snapshot;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding =
                constraints.maxWidth >= AppBreakpoints.navigationRail
                ? AppSpacing.xl
                : AppSpacing.md;
            return CustomScrollView(
              key: const ValueKey('statistics-scroll-view'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding,
                    AppSpacing.md,
                    padding,
                    AppSpacing.xl,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppBreakpoints.maxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: AppSpacing.xs,
                              children: [
                                Text(
                                  l10n.statisticsTitle,
                                  style: AppTypography.screenTitle.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                if (snapshot != null)
                                  Text(
                                    _periodDates(snapshot),
                                    style: AppTypography.label.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildPeriodSelector(l10n),
                            const SizedBox(height: AppSpacing.lg),
                            if (snapshot == null)
                              Center(
                                child: Semantics(
                                  label: l10n.statsLoading,
                                  child: const CircularProgressIndicator(),
                                ),
                              )
                            else ...[
                              LayoutBuilder(
                                builder: (context, content) {
                                  final wide = content.maxWidth >= 760;
                                  final weight = _weightCard(snapshot, l10n);
                                  final calories = _caloriesCard(
                                    snapshot,
                                    l10n,
                                  );
                                  final macros = _macrosCard(snapshot, l10n);
                                  final regularity = _regularityCard(
                                    snapshot,
                                    l10n,
                                  );
                                  return wide
                                      ? Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(child: weight),
                                                const SizedBox(
                                                  width: AppSpacing.md,
                                                ),
                                                Expanded(child: calories),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.md,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(child: macros),
                                                const SizedBox(
                                                  width: AppSpacing.md,
                                                ),
                                                Expanded(child: regularity),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            weight,
                                            const SizedBox(
                                              height: AppSpacing.md,
                                            ),
                                            calories,
                                            const SizedBox(
                                              height: AppSpacing.md,
                                            ),
                                            macros,
                                            const SizedBox(
                                              height: AppSpacing.md,
                                            ),
                                            regularity,
                                          ],
                                        );
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _frequentCard(snapshot, l10n),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _periodDates(StatisticsSnapshot snapshot) {
    var start = _period.start(_today);
    if (start == null) {
      final food = snapshot.days.firstOrNull?.nutrition.day;
      final weight = snapshot.weights.firstOrNull?.day;
      if (food == null && weight == null) {
        return AppLocalizations.of(context).statsNoData;
      }
      start = food == null
          ? weight
          : weight == null || food.isBefore(weight)
          ? food
          : weight;
    }
    return '${_date(start!)} — ${_date(_today)}';
  }

  Widget _buildPeriodSelector(AppLocalizations l10n) {
    final labels = [
      l10n.statsPeriod7,
      l10n.statsPeriod30,
      l10n.statsPeriod90,
      l10n.statsPeriod365,
      l10n.statsPeriodAll,
    ];
    final theme = Theme.of(context);
    final selectedBackground = theme.brightness == Brightness.light
        ? theme.colorScheme.primary
        : theme.colorScheme.primaryContainer;
    final selectedForeground = theme.brightness == Brightness.light
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final scroll =
            constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(12) > 16;
        final children = [
          for (var i = 0; i < StatisticsPeriod.values.length; i++)
            SizedBox(
              width: scroll ? 76 : (constraints.maxWidth - AppSpacing.xxs) / 5,
              child: Semantics(
                button: true,
                selected: _period == StatisticsPeriod.values[i],
                child: Material(
                  color: _period == StatisticsPeriod.values[i]
                      ? selectedBackground
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: InkWell(
                    key: ValueKey(
                      'stats-period-${StatisticsPeriod.values[i].name}',
                    ),
                    onTap: () => _selectPeriod(StatisticsPeriod.values[i]),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: AppTypography.label.copyWith(
                            fontWeight: _period == StatisticsPeriod.values[i]
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _period == StatisticsPeriod.values[i]
                                ? selectedForeground
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ];
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxs / 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: children),
            ),
          ),
        );
      },
    );
  }

  Widget _weightCard(StatisticsSnapshot data, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final latest = data.latestRecordedWeight;
    return _StatsPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.statsWeightChart,
                  style: AppTypography.sectionTitle.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              YamTextButton(
                key: const ValueKey('stats-add-weight'),
                label: l10n.statsAddWeight,
                icon: Icons.add_rounded,
                tone: YamTextButtonTone.accent,
                onPressed: widget.repository == null
                    ? null
                    : () => _editWeight(null),
              ),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${_format(latest.kg, decimals: 1)} ${l10n.unitKilograms}',
              style: AppTypography.prominentMetric.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              l10n.statsWeightLastDate(_date(latest.day)),
              style: AppTypography.caption.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (data.weightChange case final change?)
              Text(
                l10n.statsWeightChange(
                  '${change > 0 ? '+' : ''}${_format(change, decimals: 2)}',
                ),
                style: AppTypography.label.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (data.weights.isEmpty)
            _EmptyInCard(
              title: latest == null
                  ? l10n.statsNoWeight
                  : l10n.statsNoWeightInPeriod,
              message: l10n.statsNoWeightHint,
            )
          else ...[
            StatisticsWeightChart(
              key: ValueKey('stats-weight-${_period.name}'),
              weights: data.weights,
              goal: data.latestGoal?.targetWeightKg,
              lineColor: theme.colorScheme.primary,
              goalColor: theme.colorScheme.primary.withValues(alpha: 0.55),
              gridColor: theme.colorScheme.outlineVariant,
              semanticLabel: l10n.statsWeightChart,
              dateLabelBuilder: _date,
              detailsBuilder: (entry) => StatisticsInspectionDetails(
                title: _fullDate(entry.day),
                lines: [
                  '${_format(entry.kg, decimals: 2)} ${l10n.unitKilograms}',
                ],
                action: YamTextButton(
                  label: l10n.statsEditWeight,
                  onPressed: () => _editWeight(entry),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (data.latestGoal != null)
              Text(
                l10n.statsCurrentGoal(
                  '${_format(data.latestGoal!.targetWeightKg, decimals: 1)} ${l10n.unitKilograms}',
                ),
                style: AppTypography.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _caloriesCard(StatisticsSnapshot data, AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;
    return _StatsPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xxs,
            children: [
              Text(
                l10n.statsCaloriesChart,
                style: AppTypography.sectionTitle.copyWith(
                  color: colors.onSurface,
                ),
              ),
              if (data.calorieBuckets.any(
                (bucket) => bucket.calorieTarget != null,
              ))
                StatisticsGoalLegend(
                  color: colors.primary,
                  label: l10n.statsGoalLegend,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (data.averageCalories == null)
            _EmptyInCard(title: l10n.statsNoNutrition, message: '')
          else ...[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              children: [
                Text(
                  _format(data.averageCalories),
                  style: AppTypography.prominentMetric.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  l10n.statsDailyAverage,
                  style: AppTypography.label.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (data.latestGoal != null)
              Text(
                l10n.statsCurrentGoal(
                  '${_format(data.latestGoal!.calorieTarget)} ${l10n.unitKilocalories}',
                ),
                style: AppTypography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            StatisticsCalorieChart(
              key: ValueKey('stats-calories-${_period.name}'),
              buckets: data.calorieBuckets,
              barColor: colors.brightness == Brightness.light
                  ? colors.primary
                  : colors.primaryContainer,
              overColor: AppSemanticColors.of(context).goalAbove,
              goalColor: colors.primary,
              semanticLabel: l10n.statsCaloriesChart,
              dateLabelBuilder: _date,
              detailsBuilder: _calorieDetails,
            ),
            if (_period == StatisticsPeriod.months3 ||
                _period == StatisticsPeriod.year1 ||
                _period == StatisticsPeriod.all)
              Text(
                l10n.statsBucketAverage,
                style: AppTypography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _macrosCard(StatisticsSnapshot data, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    return _StatsPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.statsAverageMacros,
            style: AppTypography.sectionTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (data.days.isEmpty)
            _EmptyInCard(title: l10n.statsNoNutrition, message: '')
          else ...[
            _MacroMetric(
              label: l10n.macroProtein,
              consumed: data.averageProtein!,
              goal: data.averageProteinTarget,
              color: semantic.protein,
            ),
            const SizedBox(height: AppSpacing.md),
            _MacroMetric(
              label: l10n.macroFat,
              consumed: data.averageFat!,
              goal: data.averageFatTarget,
              color: semantic.fat,
            ),
            const SizedBox(height: AppSpacing.md),
            _MacroMetric(
              label: l10n.macroCarbs,
              consumed: data.averageCarbs!,
              goal: data.averageCarbsTarget,
              color: semantic.carbs,
            ),
          ],
        ],
      ),
    );
  }

  Widget _regularityCard(StatisticsSnapshot data, AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);
    return _StatsPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.statsRegularity,
            style: AppTypography.sectionTitle.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (data.days.isEmpty)
            _EmptyInCard(title: l10n.statsNoNutrition, message: '')
          else ...[
            Text(
              data.goalEvaluatedDays == 0
                  ? l10n.statsNoGoalDays
                  : l10n.statsGoalDaysSummary(
                      _format(data.withinGoalDays),
                      _format(data.goalEvaluatedDays),
                      _format(data.withinGoalPercent),
                    ),
              style: AppTypography.label.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (data.heatmap.isNotEmpty) ...[
              Text(
                l10n.statsWindow(
                  _date(data.heatmap.first.day),
                  _date(data.heatmap.last.day),
                ),
                style: AppTypography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              StatisticsRegularityCalendar(
                key: ValueKey('stats-calendar-${_period.name}'),
                cells: data.heatmap,
                detailsBuilder: _regularityDetails,
                semanticLabelBuilder: (cell) =>
                    '${_fullDate(cell.day)}, ${_statusLabel(cell.status, l10n)}',
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _Legend(
                    color: semantic.goalWithin,
                    label: l10n.statsGoalWithin,
                  ),
                  _Legend(
                    color: semantic.goalBelow,
                    label: l10n.statsGoalBelow,
                  ),
                  _Legend(
                    color: semantic.goalAbove,
                    label: l10n.statsGoalAbove,
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _statusLabel(GoalDayStatus status, AppLocalizations l10n) =>
      switch (status) {
        GoalDayStatus.within => l10n.statsGoalWithin,
        GoalDayStatus.below => l10n.statsGoalBelow,
        GoalDayStatus.above => l10n.statsGoalAbove,
        GoalDayStatus.noGoal => l10n.statsNoGoal,
        GoalDayStatus.noEntry => l10n.statsNoEntry,
      };

  Widget _frequentCard(StatisticsSnapshot data, AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;
    return _StatsPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.statsFrequentFoods,
            style: AppTypography.sectionTitle.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (data.frequentlyEaten.isEmpty)
            _EmptyInCard(title: l10n.statsNoFrequent, message: '')
          else
            for (var i = 0; i < data.frequentlyEaten.length; i++) ...[
              if (i != 0) Divider(color: colors.outlineVariant),
              Builder(
                builder: (context) {
                  final food = data.frequentlyEaten[i];
                  final unit = food.unit == DiaryBaseUnit.grams
                      ? l10n.unitGrams
                      : l10n.unitMilliliters;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.productTitle.copyWith(
                                  color: colors.onSurface,
                                ),
                              ),
                              Text(
                                [
                                  if (food.brand != null) food.brand!,
                                  l10n.statsAveragePortion(
                                    _format(food.averageAmount, decimals: 1),
                                    unit,
                                  ),
                                ].join(' · '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                l10n.statsDaysWithFood(_format(food.days)),
                                style: AppTypography.label.copyWith(
                                  color: colors.primary,
                                ),
                              ),
                              Text(
                                l10n.statsPercentOfTrackedDays(
                                  _format(data.frequencyPercent(food)),
                                ),
                                textAlign: TextAlign.end,
                                style: AppTypography.caption.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
        ],
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.card),
    ),
    child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: child),
  );
}

class _MacroMetric extends StatelessWidget {
  const _MacroMetric({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
  });
  final String label;
  final double consumed;
  final double? goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final numbers = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    )..maximumFractionDigits = 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.label.copyWith(color: color),
              ),
            ),
            Text(
              '${numbers.format(consumed)}${goal == null ? '' : ' / ${numbers.format(goal)}'} ${l10n.unitGrams}',
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        if (goal != null) ...[
          const SizedBox(height: AppSpacing.xs),
          YamProgressBar(
            value: goal == 0 ? 0 : consumed / goal!,
            color: color,
            trackColor: Theme.of(context).colorScheme.surface,
            semanticValue:
                '$label ${numbers.format(consumed)} ${l10n.unitGrams}',
          ),
        ],
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const SizedBox.square(dimension: AppSpacing.xs),
      ),
      const SizedBox(width: AppSpacing.xxs),
      Text(
        label,
        style: AppTypography.caption.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _EmptyInCard extends StatelessWidget {
  const _EmptyInCard({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    child: Text(
      message.isEmpty ? title : '$title\n$message',
      textAlign: TextAlign.center,
      style: AppTypography.body.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}
