import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/enums.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/constants/texts.dart';
import 'package:habitera/features/habit_tracker/data/models/habit.dart';
import 'package:habitera/features/habit_tracker/data/models/habit_isar.dart';
import 'package:habitera/features/habit_tracker/presentation/providers/habit_provider.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/custom_switch.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/emoji_picker_field.dart';
import 'package:habitera/features/settings/presentation/settings_provider.dart';
import 'package:habitera/notification_service.dart';
import 'package:habitera/utils/extensions.dart';
import 'package:habitera/utils/time_picker.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  const EditHabitScreen({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  late final TextEditingController textController;

  final _formKey = GlobalKey<FormState>();

  HabitFrequency _selectedFrequency = HabitFrequency.daily;

  Set<HabitFrequency> _selectedFrequencies = {HabitFrequency.daily};

  bool _isSubmitting = false;

  final List<ButtonSegment<HabitFrequency>> _frequencySegments = [
    ButtonSegment(
      value: HabitFrequency.hourly,
      label: Text('Hourly'),
      enabled: false,
    ),
    ButtonSegment(value: HabitFrequency.daily, label: Text('Daily')),
    ButtonSegment(
      value: HabitFrequency.weekly,
      label: Text('Weekly'),
      enabled: false,
    ),
  ];

  TimeOfDay? _timeOfDay;
  late TimeOfDay selectedTime;
  late bool switchValue;
  late String selectedEmoji;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.habit.title);
    selectedEmoji = widget.habit.emoji;
    if (widget.habit.reminderTime != null) {
      selectedTime = TimeOfDay(
        hour: widget.habit.reminderTime!.hour,
        minute: widget.habit.reminderTime!.minute,
      );
    } else {
      selectedTime = TimeOfDay(hour: 8, minute: 0);
    }

    switchValue = widget.habit.reminderTime != null;
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.habit);
    print(switchValue);
    final habit = widget.habit;

    return Scaffold(
      appBar: AppBar(title: Text('Edit Habit')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Icon', style: context.formTitle),
                      ),
                      kSizedBoxH8,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: EmojiPickerField(
                          selectedEmoji: selectedEmoji,
                          onChanged: (emoji) =>
                              setState(() => selectedEmoji = emoji),
                        ),
                      ),
                      kSizedBoxH15,
                      TitleField(
                        controller: textController,
                        title: 'Title',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      kSizedBoxH8,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Frequency', style: context.formTitle),
                      ),
                      kSizedBoxH8,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SegmentedButton(
                          segments: _frequencySegments,
                          selected: _selectedFrequencies,
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _selectedFrequencies = newSelection;
                              _selectedFrequency = newSelection.first;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Hourly & Weekly coming soon',
                          style: context.body.copyWith(
                            color: ColorPicker.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      kSizedBoxH8,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Set Reminder', style: context.formTitle),
                          CustomSwitch(
                            width: 47,
                            height: 26,
                            value: switchValue,
                            onChanged: (newValue) {
                              setState(() {
                                switchValue = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                      kSizedBoxH8,
                      if (switchValue == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded),
                                kSizedBoxW8,
                                Text(
                                  selectedTime.format(context),
                                  style: context.body.copyWith(fontSize: 17),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () async {
                                final picked = await pickTime(
                                  context,
                                  selectedTime,
                                );
                                if (picked != null) {
                                  setState(() => selectedTime = picked);
                                }
                              },
                              icon: Icon(Icons.edit_rounded),
                            ),
                          ],
                        ),
                    ],
                  ),
                  // AddHabitButton(
                  //   formKey: _formKey,
                  //   ref: ref,
                  //   textController: textController,
                  //   widget: widget,
                  //   selectedFrequency: _selectedFrequency,
                  //   isSubmitting: _isSubmitting,
                  //   onPressed: () async {
                  //     FocusScope.of(context).unfocus();
                  //     if (!_formKey.currentState!.validate()) return;

                  //     setState(() => _isSubmitting = true);

                  //     final repository = ref.read(habitRepositoryProvider);

                  //     final editedHabit = habit.copyWith(
                  //       title: textController.text,
                  //       frequency: _selectedFrequency.index,
                  //       reminderTime: switchValue ? selectedTime : null,
                  //         notificationId:
                  //             habit.notificationId ??
                  //             repository.generateNotificationId(),
                  //     );
                  //     await repository.editHabit(editedHabit);

                  //     // ----------------------------------------

                  //     final hadReminder = habit.reminderTime != null;
                  //     final wantsReminder = switchValue;

                  //     // * Decide notificationId properly
                  //     // * This means the habit didn't have a reminder upon adding it and now i want to add, so notificationId is created

                  //     // *  This means that the reminder hasn't been set before
                  //     var notificationId = habit.notificationId;

                  //     if (wantsReminder && notificationId == null) {
                  //       notificationId = repository.generateNotificationId();
                  //     }

                  //     // if (hadReminder) {
                  //     //   NotificationService.cancelNotification(
                  //     //     habit.notificationId!,
                  //     //   );
                  //     // }
                  //     // if (wantsReminder) {
                  //     //   NotificationService.scheduleReminder(
                  //     //     id: editedHabit.notificationId!,
                  //     //     title: editedHabit.title,
                  //     //     body: reminderBody,
                  //     //     hour: editedHabit.reminderTime!.hour,
                  //     //     minute: editedHabit.reminderTime!.minute,
                  //     //   );
                  //     // }
                  //     // ----------------------------------------

                  //     // if(!wantsReminder) {

                  //     // }

                  //     ref.invalidate(habitsProvider);

                  //     if (context.mounted) {
                  //       context.pop();
                  //     }
                  //   },
                  // ),
                  //* CASE 1: Had reminder, change time, cancel old reminder, schedule new one
                  //* CASE 2: Had reminder, turn off reminder, cancel old reminder, don't schedule
                  //* CASE 3: No reminder, turn on reminder, schedule new one
                  // -----------------
                  //* When i turn off the switch and tap the edit button :
                  //*    - I am navigated back to the habits screen and The reminder is actually cancelled ✅
                  //* When i tap to edit the habit again from habits screen
                  //*    - The switch is on like i never turned it off and the reminder is set again as a result❌
                  //* In the print satetement that shows all habits
                  //*    - The reminderTime for the habit is not cleared
                  //*    - The notificationId for the habit is not cleared
                  //* So it's like when i turn off the switch and the switchValue becomes false, the reminderTime and notificationId don't turn to null

                  // -----------------

                  //* When i turn off the switch and tap the edit button :
                  //*    - I am navigated back to the habits screen and The reminder is actually cancelled ✅
                  //* When i tap to edit the habit again from habits screen
                  //*    - The switch is on like i never turned it off and the reminder is set again as a result❌
                  //* In the print satetement that shows all habits
                  //*    - The reminderTime for the habit is not cleared
                  //*    - The notificationId for the habit is not cleared
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: AddHabitButton(
            formKey: _formKey,
            ref: ref,
            textController: textController,
            widget: widget,
            selectedFrequency: _selectedFrequency,
            isSubmitting: _isSubmitting,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if (!_formKey.currentState!.validate()) return;

              setState(() => _isSubmitting = true);

              final repository = ref.read(habitRepositoryProvider);

              // ----------------------------------------
              var notificationId = habit.notificationId;

              final hadReminder = habit.reminderTime != null;
              final wantsReminder = switchValue;
              final doesNotHaveReminder = notificationId == null;

              if (wantsReminder && doesNotHaveReminder) {
                notificationId = repository.generateNotificationId();
              }

              final editedHabit = habit.copyWith(
                title: textController.text,
                frequency: _selectedFrequency.index,
                reminderTime: switchValue ? selectedTime : null,
                notificationId: notificationId,
                emoji: selectedEmoji,
              );
              await repository.editHabit(editedHabit);

              final remindersEnabled = ref.read(remindersEnabledProvider);

              if (hadReminder && wantsReminder) {
                NotificationService.cancelNotification(habit.notificationId!);
                if (remindersEnabled) {
                  NotificationService.scheduleReminder(
                    id: editedHabit.notificationId!,
                    title: editedHabit.title,
                    body: reminderBody,
                    hour: editedHabit.reminderTime!.hour,
                    minute: editedHabit.reminderTime!.minute,
                  );
                }
              }

              if (hadReminder && !wantsReminder) {
                NotificationService.cancelNotification(habit.notificationId!);
              }
              if (!hadReminder && wantsReminder && remindersEnabled) {
                NotificationService.scheduleReminder(
                  id: editedHabit.notificationId!,
                  title: editedHabit.title,
                  body: reminderBody,
                  hour: editedHabit.reminderTime!.hour,
                  minute: editedHabit.reminderTime!.minute,
                );
              }

              ref.invalidate(habitsProvider);

              if (context.mounted) {
                context.pop();
              }
            },
          ),
        ),
      ),
    );
  }
}

