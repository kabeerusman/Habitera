import 'package:habitera/constants/enums.dart';

int dayKey(DateTime date) {
  final local = date.toLocal();
  return local.year * 10000 + local.month * 100 + local.day;
  //. YYYYMMDD
}

DateTime dayKeyToDate(int dayKey) {
  final year = dayKey ~/ 10000;
  final month = (dayKey % 10000) ~/ 100;
  final day = dayKey % 100;
  return DateTime(year, month, day);
}

int calculateStreak(Set<int> completedDayKeys) {
  final now = DateTime.now();
  var day = DateTime(now.year, now.month, now.day);

  if (!completedDayKeys.contains(dayKey(day))) {
    day = DateTime(day.year, day.month, day.day - 1);
  }
  // -------------

  var streak = 0;
  while (completedDayKeys.contains(dayKey(day))) {
    streak++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return streak;
}

List<int> currentWeekDayKeys(WeekStart weekStart) {
  final today = DateTime.now();
  final todayOnly = DateTime(today.year, today.month, today.day);
  final offset = weekStart == WeekStart.monday
      ? todayOnly.weekday -
            1 // Mon=1 -> 0 ... Sun=7 -> 6
      : todayOnly.weekday % 7; // Sun=7 -> 0, Mon=1 -> 1 ... Sat=6 -> 6
  final start = todayOnly.subtract(Duration(days: offset));
  return List.generate(7, (i) => dayKey(start.add(Duration(days: i))));
}

int calculateBestStreak(Set<int> completedDayKeys) {
  if (completedDayKeys.isEmpty) return 0;

  final dates = completedDayKeys.map(dayKeyToDate).toList()..sort();

  var best = 1;
  var current = 1;
  for (var i = 1; i < dates.length; i++) {
    // final diff = dates[i].difference(dates[i - 1]).inDays;
    final diff = (dates[i].difference(dates[i - 1]).inHours / 24).round();
    if (diff == 1) {
      current++;
    } else if (diff > 1) {
      current = 1;
    }
    if (current > best) best = current;
  }
  return best;
}
