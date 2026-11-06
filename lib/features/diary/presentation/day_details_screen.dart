import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_breakpoints.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/core/ui/nutrition/yam_progress_bar.dart';
import 'package:yam/core/ui/selection/yam_selection_controls.dart';
import 'package:yam/features/diary/domain/day_details.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/diary/presentation/diary_prototype_data.dart';
import 'package:yam/features/diary/presentation/widgets/daily_nutrition_summary.dart';
import 'package:yam/features/food_search/presentation/food_search_format.dart';
import 'package:yam/features/food_search/presentation/food_search_prototype_data.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class DayDetailsScreen extends StatefulWidget {
  const DayDetailsScreen({
    required this.snapshot,
    required this.today,
    required this.onEditEntry,
    required this.summaryHeroTag,
    super.key,
  });

  final ValueListenable<DayDetailsSnapshot> snapshot;
  final DateTime today;
  final Future<void> Function(DiaryEntry) onEditEntry;
  final Object summaryHeroTag;

  @override
  State<DayDetailsScreen> createState() => _DayDetailsScreenState();
}

class _DayDetailsScreenState extends State<DayDetailsScreen> {
  final _overviewScroll = ScrollController();
  final _foodScrollController = ScrollController();
  Locale? _locale;
  late _DayDisplay _display;
  bool _byContribution = false;
  DayDetailsMetric _metric = DayDetailsMetric.calories;

  @override
  void initState() {
    super.initState();
    widget.snapshot.addListener(_snapshotChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_locale != locale) {
      _locale = locale;
      _prepareDisplay();
    }
  }

  @override
  void didUpdateWidget(DayDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshot != widget.snapshot) {
      oldWidget.snapshot.removeListener(_snapshotChanged);
      widget.snapshot.addListener(_snapshotChanged);
    }
    if (oldWidget.snapshot != widget.snapshot ||
        oldWidget.today != widget.today) {
      _prepareDisplay();
    }
  }

  void _snapshotChanged() {
    if (!mounted || _locale == null) return;
    setState(_prepareDisplay);
  }

  void _prepareDisplay() {
    if (_locale == null) return;
    _display = _DayDisplay.prepare(
      context,
      widget.snapshot.value,
      widget.today,
    );
  }

  @override
  void dispose() {
    widget.snapshot.removeListener(_snapshotChanged);
    _overviewScroll.dispose();
    _foodScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.xs,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                l10n.dayDetailsTitle,
                                style: AppTypography.screenTitle,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              _display.date,
                              style: AppTypography.body.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (_display.isToday) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                l10n.dayDetailsSoFar,
                                style: AppTypography.label.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      YamIconButton(
                        key: const ValueKey('day-details-close'),
                        icon: Icons.close_rounded,
                        tooltip: l10n.actionClose,
                        onPressed: () => Navigator.of(context).pop(),
                        surface: false,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < AppBreakpoints.wideDiary) {
                        return _foodScroll(includeOverview: true);
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              controller: _overviewScroll,
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: _overview(),
                            ),
                          ),
                          Expanded(flex: 6, child: _foodScroll()),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _overview({bool includeFacts = true}) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Hero(
          tag: widget.summaryHeroTag,
          flightShuttleBuilder: DailyNutritionSummary.buildFlight,
          child: Material(
            type: MaterialType.transparency,
            child: DailyNutritionSummary(day: _display.summary),
          ),
        ),
        if (_display.meals.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(l10n.dayDetailsDistribution),
          const SizedBox(height: AppSpacing.sm),
          for (final meal in _display.meals) _MealDistribution(meal: meal),
          if (includeFacts && _display.facts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle(l10n.dayDetailsFacts),
            const SizedBox(height: AppSpacing.xs),
            for (final fact in _display.facts)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(fact, style: AppTypography.body),
              ),
          ],
        ],
      ],
    );
  }

  Widget _foodScroll({bool includeOverview = false}) {
    final l10n = AppLocalizations.of(context);
    final rows = _byContribution
        ? _display.contributions[_metric]!
        : _display.grouped;
    final indices = _byContribution
        ? _display.contributionIndices[_metric]!
        : _display.groupedIndices;
    return CustomScrollView(
      key: const PageStorageKey('day-details-food-scroll'),
      controller: _foodScrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (includeOverview) ...[
                  _overview(includeFacts: false),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (_display.meals.isNotEmpty) ...[
                  _SectionTitle(l10n.dayDetailsFood),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xxs,
                    children: [
                      IntrinsicWidth(
                        child: YamFilterChip(
                          key: const ValueKey('day-details-mode-meal'),
                          label: l10n.dayDetailsByMeal,
                          selected: !_byContribution,
                          onPressed: () =>
                              setState(() => _byContribution = false),
                        ),
                      ),
                      IntrinsicWidth(
                        child: YamFilterChip(
                          key: const ValueKey('day-details-mode-contribution'),
                          label: l10n.dayDetailsByContribution,
                          selected: _byContribution,
                          onPressed: () =>
                              setState(() => _byContribution = true),
                        ),
                      ),
                    ],
                  ),
                  if (_byContribution) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        for (final metric in DayDetailsMetric.values)
                          IntrinsicWidth(
                            child: YamFilterChip(
                              key: ValueKey(
                                'day-details-metric-${metric.name}',
                              ),
                              label: _display.metricLabels[metric]!,
                              selected: _metric == metric,
                              onPressed: () => setState(() => _metric = metric),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.dayDetailsContributionHint,
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ] else ...[
                  const SizedBox(height: AppSpacing.lg),
                  Icon(
                    Icons.restaurant_rounded,
                    size: AppSpacing.xl,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.dayDetailsEmptyTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.sectionTitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.dayDetailsEmptyBody,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final row = rows[index];
                if (row is _MealDisplay) {
                  return _MealHeading(key: ValueKey(row.id), meal: row);
                }
                final food = row as _EntryDisplay;
                return Column(
                  key: ValueKey(food.id),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EntryRow(
                      food: food,
                      onPressed: () async {
                        await widget.onEditEntry(food.entry);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ],
                );
              },
              childCount: rows.length,
              findChildIndexCallback: (key) =>
                  key is ValueKey<String> ? indices[key.value] : null,
            ),
          ),
        ),
        if (includeOverview && _display.meals.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionTitle(l10n.dayDetailsFacts),
                  const SizedBox(height: AppSpacing.xs),
                  for (final fact in _display.facts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(fact, style: AppTypography.body),
                    ),
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: AppTypography.sectionTitle),
  );
}

class _MealDistribution extends StatelessWidget {
  const _MealDistribution({required this.meal});

  final _MealDisplay meal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(meal.name, style: AppTypography.productTitle),
          const SizedBox(height: AppSpacing.xxs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xxs,
            children: [
              Text(meal.nutrition.calories, style: AppTypography.label),
              Text(
                meal.shareLabel,
                style: AppTypography.label.copyWith(
                  color: colors.onSurfaceVariant,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
            ],
          ),
          if (meal.share != null) ...[
            const SizedBox(height: AppSpacing.xs),
            YamProgressBar(
              value: meal.share!,
              color: colors.primary,
              trackColor: colors.surfaceContainer,
              semanticValue: '${meal.name}, ${meal.shareLabel}',
            ),
          ],
        ],
      ),
    );
  }
}

