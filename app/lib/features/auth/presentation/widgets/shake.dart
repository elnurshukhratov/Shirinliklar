import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';

/// [trigger] o'zgarganda bolasini gorizontal silkitadi (xato bo'lgan maydon uchun).
/// "Harakatni kamaytirish" yoqilgan bo'lsa silkinmaydi.
class Shake extends StatefulWidget {
  const Shake({super.key, required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && !AppMotion.reduced(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        final dx = math.sin(t * math.pi * 5) * 9 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}