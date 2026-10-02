import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/features/habit_tracker/data/models/habit.dart';
import 'package:habitera/features/habit_tracker/presentation/habit_provider.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/consistency_grid.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/habit_emoji.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/last_seven_days_date_section.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/stat_card.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/type_chip.dart';
import 'package:habitera/router/app_router.dart';
import 'package:habitera/utils/extensions.dart';

/// The habit-details screen: stats, consistency grid, and the last-7-days
/// strip, rebuilt against the v2 design (design/Habitera Design System/
/// screens/HabitDetail.jsx). Streak/completion numbers all come from
/// habitStatsProvider, which already folds in today's optimistic check-in
/// state so this screen doesn't need to compute that overlay itself.
class HabitDetailsScreen extends ConsumerStatefulWidget {
  const HabitDetailsScreen({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends ConsumerState<HabitDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(
      habitStatsProvider(widget.habit.id, widget.habit.createdAt),
    );
    final stats = statsAsync.valueOrNull;
    final dayKeys = stats?.dayKeys ?? <int>{};

    final doneHabitIdsAsync = ref.watch(doneHabitIdsProvider);
    final isDone = doneHabitIdsAsync.valueOrNull?.contains(widget.habit.id) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit'),
        actions: [
          TextButton(
            onPressed: () => context.goNamed(
              AppRoutes.editHabitsScreen.name,
              extra: widget.habit,
            ),
            child: Text(
              'Edit',
              style: context.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: ColorPicker.sky400,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(habit: widget.habit),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      emoji: '🔥',
                      value: '${stats?.currentStreak ?? 0}',
                      label: 'Current streak',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      emoji: '🏆',
                      value: '${stats?.bestStreak ?? 0}',
                      label: 'Best streak',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _ConsistencyCard(dayKeys: dayKeys),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      value: '${stats?.totalCheckins ?? 0}',
                      label: 'Total check-ins',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: '${((stats?.completionRate ?? 0) * 100).round()}%',
                      label: 'Completion rate',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _LastSevenDaysCard(dayKeys: dayKeys),
              const SizedBox(height: 15),
              _CheckInButton(
                isDone: isDone,
                onTap: () => ref
                    .read(doneHabitIdsProvider.notifier)
                    .toggleDone(widget.habit.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HabitEmoji(emoji: habit.emoji, size: 52),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.title,
                style: context.body.copyWith(fontWeight: FontWeight.w700, fontSize: 19),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Every day', style: context.small.copyWith(color: ColorPicker.ink500)),
                  if (habit.reminderTime != null) ...[
                    Text('  ·  ', style: context.small.copyWith(color: ColorPicker.ink500)),
                    const Icon(Icons.alarm_rounded, size: 14, color: ColorPicker.ink500),
                    const SizedBox(width: 2),
                    Text(
                      habit.reminderTime!.format(context),
                      style: context.small.copyWith(color: ColorPicker.ink500),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              TypeChip(type: habit.type),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard({required this.dayKeys});

  final Set<int> dayKeys;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorPicker.ink100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consistency',
                style: context.body.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Text('Daily check-ins', style: context.small.copyWith(color: ColorPicker.ink400)),
            ],
          ),
          const SizedBox(height: 10),
          ConsistencyGrid(dayKeys: dayKeys),
        ],
      ),
    );
  }
}

class _LastSevenDaysCard extends StatelessWidget {
  const _LastSevenDaysCard({required this.dayKeys});

  final Set<int> dayKeys;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorPicker.ink100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 7 days',
            style: context.body.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          LastSevenDaysDateSection(checkinDayKeysForHabit: dayKeys),
        ],
      ),
    );
  }
}

class _CheckInButton extends StatelessWidget {
  const _CheckInButton({required this.isDone, required this.onTap});

  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDone ? ColorPicker.success : ColorPicker.ink50,
          borderRadius: BorderRadius.circular(14),
          border: isDone ? null : Border.all(color: ColorPicker.ink200, width: 1.5),
          boxShadow: isDone
              ? [
                  BoxShadow(
                    color: const Color(0xFF101620).withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDone) const Icon(Icons.check_rounded, size: 20, color: Colors.white),
            if (isDone) const SizedBox(width: 8),
            Text(
              isDone ? 'Done' : 'Mark as done',
              style: context.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDone ? Colors.white : ColorPicker.ink900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
