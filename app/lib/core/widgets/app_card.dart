import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_tokens.dart';

/// Kontent kartasi (shisha EMAS): to'q/oq yuza, nozik chegara va yumshoq soya.
/// Bosilganda ozgina ko'tariladi.
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
    final lifted = _pressed && !AppMotion.reduced(context);

    return AnimatedContainer(
      duration: AppMotion.of(context),
      curve: AppMotion.curve,
      transform: Matrix4.translationValues(0, lifted ? -3 : 0, 0),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppRadius.borderCard,
        border: Border.all(color: c.border.withValues(alpha: 0.7)),
        boxShadow: lifted ? AppShadows.lifted(c) : AppShadows.rest(c),
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
    );
  }
}
