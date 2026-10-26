import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/services.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';

class StatisticsWeightChart extends StatelessWidget {
  const StatisticsWeightChart({
    required this.weights,
    required this.lineColor,
    required this.gridColor,
    required this.goalColor,
    required this.semanticLabel,
    required this.detailsBuilder,
    required this.dateLabelBuilder,
    this.goal,
    super.key,
  });

  final List<WeightRecord> weights;
  final double? goal;
  final Color lineColor;
  final Color gridColor;
  final Color goalColor;
  final String semanticLabel;
  final Widget Function(WeightRecord) detailsBuilder;
  final String Function(DateTime) dateLabelBuilder;

  @override
  Widget build(BuildContext context) => _ChartInspection(
    itemCount: weights.length,
    plotHeight: 144,
    semanticLabel: semanticLabel,
    fractionForIndex: (index) => _weightFraction(weights, index),
    dateForIndex: (index) => weights[index].day,
    dateLabelBuilder: dateLabelBuilder,
    detailsBuilder: (index) => detailsBuilder(weights[index]),
    painterBuilder: (selected) => _WeightPainter(
      weights: weights,
      goal: goal,
      lineColor: lineColor,
      gridColor: gridColor,
      goalColor: goalColor,
      surfaceColor: Theme.of(context).colorScheme.surfaceContainerLow,
      selected: selected,
    ),
  );
}

class StatisticsCalorieChart extends StatelessWidget {
  const StatisticsCalorieChart({
    required this.buckets,
    required this.barColor,
    required this.overColor,
    required this.goalColor,
    required this.semanticLabel,
    required this.detailsBuilder,
    required this.dateLabelBuilder,
    super.key,
  });

  final List<ChartBucket> buckets;
  final Color barColor;
  final Color overColor;
  final Color goalColor;
  final String semanticLabel;
  final Widget Function(ChartBucket) detailsBuilder;
  final String Function(DateTime) dateLabelBuilder;

  @override
  Widget build(BuildContext context) => _ChartInspection(
    itemCount: buckets.length,
    plotHeight: 96,
    minimumWidth: buckets.length * AppSpacing.xs,
    semanticLabel: semanticLabel,
    fractionForIndex: (index) => (index + 0.5) / buckets.length,
    dateForIndex: (index) => buckets[index].day,
    dateLabelBuilder: dateLabelBuilder,
    detailsBuilder: (index) => detailsBuilder(buckets[index]),
    painterBuilder: (selected) => _CaloriesPainter(
      buckets: buckets,
      barColor: barColor,
      overColor: overColor,
      goalColor: goalColor,
      selectionColor: Theme.of(context).colorScheme.primary,
      surfaceColor: Theme.of(context).colorScheme.surfaceContainerLow,
      selected: selected,
    ),
  );
}

/// Localized, exact inspection content shared with the regularity calendar.
class StatisticsInspectionDetails extends StatelessWidget {
  const StatisticsInspectionDetails({
    required this.title,
    required this.lines,
    this.action,
    super.key,
  });

  final String title;
  final List<String> lines;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.label.copyWith(color: colors.onSurface),
          ),
          for (final line in lines) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              line,
              style: AppTypography.body.copyWith(
                color: colors.onSurfaceVariant,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ],
          if (action case final action?) ...[
            const SizedBox(height: AppSpacing.xs),
            action,
          ],
        ],
      ),
    );
  }
}

