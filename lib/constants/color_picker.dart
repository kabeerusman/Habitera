import 'package:flutter/material.dart';

class ColorPicker {
  ColorPicker._();

  static const Color dividerColor = Color(0xFFD1D1D6);
  static const Color scaffoldBg = Color.fromARGB(255, 234, 234, 238);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color navBarIcon = Color.fromARGB(255, 105, 105, 105);
  static const Color red = Colors.red;

  // ---- v2 design tokens (design/Habitera Design System/tokens/colors.css) ----
  static const Color sky400 = Color(0xFF38B6FF); // brand
  static const Color sky500 = Color(0xFF12A2F5); // brand hover
  static const Color sky600 = Color(0xFF0186D4); // brand press
  static const Color sky50 = Color(0xFFF0F9FF); // brand tint
  static const Color sky100 = Color(0xFFDDF1FF); // brand tint strong
  static const Color sky800 = Color(0xFF0A5A8B); // brand ink

  static const Color ink50 = Color(0xFFF5F6F7); // surface card
  static const Color ink100 = Color(0xFFEEEFF1); // surface card strong / sunken
  static const Color ink200 = Color(0xFFD1D1D6); // border default
  static const Color ink400 = Color(0xFF8D8E97); // text faint
  static const Color ink500 = Color(0xFF696969); // text muted
  static const Color ink900 = Color(0xFF14151A); // text title / primary action

  static const Color success = Color(0xFF4CAF50);
  static const Color successTint = Color(0xFFEDF8EE);

  static const Color danger = Color(0xFFF44336);

  static const Color ember500 = Color(0xFFFF7A1A); // streak
  static const Color ember50 = Color(0xFFFFF3E8); // streak tint
  static const Color ember600 = Color(0xFFE15F05); // streak ink

  static const Color chipStartBg = Color(0xFFDDF1FF);
  static const Color chipStartText = Color(0xFF0A5A8B);
  static const Color chipBreakBg = Color(0xFFFFE2CB);
  static const Color chipBreakText = Color(0xFFE15F05);

  static const Color emojiTintNeutral = Color(0xFFEEEFF1);

  // ---- dark-mode tokens (design/Habitera Design System/tokens/colors.css [data-theme="dark"]) ----
  static const Color darkBgApp = Color(0xFF0F1115);
  static const Color darkSurfaceCard = Color(0xFF191D23);
  static const Color darkSurfaceCardStrong = Color(0xFF1F242C);
  static const Color darkSurfaceNav = Color(0xFF14171C);
  static const Color darkBorderSubtle = Color(0xFF23282F);
  static const Color darkBorderDefault = Color(0xFF2C323B);
  static const Color darkDivider = Color(0xFF23282F);

  static const Color darkTextTitle = Color(0xFFF4F6F8);
  static const Color darkTextBody = Color(0xFFE3E7EC);
  static const Color darkTextMuted = Color(0xFF9AA2AD);
  static const Color darkTextFaint = Color(0xFF767E89);

  static const Color darkBrand = Color(0xFF5CC4FF);
  static const Color darkBrandTint = Color.fromRGBO(56, 182, 255, 0.14);

  static const Color darkActionSolid = Color(0xFFF4F6F8);
  static const Color darkActionSolidText = Color(0xFF10131A);
  static const Color darkActionQuiet = Color(0xFF23282F);

  static const Color darkDanger = Color(0xFFFF6152);
}
