import 'package:habitera/features/habit_tracker/data/models/habit.dart';
import 'package:habitera/features/habit_tracker/data/models/habit_isar.dart';
import 'package:habitera/features/habit_tracker/data/repositories/checkin_repository.dart';
import 'package:habitera/features/habit_tracker/data/repositories/habit_repository.dart';
// import 'package:habitera/features/habit_tracker/domain/habit.dart';
import 'package:habitera/utils/date_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_provider.g.dart';

@Riverpod(keepAlive: true)
class Habits extends _$Habits {
  late HabitRepository _repo;
  @override
  Future<List<Habit>> build() async {
    _repo = ref.read(habitRepositoryProvider);
    return await _repo.getHabits();
  }

  Future<Habit> addHabit(Habit habit) async {
    final current = state.value ?? [];
    state = AsyncData([...current, habit]);
    final addedHabit = await _repo.addHabit(habit);
    return addedHabit;
    // ref.invalidateSelf();
  }

  Future<Habit> restoreDeletedHabit(Habit habit, int index) async {
    final current = state.value ?? [];
    var newList = [...current];
    newList.insert(index, habit);
    state = AsyncData(newList);

    final restoredHabit = await _repo.addHabit(habit);
    return restoredHabit;
  }

  Future<void> editHabit(Habit habitToEdit) async {
    final current = state.value ?? [];
    final previousState = state;
    state = AsyncData(
      current.map((habit) {
        return habit.id == habitToEdit.id ? habitToEdit : habit;
      }).toList(),
    );
    try {
      await _repo.editHabit(habitToEdit);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    final current = state.value ?? [];
    final previousState = state;
    state = AsyncData(current.where((habit) => habit.id != habitId).toList());
    try {
      await _repo.deleteHabit(habitId);
    } catch (e) {
      state = previousState;
    }
  }
}

@riverpod
HabitRepository habitRepository(HabitRepositoryRef ref) {
  return HabitRepository();
}

@riverpod
CheckinRepository checkinRepository(CheckinRepositoryRef ref) {
  return CheckinRepository();
}

@Riverpod(keepAlive: true)
class DoneHabitIds extends _$DoneHabitIds {
  late CheckinRepository _repo;

  @override
  Future<Set<String>> build() async {
    _repo = ref.read(checkinRepositoryProvider);
    return await _repo.doneHabitIdsToday();
  }

  Future<void> toggleDone(String habitId) async {
    final current = state.value ?? {};
    final exists = current.contains(habitId);
    final newSet = exists
        ? current.where((id) => id != habitId).toSet()
        : {...current, habitId};
    state = AsyncData(newSet);
    print('Done Habit Ids Today: ${state.value}');
    await _repo.toggleDone(habitId);
    // ref.invalidateSelf();
  }
}

@riverpod
Future<Set<int>> checkinDayKeysForHabit(
  CheckinDayKeysForHabitRef ref,
  String habitId,
) async {
  final repo = ref.read(checkinRepositoryProvider);
  return await repo.getCheckinDayKeysForHabit(habitId);
}

/// Derived numbers shown on the habit details screen (stat cards +
/// consistency grid). Bundled into one object so the screen does one
/// `ref.watch` instead of juggling four separate async values.
class HabitStats {
  const HabitStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCheckins,
    required this.completionRate,
    required this.dayKeys,
  });

  final int currentStreak;
  final int bestStreak;
  final int totalCheckins;
  final double completionRate;

  /// Every day (as a dayKey) this habit was checked in, including today's
  /// optimistic state. Reused by the consistency grid so it doesn't need
  /// its own query.
  final Set<int> dayKeys;
}

@riverpod
Future<HabitStats> habitStats(
  HabitStatsRef ref,
  String habitId,
  DateTime createdAt,
) async {
  final repo = ref.read(checkinRepositoryProvider);
  final storedDayKeys = await repo.getAllCheckinDayKeysForHabit(habitId);

  // doneHabitIdsProvider flips instantly on tap, before the write lands in
  // Supabase (see DoneHabitIds.toggleDone). If we only trusted storedDayKeys,
  // stats would lag a beat behind the checkbox on this same screen. So we
  // overlay today's optimistic state onto the persisted history, the same
  // way HabitDetailsScreen already does for the "Last 7 days" strip.
  final doneHabitIdsAsync = ref.watch(doneHabitIdsProvider);
  final isDoneToday = doneHabitIdsAsync.valueOrNull?.contains(habitId) ?? false;
  final today = dayKey(DateTime.now());
  final dayKeys = isDoneToday
      ? {...storedDayKeys, today}
      : storedDayKeys.where((key) => key != today).toSet();

  final totalCheckins = dayKeys.length;

  // Denominator = days since the habit was created (inclusive of today),
  // since HabitFrequency only ships "daily" right now — every day is a
  // scheduled day. Once per-weekday scheduling exists this should only
  // count scheduled days instead.
  final daysSinceCreation = DateTime.now().difference(createdAt).inDays + 1;
  final completionRate = daysSinceCreation > 0
      ? (totalCheckins / daysSinceCreation).clamp(0.0, 1.0)
      : 0.0;

  return HabitStats(
    currentStreak: calculateStreak(dayKeys),
    bestStreak: calculateBestStreak(dayKeys),
    totalCheckins: totalCheckins,
    completionRate: completionRate,
    dayKeys: dayKeys,
  );
}

//* FOR ISAR
// @riverpod
// class Habits extends _$Habits {
//   late HabitRepository _repo;
//   @override
//   Future<List<HabitIsar>> build() async {
//     _repo = ref.read(habitRepositoryProvider);
//     return await _repo.getHabits();
//   }

//   Future<void> addHabit(HabitIsar habit) async {
//     await _repo.addHabit(habit);
//     ref.invalidateSelf();
//   }

//   Future<void> editHabit(HabitIsar habit) async {
//     await _repo.editHabit(habit);
//     ref.invalidateSelf();
//   }

//   Future<void> deleteHabit(int habitId) async {
//     await _repo.deleteHabit(habitId);
//     ref.invalidateSelf();
//   }
// }

// @riverpod
// HabitRepository habitRepository(HabitRepositoryRef ref) {
//   return HabitRepository();
// }

// @riverpod
// CheckinRepository checkinRepository(CheckinRepositoryRef ref) {
//   return CheckinRepository();
// }

// @riverpod
// class DoneHabitIds extends _$DoneHabitIds {
//   late CheckinRepository _repo;

//   @override
//   Future<Set<int>> build() async {
//     _repo = ref.read(checkinRepositoryProvider);
//     return await _repo.doneHabitIdsToday();
//   }

//   Future<void> toggleDone(int habitId) async {
//     await _repo.toggleDone(habitId);
//     ref.invalidateSelf();
//   }
// }

// @riverpod
// Future<Set<int>> checkinDayKeysForHabit(
//   CheckinDayKeysForHabitRef ref,
//   int habitId,
// ) async {
//   final repo = ref.read(checkinRepositoryProvider);
//   return await repo.getCheckinDayKeysForHabit(habitId);
// }
