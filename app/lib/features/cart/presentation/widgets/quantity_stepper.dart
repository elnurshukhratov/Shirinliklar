import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_tokens.dart';

/// Miqdorni kamaytirish va oshirish: [-] 2 [+]. Son silliq almashadi.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.max,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final canDecrease = value > 1;
    final canIncrease = value < max;

    Widget button(IconData icon, bool enabled, VoidCallback onTap) => Material(
          color: Colors.transparent,
          borderRadius: AppRadius.borderSmall,
          child: InkWell(
            borderRadius: AppRadius.borderSmall,
            onTap: enabled ? onTap : null,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, size: 20, color: enabled ? c.primary : c.textSecondary.withAlpha(110)),
            ),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppRadius.borderBase,
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(Icons.remove_rounded, canDecrease, () => onChanged(value - 1)),
          SizedBox(
            width: 32,
            child: AnimatedSwitcher(
              duration: AppMotion.of(context, AppMotion.fast),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: Text(
                '$value',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: text.titleSmall,
              ),
            ),
          ),
          button(Icons.add_rounded, canIncrease, () => onChanged(value + 1)),
        ],
      ),
    );
  }
}
