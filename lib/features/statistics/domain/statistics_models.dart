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

GoalDayStatus calorieGoalDayStatus({
  required double? kcal,
  required int? calorieTarget,
}) {
  if (kcal == null) return GoalDayStatus.noEntry;
  if (calorieTarget == null) return GoalDayStatus.noGoal;
  final ratio = kcal / calorieTarget;
  return ratio < 0.9
      ? GoalDayStatus.below
      : ratio > 1.1
      ? GoalDayStatus.above
      : GoalDayStatus.within;
}

Map<DateTime, GoalDayStatus> calculateGoalDayStatuses({
  required DateTime start,
  required DateTime end,
  required List<NutritionDay> nutrition,
  required List<GoalVersion> goals,
}) {
  final sortedGoals = [...goals]..sort(_compareGoals);
  final caloriesByDay = {
    for (final day in nutrition) diaryDayKey(day.day): day.kcal,
  };
  final statuses = <DateTime, GoalDayStatus>{};
  var goalIndex = 0;
  GoalVersion? activeGoal;
  final lastDay = DateTime(end.year, end.month, end.day);
  for (
    var day = DateTime(start.year, start.month, start.day);
    !day.isAfter(lastDay);
    day = DateTime(day.year, day.month, day.day + 1)
  ) {
    final key = diaryDayKey(day);
    while (goalIndex < sortedGoals.length &&
        diaryDayKey(sortedGoals[goalIndex].day).compareTo(key) <= 0) {
      activeGoal = sortedGoals[goalIndex++];
    }
    statuses[day] = calorieGoalDayStatus(
      kcal: caloriesByDay[key],
      calorieTarget: activeGoal?.calorieTarget,
    );
  }
  return statuses;
}

int _compareGoals(GoalVersion a, GoalVersion b) {
  final byDay = diaryDayKey(a.day).compareTo(diaryDayKey(b.day));
  return byDay != 0 ? byDay : a.id.compareTo(b.id);
}

class TrackedDay {
  const TrackedDay({required this.nutrition, required this.status});
  final NutritionDay nutrition;
  final GoalDayStatus status;
}

class RegularityCell {
  const RegularityCell({
    required this.day,
    required this.status,
    required this.nutrition,
    required this.goal,
  });
  final DateTime day;
  final GoalDayStatus status;
  final NutritionDay? nutrition;
  final GoalVersion? goal;
}

class ChartBucket {
  const ChartBucket({
    required this.day,
    required this.endDay,
    required this.value,
    required this.days,
    required this.calorieTarget,
  });
  final DateTime day;
  final DateTime endDay;
  final double? value;
  final int days;
  final double? calorieTarget;
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

  final sortedGoals = [...goals]..sort(_compareGoals);
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
    final status = calorieGoalDayStatus(
      kcal: day.kcal,
      calorieTarget: activeGoal?.calorieTarget,
    );
    if (activeGoal != null) {
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

  var chartStart = start;
  if (chartStart == null) {
    final firstNutrition = sortedNutrition.firstOrNull?.day;
    final firstWeight = plottedWeights.firstOrNull?.day;
    final first = firstNutrition == null
        ? firstWeight
        : firstWeight == null || firstNutrition.isBefore(firstWeight)
        ? firstNutrition
        : firstWeight;
    if (first != null) {
      chartStart = DateTime(first.year, first.month, first.day);
    }
  }

  final heatmap = <RegularityCell>[];
  if (tracked.isNotEmpty) {
    final cutoff = DateTime(today.year, today.month, today.day - 29);
    final first = chartStart != null && chartStart.isAfter(cutoff)
        ? chartStart
        : cutoff;
    final nutritionByDay = {
      for (final day in sortedNutrition) diaryDayKey(day.day): day,
    };
    var heatmapGoalIndex = 0;
    GoalVersion? heatmapGoal;
    for (
      var day = first;
      !day.isAfter(DateTime(today.year, today.month, today.day));
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      final key = diaryDayKey(day);
      while (heatmapGoalIndex < sortedGoals.length &&
          diaryDayKey(sortedGoals[heatmapGoalIndex].day).compareTo(key) <= 0) {
        heatmapGoal = sortedGoals[heatmapGoalIndex++];
      }
      final nutrition = nutritionByDay[key];
      heatmap.add(
        RegularityCell(
          day: day,
          status: calorieGoalDayStatus(
            kcal: nutrition?.kcal,
            calorieTarget: heatmapGoal?.calorieTarget,
          ),
          nutrition: nutrition,
          goal: heatmapGoal,
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
    calorieBuckets: chartStart == null
        ? const []
        : _bucketCalories(
            days: sortedNutrition,
            goals: sortedGoals,
            period: period,
            start: chartStart,
            end: DateTime(today.year, today.month, today.day),
          ),
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

List<ChartBucket> _bucketCalories({
  required List<NutritionDay> days,
  required List<GoalVersion> goals,
  required StatisticsPeriod period,
  required DateTime start,
  required DateTime end,
}) {
  final daily =
      period == StatisticsPeriod.days7 || period == StatisticsPeriod.days30;
  final buckets = <ChartBucket>[];
  var nutritionIndex = 0;
  var goalIndex = 0;
  GoalVersion? activeGoal;
  for (var day = start; !day.isAfter(end);) {
    var endDay = daily
        ? day
        : period == StatisticsPeriod.months3
        ? DateTime(day.year, day.month, day.day + 7 - day.weekday)
        : DateTime(day.year, day.month + 1, 0);
    if (endDay.isAfter(end)) endDay = end;
    final endKey = diaryDayKey(endDay);
    var calories = 0.0;
    var calorieTargets = 0.0;
    var loggedDays = 0;
    var goalDays = 0;
    while (nutritionIndex < days.length &&
        diaryDayKey(days[nutritionIndex].day).compareTo(endKey) <= 0) {
      final nutrition = days[nutritionIndex++];
      final key = diaryDayKey(nutrition.day);
      while (goalIndex < goals.length &&
          diaryDayKey(goals[goalIndex].day).compareTo(key) <= 0) {
        activeGoal = goals[goalIndex++];
      }
      calories += nutrition.kcal;
      loggedDays++;
      if (activeGoal != null) {
        calorieTargets += activeGoal.calorieTarget;
        goalDays++;
      }
    }
    if (daily && loggedDays == 0) {
      while (goalIndex < goals.length &&
          diaryDayKey(goals[goalIndex].day).compareTo(endKey) <= 0) {
        activeGoal = goals[goalIndex++];
      }
    }
    buckets.add(
      ChartBucket(
        day: day,
        endDay: endDay,
        value: loggedDays == 0 ? null : calories / loggedDays,
        days: loggedDays,
        calorieTarget: daily
            ? activeGoal?.calorieTarget.toDouble()
            : loggedDays > 0 && goalDays == loggedDays
            ? calorieTargets / loggedDays
            : null,
      ),
    );
    day = DateTime(endDay.year, endDay.month, endDay.day + 1);
  }
  return buckets;
}
