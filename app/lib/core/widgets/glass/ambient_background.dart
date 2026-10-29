import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Har bir sahifa ortidagi fon: asosiy rang ustida ikki yumshoq yorug'lik dog'i
/// (olcha va karamel). Shisha qatlamlar aynan shu fonni "ko'rsatib" turadi.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final a = dark ? 0.55 : 0.60;
    final b = dark ? 0.40 : 0.50;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.background,
              gradient: RadialGradient(
                center: const Alignment(-0.9, -0.95),
                radius: 1.1,
                colors: [c.ambientA.withValues(alpha: a), c.ambientA.withValues(alpha: 0)],
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(1.0, 0.75),
                  radius: 1.0,
                  colors: [c.ambientB.withValues(alpha: b), c.ambientB.withValues(alpha: 0)],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
