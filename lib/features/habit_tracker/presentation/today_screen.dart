import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/enums.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/features/habit_tracker/data/models/habit.dart';
import 'package:habitera/features/habit_tracker/presentation/providers/habit_provider.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/habit_type_bottom_sheet.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/progress_bar.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/today_row.dart';
import 'package:habitera/router/app_router.dart';
import 'package:habitera/utils/extensions.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  late String currentGreeting;
  late Timer timer;

  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    currentGreeting = Greeting.currentGreeting;

    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final newGreeting = Greeting.currentGreeting;
      if (newGreeting != currentGreeting) {
        setState(() {
          currentGreeting = newGreeting;
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final doneHabitIdsAsync = ref.watch(doneHabitIdsProvider);
    final doneHabitIds = doneHabitIdsAsync.valueOrNull ?? <String>{};
    final user = Supabase.instance.client.auth.currentUser;
    final name = (user?.userMetadata?['name'] as String?)
        ?.trim()
        .split(' ')
        .first;

    // ------------- NEW: fires only when doneHabitIds *changes*
    ref.listen(doneHabitIdsProvider, (prev, next) {
      final habits = ref.read(habitsProvider).valueOrNull;
      final before = prev?.valueOrNull;
      final after = next.valueOrNull;

      // Bail out if anything hasn't loaded yet. The `before == null` check
      // matters most: on app launch the provider goes loading -> data, and
      // without this guard that first load would look like "just finished
      // everything" and fire confetti on every cold start.
      if (habits == null || habits.isEmpty || before == null || after == null) {
        return;
      }

      bool allDone(Set<String> ids) => habits.every((h) => ids.contains(h.id));

      // Only celebrate the transition not-done -> done, not "still done".
      if (!allDone(before) && allDone(after)) {
        setState(() => _showConfetti = true);
      }
    });
    // -------------

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Text(
                    'Today',
                    style: context.screenTitle.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name == null || name.isEmpty
                        ? currentGreeting
                        : '$currentGreeting, $name',
                    style: context.body.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: isDark
                          ? ColorPicker.darkTextTitle
                          : ColorPicker.ink500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        DateFormat(
                          'EEEE, MMMM d',
                        ).format(DateTime.now()).toUpperCase(),
                        style: context.small.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.44,
                          color: ColorPicker.ink400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: habitsAsync.when(
                      data: (habits) {
                        if (habits.isEmpty) {
                          return const _TodayEmptyState();
                        }
                        final doneCount = habits
                            .where((h) => doneHabitIds.contains(h.id))
                            .length;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProgressBar(
                              value: doneCount,
                              max: habits.length,
                              label: '$doneCount of ${habits.length} done',
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: _TodayList(
                                habits: habits,
                                doneHabitIds: doneHabitIds,
                              ),
                            ),
                          ],
                        );
                      },
                      error: (error, _) {
                        final message = (error is SocketException)
                            ? 'Please check your internet connection'
                            : 'Something went wrong. Try again';
                        return Center(child: Text(message));
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showConfetti)
            // Positioned.fill covers the whole screen (including under the
            // status bar), which is why it's outside the SafeArea.
            Positioned.fill(
              // IgnorePointer so taps still reach the habit rows underneath
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/animations/confetti.json',
                  repeat: false,
                  fit: BoxFit.cover,
                  // Remove the widget when the animation ends so it isn't
                  // left in the tree, and the next completion starts fresh.
                  onLoaded: (composition) {
                    Future.delayed(composition.duration, () {
                      if (mounted) setState(() => _showConfetti = false);
                    });
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: isDark
            ? ColorPicker.sky600
            // ? ColorPicker.sky400.withValues(alpha: 0.8)
            : ColorPicker.sky400,
        onPressed: () async {
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
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TodayList extends ConsumerWidget {
  const _TodayList({required this.habits, required this.doneHabitIds});

  final List<Habit> habits;
  final Set<String> doneHabitIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: habits.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final habit = habits[i];
        final done = doneHabitIds.contains(habit.id);
        final statsAsync = ref.watch(
          habitStatsProvider(habit.id, habit.createdAt),
        );
        return TodayRow(
          emoji: habit.emoji,
          title: habit.title,
          // streak: statsAsync.valueOrNull?.currentStreak ?? 0,
          streak: statsAsync.valueOrNull?.currentStreak,
          done: done,
          onToggle: () =>
              ref.read(doneHabitIdsProvider.notifier).toggleDone(habit.id),
          onOpen: () =>
              context.goNamed(AppRoutes.habitDetailsScreen.name, extra: habit),
        );
      },
    );
  }
}

class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState();

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
