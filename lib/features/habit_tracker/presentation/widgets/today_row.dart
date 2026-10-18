import 'package:flutter/material.dart';
import 'package:habitera/constants/color_picker.dart';
import 'package:habitera/features/habit_tracker/presentation/widgets/habit_emoji.dart';
import 'package:habitera/utils/extensions.dart';

/// A Today-screen check-in row: emoji, title, streak, and a tappable check
/// circle. design/Habitera Design System/components/today/TodayRow.jsx
class TodayRow extends StatefulWidget {
  const TodayRow({
    super.key,
    required this.emoji,
    required this.title,
    required this.streak,
    required this.done,
    required this.onToggle,
    this.onOpen,
  });

  final String emoji;
  final String title;
  final int? streak;
  // final int streak;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback? onOpen;

  @override
  State<TodayRow> createState() => _TodayRowState();
}

class _TodayRowState extends State<TodayRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _circleScale;
  late final Animation<double> _tickScale;
  late final Animation<double> _tickOpacity;

  @override
  void initState() {
    super.initState();
    // Single controller driving both the "1 -> 1.12 -> 1" circle pop (whole
    // 240ms span) and the tick fading/scaling in (first 180ms) — matches
    // the spec's two animations firing together off one completion event.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      // A row can be constructed already-done (e.g. NavBar recreates
      // TodayScreen on every tab switch instead of keeping it alive), in
      // which case there's no toggle to animate off of — start the
      // controller already completed so the tick renders immediately
      // instead of sitting at its faded/shrunk initial frame.
      value: widget.done ? 1.0 : 0.0,
    );
    _circleScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 42),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 58),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _tickScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _tickOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.75, curve: Curves.linear),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleToggle() {
    // "Fires on completion only — unchecking is silent" (spec). We only
    // play the celebration when the row is going from not-done to done.
    if (!widget.done) {
      _controller.forward(from: 0);
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.done;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final titleColor = isDark ? ColorPicker.darkTextTitle : ColorPicker.ink900;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? ColorPicker.darkSurfaceCard : ColorPicker.white,
        borderRadius: BorderRadius.circular(14),
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
      child: Row(
        children: [
          HabitEmoji(emoji: widget.emoji, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onOpen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.body.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: done
                          ? ColorPicker.ink500
                          : (isDark
                                ? ColorPicker.darkTextTitle
                                : ColorPicker.ink900),
                      // color: done ? ColorPicker.ink500 : ColorPicker.ink900,
                      decoration: done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: ColorPicker.ink400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // widget.streak > 0
                  //     ? Text(
                  //         '🔥 ${widget.streak} ${widget.streak == 1 ? 'day' : 'days'}',
                  //         style: context.small.copyWith(
                  //           // color: ColorPicker.ember600,
                  //           color: done
                  //               ? ColorPicker.ember600
                  //               : (isDark
                  //                     ? ColorPicker.ink400
                  //                     : ColorPicker.ink500),
                  //         ),
                  //       )
                  //     : Text(
                  //         'No streak yet',
                  //         style: context.small.copyWith(
                  //           color: isDark
                  //               ? ColorPicker.ink400
                  //               : ColorPicker.ink500,
                  //         ),
                  //       ),
                  // ------------- CHANGED: three states instead of two.
                  // Loading shows an invisible placeholder with the same height, so the row
                  // doesn't jump in size when the real text arrives.
                  if (widget.streak == null)
                    Text(' ', style: context.small)
                  else if (widget.streak! > 0)
                    Text(
                      '🔥 ${widget.streak} ${widget.streak == 1 ? 'day' : 'days'}',
                      style: context.small.copyWith(
                        color: done
                            ? ColorPicker.ember600
                            : (isDark
                                  ? ColorPicker.ink400
                                  : ColorPicker.ink500),
                      ),
                    )
                  else
                    Text(
                      'No streak yet',
                      style: context.small.copyWith(
                        color: isDark ? ColorPicker.ink400 : ColorPicker.ink500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleToggle,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: done ? _circleScale.value : 1.0,
                  child: child,
                );
              },
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? ColorPicker.success : Colors.transparent,
                  border: done
                      ? null
                      : Border.all(color: ColorPicker.ink500, width: 1.5),
                ),
                child: done
                    ? FadeTransition(
                        opacity: _tickOpacity,
                        child: ScaleTransition(
                          scale: _tickScale,
                          child: const Icon(
                            Icons.check,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
