import 'package:flutter/material.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/constants/enums.dart';
import 'package:habitera/utils/extensions.dart';

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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          // Same look as the delete dialog, so the app feels consistent
          backgroundColor: isDark
              ? ColorPicker.darkSurfaceCard
              : ColorPicker.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Choose an emoji',
            textAlign: TextAlign.center,
            style: context.screenTitle.copyWith(fontSize: 20),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            // ------------- CHANGED: 2 -> 1. This field is for ONE emoji.
            // Flutter counts a whole emoji as one character, so this is safe.
            // Test it with a flag or a family emoji to be sure.
            maxLength: 1,
            // -------------
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 36),
            decoration: InputDecoration(
              counterText: '',
              // hintText: '🙂', // shows what kind of input is expected
              // ------------- A soft filled box instead of a bare underline
              filled: true,
              fillColor: isDark
                  ? ColorPicker.darkBorderDefault
                  : ColorPicker.ink100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              // -------------
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? ColorPicker.sky600
                          : ColorPicker.ink900,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    // final picked = await showDialog<String>(
    //   context: context,
    //   builder: (dialogContext) {
    //     return AlertDialog(
    //       title: const Text('Choose an emoji'),
    //       content: TextField(
    //         controller: controller,
    //         autofocus: true,
    //         maxLength: 2,
    //         textAlign: TextAlign.center,
    //         style: const TextStyle(fontSize: 28),
    //         decoration: const InputDecoration(counterText: ''),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.of(dialogContext).pop(),
    //           child: const Text('Cancel'),
    //         ),
    //         TextButton(
    //           onPressed: () =>
    //               Navigator.of(dialogContext).pop(controller.text.trim()),
    //           child: const Text('Done'),
    //         ),
    //       ],
    //     );
    //   },
    // );

    if (picked != null && picked.isNotEmpty) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = !kHabitEmojiChoices.contains(selectedEmoji);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              : Icon(
                  Icons.add_rounded,
                  color: isDark ? ColorPicker.white : ColorPicker.ink500,
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? isDark
                    ? ColorPicker.darkBorderDefault
                    : ColorPicker.sky50
              : (isDark ? ColorPicker.darkBorderDefault : ColorPicker.ink50),
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: isDark ? ColorPicker.sky600 : ColorPicker.sky400,
                  width: 2,
                )
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
      strutStyle: const StrutStyle(
        fontSize: _fontSize,
        height: 1,
        forceStrutHeight: true,
      ),
    );
  }
}
