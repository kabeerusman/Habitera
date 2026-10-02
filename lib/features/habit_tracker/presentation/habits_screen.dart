import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/enums.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/constants/texts.dart';
import 'package:habitera/features/habit_tracker/data/models/habit.dart';
import 'package:habitera/features/habit_tracker/presentation/habit_provider.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/habit_emoji.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/habit_type_bottom_sheet.dart';
import 'package:habitera/notification_service.dart';
import 'package:habitera/router/app_router.dart';
import 'package:habitera/utils/extensions.dart';

/// Manage list (tab 2) — see and manage all habits. No check-ins here,
/// that's Today's job. design/Habitera Design System/ui_kits/habitera_app_v2/HabitsScreenV2.jsx
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Habits', style: context.screenTitle.copyWith(fontSize: 30)),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: () => _openAddHabitFlow(context),
                      icon: const Icon(Icons.add_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: ColorPicker.ink50,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              kSizedBoxH20,
              Expanded(
                child: habitsAsync.when(
                  data: (habits) {
                    if (habits.isEmpty) {
                      return const _HabitsEmptyState();
                    }
                    return SingleChildScrollView(
                      child: _HabitsCard(habits: habits),
                    );
                  },
                  error: (error, _) {
                    final message = error is SocketException
                        ? 'Please check your internet connection'
                        : 'Something went wrong. Try again';
                    return Center(child: Text(message));
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator.adaptive()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openAddHabitFlow(BuildContext context) async {
  final type = await showModalBottomSheet<HabitType>(
    context: context,
    builder: (_) => const HabitTypeBottomSheet(),
  );

  if (type == null || !context.mounted) return;

  final added = await context.pushNamed<bool>(
    AppRoutes.addHabitsScreen.name,
    pathParameters: {'type': type.name},
  );

  if (!context.mounted) return;

  if (added == true) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        content: Text('Habit added'),
      ),
    );
  }
}

void _deleteHabit(BuildContext context, WidgetRef ref, Habit habitToDelete) {
  final habits = ref.read(habitsProvider).value ?? [];
  final indexOfHabitToDelete = habits.indexOf(habitToDelete);

  ref.read(habitsProvider.notifier).deleteHabit(habitToDelete.id);

  if (habitToDelete.reminderTime != null) {
    NotificationService.cancelNotification(habitToDelete.notificationId!);
  }

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 8),
      content: const Text('Habit deleted'),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () async {
          final restoredHabit = await ref
              .read(habitsProvider.notifier)
              .restoreDeletedHabit(habitToDelete, indexOfHabitToDelete);

          if (restoredHabit.reminderTime != null) {
            NotificationService.scheduleReminder(
              id: restoredHabit.notificationId!,
              title: restoredHabit.title,
              body: reminderBody,
              hour: restoredHabit.reminderTime!.hour,
              minute: restoredHabit.reminderTime!.minute,
            );
          }

          messenger.showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 2),
              content: Text('Habit restored'),
            ),
          );
        },
      ),
    ),
  );
}

class _HabitsEmptyState extends StatelessWidget {
  const _HabitsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ColorPicker.sky50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              size: 52,
              color: ColorPicker.sky400,
            ),
          ),
          kSizedBoxH20,
          Text(
            'No habits yet',
            style: context.screenTitle.copyWith(fontSize: 19),
          ),
          kSizedBoxH8,
          Text(
            'Create your first habit to get started',
            textAlign: TextAlign.center,
            style: context.body.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: ColorPicker.ink500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitsCard extends StatelessWidget {
  const _HabitsCard({required this.habits});

  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorPicker.ink100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101620).withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          habits.length,
          (i) => _HabitListRow(habit: habits[i], showDivider: i > 0),
        ),
      ),
    );
  }
}

class _HabitListRow extends ConsumerWidget {
  const _HabitListRow({required this.habit, required this.showDivider});

  final Habit habit;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(
      habitStatsProvider(habit.id, habit.createdAt),
    );
    final streak = statsAsync.valueOrNull?.currentStreak ?? 0;

    return Slidable(
      key: ValueKey(habit.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) =>
                context.goNamed(AppRoutes.editHabitsScreen.name, extra: habit),
            icon: Icons.edit,
            backgroundColor: Colors.grey,
          ),
          SlidableAction(
            onPressed: (_) => _deleteHabit(context, ref, habit),
            icon: Icons.delete,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          context.goNamed(AppRoutes.habitDetailsScreen.name, extra: habit);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(minHeight: 44),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(top: BorderSide(color: ColorPicker.ink100))
                : null,
          ),
          child: Row(
            children: [
              HabitEmoji(emoji: habit.emoji, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.body.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        style: context.small.copyWith(color: ColorPicker.ink500),
                        children: [
                          const TextSpan(text: 'Every day'),
                          if (streak > 0)
                            TextSpan(
                              text: '  ·  🔥 $streak',
                              style: const TextStyle(color: ColorPicker.ember600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: ColorPicker.ink400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
