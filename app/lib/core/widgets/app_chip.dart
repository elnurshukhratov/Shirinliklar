import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_tokens.dart';

/// Filtr chipi. Tanlanganda olcha gradient va yengil yorug'lik, tanlanmaganda yupqa shaffof sirt.
/// Bosish maydoni kamida 44 dp balandlikda.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.onCta : c.textPrimary;

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.of(context, const Duration(milliseconds: 220)),
        curve: AppMotion.curve,
        constraints: const BoxConstraints(minHeight: 44),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.lerp(c.cta, Colors.white, 0.14)!, c.cta],
                )
              : null,
          color: selected ? null : c.surface.withValues(alpha: 0.62),
          borderRadius: AppRadius.borderPill,
          border: Border.all(color: selected ? c.cta : c.border),
          boxShadow: selected ? AppShadows.tinted(c.cta, strength: 0.26) : const [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.borderPill,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap == null
                ? null
                : () {
                    if (!selected) HapticFeedback.selectionClick();
                    onTap!();
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
