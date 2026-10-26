import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_semantic_colors.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/features/statistics/domain/statistics_models.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class DiaryDaySelector extends StatelessWidget {
  const DiaryDaySelector({
    required this.selectedDay,
    required this.today,
    required this.onDaySelected,
    required this.onCalendarPressed,
    this.dayStatuses = const {},
    super.key,
  });

  final DateTime selectedDay;
  final DateTime today;
  final Map<DateTime, GoalDayStatus> dayStatuses;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onCalendarPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final selectedIsToday = _isSameDay(selectedDay, today);
    final startOfWeek = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day - selectedDay.weekday + DateTime.monday,
    );
    final endOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day + DateTime.daysPerWeek - 1,
    );
    final dateLabel = [
      DateFormat.MMMMd(locale).format(selectedDay),
      DateFormat.EEEE(locale).format(selectedDay),
    ].join(', ');

    return Column(
      children: [
        Row(
          children: [
            YamIconButton(
              icon: Icons.chevron_left_rounded,
              tooltip: l10n.diaryPreviousDay,
              onPressed: () => onDaySelected(
                DateTime(
                  selectedDay.year,
                  selectedDay.month,
                  selectedDay.day - 1,
                ),
              ),
              surface: false,
            ),
            Expanded(
              child: Semantics(
                button: true,
                label: l10n.diaryOpenCalendar,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  onTap: onCalendarPressed,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectedIsToday
                                ? l10n.diaryToday
                                : DateFormat.MMMMd(locale).format(selectedDay),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.productTitle.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            dateLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            YamIconButton(
              icon: Icons.chevron_right_rounded,
              tooltip: l10n.diaryNextDay,
              onPressed: () => onDaySelected(
                DateTime(
                  selectedDay.year,
                  selectedDay.month,
                  selectedDay.day + 1,
                ),
              ),
              surface: false,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (
              var day = startOfWeek;
              !day.isAfter(endOfWeek);
              day = DateTime(day.year, day.month, day.day + 1)
            )
              Expanded(
                child: _DayTile(
                  day: day,
                  status: dayStatuses[day] ?? GoalDayStatus.noEntry,
                  selectedDay: selectedDay,
                  today: today,
                  locale: locale,
                  onSelected: onDaySelected,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.selectedDay,
    required this.status,
    required this.today,
    required this.locale,
    required this.onSelected,
  });

  final DateTime day;
  final GoalDayStatus status;
  final DateTime selectedDay;
  final DateTime today;
  final String locale;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _isSameDay(day, selectedDay);
    final isToday = _isSameDay(day, today);
    final l10n = AppLocalizations.of(context);
    final colors = theme.colorScheme;
    final semantic = AppSemanticColors.of(context);
    final statusColor = switch (status) {
      GoalDayStatus.within => semantic.goalWithin,
      GoalDayStatus.below => semantic.goalBelow,
      GoalDayStatus.above => semantic.goalAbove,
      GoalDayStatus.noGoal => colors.surfaceContainerHighest,
      GoalDayStatus.noEntry => Colors.transparent,
    };
    final colored =
        status == GoalDayStatus.within ||
        status == GoalDayStatus.below ||
        status == GoalDayStatus.above;
    final primarySelection = selected && !colored;
    final foreground =
        primarySelection ||
            status == GoalDayStatus.within ||
            status == GoalDayStatus.above
        ? colors.onPrimary
        : colors.onSurface;
    final animationDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.smallChange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        button: true,
        selected: selected,
        onTap: () => onSelected(day),
        label: [
          DateFormat.yMMMMEEEEd(locale).format(day),
          if (isToday) l10n.diaryToday,
          switch (status) {
            GoalDayStatus.within => l10n.statsGoalWithin,
            GoalDayStatus.below => l10n.statsGoalBelow,
            GoalDayStatus.above => l10n.statsGoalAbove,
            GoalDayStatus.noGoal => l10n.statsNoGoal,
            GoalDayStatus.noEntry => l10n.statsNoEntry,
          },
        ].join(', '),
        child: ExcludeSemantics(
          child: AnimatedContainer(
            duration: animationDuration,
            curve: AppMotion.standardCurve,
            decoration: BoxDecoration(
              color: primarySelection ? colors.primary : statusColor,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            foregroundDecoration: BoxDecoration(
              border: Border.all(
                color: selected ? colors.primary : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.control),
              onTap: () => onSelected(day),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.E(locale).format(day),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: AppTypography.caption.copyWith(
                          color: colored || primarySelection
                              ? foreground
                              : colors.onSurfaceVariant,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${day.day}',
                        style: AppTypography.label.copyWith(
                          color: foreground,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontFeatures: AppTypography.tabularFigures,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isToday)
                              Container(
                                key: const ValueKey('diary-today-marker'),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: colored || primarySelection
                                      ? foreground
                                      : colors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (status == GoalDayStatus.noGoal) ...[
                              if (isToday)
                                const SizedBox(width: AppSpacing.xxs),
                              Container(
                                width: AppSpacing.sm,
                                height: 2,
                                color: primarySelection
                                    ? foreground
                                    : colors.onSurfaceVariant,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
