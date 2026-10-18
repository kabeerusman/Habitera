import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitera/constants/enums.dart';
import 'package:habitera/constants/texts.dart';
import 'package:habitera/features/habit_tracker/presentation/providers/habit_provider.dart';
import 'package:habitera/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'settings_theme_mode';
const _kWeekStartKey = 'settings_week_start';
const _kRemindersEnabledKey = 'settings_reminders_enabled';
const _kDefaultReminderMinutesKey = 'settings_default_reminder_minutes';

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeModeKey);
    if (saved == null) return;
    state = ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class WeekStartController extends Notifier<WeekStart> {
  @override
  WeekStart build() {
    _load();
    return WeekStart.monday;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kWeekStartKey);
    if (saved == null) return;
    state = WeekStart.values.firstWhere(
      (value) => value.name == saved,
      orElse: () => WeekStart.monday,
    );
  }

  Future<void> setWeekStart(WeekStart value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWeekStartKey, value.name);
  }
}

final weekStartProvider = NotifierProvider<WeekStartController, WeekStart>(
  WeekStartController.new,
);

class RemindersEnabledController extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_kRemindersEnabledKey);
    if (saved == null) return;
    state = saved;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRemindersEnabledKey, value);

    if (value) {
      await _rescheduleAll();
    } else {
      await NotificationService.cancelAllNotifications();
    }
  }

  // Per-habit reminderTime/notificationId are left alone when the master
  // switch is off (add/edit habit skip actually scheduling, see
  // add_habit_screen.dart / edit_habit_screen.dart) — so turning it back on
  // just needs to replay whatever the habits already have set.
  Future<void> _rescheduleAll() async {
    final habits = await ref.read(habitsProvider.future);
    for (final habit in habits) {
      final reminderTime = habit.reminderTime;
      final notificationId = habit.notificationId;
      if (reminderTime == null || notificationId == null) continue;
      await NotificationService.scheduleReminder(
        id: notificationId,
        title: habit.title,
        body: reminderBody,
        hour: reminderTime.hour,
        minute: reminderTime.minute,
      );
    }
  }
}

final remindersEnabledProvider =
    NotifierProvider<RemindersEnabledController, bool>(
      RemindersEnabledController.new,
    );

class DefaultReminderTimeController extends Notifier<TimeOfDay> {
  @override
  TimeOfDay build() {
    _load();
    return const TimeOfDay(hour: 8, minute: 0);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt(_kDefaultReminderMinutesKey);
    if (minutes == null) return;
    state = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  Future<void> setTime(TimeOfDay time) async {
    state = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _kDefaultReminderMinutesKey,
      time.hour * 60 + time.minute,
    );
  }
}

final defaultReminderTimeProvider =
    NotifierProvider<DefaultReminderTimeController, TimeOfDay>(
      DefaultReminderTimeController.new,
    );
