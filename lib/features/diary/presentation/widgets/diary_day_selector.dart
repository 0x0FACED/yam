import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam/app/theme/app_radius.dart';
import 'package:yam/app/theme/app_spacing.dart';
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
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final selectedIsToday = _isSameDay(selectedDay, today);
    final startOfWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday - DateTime.monday),
    );

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.diaryPreviousDay,
              onPressed: () =>
                  onDaySelected(selectedDay.subtract(const Duration(days: 1))),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Semantics(
                button: true,
                label: l10n.diaryOpenCalendar,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  onTap: onCalendarPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Column(
                      children: [
                        Text(
                          selectedIsToday
                              ? l10n.diaryToday
                              : DateFormat.MMMMd(locale).format(selectedDay),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (selectedIsToday)
                          Text(
                            DateFormat.MMMMd(locale).format(selectedDay),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.diaryNextDay,
              onPressed: () =>
                  onDaySelected(selectedDay.add(const Duration(days: 1))),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => onDaySelected(today),
              icon: const Icon(Icons.today_outlined, size: 18),
              label: Text(l10n.diaryReturnToToday),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Material(
        color: selected ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.control),
          onTap: () => onSelected(day),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E(locale).format(day),
                    maxLines: 1,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${day.day}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                    child: isToday && !selected
                        ? Center(
                            child: Container(
                              width: 4,
                              height: 4,
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
    );
  }
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
