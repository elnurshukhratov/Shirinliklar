import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Har bir sahifa ortidagi fon: vitrina ortidagi yorug'lik. Uchta yumshoq nur dog'i
/// (olcha — yuqori chapda, pistachio — pastki o'ngda, karamel — o'rtada).
/// Shisha qatlamlar aynan shu nurni sindirib "ko'rsatib" turadi.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final a = dark ? 0.62 : 0.62;
    final b = dark ? 0.50 : 0.55;
    final m = dark ? 0.22 : 0.30;

    RadialGradient orb(Alignment center, double radius, Color color, double alpha) => RadialGradient(
          center: center,
          radius: radius,
          colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
        );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Fon bir marta chiziladi: sahifa aylantirilganda qayta chizilmaydi.
        RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(color: c.background),
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: orb(const Alignment(-1.0, -1.0), 1.15, c.ambientA, a)),
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: orb(const Alignment(1.05, 0.85), 1.05, c.ambientB, b)),
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: orb(const Alignment(0.9, -0.35), 0.7, c.ambientC, m)),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
