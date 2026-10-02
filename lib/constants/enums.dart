enum Greeting {
  morning('Good Morning', 0, 12),
  afternoon('Good Afternoon', 12, 18),
  evening('Good Evening', 18, 24);

  final String text;
  final int startHour;
  final int endHour;
  const Greeting(this.text, this.startHour, this.endHour);

  static String get currentGreeting {
    final currentHour = DateTime.now().hour;

    return Greeting.values.firstWhere((greeting) {
      return currentHour >= greeting.startHour &&
          currentHour < greeting.endHour;
    }).text;
  }

}

enum HabitType {
  startHabit,
  breakHabit,
}

enum HabitFrequency {
  hourly,
  daily,
  weekly,
}

enum HabitMenuAction { edit, delete }

enum WeekStart {
  monday('Monday'),
  sunday('Sunday');

  final String label;
  const WeekStart(this.label);
}

/// Habit identity emoji choices — design/Habitera Design System handoff README.
const kHabitEmojiChoices = [
  '✨', '🍎', '📖', '🏃', '💧', '🧘', '💊', '🛏️', '🚭', '🍩', '📵', '🎯',
];

const kDefaultHabitEmoji = '✨';

//* For testing purposes
  // static Greeting get current {
  //   final now = DateTime.now();
  //   final hour = now.hour;
  //   final minute = now.minute;

  //   // Modify the condition for testing to check hour and minute
  //   if (hour == 11 && minute >= 58) {
  //     return Greeting.afternoon; // Simulate switch at 11:58 AM
  //   } else if (hour == 18 && minute >= 25) {
  //     return Greeting.afternoon; // Simulate switch at 5:58 PM
  //   } else if (hour >= 0 && hour < 12) {
  //     return Greeting.morning;
  //   } else if (hour >= 12 && hour < 18) {
  //     return Greeting.afternoon;
  //   } else {
  //     return Greeting.evening;
  //   }
  // }










//* Method 2 for the currentGreeting method
// static String get currentGreeting {
//   final currentHour = DateTime.now().hour;
//   late String current;

//   for (var greeting in Greeting.values) {
//     if (currentHour >= greeting.startHour && currentHour < greeting.endHour) {
//       current = greeting.text;
//     }
//   }
//   return current;
// }


//* OLD enum code
// enum Greeting {
//   morning('Good Morning.'),
//   afternoon('Good Afternoon.'),
//   evening('Good Evening.');

//   final String text;
//   const Greeting(this.text);
// }
// 'Good Morning'
// 'Good Afternoon'
// 'Good Evening'


