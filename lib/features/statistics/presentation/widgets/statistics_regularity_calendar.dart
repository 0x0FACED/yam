import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';

class StatisticsRegularityCalendar extends StatelessWidget {
  const StatisticsRegularityCalendar({
    required this.cells,
    required this.detailsBuilder,
    required this.semanticLabelBuilder,
    super.key,
  });

  final List<RegularityCell> cells;
  final Widget Function(RegularityCell) detailsBuilder;
  final String Function(RegularityCell) semanticLabelBuilder;

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) return const SizedBox.shrink();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final weekdays = DateFormat.E(locale).dateSymbols.SHORTWEEKDAYS;
    const minimumWidth =
        DateTime.daysPerWeek * kMinInteractiveDimensionCupertino;
    final leadingDays = cells.first.day.weekday - DateTime.monday;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.max(constraints.maxWidth, minimumWidth);
        final calendar = SizedBox(
          width: width,
          child: Column(
            children: [
              Row(
                children: [
                  for (
                    var weekday = 1;
                    weekday <= DateTime.daysPerWeek;
                    weekday++
                  )
                    Expanded(
                      child: Text(
                        weekdays[weekday % DateTime.daysPerWeek],
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              for (
                var start = -leadingDays;
                start < cells.length;
                start += DateTime.daysPerWeek
              ) ...[
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    for (
                      var weekday = 0;
                      weekday < DateTime.daysPerWeek;
                      weekday++
                    )
                      Expanded(
                        child:
                            start + weekday < 0 ||
                                start + weekday >= cells.length
                            ? const SizedBox.shrink()
                            : _RegularityDayTile(
                                key: ValueKey(
                                  'stats-day-${cells[start + weekday].day.toIso8601String()}',
                                ),
                                cell: cells[start + weekday],
                                semanticLabel: semanticLabelBuilder(
                                  cells[start + weekday],
                                ),
                                detailsBuilder: () =>
                                    detailsBuilder(cells[start + weekday]),
                              ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
        if (constraints.maxWidth >= minimumWidth) return calendar;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: calendar,
        );
      },
    );
  }
}

class _RegularityDayTile extends StatefulWidget {
  const _RegularityDayTile({
    required this.cell,
    required this.semanticLabel,
    required this.detailsBuilder,
    super.key,
  });

  final RegularityCell cell;
  final String semanticLabel;
  final Widget Function() detailsBuilder;

  @override
  State<_RegularityDayTile> createState() => _RegularityDayTileState();
}

class _RegularityDayTileState extends State<_RegularityDayTile> {
  final _overlay = OverlayPortalController();
  final _focus = FocusNode();
  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context, axis: Axis.vertical)?.position;
    if (position != _scrollPosition) {
      _scrollPosition?.isScrollingNotifier.removeListener(_onScroll);
      _scrollPosition = position;
      position?.isScrollingNotifier.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if ((_scrollPosition?.isScrollingNotifier.value ?? false) &&
        _overlay.isShowing) {
      // Content-size corrections can start scrolling during layout.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hide();
      });
    }
  }

  void _hide() {
    if (_overlay.isShowing) setState(_overlay.hide);
  }

  void _toggle() {
    _focus.requestFocus();
    setState(_overlay.toggle);
  }

  @override
  void dispose() {
    _scrollPosition?.isScrollingNotifier.removeListener(_onScroll);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);
    final background = switch (widget.cell.status) {
      GoalDayStatus.within => semantic.goalWithin,
      GoalDayStatus.below => semantic.goalBelow,
      GoalDayStatus.above => semantic.goalAbove,
      GoalDayStatus.noGoal => colors.surfaceContainerHighest,
      _ => colors.surface,
    };
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _hide();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TapRegion(
        groupId: this,
        onTapOutside: (_) => _hide(),
        child: OverlayPortal.overlayChildLayoutBuilder(
          controller: _overlay,
          overlayChildBuilder: (context, info) {
            final anchor = MatrixUtils.transformRect(
              info.childPaintTransform,
              Offset.zero & info.childSize,
            );
            final padding = MediaQuery.paddingOf(context);
            return CustomSingleChildLayout(
              delegate: _DayPopoverLayout(anchor, padding),
              child: TapRegion(
                groupId: this,
                child: Material(
                  color: colors.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.control),
                    side: BorderSide(color: colors.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    child: Semantics(
                      liveRegion: true,
                      child: widget.detailsBuilder(),
                    ),
                  ),
                ),
              ),
            );
          },
          child: Semantics(
            label: widget.semanticLabel,
            button: true,
            selected: _overlay.isShowing,
            excludeSemantics: true,
            onTap: _toggle,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                focusNode: _focus,
                onTap: _toggle,
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Ink(
                    decoration: ShapeDecoration(
                      color: background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        side: _overlay.isShowing
                            ? BorderSide(color: colors.primary, width: 2)
                            : BorderSide.none,
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(
                          kMinInteractiveDimensionCupertino,
                          MediaQuery.textScalerOf(context).scale(16) +
                              AppSpacing.sm,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.cell.day.day}',
                              style: AppTypography.caption.copyWith(
                                color:
                                    widget.cell.status ==
                                            GoalDayStatus.within ||
                                        widget.cell.status ==
                                            GoalDayStatus.above
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                            if (widget.cell.status == GoalDayStatus.noGoal) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Container(
                                width: AppSpacing.sm,
                                height: 2,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayPopoverLayout extends SingleChildLayoutDelegate {
  const _DayPopoverLayout(this.anchor, this.padding);

  final Rect anchor;
  final EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        maxWidth: math.min(
          320,
          math.max(0, constraints.maxWidth - 2 * AppSpacing.md),
        ),
        maxHeight: math.max(
          0,
          constraints.maxHeight - padding.vertical - 2 * AppSpacing.md,
        ),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final minX = padding.left + AppSpacing.md;
    final maxX = math.max(
      minX,
      size.width - padding.right - AppSpacing.md - childSize.width,
    );
    final minY = padding.top + AppSpacing.md;
    final maxY = math.max(
      minY,
      size.height - padding.bottom - AppSpacing.md - childSize.height,
    );
    final above = anchor.top - AppSpacing.xs - childSize.height;
    final y = above >= minY ? above : anchor.bottom + AppSpacing.xs;
    return Offset(
      (anchor.center.dx - childSize.width / 2).clamp(minX, maxX),
      y.clamp(minY, maxY),
    );
  }

  @override
  bool shouldRelayout(covariant _DayPopoverLayout oldDelegate) =>
      anchor != oldDelegate.anchor || padding != oldDelegate.padding;
}
