import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key, required this.type});

  // late TextEditingController titleController;
  final HabitType type;

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final textController = TextEditingController();

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

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  var selectedTime = TimeOfDay(hour: 8, minute: 0);

  var switchValue = false;

  var selectedEmoji = kDefaultHabitEmoji;

  @override
  Widget build(BuildContext context) {
    final title = widget.type == HabitType.startHabit
        ? 'Create New Habit'
        : 'Break A Bad Habit';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: padAll16,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          // Transform.scale(
                          //   scaleX: 0.9,
                          //   scaleY: 0.8,
                          //   // scale: 0.8,
                          //   child: Switch(
                          //     padding: EdgeInsets.zero,
                          //     materialTapTargetSize:
                          //         MaterialTapTargetSize.shrinkWrap,
                          //     // minimumSize: Size.zero,
                          //     value: switchValue,
                          //     onChanged: (newValue) {
                          //       setState(() {
                          //         switchValue = newValue;
                          //       });
                          //     },
                          //   ),
                          // ),
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
              // print(timeOfDay);
              if (!_formKey.currentState!.validate()) return;

              setState(() => _isSubmitting = true);

              final repository = ref.read(habitRepositoryProvider);

              // final habit = HabitIsar()
              //   ..title = textController.text
              //   ..type = widget.type.index
              //   ..frequency = _selectedFrequency.index
              //   ..createdAt = DateTime.now();
              final habit = Habit(
                userId: '',
                title: textController.text,
                type: widget.type.index,
                createdAt: DateTime.now(),
                frequency: _selectedFrequency.index,
                reminderTime: switchValue ? selectedTime : null,
                emoji: selectedEmoji,
              );

              final addedHabit = await repository.addHabit(habit);

              final remindersEnabled = ref.read(remindersEnabledProvider);
              if (addedHabit.reminderTime != null && remindersEnabled) {
                NotificationService.scheduleReminder(
                  id: addedHabit.notificationId!,
                  title: addedHabit.title,
                  body: reminderBody,
                  hour: addedHabit.reminderTime!.hour,
                  minute: addedHabit.reminderTime!.minute,
                );
              }

              ref.invalidate(habitsProvider);

              textController.clear();
              if (!context.mounted) return;
              context.pop(true);
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
  final AddHabitScreen widget;
  final HabitFrequency selectedFrequency;
  final bool isSubmitting;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? ColorPicker.sky600 : ColorPicker.ink900,
        foregroundColor: isDark ? ColorPicker.darkTextTitle : ColorPicker.white,
      ),
      onPressed: !isSubmitting ? onPressed : null,
      child: isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
          : Text('Add'),
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
    return Container(
      // color: Colors.red.shade200,
      // height: 55.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.formTitle),
          kSizedBoxH8,
          TextFormField(
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
        ],
      ),
    );
  }
}
