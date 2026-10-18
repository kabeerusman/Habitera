import 'package:flutter/material.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/utils/extensions.dart';

/// A single big-number statistic on the habit-details screen.
/// design/Habitera Design System/components/today/StatCard.jsx
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.emoji,
  });

  final String value;
  final String label;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? ColorPicker.darkSurfaceCard : ColorPicker.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color.fromARGB(255, 56, 56, 56)
              : ColorPicker.ink100,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101620).withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 20, height: 1)),
            const SizedBox(height: 2),
          ],
          Text(value, style: context.screenTitle.copyWith(fontSize: 28)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.small.copyWith(
              fontSize: 14,

              color: isDark ? ColorPicker.ink400 : ColorPicker.ink500,
            ),
          ),
        ],
      ),
    );
  }
}
