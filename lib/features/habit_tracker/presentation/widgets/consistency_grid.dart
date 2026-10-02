import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/utils/date_utils.dart';

/// Check-in consistency heatmap: one column per week, one cell per day.
/// Column count is derived from available width (measured, never clipped),
/// showing the most recent weeks. design/Habitera Design System/components/today/ConsistencyGrid.jsx
///
/// A single habit's history is binary per day (checked in or not), unlike
/// the design reference's multi-habit aggregate, so only the empty (level 0)
/// and full (level 3, `success`) cell colours are ever used here.
class ConsistencyGrid extends StatelessWidget {
  const ConsistencyGrid({
    super.key,
    required this.dayKeys,
    this.cell = 10,
    this.gap = 3,
    this.maxWeeks = 26,
  });

  final Set<int> dayKeys;
  final double cell;
  final double gap;
  final int maxWeeks;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 300.0;
        final fitCols = math.max(8, ((width + gap) / (cell + gap)).floor());
        final cols = math.min(maxWeeks, fitCols);

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final todayWeekday = today.weekday % 7; // Sun=0 .. Sat=6
        final totalDays = cols * 7;
        final start = today.subtract(Duration(days: totalDays - 1 - todayWeekday));

        final columns = <Widget>[];
        final monthLabels = <Widget>[];
        for (var w = 0; w < cols; w++) {
          final weekStart = start.add(Duration(days: w * 7));
          if (w % 5 == 0) {
            final labelCols = math.min(5, cols - w);
            monthLabels.add(
              SizedBox(
                width: (cell + gap) * labelCols,
                child: Text(
                  _months[weekStart.month - 1],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: ColorPicker.ink400,
                  ),
                ),
              ),
            );
          }

          final cells = <Widget>[];
          for (var d = 0; d < 7; d++) {
            final date = weekStart.add(Duration(days: d));
            final isFuture = date.isAfter(today);
            final isDone = !isFuture && dayKeys.contains(dayKey(date));
            cells.add(
              Padding(
                padding: EdgeInsets.only(bottom: d == 6 ? 0 : gap),
                child: Container(
                  width: cell,
                  height: cell,
                  decoration: BoxDecoration(
                    color: isFuture
                        ? Colors.transparent
                        : (isDone ? ColorPicker.success : ColorPicker.ink100),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            );
          }
          columns.add(
            Padding(
              padding: EdgeInsets.only(right: w == cols - 1 ? 0 : gap),
              child: Column(children: cells),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: monthLabels),
            const SizedBox(height: 6),
            Row(mainAxisSize: MainAxisSize.min, children: columns),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Less', style: TextStyle(fontSize: 11, color: ColorPicker.ink400)),
                const SizedBox(width: 4),
                _legendDot(ColorPicker.ink100),
                _legendDot(ColorPicker.success.withValues(alpha: 0.28)),
                _legendDot(ColorPicker.success.withValues(alpha: 0.58)),
                _legendDot(ColorPicker.success),
                const SizedBox(width: 4),
                const Text('More', style: TextStyle(fontSize: 11, color: ColorPicker.ink400)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _legendDot(Color color) => Container(
    width: 9,
    height: 9,
    margin: const EdgeInsets.symmetric(horizontal: 1),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
  );
}
