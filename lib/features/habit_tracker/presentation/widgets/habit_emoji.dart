import 'package:flutter/material.dart';
import 'package:habitera/constants/color_picker.dart';

/// A habit's emoji in a tinted circle — the habit's visual identity.
/// design/Habitera Design System/components/today/HabitEmoji.jsx
///
/// The design kit supports per-habit tint colours (sky/green/ember/teal/
/// violet), but the Habit model only stores an emoji, not a colour — adding
/// a tint would need a schema change that wasn't part of this pass. Every
/// circle uses the brand sky tint for now; the tint is purely decorative
/// (completion is always shown via the green check, never this colour), so
/// that's a safe simplification.
class HabitEmoji extends StatelessWidget {
  const HabitEmoji({super.key, required this.emoji, this.size = 40});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        // color: ColorPicker.sky100,
        shape: BoxShape.circle,
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: size * 0.5, height: 1),
        strutStyle: StrutStyle(
          fontSize: size * 0.5,
          height: 1,
          forceStrutHeight: true,
        ),
      ),
    );
  }
}
