import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';

class StatisticsWeightChart extends StatelessWidget {
  const StatisticsWeightChart({
    required this.weights,
    required this.lineColor,
    required this.gridColor,
    required this.goalColor,
    required this.semanticLabel,
    required this.onSelected,
    this.goal,
    super.key,
  });

  final List<WeightRecord> weights;
  final double? goal;
  final Color lineColor;
  final Color gridColor;
  final Color goalColor;
  final String semanticLabel;
  final ValueChanged<WeightRecord> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              if (weights.isEmpty) return;
              final width = constraints.maxWidth;
              final fraction = (details.localPosition.dx / width).clamp(
                0.0,
                1.0,
              );
              var index = 0;
              for (var i = 1; i < weights.length; i++) {
                if ((_weightFraction(weights, i) - fraction).abs() <
                    (_weightFraction(weights, index) - fraction).abs()) {
                  index = i;
                }
              }
              onSelected(weights[index]);
            },
            child: SizedBox(
              height: 144,
              child: CustomPaint(
                painter: _WeightPainter(
                  weights: weights,
                  goal: goal,
                  lineColor: lineColor,
                  gridColor: gridColor,
                  goalColor: goalColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeightPainter extends CustomPainter {
  const _WeightPainter({
    required this.weights,
    required this.goal,
    required this.lineColor,
    required this.gridColor,
    required this.goalColor,
  });

  final List<WeightRecord> weights;
  final double? goal;
  final Color lineColor;
  final Color gridColor;
  final Color goalColor;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = AppSpacing.xs;
    final usableHeight = size.height - 2 * inset;
    for (var index = 0; index < 4; index++) {
      final y = inset + usableHeight * index / 3;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1,
      );
    }
    if (weights.isEmpty) return;
    final values = [for (final entry in weights) entry.kg, ?goal];
    var min = values.reduce(math.min);
    var max = values.reduce(math.max);
    final padding = math.max((max - min) * 0.14, 0.3);
    min -= padding;
    max += padding;
    double yFor(double value) =>
        inset + (max - value) / (max - min) * usableHeight;

    if (goal case final target?) {
      final y = yFor(target);
      final paint = Paint()
        ..color = goalColor
        ..strokeWidth = 1;
      for (var x = 0.0; x < size.width; x += AppSpacing.xs) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + AppSpacing.xxs, size.width), y),
          paint,
        );
      }
    }

    final points = [
      for (var i = 0; i < weights.length; i++)
        Offset(_weightFraction(weights, i) * size.width, yFor(weights[i].kg)),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        i == points.length - 1 ? 4.5 : 3,
        Paint()..color = lineColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeightPainter oldDelegate) =>
      oldDelegate.weights != weights ||
      oldDelegate.goal != goal ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.goalColor != goalColor;
}

double _weightFraction(List<WeightRecord> weights, int index) {
  if (weights.length == 1) return 0.5;
  DateTime date(WeightRecord record) =>
      DateTime.utc(record.day.year, record.day.month, record.day.day);
  final first = date(weights.first);
  final duration = date(weights.last).difference(first).inDays;
  if (duration == 0) return 0.5;
  return date(weights[index]).difference(first).inDays / duration;
}

class StatisticsCalorieChart extends StatelessWidget {
  const StatisticsCalorieChart({
    required this.buckets,
    required this.statuses,
    required this.barColor,
    required this.overColor,
    required this.goalColor,
    required this.semanticLabel,
    this.goal,
    super.key,
  });

  final List<ChartBucket> buckets;
  final List<GoalDayStatus> statuses;
  final double? goal;
  final Color barColor;
  final Color overColor;
  final Color goalColor;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(constraints.maxWidth, buckets.length * 9.0),
            height: 96,
            child: CustomPaint(
              painter: _CaloriesPainter(
                buckets: buckets,
                statuses: statuses,
                goal: goal,
                barColor: barColor,
                overColor: overColor,
                goalColor: goalColor,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _CaloriesPainter extends CustomPainter {
  const _CaloriesPainter({
    required this.buckets,
    required this.statuses,
    required this.goal,
    required this.barColor,
    required this.overColor,
    required this.goalColor,
  });

  final List<ChartBucket> buckets;
  final List<GoalDayStatus> statuses;
  final double? goal;
  final Color barColor;
  final Color overColor;
  final Color goalColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (buckets.isEmpty) return;
    final maxValue = math.max(
      buckets.map((bucket) => bucket.value).reduce(math.max),
      (goal ?? 0) * 1.15,
    );
    final scale = maxValue <= 0 ? 1.0 : maxValue;
    if (goal case final target?) {
      final y = size.height * (1 - target / scale);
      final paint = Paint()
        ..color = goalColor
        ..strokeWidth = 1;
      for (var x = 0.0; x < size.width; x += AppSpacing.xs) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + AppSpacing.xxs, size.width), y),
          paint,
        );
      }
    }
    final cell = size.width / buckets.length;
    for (var i = 0; i < buckets.length; i++) {
      final bucket = buckets[i];
      final barWidth = math.max(2.0, cell - AppSpacing.xxs);
      final height = bucket.value / scale * size.height;
      final paint = Paint()
        ..color = i < statuses.length && statuses[i] == GoalDayStatus.above
            ? overColor
            : barColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * cell + (cell - barWidth) / 2,
            size.height - height,
            barWidth,
            height,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CaloriesPainter oldDelegate) =>
      oldDelegate.buckets != buckets ||
      oldDelegate.statuses != statuses ||
      oldDelegate.goal != goal ||
      oldDelegate.barColor != barColor ||
      oldDelegate.overColor != overColor ||
      oldDelegate.goalColor != goalColor;
}
