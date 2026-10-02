import 'package:flutter/material.dart';
import 'package:habitera/constants/color_picker.dart';

class AppInputDecorationTheme {
  // Radius/border widths follow the design system's input tokens:
  // design/Habitera Design System/tokens/radius.css (10 for inputs) and
  // colors.css (--border-default, 1.5px --brand focus).
  static final appInputDecorationTheme = InputDecorationTheme(
    contentPadding: const EdgeInsets.all(8.0),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: ColorPicker.ink200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: ColorPicker.sky400, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: ColorPicker.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: ColorPicker.danger, width: 1.5),
    ),
    floatingLabelBehavior: FloatingLabelBehavior.never,
  );
}
