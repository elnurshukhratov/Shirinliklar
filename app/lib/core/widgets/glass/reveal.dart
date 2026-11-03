import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';

/// Ketma-ket (stagger) kirish animatsiyasi: element pastdan ozgina ko'tarilib, yengil kattalashib
/// xiralikdan chiqadi. [index] qancha katta bo'lsa, shuncha kechroq boshlanadi
/// (eng ko'pi [AppMotion.maxStaggerSteps] qadam, shuning uchun uzun ro'yxatda kutdirmaydi).
/// "Harakatni kamaytirish" yoqilgan bo'lsa, element darhol ko'rinadi.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 16,
  });

  final Widget child;
  final int index;

  /// Boshlang'ich pastga siljish (dp).
  final double offset;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppMotion.entrance);
  late final CurvedAnimation _curved =
      CurvedAnimation(parent: _controller, curve: AppMotion.emphasized);
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (AppMotion.reduced(context)) {
      _controller.value = 1;
      return;
    }
    final steps = widget.index.clamp(0, AppMotion.maxStaggerSteps);
    if (steps == 0) {
      _controller.forward();
    } else {
      _timer = Timer(AppMotion.stagger * steps, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      child: widget.child,
      builder: (context, child) {
        final t = _curved.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - t)),
            child: Transform.scale(scale: 0.98 + 0.02 * t, child: child),
          ),
        );
      },
    );
  }
}
