import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';

enum DayDetailsMetric { calories, protein, fat, carbs }

class DayDetailsSnapshot {
  factory DayDetailsSnapshot({
    required DateTime day,
    required List<DiaryEntry> entries,
    required List<GoalVersion> goals,
  }) {
    final dayEntries = List<DiaryEntry>.unmodifiable(entries);
    final totals = _sumNutrition(dayEntries);
    final entriesByMeal = <String, List<DiaryEntry>>{};
    var estimatedCount = 0;
    for (final entry in dayEntries) {
      (entriesByMeal[entry.mealId] ??= []).add(entry);
      if (entry.isEstimated) estimatedCount++;
    }
    final meals = <DayDetailsMeal>[];
    DayDetailsMeal? largestMeal;
    for (final mealId in diaryMealIds) {
      final mealEntries = entriesByMeal[mealId];
      if (mealEntries == null) continue;
      final mealTotals = _sumNutrition(mealEntries);
      final meal = DayDetailsMeal._(
        id: mealId,
        entries: List<DiaryEntry>.unmodifiable(mealEntries),
        totals: mealTotals,
        calorieShare: totals.kcal == 0 ? null : mealTotals.kcal / totals.kcal,
      );
      meals.add(meal);
      if (largestMeal == null || mealTotals.kcal > largestMeal.totals.kcal) {
        largestMeal = meal;
      }
    }
    final rankings = <List<DayDetailsContribution>>[];
    for (final metric in DayDetailsMetric.values) {
      final total = _metricValue(totals, metric);
      final ranked = <(int, DayDetailsContribution)>[];
      for (var index = 0; index < dayEntries.length; index++) {
        final entry = dayEntries[index];
        final value = _metricValue(entry.nutrition, metric);
        ranked.add((
          index,
          DayDetailsContribution._(
            entry: entry,
            value: value,
            share: total == 0 ? null : value / total,
          ),
        ));
      }
      ranked.sort((a, b) {
        final byValue = b.$2.value.compareTo(a.$2.value);
        return byValue != 0 ? byValue : a.$1.compareTo(b.$1);
      });
      rankings.add(
        List<DayDetailsContribution>.unmodifiable(
          ranked.map((item) => item.$2),
        ),
      );
    }
    return DayDetailsSnapshot._(
      day: DateTime(day.year, day.month, day.day),
      entries: dayEntries,
      totals: totals,
      goal: _goalForDay(day, goals),
      meals: List<DayDetailsMeal>.unmodifiable(meals),
      estimatedCount: estimatedCount,
      largestMeal: largestMeal,
      rankings: rankings,
    );
  }

  const DayDetailsSnapshot._({
    required this.day,
    required this.entries,
    required this.totals,
    required this.goal,
    required this.meals,
    required this.estimatedCount,
    required DayDetailsMeal? largestMeal,
    required List<List<DayDetailsContribution>> rankings,
  }) : _largestMeal = largestMeal,
       _rankings = rankings;

  final DateTime day;
  final List<DiaryEntry> entries;
  final DiaryNutrition totals;
  final GoalVersion? goal;
  final List<DayDetailsMeal> meals;
  final int estimatedCount;
  final DayDetailsMeal? _largestMeal;
  final List<List<DayDetailsContribution>> _rankings;

  DayDetailsMeal? get largestMeal => _largestMeal;

  List<DayDetailsContribution> contributions(DayDetailsMetric metric) =>
      _rankings[metric.index];
}

class DayDetailsMeal {
  const DayDetailsMeal._({
    required this.id,
    required this.entries,
    required this.totals,
    required this.calorieShare,
  });

  final String id;
  final List<DiaryEntry> entries;
  final DiaryNutrition totals;
  final double? calorieShare;
}

class DayDetailsContribution {
  const DayDetailsContribution._({
    required this.entry,
    required this.value,
    required this.share,
  });

  final DiaryEntry entry;
  final double value;
  final double? share;
}

DiaryNutrition _sumNutrition(List<DiaryEntry> entries) {
  var kcal = 0.0;
  var protein = 0.0;
  var fat = 0.0;
  var carbs = 0.0;
  for (final entry in entries) {
    kcal += entry.nutrition.kcal;
    protein += entry.nutrition.protein;
    fat += entry.nutrition.fat;
    carbs += entry.nutrition.carbs;
  }
  return DiaryNutrition(kcal: kcal, protein: protein, fat: fat, carbs: carbs);
}

double _metricValue(DiaryNutrition nutrition, DayDetailsMetric metric) =>
    switch (metric) {
      DayDetailsMetric.calories => nutrition.kcal,
      DayDetailsMetric.protein => nutrition.protein,
      DayDetailsMetric.fat => nutrition.fat,
      DayDetailsMetric.carbs => nutrition.carbs,
    };

GoalVersion? _goalForDay(DateTime day, List<GoalVersion> goals) {
  final dayKey = diaryDayKey(day);
  GoalVersion? activeGoal;
  String? activeKey;
  for (final goal in goals) {
    final key = diaryDayKey(goal.day);
    if (key.compareTo(dayKey) > 0) continue;
    if (activeGoal == null ||
        key.compareTo(activeKey!) > 0 ||
        (key == activeKey && goal.id.compareTo(activeGoal.id) > 0)) {
      activeGoal = goal;
      activeKey = key;
    }
  }
  return activeGoal;
}
