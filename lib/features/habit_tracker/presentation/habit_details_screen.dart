import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/enums.dart';
import 'package:habitera/features/habit_tracker/data/models/habit.dart';
import 'package:habitera/features/habit_tracker/presentation/providers/habit_provider.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/consistency_grid.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/habit_emoji.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/last_seven_days_date_section.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/stat_card.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/type_chip.dart';
import 'package:habitera/features/settings/presentation/settings_provider.dart';
import 'package:habitera/router/app_router.dart';
import 'package:habitera/utils/extensions.dart';

/// The habit-details screen: stats, consistency grid, and the last-7-days
/// strip, rebuilt against the v2 design (design/Habitera Design System/
/// screens/HabitDetail.jsx). Streak/completion numbers all come from
/// habitStatsProvider, which already folds in today's optimistic check-in
/// state so this screen doesn't need to compute that overlay itself.
class HabitDetailsScreen extends ConsumerStatefulWidget {
  const HabitDetailsScreen({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends ConsumerState<HabitDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    print(widget.habit.title);
    final statsAsync = ref.watch(
      habitStatsProvider(widget.habit.id, widget.habit.createdAt),
    );
    final stats = statsAsync.valueOrNull;
    final dayKeys = stats?.dayKeys ?? <int>{};

    final doneHabitIdsAsync = ref.watch(doneHabitIdsProvider);
    final isDone =
        doneHabitIdsAsync.valueOrNull?.contains(widget.habit.id) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit'),
        actions: [
          TextButton(
            onPressed: () => context.goNamed(
              AppRoutes.editHabitsScreen.name,
              extra: widget.habit,
            ),
            child: Text(
              'Edit',
              style: context.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: ColorPicker.sky400,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(habit: widget.habit),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      emoji: '🔥',
                      value: '${stats?.currentStreak ?? 0}',
                      label: 'Current streak',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      emoji: '🏆',
                      value: '${stats?.bestStreak ?? 0}',
                      label: 'Best streak',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: '${stats?.totalCheckins ?? 0}',
                      label: 'Total check-ins',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: '${((stats?.completionRate ?? 0) * 100).round()}%',
                      label: 'Completion rate',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _CalendarCard(
                dayKeys: dayKeys,
                createdAt: widget.habit.createdAt,
              ),
              const SizedBox(height: 15),
              // _LastSevenDaysCard(dayKeys: dayKeys),
              _CheckInButton(
                isDone: isDone,
                onTap: () => ref
                    .read(doneHabitIdsProvider.notifier)
                    .toggleDone(widget.habit.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HabitEmoji(emoji: habit.emoji, size: 52),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.title,
                style: context.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                  color: isDark
                      ? ColorPicker.darkTextTitle
                      : ColorPicker.ink500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Every day',
                    style: context.small.copyWith(
                      fontSize: 14,
                      color: isDark ? ColorPicker.ink400 : ColorPicker.ink500,
                    ),
                  ),
                  if (habit.reminderTime != null) ...[
                    Text(
                      '  ·  ',
                      style: context.small.copyWith(
                        fontSize: 14,

                        color: ColorPicker.ink500,
                      ),
                    ),
                    Icon(
                      Icons.alarm_rounded,
                      size: 14,
                      color: isDark ? ColorPicker.ink400 : ColorPicker.ink500,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      habit.reminderTime!.format(context),
                      style: context.small.copyWith(
                        fontSize: 14,

                        color: isDark ? ColorPicker.ink400 : ColorPicker.ink500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              TypeChip(type: habit.type),
            ],
          ),
        ),
      ],
    );
  }
}

// class _ConsistencyCard extends StatelessWidget {
//   const _ConsistencyCard({required this.dayKeys});

//   final Set<int> dayKeys;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: ColorPicker.ink100),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Consistency',
//                 style: context.body.copyWith(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 16,
//                 ),
//               ),
//               Text(
//                 'Daily check-ins',
//                 style: context.small.copyWith(color: ColorPicker.ink400),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           ConsistencyGrid(dayKeys: dayKeys),
//         ],
//       ),
//     );
//   }
// }

// Drop-in replacement for _ConsistencyCard. Same card shell as _LastSevenDaysCard
// so the two cards look like siblings in both themes.
class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.dayKeys, required this.createdAt});

  final Set<int> dayKeys;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ColorPicker.darkSurfaceCard : ColorPicker.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? const Color.fromARGB(255, 56, 56, 56)
              : ColorPicker.ink100,
        ),
      ),
      child: HabitCalendar(dayKeys: dayKeys, createdAt: createdAt),
    );
  }
}

class HabitCalendar extends ConsumerStatefulWidget {
  const HabitCalendar({
    super.key,
    required this.dayKeys,
    required this.createdAt,
  });

  final Set<int> dayKeys;
  final DateTime createdAt;

  @override
  ConsumerState<HabitCalendar> createState() => _HabitCalendarState();
}

