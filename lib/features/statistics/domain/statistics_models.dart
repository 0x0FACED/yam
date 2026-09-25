import 'package:yam/app/session/session_profile.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';

enum StatisticsPeriod {
  days7(7),
  days30(30),
  months3(90),
  year1(365),
  all(null);

  const StatisticsPeriod(this.days);
  final int? days;

  DateTime? start(DateTime today) => days == null
      ? null
      : DateTime(today.year, today.month, today.day - days! + 1);
}

class GoalVersion {
  const GoalVersion({
    required this.id,
    required this.day,
    required this.goal,
    required this.calorieTarget,
    required this.proteinTarget,
    required this.fatTarget,
    required this.carbsTarget,
    required this.targetWeightKg,
  });

  final String id;
  final DateTime day;
  final WeightGoal goal;
  final int calorieTarget;
  final int proteinTarget;
  final int fatTarget;
  final int carbsTarget;
  final double targetWeightKg;
}

class WeightRecord {
  const WeightRecord({required this.id, required this.day, required this.kg});

  final String id;
  final DateTime day;
  final double kg;
}

class NutritionDay {
  const NutritionDay({
    required this.day,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final DateTime day;
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;
}

class FrequentFood {
  const FrequentFood({
    required this.name,
    required this.days,
    required this.averageAmount,
    required this.unit,
    this.brand,
  });

  final String name;
  final String? brand;
  final int days;
  final double averageAmount;
  final DiaryBaseUnit unit;
}

enum GoalDayStatus { below, within, above, noGoal, noEntry }

class TrackedDay {
  const TrackedDay({required this.nutrition, required this.status});
  final NutritionDay nutrition;
  final GoalDayStatus status;
}

class RegularityCell {
  const RegularityCell({required this.day, required this.status});
  final DateTime day;
  final GoalDayStatus status;
}

class ChartBucket {
  const ChartBucket({
    required this.day,
    required this.value,
    required this.days,
  });
  final DateTime day;
  final double value;
  final int days;
}

class StatisticsSnapshot {
  const StatisticsSnapshot({
    required this.period,
    required this.today,
    required this.days,
    required this.heatmap,
    required this.weights,
    required this.latestRecordedWeight,
    required this.frequentlyEaten,
    required this.calorieBuckets,
    required this.withinGoalDays,
    required this.goalEvaluatedDays,
    required this.averageCalories,
    required this.averageProtein,
    required this.averageFat,
    required this.averageCarbs,
    required this.averageProteinTarget,
    required this.averageFatTarget,
    required this.averageCarbsTarget,
    required this.latestGoal,
  });

  final StatisticsPeriod period;
  final DateTime today;
  final List<TrackedDay> days;
  final List<RegularityCell> heatmap;
  final List<WeightRecord> weights;
  final WeightRecord? latestRecordedWeight;
  final List<FrequentFood> frequentlyEaten;
  final List<ChartBucket> calorieBuckets;
  final int withinGoalDays;
  final int goalEvaluatedDays;
  final double? averageCalories;
  final double? averageProtein;
  final double? averageFat;
  final double? averageCarbs;
  final double? averageProteinTarget;
  final double? averageFatTarget;
  final double? averageCarbsTarget;
  final GoalVersion? latestGoal;

  double? get withinGoalPercent =>
      goalEvaluatedDays == 0 ? null : withinGoalDays * 100 / goalEvaluatedDays;

  double? get averageProteinPercent =>
      averageProtein == null ||
          averageProteinTarget == null ||
          averageProteinTarget == 0
      ? null
      : averageProtein! * 100 / averageProteinTarget!;

  double? frequencyPercent(FrequentFood food) =>
      days.isEmpty ? null : food.days * 100 / days.length;

  WeightRecord? get latestWeight => weights.isEmpty ? null : weights.last;

  double? get weightChange =>
      weights.length < 2 ? null : weights.last.kg - weights.first.kg;
}

StatisticsSnapshot calculateStatistics({
  required StatisticsPeriod period,
  required DateTime today,
  required List<NutritionDay> nutrition,
  required List<GoalVersion> goals,
  required List<WeightRecord> weightEntries,
  required List<FrequentFood> frequentFoods,
}) {
  final start = period.start(today);
  final endKey = diaryDayKey(today);
  bool inRange(DateTime date) {
    final key = diaryDayKey(date);
    return key.compareTo(endKey) <= 0 &&
        (start == null || key.compareTo(diaryDayKey(start)) >= 0);
  }

  final sortedGoals = [...goals]
    ..sort((a, b) {
      final byDay = diaryDayKey(a.day).compareTo(diaryDayKey(b.day));
      return byDay != 0 ? byDay : a.id.compareTo(b.id);
    });
  final sortedNutrition = [...nutrition.where((day) => inRange(day.day))]
    ..sort((a, b) => a.day.compareTo(b.day));
  final sortedWeights = [...weightEntries.where((entry) => inRange(entry.day))]
    ..sort((a, b) {
      final byDay = a.day.compareTo(b.day);
      return byDay != 0 ? byDay : a.id.compareTo(b.id);
    });
  final weightPerDay = <String, WeightRecord>{
    for (final entry in sortedWeights) diaryDayKey(entry.day): entry,
  };
  final plottedWeights = weightPerDay.values.toList()
    ..sort((a, b) => a.day.compareTo(b.day));
  WeightRecord? latestRecordedWeight;
  for (final weight in weightEntries) {
    if (diaryDayKey(weight.day).compareTo(endKey) > 0) continue;
    final previous = latestRecordedWeight;
    if (previous == null ||
        diaryDayKey(weight.day).compareTo(diaryDayKey(previous.day)) > 0 ||
        (diaryDayKey(weight.day) == diaryDayKey(previous.day) &&
            weight.id.compareTo(previous.id) > 0)) {
      latestRecordedWeight = weight;
    }
  }

  var goalIndex = 0;
  GoalVersion? activeGoal;
  var within = 0;
  var evaluated = 0;
  var targetProtein = 0.0;
  var targetFat = 0.0;
  var targetCarbs = 0.0;
  final tracked = <TrackedDay>[];
  for (final day in sortedNutrition) {
    while (goalIndex < sortedGoals.length &&
        diaryDayKey(
              sortedGoals[goalIndex].day,
            ).compareTo(diaryDayKey(day.day)) <=
            0) {
      activeGoal = sortedGoals[goalIndex++];
    }
    GoalDayStatus status;
    if (activeGoal == null) {
      status = GoalDayStatus.noGoal;
    } else {
      final ratio = day.kcal / activeGoal.calorieTarget;
      status = ratio < 0.9
          ? GoalDayStatus.below
          : ratio > 1.1
          ? GoalDayStatus.above
          : GoalDayStatus.within;
      evaluated++;
      if (status == GoalDayStatus.within) within++;
      targetProtein += activeGoal.proteinTarget;
      targetFat += activeGoal.fatTarget;
      targetCarbs += activeGoal.carbsTarget;
    }
    tracked.add(TrackedDay(nutrition: day, status: status));
  }

  final currentGoal = [
    for (final goal in sortedGoals)
      if (diaryDayKey(goal.day).compareTo(endKey) <= 0) goal,
  ].lastOrNull;
  double? average(double Function(NutritionDay day) value) => tracked.isEmpty
      ? null
      : tracked.fold<double>(0, (sum, day) => sum + value(day.nutrition)) /
            tracked.length;

  final heatmap = <RegularityCell>[];
  if (tracked.isNotEmpty) {
    final cutoff = DateTime(today.year, today.month, today.day - 29);
    final first = start != null && start.isAfter(cutoff) ? start : cutoff;
    final statuses = {
      for (final day in tracked) diaryDayKey(day.nutrition.day): day.status,
    };
    for (
      var day = first;
      !day.isAfter(DateTime(today.year, today.month, today.day));
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      heatmap.add(
        RegularityCell(
          day: day,
          status: statuses[diaryDayKey(day)] ?? GoalDayStatus.noEntry,
        ),
      );
    }
  }

  return StatisticsSnapshot(
    period: period,
    today: today,
    days: tracked,
    heatmap: heatmap,
    weights: plottedWeights,
    latestRecordedWeight: latestRecordedWeight,
    frequentlyEaten: frequentFoods,
    calorieBuckets: bucketCalories(sortedNutrition, period),
    withinGoalDays: within,
    goalEvaluatedDays: evaluated,
    averageCalories: average((day) => day.kcal),
    averageProtein: average((day) => day.protein),
    averageFat: average((day) => day.fat),
    averageCarbs: average((day) => day.carbs),
    averageProteinTarget: evaluated != tracked.length || evaluated == 0
        ? null
        : targetProtein / evaluated,
    averageFatTarget: evaluated != tracked.length || evaluated == 0
        ? null
        : targetFat / evaluated,
    averageCarbsTarget: evaluated != tracked.length || evaluated == 0
        ? null
        : targetCarbs / evaluated,
    latestGoal: currentGoal,
  );
}

List<ChartBucket> bucketCalories(
  List<NutritionDay> days,
  StatisticsPeriod period,
) {
  if (period == StatisticsPeriod.days7 || period == StatisticsPeriod.days30) {
    return [
      for (final day in days)
        ChartBucket(day: day.day, value: day.kcal, days: 1),
    ];
  }
  DateTime bucketStart(DateTime date) => period == StatisticsPeriod.months3
      ? DateTime(date.year, date.month, date.day - (date.weekday - 1))
      : DateTime(date.year, date.month);
  final groups = <String, (DateTime, double, int)>{};
  for (final day in days) {
    final start = bucketStart(day.day);
    final key = diaryDayKey(start);
    final current = groups[key];
    groups[key] = (
      start,
      (current?.$2 ?? 0) + day.kcal,
      (current?.$3 ?? 0) + 1,
    );
  }
  return [
    for (final group in groups.values)
      ChartBucket(day: group.$1, value: group.$2 / group.$3, days: group.$3),
  ];
}
