// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_unnecessary_containers
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import 'package:habitera/constants/enums.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/constants/texts.dart';
import 'package:habitera/features/habit_tracker/data/models/habit.dart';
import 'package:habitera/features/habit_tracker/data/models/habit_isar.dart';
import 'package:habitera/features/habit_tracker/data/repositories/habit_repository.dart';
import 'package:habitera/features/habit_tracker/presentation/habit_provider.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/date_section.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/habit_type_bottom_sheet.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/type_chip.dart';
import 'package:habitera/notification_service.dart';
import 'package:habitera/router/app_router.dart';
import 'package:habitera/utils/created_date.dart';
import 'package:habitera/utils/extensions.dart';

// -----------------------------
//* THIS SCREEN IS WHERE THE HABITS ARE SHOWN
// -----------------------------

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  late String currentGreeting;
  late Timer timer;

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
    final habits = ref.watch(habitsProvider);
    print('Habits in HabitsScreen: ${habits.value}');
    final doneHabitIdsAsync = ref.watch(doneHabitIdsProvider);
    final doneHabitIds = doneHabitIdsAsync.value ?? <String>{};

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kSizedBoxH10,
              Text(
                currentGreeting,
                style: context.screenTitle.copyWith(fontSize: 30.0),
              ),
              kSizedBoxH10,
              DateSection(),
              kSizedBoxH20,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'YOUR HABITS',
                    // 'TODAY',
                    style: context.sectionTitle,
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: habits.when(
                  data: (habits) {
                    if (habits.isEmpty) {
                      return EmptyState();
                    }
                    //*  Testing purpose only
                    // return Center(
                    //   child: Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       ElevatedButton(
                    //         onPressed: () {
                    //           NotificationService.showInstantNotifications(
                    //             title: 'Habit Reminder',
                    //             body: 'Time to: ',
                    //           );
                    //         },
                    //         child: Text('Show Instant notification'),
                    //       ),
                    //       ElevatedButton(
                    //         onPressed: () {
                    //           NotificationService.scheduleReminder(
                    //             id: 1,
                    //             title: 'Scheduled Reminder',
                    //             body: 'Time to work on your habit',
                    //             hour: 11,
                    //             minute: 40,
                    //           );
                    //           // title: 'Habit Reminder',
                    //           // body: 'Time to: ',
                    //         },
                    //         child: Text('Show Scheduled notification'),
                    //       ),
                    //     ],
                    //   ),
                    // );

                    return HabitListView(
                      doneHabitIds: doneHabitIds,
                      habits: habits,
                    );
                  },
                  error: (error, _) {
                    var message = 'Something went wrong. Try again';
                    if (error is SocketException) {
                      return Center(
                        child: Text('Please check your internet connection'),
                      );
                    }
                    return Center(child: Text(message));
                  },
                  loading: () =>
                      Center(child: CircularProgressIndicator.adaptive()),
                )
              ),
              // CreateHabitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 90.0),
          kSizedBoxH10,
          Text(
            'No habits yet',
            style: context.screenTitle.copyWith(fontSize: 19),
          ),
          kSizedBoxH8,
          Text(
            'Create your first habit to get started',
            style: context.body.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class HabitListView extends ConsumerWidget {
  const HabitListView({
    super.key,
    required this.doneHabitIds,
    required this.habits,
  });

  final Set<String> doneHabitIds;
  final List<Habit> habits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemBuilder: (_, i) {
        final habit = habits[i];
        final isDone = doneHabitIds.contains(habit.id);
        return HabitTile(
          habit: habit,
          type: habit.type,
          habitTitle: habit.title,
          createdAt: habit.createdAt,
          onEdit: () {
            context.goNamed(AppRoutes.editHabitsScreen.name, extra: habit);
            // print('Edit habit: ${habit.title}');
          },
          onTapDelete: () {
            final habitToDelete = habit;
            final indexOfHabitToDelete = habits.indexOf(habitToDelete);

            ref.read(habitsProvider.notifier).deleteHabit(habitToDelete.id);
            // print('Habits after onTapDelete $habits');

            if (habit.reminderTime != null) {
              NotificationService.cancelNotification(
                habitToDelete.notificationId!,
              );
            }

            if (!context.mounted) return;

            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                duration: Duration(seconds: 8),
                content: Text('Habit deleted'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () async {
                    final restoredHabit = await ref
                        .read(habitsProvider.notifier)
                        .restoreDeletedHabit(
                          habitToDelete,
                          indexOfHabitToDelete,
                        );

                    NotificationService.scheduleReminder(
                      id: restoredHabit.notificationId!,
                      title: restoredHabit.title,
                      body: reminderBody,
                      hour: restoredHabit.reminderTime!.hour,
                      minute: restoredHabit.reminderTime!.minute,
                    );

                    messenger.showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text('Habit restored'),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          isDone: isDone,
          onChanged: (value) async {
              // ref.read(doneHabitIdsProvider.notifier).toggleDone(habit.id);
            try {
              ref.read(doneHabitIdsProvider.notifier).toggleDone(habit.id);
            } catch (e) {
              print('ERROR FROM CHECKIN: $e');
            }
            // print('aaaaa');
          },
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 10.0),
      itemCount: habits.length,
    );
  }
}

class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.habitTitle,
    required this.type,
    required this.createdAt,
    this.onEdit,
    this.onDelete,
    this.onTapDelete,
    required this.habit,
    this.onChanged,
    required this.isDone,
  });

  final String habitTitle;
  // final String habitCreatedTime;
  final int type;
  final DateTime createdAt;
  // final VoidCallback? onEdit;
  final void Function()? onDelete;
  final void Function()? onEdit;
  final void Function()? onTapDelete;
  final void Function(bool?)? onChanged;
  final Habit habit;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(habit.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              onEdit?.call();
            },
            icon: Icons.edit,
            backgroundColor: Colors.grey,
          ),
          SlidableAction(
            onPressed: (_) {
              onTapDelete?.call();
            },
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
          // height: 113.0,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(13.0),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            habitTitle,
                            style: context.body.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            // style: context.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily • ${createdDate(createdAt)}',
                          style: context.small.copyWith(
                            // color: Colors.black38,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TypeChip(type: type),
                      ],
                    ),
                    //. Checkbox
                    Checkbox(
                      value: isDone,
                      activeColor: Colors.green,
                      onChanged: onChanged,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 6,
                top: 2,
                child: Container(
                  // color: Colors.orange.shade200,
                  // height: 10,
                  child: PopupMenuButton(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.more_horiz),

                    itemBuilder: (_) {
                      return [
                        PopupMenuItem(
                          onTap: onEdit,
                          child: Text(
                            'Edit',
                            style: context.body.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                            // style: context.textTheme.bodyLarge?.copyWith(
                            //   fontSize: 15,
                            // ),
                          ),
                        ),

                        PopupMenuItem(
                          onTap: onTapDelete,
                          child: Text(
                            'Delete',
                            style: context.body.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                            // style: context.textTheme.bodyLarge?.copyWith(
                            //   fontSize: 15,
                            // ),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class CreateHabitButton extends StatelessWidget {
//   const CreateHabitButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text('Create new habit', style: context.textTheme.bodyLarge),
//         IconButton(
//           onPressed: () async {
//             final type = await showModalBottomSheet<HabitType>(
//               context: context,
//               builder: (_) => HabitTypeBottomSheet(),
//             );

//             if (type == null || !context.mounted) return;

//             final added = await context.pushNamed<bool>(
//               AppRoutes.addHabitsScreen.name,
//               pathParameters: {'type': type.name},
//             );

//             if (!context.mounted) return;

//             if (added == true) {
//               final messenger = ScaffoldMessenger.of(context);
//               messenger.hideCurrentSnackBar();
//               messenger.showSnackBar(
//                 SnackBar(
//                   duration: Duration(seconds: 2),
//                   content: Text('Habit added'),
//                 ),
//               );
//             }
//           },
//           icon: Icon(Icons.add),
//         ),
//       ],
//     );
//   }
// }

//* FOR ISAR
// class HabitsScreen extends ConsumerStatefulWidget {
//   const HabitsScreen({super.key});

//   @override
//   ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
// }

// class _HabitsScreenState extends ConsumerState<HabitsScreen> {
//   late String currentGreeting;
//   late Timer timer;

//   @override
//   void initState() {
//     super.initState();
//     currentGreeting = Greeting.currentGreeting;

//     timer = Timer.periodic(const Duration(minutes: 1), (timer) {
//       final newGreeting = Greeting.currentGreeting;
//       if (newGreeting != currentGreeting) {
//         setState(() {
//           currentGreeting = newGreeting;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final habits = ref.watch(habitsProvider);

//     final doneHabitIdsAsync = ref.watch(doneHabitIdsProvider);
//     final doneHabitIds = doneHabitIdsAsync.value ?? <int>{};

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               kSizedBoxH10,
//               Text(
//                 currentGreeting,
//                 style: GoogleFonts.nunitoSans(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 30.0,
//                 ),
//               ),
//               kSizedBoxH10,
//               DateSection(),
//               kSizedBoxH20,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'YOUR HABITS',
//                     // 'TODAY',
//                     style: GoogleFonts.nunitoSans(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 15.0,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Text(
//                         'SORT',
//                         style: context.textTheme.bodyLarge?.copyWith(
//                           // color: Colors.black38,
//                           // color: Theme.of(context).colorScheme.onSurfaceVariant,
//                           fontSize: 15.0,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.filter_list),
//                         onPressed: () {},
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10.0),
//               Expanded(
//                 child: habits.when(
//                   data: (habits) {
//                     if (habits.isEmpty) {
//                       return Center(
//                         child: Column(
//                           children: [
//                             Text('No habits yet'),
//                             Text('Create a your first habit to get started'),
//                           ],
//                         ),
//                       );
//                     }

//                     return HabitListView(
//                       doneHabitIds: doneHabitIds,
//                       habits: habits,
//                     );
//                   },
//                   error: (error, stack) => Center(child: Text('Error: $error')),
//                   loading: () =>
//                       Center(child: CircularProgressIndicator.adaptive()),
//                 ),
//               ),
//               CreateHabitButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class HabitListView extends ConsumerWidget {
//   const HabitListView({
//     super.key,
//     required this.doneHabitIds,
//     required this.habits,
//   });

//   final Set<int> doneHabitIds;
//   final List<HabitIsar> habits;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ListView.separated(
//       itemBuilder: (_, i) {
//         final habit = habits[i];
//         final isDone = doneHabitIds.contains(habit.id);
//         return HabitTile(
//           habit: habit,
//           type: habit.type,
//           habitTitle: habit.title,
//           createdAt: habit.createdAt,
//           onDelete: () async {
//             ref.read(habitsProvider.notifier).deleteHabit(habit.id);
//           },
//           onTapDelete: () async {
//             final deletedHabit = habit;
//             ref.read(habitsProvider.notifier).deleteHabit(deletedHabit.id);

//             if (!context.mounted) return;

//             final messenger = ScaffoldMessenger.of(context);
//             messenger.hideCurrentSnackBar();
//             messenger.showSnackBar(
//               SnackBar(
//                 duration: Duration(seconds: 8),
//                 content: Text('Habit deleted'),
//                 action: SnackBarAction(
//                   label: 'UNDO',
//                   onPressed: () async {
//                     ref.read(habitsProvider.notifier).addHabit(habit);

//                     messenger.showSnackBar(
//                       SnackBar(
//                         duration: Duration(seconds: 2),
//                         content: Text('Habit restored'),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             );
//           },
//           isDone: isDone,
//           onChanged: (value) async {
//             ref.read(doneHabitIdsProvider.notifier).toggleDone(habit.id);
//           },
//         );
//       },
//       separatorBuilder: (_, _) => const SizedBox(height: 10.0),
//       itemCount: habits.length,
//     );
//   }
// }

// class HabitTile extends StatelessWidget {
//   const HabitTile({
//     super.key,
//     required this.habitTitle,
//     required this.type,
//     required this.createdAt,
//     this.onEdit,
//     this.onDelete,
//     this.onTapDelete,
//     required this.habit,
//     this.onChanged,
//     required this.isDone,
//   });

//   final String habitTitle;
//   // final String habitCreatedTime;
//   final int type;
//   final DateTime createdAt;
//   final VoidCallback? onEdit;
//   final Future<void> Function()? onDelete;
//   final void Function()? onTapDelete;
//   final void Function(bool?)? onChanged;
//   final HabitIsar habit;
//   final bool isDone;

//   @override
//   Widget build(BuildContext context) {
//     return Slidable(
//       key: UniqueKey(),
//       endActionPane: ActionPane(
//         motion: const StretchMotion(),
//         children: [
//           SlidableAction(
//             onPressed: (_) {},
//             icon: Icons.edit,
//             backgroundColor: Colors.grey,
//           ),
//           SlidableAction(
//             onPressed: (_) async {
//               await onDelete?.call();
//             },
//             icon: Icons.delete,
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () {
//           context.goNamed(
//             AppRoutes.habitDetailsScreen.name,
//             extra: habit,

//             // extra: HabitDetailsArgs(
//             //   habit: habit,
//             //   isDone: isDone,
//             //   onChanged: onChanged,
//             // ),
//           );
//         },
//         child: Container(
//           height: 113.0,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(13.0),
//           ),
//           child: Container(
//             // color: Colors.blue.shade200,
//             child: Stack(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10.0,
//                     vertical: 10.0,
//                   ),

//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         // color: Colors.red.shade200,

//                         // height: 20,
//                         child: Row(
//                           // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 habitTitle,
//                                 style: context.textTheme.bodyLarge,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         // color: Colors.green.shade200,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,

//                           children: [
//                             Text(
//                               'Daily • ${createdDate(createdAt)}',
//                               style: context.textTheme.bodySmall?.copyWith(
//                                 // color: Colors.black38,
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.onSurfaceVariant,
//                               ),
//                             ),
//                             TypeChip(type: type),
//                           ],
//                         ),
//                       ),
//                       //. Checkbox
//                       Checkbox(
//                         value: isDone,
//                         activeColor: Colors.green,
//                         onChanged: onChanged,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Positioned(
//                   right: 6,
//                   top: 2,
//                   child: Container(
//                     // color: Colors.orange.shade200,
//                     // height: 10,
//                     child: PopupMenuButton(
//                       padding: EdgeInsets.zero,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(Icons.more_horiz),

//                       itemBuilder: (_) {
//                         return [
//                           PopupMenuItem(
//                             onTap: () {
//                               context.goNamed(
//                                 AppRoutes.editHabitsScreen.name,
//                                 extra: habit,
//                               );
//                             },
//                             child: Text('Edit'),
//                           ),

//                           PopupMenuItem(
//                             onTap: onTapDelete,
//                             child: Text('Delete'),
//                           ),
//                         ];
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CreateHabitButton extends StatelessWidget {
//   const CreateHabitButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text('Create new habit', style: context.textTheme.bodyLarge),
//         IconButton(
//           onPressed: () async {
//             final type = await showModalBottomSheet<HabitType>(
//               context: context,
//               builder: (_) => HabitTypeBottomSheet(),
//             );

//             if (type == null || !context.mounted) return;

//             final added = await context.pushNamed<bool>(
//               AppRoutes.addHabitsScreen.name,
//               pathParameters: {'type': type.name},
//             );

//             if (!context.mounted) return;

//             if (added == true) {
//               final messenger = ScaffoldMessenger.of(context);
//               messenger.hideCurrentSnackBar();
//               messenger.showSnackBar(
//                 SnackBar(
//                   duration: Duration(seconds: 2),
//                   content: Text('Habit added'),
//                 ),
//               );
//             }
//           },
//           icon: Icon(Icons.add),
//         ),
//       ],
//     );
//   }
// }
