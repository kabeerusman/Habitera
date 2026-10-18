import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/features/settings/presentation/settings_provider.dart';

import 'package:habitera/utils/date_utils.dart';
import 'package:habitera/utils/extensions.dart';
import 'package:intl/intl.dart';

/// The "Last 7 days" row on habit details — design system's WeekProgress.
/// Shows the current calendar week, first day picked by the Settings
/// "week starts on" preference, so it reorders alongside DateStrip.
class LastSevenDaysDateSection extends ConsumerWidget {
  const LastSevenDaysDateSection({
    super.key,
    required this.checkinDayKeysForHabit,
  });

  final Set<int> checkinDayKeysForHabit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = ref.watch(weekStartProvider);
    final dates = currentWeekDayKeys(weekStart);
    final today = dayKey(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isToday = dates[index] == today;
        final isDone = checkinDayKeysForHabit.contains(dates[index]);

        return DetailsDateColumn(
          dates: dates,
          index: index,
          isToday: isToday,
          isDone: isDone,
        );
      }),
    );
  }
}

class DetailsDateColumn extends StatelessWidget {
  const DetailsDateColumn({
    super.key,
    required this.dates,
    required this.index,
    required this.isToday,
    required this.isDone,
  });

  final List<int> dates;
  final int index;
  final bool isToday;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final date = dayKeyToDate(dates[index]);

    var weekDay = DateFormat('EEE').format(date);
    var dayNumber = date.day;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: isToday
              ? BoxDecoration(
                  // color: ColorPicker.sky50,
                  color: isDark
                      ? ColorPicker.sky800.withValues(alpha: 0.5)
                      : ColorPicker.sky50,
                  border: Border.all(
                    color: isDark
                        ? ColorPicker.sky400.withValues(alpha: 0.7)
                        : ColorPicker.sky400,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekDay.toLowerCase(),
                style: context.small.copyWith(
                  fontSize: 14.0,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  color: isToday
                      ? (isDark ? ColorPicker.sky50 : ColorPicker.sky800)
                      : null,
                ),
              ),
              Text(
                '$dayNumber',
                style: context.small.copyWith(
                  fontSize: 14.0,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  color: isToday
                      ? (isDark ? ColorPicker.sky50 : ColorPicker.sky800)
                      : null,
                ),
              ),
            ],
          ),
        ),
        kSizedBoxH10,
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? ColorPicker.success : Colors.transparent,
            border: isDone ? null : Border.all(color: ColorPicker.ink200),
          ),
        ),
      ],
    );
  }
}
