import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/features/settings/presentation/settings_provider.dart';
import 'package:habitera/utils/date_utils.dart';
import 'package:habitera/utils/extensions.dart';
import 'package:intl/intl.dart';

/// The current-week header — design system's DateStrip. Monday/Sunday-first
/// per the Settings "week starts on" preference.
class DateSection extends ConsumerWidget {
  const DateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = ref.watch(weekStartProvider);
    final dayKeys = currentWeekDayKeys(weekStart);
    final today = dayKey(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isToday = dayKeys[index] == today;
        return DateColumn(dayKeys: dayKeys, index: index, isToday: isToday);
      }),
    );
  }
}

class DateColumn extends StatelessWidget {
  const DateColumn({
    super.key,
    required this.dayKeys,
    required this.index,
    required this.isToday,
  });

  final List<int> dayKeys;
  final int index;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final date = dayKeyToDate(dayKeys[index]);
    final labelStyle = context.body.copyWith(
      fontSize: 14.0,
      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
      color: isToday ? ColorPicker.sky800 : null,
    );

    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(DateFormat('EEE').format(date).toLowerCase(), style: labelStyle),
        Text('${date.day}', style: labelStyle),
      ],
    );

    if (!isToday) return column;

    return Container(
      width: 40.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: ColorPicker.sky50,
        border: Border.all(color: ColorPicker.sky400, width: 1.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: column,
    );
  }
}
