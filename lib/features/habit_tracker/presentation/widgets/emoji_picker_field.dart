import 'package:flutter/material.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/enums.dart';

/// Inline emoji picker for the Add/Edit habit forms: every choice from
/// kHabitEmojiChoices shown at once in a grey circle, with the selected
/// one highlighted by a coloured ring — matches the "Icon" section of the
/// v2 Create New Habit screen. A trailing "+" tile lets the user type any
/// emoji of their own via the system emoji keyboard; once picked, that
/// custom emoji takes the "+" tile's place so it stays visible/editable.
class EmojiPickerField extends StatelessWidget {
  const EmojiPickerField({
    super.key,
    required this.selectedEmoji,
    required this.onChanged,
  });

  final String selectedEmoji;
  final ValueChanged<String> onChanged;

  Future<void> _pickCustomEmoji(BuildContext context) async {
    final controller = TextEditingController(
      text: kHabitEmojiChoices.contains(selectedEmoji) ? '' : selectedEmoji,
    );

    final picked = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Choose an emoji'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28),
            decoration: const InputDecoration(counterText: ''),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );

    if (picked != null && picked.isNotEmpty) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = !kHabitEmojiChoices.contains(selectedEmoji);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...kHabitEmojiChoices.map((emoji) {
          final isSelected = emoji == selectedEmoji;
          return _EmojiCircle(
            isSelected: isSelected,
            onTap: () => onChanged(emoji),
            child: _EmojiGlyph(emoji),
          );
        }),
        _EmojiCircle(
          isSelected: isCustom,
          onTap: () => _pickCustomEmoji(context),
          child: isCustom
              ? _EmojiGlyph(selectedEmoji)
              : const Icon(Icons.add_rounded, color: ColorPicker.ink500),
        ),
      ],
    );
  }
}

class _EmojiCircle extends StatelessWidget {
  const _EmojiCircle({
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? ColorPicker.sky50 : ColorPicker.ink50,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: ColorPicker.sky400, width: 2)
              : null,
        ),
        child: child,
      ),
    );
  }
}

/// Emoji text with a forced strut height, so it centers vertically in its
/// circle instead of sitting high (most emoji glyphs carry extra descender
/// space that throws off Container's default text baseline centering).
class _EmojiGlyph extends StatelessWidget {
  const _EmojiGlyph(this.emoji);

  final String emoji;
  static const double _fontSize = 20;

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: const TextStyle(fontSize: _fontSize, height: 1),
      strutStyle: const StrutStyle(fontSize: _fontSize, height: 1, forceStrutHeight: true),
    );
  }
}
