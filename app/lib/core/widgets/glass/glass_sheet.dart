import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_tokens.dart';

/// Shisha ko'rinishidagi almashtirgich. Yoqilganda olcha tintli, o'chiqda yarim shaffof trek;
/// bosib turganda "tomchi" cho'ziladi, qo'yib yuborilganda sakrab joyiga o'tadi.
/// Bosish maydoni kamida 48 dp.
class GlassSwitch extends StatefulWidget {
  const GlassSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  State<GlassSwitch> createState() => _GlassSwitchState();
}

class _GlassSwitchState extends State<GlassSwitch> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final enabled = widget.onChanged != null;
    final on = widget.value;
    final d = AppMotion.of(context, const Duration(milliseconds: 260));
    final thumbW = _down && enabled ? 32.0 : 26.0;

    final offTrack = dark
        ? Colors.white.withValues(alpha: 0.16)
        : c.textPrimary.withValues(alpha: 0.14);

    return Semantics(
      toggled: on,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: enabled ? () => _set(false) : null,
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                widget.onChanged!(!on);
              }
            : null,
        child: SizedBox(
          width: 60,
          height: 48,
          child: Center(
            child: AnimatedOpacity(
              duration: AppMotion.of(context, AppMotion.fast),
              opacity: enabled ? 1 : 0.5,
              child: AnimatedContainer(
                duration: d,
                curve: AppMotion.curve,
                width: 54,
                height: 32,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: on ? c.cta : offTrack,
                  borderRadius: AppRadius.borderPill,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: on ? 0.28 : (dark ? 0.18 : 0.5)),
                  ),
                  boxShadow: on ? AppShadows.tinted(c.cta, strength: 0.28) : const [],
                ),
                child: AnimatedAlign(
                  duration: d,
                  curve: AppMotion.springCurve,
                  alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: AppMotion.of(context, const Duration(milliseconds: 180)),
                    curve: AppMotion.curve,
                    width: thumbW,
                    height: 26,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xFFF2F0F7)],
                      ),
                      borderRadius: AppRadius.borderPill,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sarlavha + [GlassSwitch] qatori. Butun qator bosiladi (katta bosish maydoni).
class GlassSwitchTile extends StatelessWidget {
  const GlassSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final enabled = onChanged != null;

    return Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onChanged!(!value);
                }
              : null,
          child: Row(
            children: [
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
              GlassSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