class StatisticsGoalLegend extends StatelessWidget {
  const StatisticsGoalLegend({
    required this.color,
    required this.label,
    super.key,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ExcludeSemantics(
        child: CustomPaint(
          size: const Size(AppSpacing.lg, AppSpacing.xs),
          painter: _GoalLegendPainter(color),
        ),
      ),
      const SizedBox(width: AppSpacing.xs),
      Flexible(
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}

/// Only horizontal gestures enter the arena: a vertical swipe still belongs to
/// the page. A wide chart keeps the native horizontal scroll recognizer and
/// observes that drag to inspect the bucket currently beneath the pointer.
class _ChartInspection extends StatefulWidget {
  const _ChartInspection({
    required this.itemCount,
    required this.plotHeight,
    required this.semanticLabel,
    required this.fractionForIndex,
    required this.dateForIndex,
    required this.dateLabelBuilder,
    required this.detailsBuilder,
    required this.painterBuilder,
    this.minimumWidth = 0,
  });

  final int itemCount;
  final double plotHeight;
  final double minimumWidth;
  final String semanticLabel;
  final double Function(int) fractionForIndex;
  final DateTime Function(int) dateForIndex;
  final String Function(DateTime) dateLabelBuilder;
  final Widget Function(int) detailsBuilder;
  final CustomPainter Function(int?) painterBuilder;

  @override
  State<_ChartInspection> createState() => _ChartInspectionState();
}

class _ChartInspectionState extends State<_ChartInspection>
    with SingleTickerProviderStateMixin {
  final _overlay = OverlayPortalController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  final _tapGroup = Object();
  late final Ticker _edgeScroll;
  int? _selected;
  int? _pointer;
  Offset? _pointerStart;
  Offset? _pointerPosition;
  bool _horizontalDrag = false;
  bool _verticalDrag = false;
  bool _longPress = false;
  bool _revealingSelection = false;
  Duration? _lastTick;
  double _viewportWidth = 0;
  double _contentWidth = 0;
  double? _inspectionX;
  double? _inspectionY;

  double get _scrollOffset => _scroll.hasClients ? _scroll.offset : 0;

  @override
  void initState() {
    super.initState();
    _edgeScroll = createTicker(_scrollAtEdge);
    _scroll.addListener(_scrollChanged);
    FocusManager.instance.addEarlyKeyEventHandler(_escape);
  }

  @override
  void didUpdateWidget(covariant _ChartInspection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selected != null && _selected! >= widget.itemCount) {
      _selected = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selected == null) _overlay.hide();
      });
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeEarlyKeyEventHandler(_escape);
    _edgeScroll.dispose();
    _focus.dispose();
    _scroll
      ..removeListener(_scrollChanged)
      ..dispose();
    super.dispose();
  }

