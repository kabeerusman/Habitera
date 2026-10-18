import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/enums.dart';
import 'package:habitera/constants/sizes.dart';
import 'package:habitera/router/app_router.dart';
import 'package:habitera/utils/extensions.dart';

class HabitTypeBottomSheet extends StatelessWidget {
  const HabitTypeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorPicker.darkBorderDefault : ColorPicker.white,
        borderRadius: BorderRadius.circular(30.0),
      ),
      height: 250,
      width: double.infinity,
      child: Column(
        children: [
          kSizedBoxH10,
          Text('Add a Habit', style: context.sectionTitle),
          kSizedBoxH20,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? ColorPicker.sky600 : ColorPicker.ink900,
              foregroundColor: isDark
                  ? ColorPicker.darkTextTitle
                  : ColorPicker.white,
            ),
            onPressed: () => context.pop(HabitType.startHabit),
            child: Text('Start a Habit'),
          ),
          Text('(e.g. Exercise, Read, Wake up early)'),
          kSizedBoxH15,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? ColorPicker.sky600 : ColorPicker.ink900,
              foregroundColor: isDark
                  ? ColorPicker.darkTextTitle
                  : ColorPicker.white,
            ),
            onPressed: () => context.pop(HabitType.breakHabit),
            child: Text('Break a Habit'),
          ),
          Text('(e.g. Smoking, Sugar, Procrastination)'),
        ],
      ),
    );
  }
}

void goToAddHabit(BuildContext context, HabitType type) async {
  final added = await context.pushNamed<bool>(
    AppRoutes.addHabitsScreen.name,
    pathParameters: {'type': type.name},
  );

  if (context.mounted && added == true) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Habit added')));
  }
}

// class HabitTypeBottomSheet extends StatelessWidget {
//   const HabitTypeBottomSheet({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 250,
//       width: double.infinity,
//       child: Column(
//         children: [
//           kSizedBoxH10,
//           Text('Add a Habit', style: context.textTheme.titleMedium),
//           kSizedBoxH20,
//           ElevatedButton(
//             onPressed: () {
//               context.pop();
//               goToAddHabit(context, HabitType.startHabit);
//             },
//             child: Text('Start a Habit'),
//           ),
//           Text('(e.g. Exercise, Read, Wake up early)'),
//           kSizedBoxH15,
//           ElevatedButton(
//             onPressed: () {
//               context.pop();
//               goToAddHabit(context, HabitType.breakHabit);
//             },
//             child: Text('Break a Habit'),
//           ),
//           Text('(e.g. Smoking, Sugar, Procrastination)'),
//         ],
//       ),
//     );
//   }
// }

// void goToAddHabit(BuildContext context, HabitType type) async {
//   final added = await context.pushNamed<bool>(
//     AppRoutes.addHabitsScreen.name,
//     pathParameters: {'type': type.name},
//   );

//   if (context.mounted && added == true) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Habit added')));
//   }
// }
