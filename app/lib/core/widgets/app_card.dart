import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_tokens.dart';

/// Kontent kartasi (shisha EMAS): toza yuza, nozik chegara va yumshoq soya.
/// Bosilganda ozgina kichrayadi va soya qisqaradi (sirt "bosilgandek").
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final pressed = _pressed && !AppMotion.reduced(context);

    return AnimatedScale(
      scale: pressed ? 0.985 : 1,
      duration: AppMotion.of(context, AppMotion.fast),
      curve: pressed ? AppMotion.curve : AppMotion.spring,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderCard,
          boxShadow: pressed
              ? [BoxShadow(color: c.shadow, blurRadius: 12, spreadRadius: -4, offset: const Offset(0, 4))]
              : AppShadows.rest(c),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: AppRadius.borderCard,
            border: Border.all(color: c.border.withValues(alpha: dark ? 0.9 : 0.7)),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: AppRadius.borderCard,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: widget.onTap == null ? null : (v) => setState(() => _pressed = v),
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
