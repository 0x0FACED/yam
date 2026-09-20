import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_motion.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
import 'package:yam/app/theme/app_typography.dart';
import 'package:yam/core/ui/buttons/yam_buttons.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class DiaryDaySelector extends StatelessWidget {
  const DiaryDaySelector({
    required this.selectedDay,
    required this.today,
    required this.onDaySelected,
    required this.onCalendarPressed,
    super.key,
  });

  final DateTime selectedDay;
  final DateTime today;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onCalendarPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final selectedIsToday = _isSameDay(selectedDay, today);
    final startOfWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday - DateTime.monday),
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
              onPressed: () =>
                  onDaySelected(selectedDay.subtract(const Duration(days: 1))),
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
              onPressed: () =>
                  onDaySelected(selectedDay.add(const Duration(days: 1))),
              surface: false,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (var index = 0; index < DateTime.daysPerWeek; index++)
              Expanded(
                child: _DayTile(
                  day: startOfWeek.add(Duration(days: index)),
                  selectedDay: selectedDay,
                  today: today,
                  locale: locale,
                  onSelected: onDaySelected,
                ),
              ),
          ],
        ),
        if (!selectedIsToday) ...[
          const SizedBox(height: AppSpacing.xxs),
          Align(
            alignment: Alignment.centerRight,
            child: YamTextButton(
              label: l10n.diaryReturnToToday,
              icon: Icons.today_outlined,
              onPressed: () => onDaySelected(today),
            ),
          ),
        ],
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.selectedDay,
    required this.today,
    required this.locale,
    required this.onSelected,
  });

  final DateTime day;
  final DateTime selectedDay;
  final DateTime today;
  final String locale;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _isSameDay(day, selectedDay);
    final isToday = _isSameDay(day, today);
    final foreground = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final animationDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.smallChange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        button: true,
        selected: selected,
        label: DateFormat.yMMMMEEEEd(locale).format(day),
        child: ExcludeSemantics(
          child: AnimatedContainer(
            duration: animationDuration,
            curve: AppMotion.standardCurve,
            decoration: BoxDecoration(
              color: selected ? theme.colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.control),
              onTap: () => onSelected(day),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
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
                          color: selected
                              ? foreground.withValues(alpha: 0.8)
                              : theme.colorScheme.onSurfaceVariant,
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
                      SizedBox(
                        height: 3,
                        child: isToday && !selected
                            ? Center(
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
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
