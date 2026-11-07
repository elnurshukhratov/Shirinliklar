import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_motion.dart';

/// Bosilganda yengil kichrayib, qo'yib yuborilganda prujina (snappy) bilan qaytadigan o'ram.
/// Faqat teginishga javobni beradi (ripple yo'q): ichidagi vidjetning o'zi ham
/// bosiladigan bo'lsa, uni shu o'ramga o'tkazmang.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.haptic = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final active = _down && enabled && !AppMotion.reduced(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: enabled
          ? () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: SpringBuilder(
        value: active ? 1 : 0,
        description: AppMotion.snappy,
        child: widget.child,
        builder: (context, v, child) => Transform.scale(
          scale: 1 - (1 - widget.scale) * v,
          child: child,
        ),
      ),
    );
  }
}