class _HabitCalendarState extends ConsumerState<HabitCalendar> {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // Only year + month matter here. Day is pinned to 1 so month math
  // (next/prev) never trips over "Jan 31 + 1 month".
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  // MUST match however your stats provider builds its dayKeys.
  // If this is wrong, the calendar renders fine but nothing is highlighted.
  int _dayKeyOf(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  void _changeMonth(int delta) {
    // DateTime normalizes overflow, so month 13 becomes January next year.
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  // Collapses year+month into one number so "is month A before month B"
  // is a plain int comparison instead of a two-field if/else.
  int _monthIndex(DateTime d) => d.year * 12 + d.month;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final weekStart = ref.watch(weekStartProvider);
    final startsOnMonday = weekStart == WeekStart.monday;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Strip the time so a habit created at 9pm still counts as "created today".
    // Add .toLocal() on createdAt if Supabase hands it back as UTC.
    final createdDay = DateTime(
      widget.createdAt.year,
      widget.createdAt.month,
      widget.createdAt.day,
    );

    final canGoForward = _monthIndex(_month) < _monthIndex(now);
    // Stop at the creation month: earlier pages would be all dimmed numbers.
    final canGoBack = _monthIndex(_month) > _monthIndex(createdDay);

    // DateTime.weekday is Mon=1..Sun=7. Subtract the week's first weekday and
    // wrap with % 7 to get the blank cells before the 1st for either start day.
    // (Dart's % never returns negatives when the divisor is positive.)
    final firstWeekday = startsOnMonday ? DateTime.monday : DateTime.sunday;
    final leadingBlanks = (_month.weekday - firstWeekday) % 7;

    final weekdayLabels = startsOnMonday
        ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
        : const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    // ---------- END NEW ----------

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final textColor = isDark ? ColorPicker.darkTextTitle : ColorPicker.ink500;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: canGoBack ? () => _changeMonth(-1) : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Text(
              '${_months[_month.month - 1]} ${_month.year}',
              style: context.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            IconButton(
              // null disables the button and greys it out automatically.
              onPressed: canGoForward ? () => _changeMonth(1) : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final d in weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: context.small.copyWith(
                      fontSize: 13,
                      color: ColorPicker.ink400,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // shrinkWrap + NeverScrollable because this lives inside your
        // SingleChildScrollView. Two scrollables would fight each other.
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          children: [
            // Empty cells push day 1 under the right weekday column.
            for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
            for (var day = 1; day <= daysInMonth; day++)
              _buildDay(
                context,
                DateTime(_month.year, _month.month, day),
                today,
                createdDay,
                textColor,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDay(
    BuildContext context,
    DateTime date,
    DateTime today,
    DateTime createdDay,
    Color textColor,
  ) {
    final isDone = widget.dayKeys.contains(_dayKeyOf(date));
    final isToday = date == today;
    // final isFuture = date.isAfter(today);
    // Future days and pre-creation days both can't have a check-in, so they
    // share one dimmed style. isDone is checked first below, so a real
    // check-in always wins even if the dates somehow disagree.
    final isOutOfRange = date.isAfter(today) || date.isBefore(createdDay);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? ColorPicker.success : null,
        // Ring (not fill) for today, so "today" and "done" can both be true
        // and still read as two different things.
        border: isToday && !isDone
            ? Border.all(color: ColorPicker.sky400, width: 1.5)
            : null,
      ),
      child: Text(
        '${date.day}',
        style: context.small.copyWith(
          fontWeight: isDone || isToday ? FontWeight.w700 : FontWeight.w400,
          color: isDone
              ? Colors.white
              : (isOutOfRange ? textColor.withValues(alpha: 0.35) : textColor),
        ),
      ),
    );
  }
}

// class _LastSevenDaysCard extends StatelessWidget {
//   const _LastSevenDaysCard({required this.dayKeys});

//   final Set<int> dayKeys;

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark ? ColorPicker.darkSurfaceCard : ColorPicker.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: isDark
//               ? const Color.fromARGB(255, 56, 56, 56)
//               : ColorPicker.ink100,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Last 7 days',
//             style: context.body.copyWith(
//               fontWeight: FontWeight.w700,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 12),
//           LastSevenDaysDateSection(checkinDayKeysForHabit: dayKeys),
//         ],
//       ),
//     );
//   }
// }

class _CheckInButton extends StatelessWidget {
  const _CheckInButton({required this.isDone, required this.onTap});

  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDone
              ? ColorPicker.success
              : (isDark ? ColorPicker.ink50 : ColorPicker.ink900),
          borderRadius: BorderRadius.circular(14),
          border: isDone
              ? null
              : Border.all(color: ColorPicker.ink200, width: 1.5),
          boxShadow: isDone
              ? [
                  BoxShadow(
                    color: const Color(0xFF101620).withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDone)
              const Icon(Icons.check_rounded, size: 20, color: Colors.white),
            if (isDone) const SizedBox(width: 8),
            Text(
              isDone ? 'Done' : 'Mark as done',
              style: context.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDone
                    ? Colors.white
                    : isDark
                    ? ColorPicker.ink900
                    : ColorPicker.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
