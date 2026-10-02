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
  var currentDay = dayKey(DateTime.now());
  var streak = 0;

  while (completedDayKeys.contains(currentDay)) {
    final dayBeforeDateTime = dayKeyToDate(currentDay).subtract(Duration(days: 1));
    currentDay = dayKey(dayBeforeDateTime);
    streak++;
  }
  return streak;
}

// Unlike calculateStreak (which only cares about the run ending today),
// this scans a habit's whole check-in history to find the longest run
// that ever happened, even if it's since been broken.
//
// dayKeys aren't sequential integers (231231 -> 240101 jumps by 8870,
// not 1) because they're a YYYYMMDD encoding, so we can't compare keys
// directly to detect "consecutive". Instead we convert every key back to
// a real DateTime, sort them chronologically, and walk the sorted list:
// a 1-day gap between neighbours extends the current run, anything else
// (a gap > 1, i.e. a missed day) resets it back to 1. `best` tracks the
// longest run seen at any point during that walk.
// The current calendar week's dayKeys, oldest-to-newest, with the first
// cell picked by the Settings "week starts on" preference — so DateStrip
// and WeekProgress reorder together instead of always starting Monday.
List<int> currentWeekDayKeys(WeekStart weekStart) {
  final today = DateTime.now();
  final todayOnly = DateTime(today.year, today.month, today.day);
  final offset = weekStart == WeekStart.monday
      ? todayOnly.weekday - 1 // Mon=1 -> 0 ... Sun=7 -> 6
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
    final diff = dates[i].difference(dates[i - 1]).inDays;
    if (diff == 1) {
      current++;
    } else if (diff > 1) {
      current = 1;
    }
    if (current > best) best = current;
  }
  return best;
}
