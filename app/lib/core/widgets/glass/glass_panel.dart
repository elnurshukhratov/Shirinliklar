import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_tokens.dart';
import 'glass_container.dart';
import 'pressable.dart';

/// Sozlamalar kabi boshqaruv qatorlarini guruhlaydigan shisha panel. Qatorlar orasida ingichka
/// ajratgich chiziladi. Ichidagi qatorlar o'zi shisha emas (shisha ustiga shisha qo'yilmaydi).
class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.children, this.padding = EdgeInsets.zero});

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Divider(height: 1, color: c.border.withValues(alpha: 0.7)),
        ));
      }
      rows.add(children[i]);
    }

    return GlassContainer(
      level: GlassLevel.panel,
      blur: false,
      borderRadius: AppRadius.borderPanel,
      child: Padding(
        padding: padding,
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }
}

/// [GlassPanel] ichidagi bitta qator: ikonka, sarlavha, ixtiyoriy izoh va oxirida vidjet
/// ([trailing]) yoki o'q. [onTap] berilsa, qator bosilganda yengil kichrayadi.
class GlassPanelTile extends StatelessWidget {
  const GlassPanelTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: c.primary),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: text.bodyLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: text.bodySmall?.copyWith(color: c.textSecondary)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right_rounded, color: c.textSecondary)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );

    if (onTap == null) return row;
    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      child: Pressable(scale: 0.985, haptic: true, onTap: onTap, child: row),
    );
  }
}

/// Siljiydigan "tomchi" bilan segment tanlagich (til, mavzu kabi 2–4 variantli tanlov uchun).
class GlassSegmented<T> extends StatelessWidget {
  const GlassSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;
    final selectedIndex = options.indexWhere((o) => o.$1 == value).clamp(0, options.length - 1);
    const inset = 4.0;
    const height = 48.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final thumbW = (constraints.maxWidth - inset * 2) / options.length;

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: dark ? Colors.white.withValues(alpha: 0.08) : c.textPrimary.withValues(alpha: 0.06),
            borderRadius: AppRadius.borderPill,
            border: Border.all(color: Colors.white.withValues(alpha: dark ? 0.10 : 0.55)),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: AppMotion.of(context, const Duration(milliseconds: 320)),
                curve: AppMotion.springCurve,
                left: inset + thumbW * selectedIndex,
                top: inset,
                width: thumbW,
                height: height - inset * 2 - 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color.lerp(c.cta, Colors.white, 0.14)!, c.cta],
                    ),
                    borderRadius: AppRadius.borderPill,
                    boxShadow: AppShadows.tinted(c.cta, strength: 0.26),
                  ),
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: inset),
                  for (final (v, label) in options)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: v == value,
                        label: label,
                        excludeSemantics: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(v),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: AnimatedDefaultTextStyle(
                                  duration: AppMotion.of(context, AppMotion.fast),
                                  style: (text.labelLarge ?? const TextStyle()).copyWith(
                                    color: v == value ? c.onCta : c.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  child: Text(label, maxLines: 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: inset),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}