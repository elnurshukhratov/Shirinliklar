import 'package:flutter/material.dart';

/// Kengayuvchi sahifa ochilganda orqadagi sahifa shu masshtabgacha kichrayadi.
const double kExpandBackdropMinScale = 0.94;

final Map<Object, double> _owners = <Object, double>{};

/// Orqa sahifaning "bosilganlik" darajasi (0..1): eng faol kengayuvchi sahifaning progressi.
final ValueNotifier<double> expandBackdropProgress = ValueNotifier<double>(0);

double expandBackdropScale(double progress) =>
    1 - (1 - kExpandBackdropMinScale) * progress.clamp(0.0, 1.0).toDouble();

void setExpandBackdrop(Object owner, double progress) {
  _owners[owner] = progress.clamp(0.0, 1.0).toDouble();
  _publish();
}

void clearExpandBackdrop(Object owner) {
  _owners.remove(owner);
  _publish();
}

void _publish() {
  var max = 0.0;
  for (final v in _owners.values) {
    if (v > max) max = v;
  }
  expandBackdropProgress.value = max;
}

/// Kengayuvchi sahifa ustiga ochilganda ~0.94 ga kichrayib, xiralashadigan orqa sahifa o'rami.
/// Daraxt tuzilishi doim bir xil (sahifa holati yo'qolmaydi).
class ExpandBackdrop extends StatelessWidget {
  const ExpandBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: expandBackdropProgress,
      child: child,
      builder: (context, p, child) {
        final active = p > 0.001;
        return Transform.scale(
          scale: expandBackdropScale(p),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36 * p),
            clipBehavior: active ? Clip.antiAlias : Clip.none,
            child: Stack(
              fit: StackFit.expand,
              children: [
                child!,
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(color: Colors.black.withValues(alpha: 0.30 * p)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}