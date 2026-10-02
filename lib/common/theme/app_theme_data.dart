import 'package:flutter/material.dart';
import 'package:habitera/common/theme/app_appbar_theme.dart';
import 'package:habitera/common/theme/app_elevated_button_theme.dart';
import 'package:habitera/common/theme/app_input_decoration_theme.dart';
import 'package:habitera/common/theme/app_navbar_theme.dart';
import 'package:habitera/common/theme/app_snackbar_theme.dart';
import 'package:habitera/common/theme/text_theme.dart';
import 'package:habitera/constants/color_picker.dart';
// import 'package:habitera/common/theme/dark_mode.dart';
// import 'package:habitera/common/theme/light_mode.dart';

class AppThemeData {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
    navigationBarTheme: AppNavbarTheme.appNavbarTheme,
    // textTheme: NewAppTextTheme.newAppTextTheme,
    textTheme: AppTextTheme.appTextTheme,
    inputDecorationTheme: AppInputDecorationTheme.appInputDecorationTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.elevatedButtonTheme,
    scaffoldBackgroundColor: ColorPicker.white,
    appBarTheme: AppAppbarTheme.appAppBarTheme,
    snackBarTheme: AppSnackbarTheme.appSnackbarTheme,
    // switchTheme: SwitchThemeData()
    // bottomNavigationBarTheme: BottomNavigationBarThemeData(
    //   backgroundColor: ColorPicker.scaffoldBg,
    //   selectedItemColor: ColorPicker.black,
    //   unselectedItemColor: ColorPicker.grey,
    // ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorPicker.sky400,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: ColorPicker.darkBgApp,
    textTheme: AppTextTheme.appTextTheme.apply(
      bodyColor: ColorPicker.darkTextBody,
      displayColor: ColorPicker.darkTextTitle,
    ),
    dividerColor: ColorPicker.darkDivider,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ColorPicker.darkSurfaceNav,
      height: 50,
      indicatorColor: Colors.transparent,
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => Colors.transparent,
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: ColorPicker.darkTextTitle);
        }
        return const IconThemeData(color: ColorPicker.darkTextMuted);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return AppTextTheme.nunitoSans(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          fontsize: 14,
          color: selected
              ? ColorPicker.darkTextTitle
              : ColorPicker.darkTextMuted,
        );
      }),
      labelPadding: const EdgeInsets.only(bottom: 4),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorPicker.darkBgApp,
      foregroundColor: ColorPicker.darkTextTitle,
      titleTextStyle: AppTextTheme.nunitoSans(
        fontWeight: FontWeight.w700,
        fontsize: 24,
        color: ColorPicker.darkTextTitle,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPicker.darkActionSolid,
        foregroundColor: ColorPicker.darkActionSolidText,
        fixedSize: const Size(double.infinity, 40),
        shape: const StadiumBorder(),
        textStyle: AppTextTheme.nunitoSans(
          fontWeight: FontWeight.w700,
          fontsize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(8.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: ColorPicker.darkBorderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: ColorPicker.darkBrand, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: ColorPicker.darkDanger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: ColorPicker.darkDanger, width: 1.5),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ColorPicker.darkSurfaceCardStrong,
      contentTextStyle: AppTextTheme.nunitoSans(
        color: ColorPicker.darkTextTitle,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

//*  Using provider to switch between the light mode and dark mode (MITCH KOKO's video)
// class ThemeProvider extends ChangeNotifier {
//   ThemeData _themeData = lightMode;

//   ThemeData get themeData => _themeData;

//   bool get isDarkMode => _themeData == darkMode;

//   set themeData(ThemeData themeData) {
//     _themeData = themeData;
//     notifyListeners();
//   }

//   //toggle method to switch between the two
//   void toogleTheme() {
//     if (_themeData == lightMode) {
//       _themeData = darkMode;
//     } else {
//       _themeData = lightMode;
//     }
//     notifyListeners();
//   }
// }
