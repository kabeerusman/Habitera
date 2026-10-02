import 'package:flutter/material.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/utils/extensions.dart';

/// Daily completion bar — "N of M done".
/// design/Habitera Design System/components/today/ProgressBar.jsx
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.max,
    required this.label,
    this.height = 8,
  });

  final int value;
  final int max;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.body.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: height,
            width: double.infinity,
            color: ColorPicker.ink100,
            alignment: Alignment.centerLeft,
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOut,
              widthFactor: pct,
              child: Container(color: ColorPicker.sky400),
            ),
          ),
        ),
      ],
    );
  }
}
