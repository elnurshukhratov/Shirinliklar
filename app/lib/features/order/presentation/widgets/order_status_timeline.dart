import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../domain/order_models.dart';
import '../order_labels.dart';

/// Buyurtma holati: gorizontal bosqichli chiziq. Joriy bosqich asosiy rangda ajralib turadi.
class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({super.key, required this.steps, required this.current});

  final List<OrderStatus> steps;
  final OrderStatus current;

  static const double _dot = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final currentIndex = steps.indexOf(current);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: _dot,
                  child: Row(
                    children: [
                      Expanded(
                        child: i == 0
                            ? const SizedBox.shrink()
                            : _Line(color: i <= currentIndex ? c.primary : c.border),
                      ),
                      _Dot(done: i < currentIndex, active: i == currentIndex),
                      Expanded(
                        child: i == steps.length - 1
                            ? const SizedBox.shrink()
                            : _Line(color: i < currentIndex ? c.primary : c.border),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    orderStatusLabel(l10n, steps[i]),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelSmall?.copyWith(
                      color: i == currentIndex ? c.primary : c.textSecondary,
                      fontWeight: i == currentIndex ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.of(context),
      curve: AppMotion.curve,
      height: 3,
      color: color,
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.done, required this.active});

  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final filled = done || active;

    return AnimatedContainer(
      duration: AppMotion.of(context),
      curve: AppMotion.curve,
      width: OrderStatusTimeline._dot,
      height: OrderStatusTimeline._dot,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? c.primary : c.surface,
        border: Border.all(color: filled ? c.primary : c.border, width: 2),
      ),
      child: done
          ? Icon(Icons.check_rounded, size: 16, color: c.onPrimary)
          : active
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: c.onPrimary),
                  ),
                )
              : null,
    );
  }
}