  KeyEventResult _escape(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        _selected != null &&
        (ModalRoute.of(context)?.isCurrent ?? true)) {
      _dismiss();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _keyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || widget.itemCount == 0) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      _step(-1);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _step(1);
    } else if (key == LogicalKeyboardKey.home) {
      _select(0, reveal: true);
    } else if (key == LogicalKeyboardKey.end) {
      _select(widget.itemCount - 1, reveal: true);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _select(_selected ?? 0, reveal: true);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _step(int direction) {
    final current = _selected ?? (direction > 0 ? -1 : widget.itemCount);
    _select(
      math.max(0, math.min(current + direction, widget.itemCount - 1)),
      reveal: true,
    );
  }

  void _select(int index, {bool reveal = false}) {
    if (widget.itemCount == 0) return;
    final changed = _selected != index;
    if (changed || (reveal && _inspectionY != null)) {
      setState(() => _selected = index);
    }
    if (!_overlay.isShowing) _overlay.show();
    if (reveal && _scroll.hasClients) {
      final x = _plotX(widget.fractionForIndex(index), _contentWidth);
      final left = _scrollOffset + AppSpacing.md;
      final right = _scrollOffset + _viewportWidth - AppSpacing.md;
      if (x < left || x > right) {
        _revealingSelection = true;
        _scroll.jumpTo(
          (x - _viewportWidth / 2).clamp(
            _scroll.position.minScrollExtent,
            _scroll.position.maxScrollExtent,
          ),
        );
        _revealingSelection = false;
      }
    }
    if (reveal) {
      _inspectionY = null;
      _inspectionX =
          _plotX(widget.fractionForIndex(index), _contentWidth) - _scrollOffset;
    }
  }

  void _selectAt(double viewportX, {bool focus = false, double? pointerY}) {
    if (widget.itemCount == 0) return;
    _inspectionX = viewportX.clamp(0, _viewportWidth);
    final previousY = _inspectionY;
    _inspectionY = pointerY ?? _pointerPosition?.dy ?? _inspectionY;
    final usableWidth = _contentWidth - AppSpacing.xs * 2;
    final fraction = usableWidth <= 0
        ? 0.5
        : ((_inspectionX! + _scrollOffset - AppSpacing.xs) / usableWidth).clamp(
            0.0,
            1.0,
          );
    final index = _nearestIndex(
      widget.itemCount,
      widget.fractionForIndex,
      fraction,
    );
    final sameSelection = _selected == index;
    _select(index);
    if (sameSelection && previousY != _inspectionY) setState(() {});
    if (focus) _focus.requestFocus();
  }

  void _dismiss() {
    if (_selected == null) return;
    _endPress();
    _overlay.hide();
    setState(() => _selected = null);
  }

  void _pointerDown(PointerDownEvent event) {
    if (_pointer != null) return;
    _pointer = event.pointer;
    _pointerStart = event.localPosition;
    _pointerPosition = event.localPosition;
    _horizontalDrag = false;
    _verticalDrag = false;
  }

  void _pointerMove(PointerMoveEvent event, bool scrollable) {
    if (event.pointer != _pointer) return;
    _pointerPosition = event.localPosition;
    if (!scrollable || _longPress || _verticalDrag) return;
    final delta = event.localPosition - _pointerStart!;
    if (!_horizontalDrag) {
      if (delta.dy.abs() > kTouchSlop && delta.dy.abs() >= delta.dx.abs()) {
        _verticalDrag = true;
        return;
      }
      if (delta.dx.abs() <= kTouchSlop || delta.dx.abs() <= delta.dy.abs()) {
        return;
      }
      _horizontalDrag = true;
    }
    _selectAt(event.localPosition.dx, focus: true);
  }

  void _pointerUp(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    _pointerStart = null;
    _pointerPosition = null;
    _horizontalDrag = false;
    _verticalDrag = false;
    _endPress();
  }

  void _startPress(LongPressStartDetails details) {
    _longPress = true;
    _pointerPosition = details.localPosition;
    _selectAt(details.localPosition.dx, focus: true);
    _lastTick = null;
    _edgeScroll.start();
  }

  void _endPress() {
    _longPress = false;
    _lastTick = null;
    _edgeScroll.stop();
  }

  void _scrollAtEdge(Duration elapsed) {
    final previous = _lastTick;
    _lastTick = elapsed;
    if (previous == null || !_longPress || !_scroll.hasClients) return;
    final x = _pointerPosition?.dx;
    if (x == null) return;
    const edge = AppSpacing.xl;
    final direction = x < edge
        ? -((edge - x) / edge).clamp(0.0, 1.0)
        : x > _viewportWidth - edge
        ? ((x - _viewportWidth + edge) / edge).clamp(0.0, 1.0)
        : 0.0;
    if (direction == 0) return;
    final seconds = (elapsed - previous).inMicroseconds / 1000000;
    final next = (_scrollOffset + direction * AppSpacing.xl * 8 * seconds)
        .clamp(
          _scroll.position.minScrollExtent,
          _scroll.position.maxScrollExtent,
        );
    if (next != _scrollOffset) _scroll.jumpTo(next);
  }

  void _scrollChanged() {
    if (_selected == null || _revealingSelection) return;
    // Retain a visible inspection anchor during native drag, wheel and inertia.
    // Reading the new content offset keeps the tooltip and highlighted bucket
    // together rather than leaving a tooltip for an off-screen selection.
    _selectAt(_pointerPosition?.dx ?? _inspectionX ?? _viewportWidth / 2);
    setState(() {});
  }

  String _dateLabel(int index) =>
      widget.dateLabelBuilder(widget.dateForIndex(index));

  Widget _popover(BuildContext context, OverlayChildLayoutInfo info) {
    final selected = _selected;
    if (selected == null) return const SizedBox.shrink();
    final anchor = MatrixUtils.transformRect(
      info.childPaintTransform,
      Offset.zero & info.childSize,
    );
    final x =
        _plotX(widget.fractionForIndex(selected), _contentWidth) -
        _scrollOffset;
    final point = MatrixUtils.transformPoint(
      info.childPaintTransform,
      Offset(x, 0),
    );
    final media = MediaQuery.of(context);
    if (anchor.bottom <= media.padding.top ||
        anchor.top >= info.overlaySize.height - media.padding.bottom) {
      return const SizedBox.shrink();
    }
    final fingerY = _inspectionY == null
        ? null
        : MatrixUtils.transformPoint(
            info.childPaintTransform,
            Offset(x, _inspectionY!),
          ).dy;
    final colors = Theme.of(context).colorScheme;
    return CustomSingleChildLayout(
      delegate: _InspectionLayout(
        anchor: anchor,
        anchorX: point.dx,
        fingerY: fingerY,
        insets: EdgeInsets.fromLTRB(
          media.padding.left + AppSpacing.md,
          media.padding.top + AppSpacing.xs,
          media.padding.right + AppSpacing.md,
          math.max(media.padding.bottom, media.viewInsets.bottom) +
              AppSpacing.xs,
        ),
      ),
      child: TapRegion(
        groupId: _tapGroup,
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Material(
            color: colors.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.control),
              side: BorderSide(color: colors.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              primary: false,
              child: widget.detailsBuilder(selected),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      _viewportWidth = constraints.maxWidth;
      _contentWidth = math.max(_viewportWidth, widget.minimumWidth);
      final scrollable = _contentWidth > _viewportWidth;
      final hasItems = widget.itemCount > 0;
      final selected = _selected;
      final next = selected == null
          ? 0
          : math.min(selected + 1, widget.itemCount - 1);
      final previous = selected == null
          ? widget.itemCount - 1
          : math.max(0, selected - 1);
      final plot = SizedBox(
        width: _contentWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _contentWidth,
              height: widget.plotHeight,
              child: CustomPaint(painter: widget.painterBuilder(selected)),
            ),
            const SizedBox(height: AppSpacing.xs),
            _DateAxis(
              itemCount: widget.itemCount,
              fractionForIndex: widget.fractionForIndex,
              dateForIndex: widget.dateForIndex,
              dateLabelBuilder: widget.dateLabelBuilder,
            ),
          ],
        ),
      );
      return OverlayPortal.overlayChildLayoutBuilder(
        controller: _overlay,
        overlayLocation: OverlayChildLocation.rootOverlay,
        overlayChildBuilder: _popover,
        child: TapRegion(
          groupId: _tapGroup,
          onTapOutside: (_) => _dismiss(),
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            focusable: hasItems,
            label: widget.semanticLabel,
            value: hasItems
                ? (selected == null
                      ? widget.semanticLabel
                      : _dateLabel(selected))
                : null,
            increasedValue: hasItems ? _dateLabel(next) : null,
            decreasedValue: hasItems ? _dateLabel(previous) : null,
            onIncrease: hasItems ? () => _step(1) : null,
            onDecrease: hasItems ? () => _step(-1) : null,
            onTap: hasItems
                ? () => _select(_selected ?? 0, reveal: true)
                : null,
            onDidGainAccessibilityFocus: hasItems
                ? () => _select(_selected ?? 0, reveal: true)
                : null,
            onDismiss: selected == null ? null : _dismiss,
            child: Focus(
              focusNode: _focus,
              includeSemantics: false,
              onKeyEvent: _keyEvent,
              onFocusChange: (focused) {
                if (focused && _selected == null && hasItems) {
                  _select(0, reveal: true);
                }
              },
              child: ExcludeSemantics(
                child: Listener(
                  onPointerDown: _pointerDown,
                  onPointerMove: (event) => _pointerMove(event, scrollable),
                  onPointerUp: _pointerUp,
                  onPointerCancel: _pointerUp,
                  child: MouseRegion(
                    cursor: hasItems
                        ? SystemMouseCursors.precise
                        : MouseCursor.defer,
                    onHover: hasItems
                        ? (event) => _selectAt(
                            event.localPosition.dx,
                            pointerY: event.localPosition.dy,
                          )
                        : null,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      excludeFromSemantics: true,
                      onTapUp: hasItems
                          ? (details) => _selectAt(
                              details.localPosition.dx,
                              focus: true,
                              pointerY: details.localPosition.dy,
                            )
                          : null,
                      onLongPressStart: hasItems ? _startPress : null,
                      onLongPressMoveUpdate: hasItems
                          ? (details) {
                              _pointerPosition = details.localPosition;
                              _selectAt(details.localPosition.dx);
                            }
                          : null,
                      onLongPressEnd: hasItems ? (_) => _endPress() : null,
                      onLongPressCancel: hasItems ? _endPress : null,
                      onHorizontalDragStart: hasItems && !scrollable
                          ? (details) =>
                                _selectAt(details.localPosition.dx, focus: true)
                          : null,
                      onHorizontalDragUpdate: hasItems && !scrollable
                          ? (details) => _selectAt(details.localPosition.dx)
                          : null,
                      child: scrollable
                          ? SingleChildScrollView(
                              controller: _scroll,
                              scrollDirection: Axis.horizontal,
                              child: plot,
                            )
                          : plot,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _InspectionLayout extends SingleChildLayoutDelegate {
  const _InspectionLayout({
    required this.anchor,
    required this.anchorX,
    required this.fingerY,
    required this.insets,
  });

  final Rect anchor;
  final double anchorX;
  final double? fingerY;
  final EdgeInsets insets;

  double _spaceAboveFinger() => fingerY! - AppSpacing.xxl - insets.top;

  double _spaceBelowFinger(double height) =>
      height - insets.bottom - fingerY! - AppSpacing.xxl;

  bool _useBelowFinger(double height) =>
      fingerY != null &&
      anchor.top - insets.top - AppSpacing.xs < AppSpacing.xxl * 2 &&
      _spaceAboveFinger() < AppSpacing.xxl * 2 &&
      _spaceBelowFinger(height) > _spaceAboveFinger();

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final width = math.max(0.0, constraints.maxWidth - insets.horizontal);
    final height = math.max(0.0, constraints.maxHeight - insets.vertical);
    final above = anchor.top - insets.top - AppSpacing.xs;
    final available = above >= AppSpacing.xxl * 2
        ? above
        : fingerY == null
        ? height * 0.5
        : _useBelowFinger(constraints.maxHeight)
        ? _spaceBelowFinger(constraints.maxHeight)
        : _spaceAboveFinger();
    return BoxConstraints(
      maxWidth: math.min(320, width),
      // Keep the popover above the plot whenever possible. At the top edge,
      // keep a finger-sized gap instead; overflowing details scroll in place.
      maxHeight: math.max(0.0, math.min(available, height)),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final preferredY = _useBelowFinger(size.height)
        ? fingerY! + AppSpacing.xxl
        : anchor.top - AppSpacing.xs - childSize.height;
    return Offset(
      (anchorX - childSize.width / 2).clamp(
        insets.left,
        math.max(insets.left, size.width - insets.right - childSize.width),
      ),
      preferredY.clamp(
        insets.top,
        math.max(insets.top, size.height - insets.bottom - childSize.height),
      ),
    );
  }

  @override
  bool shouldRelayout(covariant _InspectionLayout oldDelegate) =>
      oldDelegate.anchor != anchor ||
      oldDelegate.anchorX != anchorX ||
      oldDelegate.fingerY != fingerY ||
      oldDelegate.insets != insets;
}

class _DateAxis extends StatelessWidget {
  const _DateAxis({
    required this.itemCount,
    required this.fractionForIndex,
    required this.dateForIndex,
    required this.dateLabelBuilder,
  });

  final int itemCount;
  final double Function(int) fractionForIndex;
  final DateTime Function(int) dateForIndex;
  final String Function(DateTime) dateLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return SizedBox(
      width: double.infinity,
      height:
          scaler.scale(AppTypography.caption.fontSize!) *
          AppTypography.caption.height!,
      child: CustomPaint(
        painter: _DateAxisPainter(
          itemCount: itemCount,
          fractionForIndex: fractionForIndex,
          dateForIndex: dateForIndex,
          dateLabelBuilder: dateLabelBuilder,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textDirection: Directionality.of(context),
          textScaler: scaler,
        ),
      ),
    );
  }
}

class _DateAxisPainter extends CustomPainter {
  const _DateAxisPainter({
    required this.itemCount,
    required this.fractionForIndex,
    required this.dateForIndex,
    required this.dateLabelBuilder,
    required this.style,
    required this.textDirection,
    required this.textScaler,
  });

  final int itemCount;
  final double Function(int) fractionForIndex;
  final DateTime Function(int) dateForIndex;
  final String Function(DateTime) dateLabelBuilder;
  final TextStyle style;
  final TextDirection textDirection;
  final TextScaler textScaler;

  TextPainter _label(int index, double maxWidth) => TextPainter(
    text: TextSpan(text: dateLabelBuilder(dateForIndex(index)), style: style),
    textDirection: textDirection,
    textScaler: textScaler,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth);

  Rect _rect(TextPainter label, int index, Size size) => Rect.fromLTWH(
    (_plotX(fractionForIndex(index), size.width) - label.width / 2).clamp(
      0.0,
      math.max(0.0, size.width - label.width),
    ),
    0,
    label.width,
    label.height,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount == 0 || size.width <= 0) return;
    final first = _label(0, size.width);
    final firstRect = _rect(first, 0, size);
    final firstWidth = first.width;
    first.paint(canvas, firstRect.topLeft);
    first.dispose();
    if (itemCount == 1) return;
    final last = _label(itemCount - 1, size.width);
    final lastRect = _rect(last, itemCount - 1, size);
    final lastWidth = last.width;
    if (firstRect.right + AppSpacing.sm > lastRect.left) {
      last.dispose();
      return;
    }
    last.paint(canvas, lastRect.topLeft);
    last.dispose();
    final intervals = math.max(
      1,
      math.min(
        itemCount - 1,
        (size.width / (math.max(firstWidth, lastWidth) + AppSpacing.lg))
            .floor(),
      ),
    );
    var previousRight = firstRect.right;
    var previousIndex = 0;
    for (var slot = 1; slot < intervals; slot++) {
      final index = _nearestIndex(
        itemCount,
        fractionForIndex,
        slot / intervals,
      );
      if (index == previousIndex || index == itemCount - 1) continue;
      previousIndex = index;
      final label = _label(index, size.width);
      final rect = _rect(label, index, size);
      if (rect.left >= previousRight + AppSpacing.sm &&
          rect.right + AppSpacing.sm <= lastRect.left) {
        label.paint(canvas, rect.topLeft);
        previousRight = rect.right;
      }
      label.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant _DateAxisPainter oldDelegate) =>
      oldDelegate.itemCount != itemCount ||
      oldDelegate.fractionForIndex != fractionForIndex ||
      oldDelegate.dateForIndex != dateForIndex ||
      oldDelegate.dateLabelBuilder != dateLabelBuilder ||
      oldDelegate.style != style ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.textScaler != textScaler;
}

class _WeightPainter extends CustomPainter {
  const _WeightPainter({
    required this.weights,
    required this.goal,
    required this.lineColor,
    required this.gridColor,
    required this.goalColor,
    required this.surfaceColor,
    required this.selected,
  });

  final List<WeightRecord> weights;
  final double? goal;
  final Color lineColor;
  final Color gridColor;
  final Color goalColor;
  final Color surfaceColor;
  final int? selected;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = AppSpacing.xs;
    final height = size.height - inset * 2;
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var index = 0; index < 4; index++) {
      final y = inset + height * index / 3;
      canvas.drawLine(Offset(inset, y), Offset(size.width - inset, y), grid);
    }
    if (weights.isEmpty) return;
    var min = weights.first.kg;
    var max = min;
    for (final entry in weights) {
      min = math.min(min, entry.kg);
      max = math.max(max, entry.kg);
    }
    if (goal case final goal?) {
      min = math.min(min, goal);
      max = math.max(max, goal);
    }
    final padding = math.max((max - min) * 0.14, 0.3);
    min -= padding;
    max += padding;
    double yFor(double value) => inset + (max - value) / (max - min) * height;
    Offset point(int index) => Offset(
      _plotX(_weightFraction(weights, index), size.width),
      yFor(weights[index].kg),
    );
    if (goal case final target?) {
      _drawDashedLine(
        canvas,
        Offset(inset, yFor(target)),
        Offset(size.width - inset, yFor(target)),
        Paint()
          ..color = goalColor
          ..strokeWidth = 1.5,
      );
    }
    if (selected case final index?) {
      _drawInspectionGuide(canvas, size, point(index).dx, lineColor);
    }
    final first = point(0);
    final path = Path()..moveTo(first.dx, first.dy);
    for (var i = 1; i < weights.length; i++) {
      final current = point(i);
      path.lineTo(current.dx, current.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    final dot = Paint()..color = lineColor;
    final surface = Paint()..color = surfaceColor;
    for (var i = 0; i < weights.length; i++) {
      final current = point(i);
      if (i == selected) canvas.drawCircle(current, 7, surface);
      canvas.drawCircle(current, i == selected ? 5 : 3, dot);
      if (i == selected) canvas.drawCircle(current, 2, surface);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightPainter oldDelegate) =>
      oldDelegate.weights != weights ||
      oldDelegate.goal != goal ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.goalColor != goalColor ||
      oldDelegate.surfaceColor != surfaceColor ||
      oldDelegate.selected != selected;
}

class _CaloriesPainter extends CustomPainter {
  const _CaloriesPainter({
    required this.buckets,
    required this.barColor,
    required this.overColor,
    required this.goalColor,
    required this.selectionColor,
    required this.surfaceColor,
    required this.selected,
  });

  final List<ChartBucket> buckets;
  final Color barColor;
  final Color overColor;
  final Color goalColor;
  final Color selectionColor;
  final Color surfaceColor;
  final int? selected;

  @override
  void paint(Canvas canvas, Size size) {
    if (buckets.isEmpty) return;
    const inset = AppSpacing.xs;
    final height = size.height - inset * 2;
    var maxValue = 0.0;
    for (final bucket in buckets) {
      maxValue = math.max(maxValue, bucket.value ?? 0);
      maxValue = math.max(maxValue, bucket.calorieTarget ?? 0);
    }
    final scale = maxValue <= 0 ? 1.0 : maxValue * 1.1;
    double yFor(double value) => inset + height * (1 - value / scale);
    final width = size.width - inset * 2;
    final cell = width / buckets.length;
    final barWidth = math.max(1.0, cell - AppSpacing.xxs);
    final bar = Paint();
    for (var i = 0; i < buckets.length; i++) {
      final bucket = buckets[i];
      final x = inset + (i + 0.5) * cell;
      if (i == selected) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(inset + i * cell, inset, cell, height),
            const Radius.circular(AppRadius.small),
          ),
          Paint()..color = selectionColor.withValues(alpha: 0.1),
        );
        _drawInspectionGuide(canvas, size, x, selectionColor);
      }
      final value = bucket.value;
      if (value == null) continue;
      final target = bucket.calorieTarget;
      bar.color = target != null && value > target * 1.1 ? overColor : barColor;
      final rect = Rect.fromLTWH(
        x - barWidth / 2,
        yFor(value),
        barWidth,
        value / scale * height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(AppRadius.small)),
        bar,
      );
      if (i == selected && value > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(AppRadius.small)),
          Paint()
            ..color = selectionColor
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // Historical goals are painted last, including their surface halo, so a
    // tall bar can never hide the target. Null goals break the step completely.
    final halo = Paint()
      ..color = surfaceColor
      ..strokeWidth = 4.5;
    final goal = Paint()
      ..color = goalColor
      ..strokeWidth = 1.5;
    for (var pass = 0; pass < 2; pass++) {
      final paint = pass == 0 ? halo : goal;
      for (var i = 0; i < buckets.length; i++) {
        final target = buckets[i].calorieTarget;
        if (target == null) continue;
        final left = inset + i * cell;
        final y = yFor(target);
        _drawDashedLine(
          canvas,
          Offset(left, y),
          Offset(left + cell, y),
          paint,
          phase: i * cell,
        );
        if (i > 0) {
          final previous = buckets[i - 1].calorieTarget;
          if (previous != null && previous != target) {
            _drawDashedLine(
              canvas,
              Offset(left, yFor(previous)),
              Offset(left, y),
              paint,
            );
          }
        }
      }
    }
    if (selected case final index?) {
      final value = buckets[index].value;
      if (value != null) {
        final x = inset + (index + 0.5) * cell;
        final y = yFor(value);
        canvas.drawCircle(Offset(x, y), 5, Paint()..color = surfaceColor);
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = selectionColor);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CaloriesPainter oldDelegate) =>
      oldDelegate.buckets != buckets ||
      oldDelegate.barColor != barColor ||
      oldDelegate.overColor != overColor ||
      oldDelegate.goalColor != goalColor ||
      oldDelegate.selectionColor != selectionColor ||
      oldDelegate.surfaceColor != surfaceColor ||
      oldDelegate.selected != selected;
}

class _GoalLegendPainter extends CustomPainter {
  const _GoalLegendPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) => _drawDashedLine(
    canvas,
    Offset(0, size.height / 2),
    Offset(size.width, size.height / 2),
    Paint()
      ..color = color
      ..strokeWidth = 1.5,
  );

  @override
  bool shouldRepaint(covariant _GoalLegendPainter oldDelegate) =>
      oldDelegate.color != color;
}

double _plotX(double fraction, double width) =>
    AppSpacing.xs + math.max(0, width - AppSpacing.xs * 2) * fraction;

double _weightFraction(List<WeightRecord> weights, int index) {
  if (weights.length == 1) return 0.5;
  DateTime date(WeightRecord record) =>
      DateTime.utc(record.day.year, record.day.month, record.day.day);
  final first = date(weights.first);
  final duration = date(weights.last).difference(first).inDays;
  if (duration == 0) return 0.5;
  return date(weights[index]).difference(first).inDays / duration;
}

int _nearestIndex(int count, double Function(int) fractionForIndex, double x) {
  var low = 0;
  var high = count - 1;
  while (low < high) {
    final middle = (low + high) ~/ 2;
    if (fractionForIndex(middle) < x) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }
  if (low > 0 &&
      (fractionForIndex(low - 1) - x).abs() <=
          (fractionForIndex(low) - x).abs()) {
    return low - 1;
  }
  return low;
}

void _drawInspectionGuide(Canvas canvas, Size size, double x, Color color) {
  canvas.drawLine(
    Offset(x, AppSpacing.xs),
    Offset(x, size.height - AppSpacing.xs),
    Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1,
  );
  final pointer = Path()
    ..moveTo(x - AppSpacing.xxs, 0)
    ..lineTo(x + AppSpacing.xxs, 0)
    ..lineTo(x, AppSpacing.xxs)
    ..close();
  canvas.drawPath(pointer, Paint()..color = color);
}

void _drawDashedLine(
  Canvas canvas,
  Offset start,
  Offset end,
  Paint paint, {
  double phase = 0,
}) {
  final delta = end - start;
  final length = delta.distance;
  if (length == 0) return;
  final direction = delta / length;
  const dash = AppSpacing.xxs;
  const period = dash * 2;
  for (
    var distance = -(phase % period);
    distance < length;
    distance += period
  ) {
    final from = math.max(0.0, distance);
    final to = math.min(length, distance + dash);
    if (to > from) {
      canvas.drawLine(start + direction * from, start + direction * to, paint);
    }
  }
}