class _MealHeading extends StatelessWidget {
  const _MealHeading({required this.meal, super.key});

  final _MealDisplay meal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(meal.name, style: AppTypography.screenTitle),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xxs,
                children: [
                  Text(
                    meal.nutrition.calories,
                    style: AppTypography.productTitle.copyWith(
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                  Text(
                    meal.shareLabel,
                    style: AppTypography.label.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              _MacroLabels(nutrition: meal.nutrition),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.food, required this.onPressed});

  final _EntryDisplay food;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = AppSemanticColors.of(context);
    final valueColor = switch (food.metric) {
      DayDetailsMetric.protein => semantic.protein,
      DayDetailsMetric.fat => semantic.fat,
      DayDetailsMetric.carbs => semantic.carbs,
      DayDetailsMetric.calories || null => colors.onSurface,
    };
    return Semantics(
      button: true,
      label: food.semanticLabel,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(food.entry.food.name, style: AppTypography.productTitle),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    food.details,
                    style: AppTypography.caption.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        food.contributionValue ?? food.nutrition.calories,
                        style: AppTypography.productTitle.copyWith(
                          color: valueColor,
                          fontWeight: FontWeight.w700,
                          fontFeatures: AppTypography.tabularFigures,
                        ),
                      ),
                      if (food.shareLabel != null)
                        Text(
                          food.shareLabel!,
                          style: AppTypography.label.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  if (food.metric != null &&
                      food.metric != DayDetailsMetric.calories) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      food.nutrition.calories,
                      style: AppTypography.label.copyWith(
                        color: colors.onSurfaceVariant,
                        fontFeatures: AppTypography.tabularFigures,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  _MacroLabels(nutrition: food.nutrition),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroLabels extends StatelessWidget {
  const _MacroLabels({required this.nutrition});

  final _NutritionDisplay nutrition;

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.of(context);
    return Semantics(
      label: nutrition.semanticLabel,
      child: ExcludeSemantics(
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xxs,
          children: [
            Text(
              nutrition.protein,
              style: AppTypography.label.copyWith(
                color: colors.protein,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
            Text(
              nutrition.fat,
              style: AppTypography.label.copyWith(
                color: colors.fat,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
            Text(
              nutrition.carbs,
              style: AppTypography.label.copyWith(
                color: colors.carbs,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

sealed class _DetailsRow {
  const _DetailsRow(this.id);

  final String id;
}

class _MealDisplay extends _DetailsRow {
  const _MealDisplay({
    required String id,
    required this.name,
    required this.nutrition,
    required this.share,
    required this.shareLabel,
  }) : super('meal-$id');

  final String name;
  final _NutritionDisplay nutrition;
  final double? share;
  final String shareLabel;
}

class _EntryDisplay extends _DetailsRow {
  _EntryDisplay({
    required this.entry,
    required this.details,
    required this.nutrition,
    required this.semanticLabel,
    this.metric,
    this.contributionValue,
    this.shareLabel,
  }) : super('day-details-entry-${entry.id}');

  final DiaryEntry entry;
  final String details;
  final _NutritionDisplay nutrition;
  final String semanticLabel;
  final DayDetailsMetric? metric;
  final String? contributionValue;
  final String? shareLabel;
}

class _NutritionDisplay {
  const _NutritionDisplay({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.semanticLabel,
  });

  factory _NutritionDisplay.prepare(
    DiaryNutrition nutrition,
    AppLocalizations l10n,
    NumberFormat numbers,
  ) {
    final protein = '${numbers.format(nutrition.protein)} ${l10n.unitGrams}';
    final fat = '${numbers.format(nutrition.fat)} ${l10n.unitGrams}';
    final carbs = '${numbers.format(nutrition.carbs)} ${l10n.unitGrams}';
    final calories = l10n.mealCalories(numbers.format(nutrition.kcal));
    return _NutritionDisplay(
      calories: calories,
      protein: '${l10n.macroProteinShort} $protein',
      fat: '${l10n.macroFatShort} $fat',
      carbs: '${l10n.macroCarbsShort} $carbs',
      semanticLabel:
          '$calories, ${l10n.macroProtein} $protein, '
          '${l10n.macroFat} $fat, ${l10n.macroCarbs} $carbs',
    );
  }

  final String calories;
  final String protein;
  final String fat;
  final String carbs;
  final String semanticLabel;
}

class _DayDisplay {
  const _DayDisplay({
    required this.date,
    required this.isToday,
    required this.summary,
    required this.meals,
    required this.grouped,
    required this.groupedIndices,
    required this.contributions,
    required this.contributionIndices,
    required this.metricLabels,
    required this.facts,
  });

  factory _DayDisplay.prepare(
    BuildContext context,
    DayDetailsSnapshot snapshot,
    DateTime today,
  ) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final numbers = NumberFormat.decimalPattern(locale)
      ..maximumFractionDigits = 1;
    final percentages = NumberFormat.percentPattern(locale)
      ..maximumFractionDigits = 1;
    final metricLabels = {
      DayDetailsMetric.calories: l10n.dayDetailsCalories,
      DayDetailsMetric.protein: l10n.macroProtein,
      DayDetailsMetric.fat: l10n.macroFat,
      DayDetailsMetric.carbs: l10n.macroCarbs,
    };
    String mealName(String id) => switch (id) {
      'breakfast' => l10n.mealBreakfast,
      'lunch' => l10n.mealLunch,
      'dinner' => l10n.mealDinner,
      'snacks' => l10n.mealSnacks,
      _ => id,
    };
    String shareLabel(double? share) => share == null
        ? l10n.dayDetailsNoShare
        : l10n.dayDetailsShare(percentages.format(share));
    final foods = <String, _EntryDisplay>{};
    final prototypeEntries = <String, DiaryPrototypeEntry>{};
    for (final entry in snapshot.entries) {
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
      final brand = entry.food.brand;
      final details = [
        quantity,
        if (brand != null && brand.isNotEmpty) brand,
        if (entry.isEstimated) l10n.assistantEstimatedLabel,
      ].join(' · ');
      final nutrition = _NutritionDisplay.prepare(
        entry.nutrition,
        l10n,
        numbers,
      );
      foods[entry.id] = _EntryDisplay(
        entry: entry,
        details: details,
        nutrition: nutrition,
        semanticLabel:
            '${entry.food.name}, $details, ${nutrition.semanticLabel}, '
            '${l10n.diaryEditEntry}',
      );
      prototypeEntries[entry.id] = DiaryPrototypeEntry(
        id: entry.id,
        name: entry.food.name,
        brand: brand,
        quantity: quantity,
        calories: entry.nutrition.kcal.round(),
        exactCalories: entry.nutrition.kcal,
        protein: entry.nutrition.protein,
        fat: entry.nutrition.fat,
        carbs: entry.nutrition.carbs,
        storedEntry: entry,
      );
    }
    final meals = <_MealDisplay>[];
    final grouped = <_DetailsRow>[];
    final prototypeMeals = <DiaryPrototypeMeal>[];
    for (final meal in snapshot.meals) {
      final display = _MealDisplay(
        id: meal.id,
        name: mealName(meal.id),
        nutrition: _NutritionDisplay.prepare(meal.totals, l10n, numbers),
        share: meal.calorieShare,
        shareLabel: shareLabel(meal.calorieShare),
      );
      meals.add(display);
      grouped.add(display);
      for (final entry in meal.entries) {
        grouped.add(foods[entry.id]!);
      }
      prototypeMeals.add(
        DiaryPrototypeMeal(
          id: meal.id,
          name: display.name,
          entries: [
            for (final entry in meal.entries) prototypeEntries[entry.id]!,
          ],
        ),
      );
    }
    final contributions = <DayDetailsMetric, List<_EntryDisplay>>{};
    for (final metric in DayDetailsMetric.values) {
      final ranked = <_EntryDisplay>[];
      for (final contribution in snapshot.contributions(metric)) {
        final food = foods[contribution.entry.id]!;
        final value = metric == DayDetailsMetric.calories
            ? l10n.mealCalories(numbers.format(contribution.value))
            : '${metricLabels[metric]} '
                  '${numbers.format(contribution.value)} ${l10n.unitGrams}';
        final share = shareLabel(contribution.share);
        ranked.add(
          _EntryDisplay(
            entry: food.entry,
            details: '${mealName(food.entry.mealId)} · ${food.details}',
            nutrition: food.nutrition,
            semanticLabel:
                '${food.entry.food.name}, '
                '${mealName(food.entry.mealId)}, ${food.details}, '
                '$value, $share, ${food.nutrition.semanticLabel}, '
                '${l10n.diaryEditEntry}',
            metric: metric,
            contributionValue: value,
            shareLabel: share,
          ),
        );
      }
      contributions[metric] = ranked;
    }
    final goal = snapshot.goal;
    final largest = snapshot.largestMeal;
    final remainingProtein = goal == null
        ? null
        : goal.proteinTarget - snapshot.totals.protein;
    final facts = [
      if (largest != null)
        l10n.dayDetailsLargestMeal(
          mealName(largest.id),
          numbers.format(largest.totals.kcal),
        ),
      if (remainingProtein != null && remainingProtein > 0)
        l10n.dayDetailsProteinRemaining(numbers.format(remainingProtein)),
      if (snapshot.estimatedCount > 0)
        l10n.dayDetailsEstimatedCount(snapshot.estimatedCount),
    ];
    return _DayDisplay(
      date: DateFormat.yMMMMEEEEd(locale).format(snapshot.day),
      isToday:
          snapshot.day.year == today.year &&
          snapshot.day.month == today.month &&
          snapshot.day.day == today.day,
      summary: DiaryPrototypeDay(
        calorieTarget: goal?.calorieTarget,
        proteinTarget: goal?.proteinTarget,
        fatTarget: goal?.fatTarget,
        carbsTarget: goal?.carbsTarget,
        meals: prototypeMeals,
      ),
      meals: meals,
      grouped: grouped,
      groupedIndices: {
        for (var index = 0; index < grouped.length; index++)
          grouped[index].id: index,
      },
      contributions: contributions,
      contributionIndices: {
        for (final metric in DayDetailsMetric.values)
          metric: {
            for (var index = 0; index < contributions[metric]!.length; index++)
              contributions[metric]![index].id: index,
          },
      },
      metricLabels: metricLabels,
      facts: facts,
    );
  }

  final String date;
  final bool isToday;
  final DiaryPrototypeDay summary;
  final List<_MealDisplay> meals;
  final List<_DetailsRow> grouped;
  final Map<String, int> groupedIndices;
  final Map<DayDetailsMetric, List<_EntryDisplay>> contributions;
  final Map<DayDetailsMetric, Map<String, int>> contributionIndices;
  final Map<DayDetailsMetric, String> metricLabels;
  final List<String> facts;
}
