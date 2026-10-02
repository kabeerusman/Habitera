import 'package:flutter/material.dart';
import 'package:habitera/constants/enums.dart';

const _keep = Object();

class Habit {
  Habit({
    this.id = "",
    required this.userId,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.frequency,
    this.reminderTime,
    this.notificationId,
    this.emoji = kDefaultHabitEmoji,
  });

  final String id;
  final String userId;
  final String title;
  final int type;
  final DateTime createdAt;
  final int frequency;
  final TimeOfDay? reminderTime;
  final int? notificationId;
  final String emoji;

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    int? type,
    DateTime? createdAt,
    int? frequency,
    Object? reminderTime = _keep,
    Object? notificationId = _keep,
    String? emoji,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime == _keep ? this.reminderTime : reminderTime as TimeOfDay?,
      notificationId: notificationId == _keep ? this.notificationId : notificationId as int?,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'title': title,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'frequency': frequency,
      'reminder_hour': reminderTime?.hour,
      'reminder_minute': reminderTime?.minute,
      'notification_id': notificationId,
      'emoji': emoji,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      type: map['type'] as int,
      createdAt: DateTime.parse(map['created_at']),
      frequency: map['frequency'] as int,
      reminderTime:
          map['reminder_hour'] != null && map['reminder_minute'] != null
          ? TimeOfDay(
              hour: map['reminder_hour'] as int,
              minute: map['reminder_minute'] as int,
            )
          : null,
      notificationId: map['notification_id'] as int?,
      emoji: (map['emoji'] as String?) ?? kDefaultHabitEmoji,
    );
  }
  @override
  String toString() {
    return 'Habit(id: $id, userId: $userId, title: $title, type: $type, createdAt: $createdAt, frequency: $frequency, reminderTime: $reminderTime, notificationId: $notificationId, emoji: $emoji)';
  }
}
  // String toJson() => json.encode(toMap());

  // factory Habit.fromJson(String source) =>
  //     Habit.fromMap(json.decode(source) as Map<String, dynamic>);


  // @override
  // bool operator ==(covariant Habit other) {
  //   if (identical(this, other)) return true;

  //   return other.id == id &&
  //       other.userId == userId &&
  //       other.title == title &&
  //       other.type == type &&
  //       other.createdAt == createdAt &&
  //       other.frequency == frequency;
  // }

  // @override
  // int get hashCode {
  //   return id.hashCode ^
  //       userId.hashCode ^
  //       title.hashCode ^
  //       type.hashCode ^
  //       createdAt.hashCode ^
  //       frequency.hashCode;