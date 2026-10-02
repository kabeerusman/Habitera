// will handle all isar operations so the ui doesn't handle that
// will handle saving and loading of habits from the database so the ui doesn't need to know how data is stored
import 'package:habitera/features/habit_tracker/data/models/habit.dart';
import 'package:habitera/features/habit_tracker/data/models/habit_isar.dart';
import 'package:habitera/isar_service.dart';
// import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//* REVIEW and Implement:
// int? notificationId = habit.notificationId;

// if (habit.reminderTime != null && notificationId == null) {
//   notificationId = generateNotificationId();
// }
final _supabase = Supabase.instance.client;
final userId = _supabase.auth.currentUser!.id;

class HabitRepository {
  Future<Habit> addHabit(Habit habit) async {
    int? notificationId;

    if (habit.reminderTime != null) {
      notificationId = generateNotificationId();
      // print(notificationId);
    }

    final newHabit = habit.copyWith(
      userId: userId,
      notificationId: notificationId,
    );

    final result = await _supabase
        .from('habits')
        .insert(newHabit.toMap())
        .select()
        .single();
    return Habit.fromMap(result);
  }

  Future<List<Habit>> getHabits() async {
    print('getHabits called, userId: $userId');
    final rawHabits = await _supabase
        .from('habits')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    print('Habits from getHabis in Repository: $rawHabits');
    final habits = rawHabits.map((habit) => Habit.fromMap(habit)).toList();

    return habits;
  }

  Future<void> editHabit(Habit habit) async {
    final editedHabitItems = {
      'title': habit.title,
      'frequency': habit.frequency,
      'reminder_hour': habit.reminderTime?.hour,
      'reminder_minute': habit.reminderTime?.minute,
      'notification_id': habit.notificationId,
      'emoji': habit.emoji,
    };
    await _supabase.from('habits').update(editedHabitItems).eq('id', habit.id);
  }

  Future<void> deleteHabit(String habitId) async {
    await _supabase.from('habits').delete().eq('id', habitId);
  }

  int generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch % 100000;
  }
}

// class HabitRepository {
//   Future<void> addHabit(HabitIsar habit) async {
//     await IsarService.isar.writeTxn(() async {
//       await IsarService.isar.habitIsars.put(habit);
//     });
//   }

//   Future<void> editHabit(HabitIsar habit) async {
//     await IsarService.isar.writeTxn(() async {
//       await IsarService.isar.habitIsars.put(habit);
//     });
//   }

//   Future<List<HabitIsar>> getHabits() async {
//     return await IsarService.isar.habitIsars.where().findAll();
//   }

//   Future<void> deleteHabit(int habitId) async {
//     await IsarService.isar.writeTxn(() async {
//       await IsarService.isar.habitIsars.delete(habitId);
//     });
//   }
// }
