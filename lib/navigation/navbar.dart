import 'package:flutter/material.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/features/habit_tracker/presentation/habits_screen.dart';
import 'package:habitera/features/habit_tracker/presentation/settings_screen.dart';
import 'package:habitera/features/habit_tracker/presentation/today_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final _screens = const [TodayScreen(), HabitsScreen(), SettingsScreen()];

  var _currentIndex = 0;

  static const _navigationDestinations = [
    NavigationDestination(
      icon: Icon(Icons.check_circle_outline_rounded),
      selectedIcon: Icon(Icons.check_circle_rounded),
      label: 'Today',
    ),
    NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'Habits'),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Each screen owns its own Scaffold/FAB (the FAB is Today-only in v2;
      // Habits gets a header add-icon-button instead), so this outer
      // Scaffold only hosts the shared bottom nav.
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? ColorPicker.darkBorderSubtle
                  : Colors.grey.shade300,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: _navigationDestinations,
        ),
      ),
    );
  }
}

// class _NavBarState extends State<NavBar> {
//   final screens = [
//     const HabitsScreen(),
//     // const ChatsScreen(),
//     // AddHabitScreen(type: ,),
//     // const ShopScreen(),
//     const ProfileScreen(),
//   ];

//   var _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: screens[_currentIndex],
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _currentIndex,
//         onDestinationSelected: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         destinations: [
//           const NavigationDestination(
//             icon: Icon(Icons.punch_clock_rounded),
//             label: 'Habits',
//           ),
//           // const NavigationDestination(icon: Icon(Icons.people), label: 'Chats'),
//           // CircleAvatar(
//           //   radius: 30.0,
//           //   backgroundColor: Colors.indigoAccent,
//           //   child: IconButton(
//           //     // onPressed: () => context.goNamed(AppRoutes.addHabitsScreen.name),
//           //     onPressed: () {
//           //       showModalBottomSheet(
//           //         context: context,
//           //         builder: (_) => HabitTypeBottomSheet(),
//           //       );
//           //     },
//           //     icon: const Icon(Icons.add),
//           //   ),
//           // ),
//           // const NavigationDestination(
//           //   icon: Icon(Icons.shopping_bag_rounded),
//           //   label: 'Shop',
//           // ),
//           const NavigationDestination(
//             icon: Icon(Icons.person_rounded),
//             label: 'Profile',
//           ),
//         ],
//       ),
//       // floatingActionButton: CircleAvatar(
//       //   radius: 30.0,
//       //   backgroundColor: const Color.fromARGB(255, 163, 164, 175),
//       //   child: IconButton(
//       //     // onPressed: () => context.goNamed(AppRoutes.addHabitsScreen.name),
//       //     onPressed: () {
//       //       showModalBottomSheet(
//       //         context: context,
//       //         builder: (_) => HabitTypeBottomSheet(),
//       //       );
//       //     },
//       //     icon: const Icon(Icons.add),
//       //   ),
//       // ),
//     );
//   }
// }