class AddHabitButton extends StatelessWidget {
  const AddHabitButton({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.ref,
    required this.textController,
    required this.widget,
    required this.selectedFrequency,
    required this.isSubmitting,
    required this.onPressed,
    // required this.isValid,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final WidgetRef ref;
  final TextEditingController textController;
  final EditHabitScreen widget;
  final HabitFrequency selectedFrequency;
  final bool isSubmitting;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: !isSubmitting ? onPressed : null,
      child: isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
          : Text('Edit'),
    );
  }
}

class TitleField extends StatelessWidget {
  const TitleField({
    super.key,
    required this.title,
    this.prefixIcon,
    this.label,
    this.isDense,
    this.validator,
    this.onChanged,
    this.focusedBorder,
    this.enabledBorder,
    this.controller,
    this.suffixIcon,
    // required this.isCorrect
  });

  final String title;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? label;
  final bool? isDense;
  final Function(String)? onChanged;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextEditingController? controller;
  // final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.labelLarge),
        kSizedBoxH8,
        SizedBox(
          height: 50.0,
          child: TextFormField(
            controller: controller,
            validator: validator,
            onChanged: onChanged,

            // style: context.textTheme.bodySmall?.copyWith(fontSize: 14),
            // keyboardType: TextInputType.name,
            decoration: InputDecoration(
              isDense: isDense,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 34.5,
                minHeight: 48,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              label: label,
              focusedBorder: focusedBorder,
              enabledBorder: enabledBorder,
              //     .inputDecorationTheme
              //     .focusedBorder
              //     ?.copyWith(
              //         borderSide: BorderSide(
              //             color: isCorrect ? Colors.green : black3)),
            ),
          ),
        ),
      ],
    );
  }
}
