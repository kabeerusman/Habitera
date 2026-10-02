import 'package:flutter/material.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/utils/extensions.dart';

class TypeChip extends StatelessWidget {
  const TypeChip({super.key, required this.type});

  final int type;

  @override
  Widget build(BuildContext context) {
    final isStart = type == 0;
    final bg = isStart ? ColorPicker.chipStartBg : ColorPicker.chipBreakBg;
    final fg = isStart ? ColorPicker.chipStartText : ColorPicker.chipBreakText;
    final label = isStart ? 'START' : 'BREAK';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(50)),
      child: Text(
        label,
        style: context.small.copyWith(
          color: fg,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
