import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart' show SpringDescription;
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import 'glass_container.dart';

class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount,
    this.emphasized = false,
    this.iconKey,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// null — belgi (badge) yo'q; 0 — belgi bor, lekin hozir yashirin; >0 — son ko'rinadi va o'zgarganda sakraydi.
  final int? badgeCount;

  /// Markazdagi biroz kattaroq element (Savat).
  final bool emphasized;

  /// Ikonka o'rnini tashqaridan topish uchun (masalan, "savatga uchish" animatsiyasi).
  final GlobalKey? iconKey;
}

/// Suzuvchi shisha navigatsiya kapsulasi. Faol element: ikonka + yorliq yonma-yon kengaygan "tomchi",
/// qolganlari faqat ikonka. Indikator siljiganda cho'ziladi va qisqaradi (squash & stretch):
/// yo'nalish bo'yicha oldingi chet tez, orqadagisi bouncy prujina bilan ergashadi.
/// Bosib turganda "linza": indikator ~1.12 kattalashadi va yorqinroq bo'ladi.
/// Har bir element kamida 48 dp. "Harakatni kamaytirish" yoqilganda prujina va linza o'chadi.
class GlassNavigationBar extends StatefulWidget {
  const GlassNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.margin = const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
  });

  final List<GlassNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsetsGeometry margin;

  @override
  State<GlassNavigationBar> createState() => _GlassNavigationBarState();
}

class _GlassNavigationBarState extends State<GlassNavigationBar> with TickerProviderStateMixin {
  /// Yo'nalish bo'yicha OLDINGI chet: tez va deyarli sakramaydi.
  static const SpringDescription _lead = SpringDescription(mass: 1, stiffness: 820, damping: 38);

  /// ORQADAGI chet va kengliklar: sezilarli sakraydi.
  static const SpringDescription _trail = AppMotion.bouncy;

  late final AnimationController _soft =
      AnimationController.unbounded(vsync: this, value: widget.selectedIndex.toDouble());
  late final AnimationController _fast =
      AnimationController.unbounded(vsync: this, value: widget.selectedIndex.toDouble());
  late final AnimationController _lens = AnimationController.unbounded(vsync: this, value: 0);
  int _dir = 1;

  @override
  void didUpdateWidget(GlassNavigationBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex == widget.selectedIndex) return;
    _dir = widget.selectedIndex > old.selectedIndex ? 1 : -1;
    final target = widget.selectedIndex.toDouble();
    if (AppMotion.reduced(context)) {
      _soft.value = target;
      _fast.value = target;
      return;
    }
    _soft.springTo(target, description: _trail);
    _fast.springTo(target, description: _lead);
  }

  @override
  void dispose() {
    _soft.dispose();
    _fast.dispose();
    _lens.dispose();
    super.dispose();
  }

  void _press(bool down) {
    if (down) {
      HapticFeedback.selectionClick();
      if (AppMotion.reduced(context)) return;
      _lens.springTo(1, description: AppMotion.snappy);
    } else if (_lens.value != 0) {
      _lens.springTo(0, description: AppMotion.snappy);
    }
  }

  /// Bo'laklarga bo'lingan chiziqli interpolyatsiya (chegaradan tashqarida davom ettiriladi).
  static double _at(List<double> v, double p) {
    if (v.length == 1) return v[0];
    final i = p.floor().clamp(0, v.length - 2).toInt();
    return v[i] + (v[i + 1] - v[i]) * (p - i);
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.items.length;
    if (n == 0) return const SizedBox.shrink();

    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3).toDouble();
    final height = 62 * scale;
    final selected = widget.selectedIndex.clamp(0, n - 1).toInt();

    return SafeArea(
      top: false,
      child: Padding(
        padding: widget.margin,
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: GlassContainer(
              level: GlassLevel.bar,
              borderRadius: BorderRadius.circular(height / 2 + 6),
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                height: height,
                child: Listener(
                  onPointerDown: (_) => _press(true),
                  onPointerUp: (_) => _press(false),
                  onPointerCancel: (_) => _press(false),
                  child: LayoutBuilder(
                    builder: (context, constraints) =>
                        _track(constraints.maxWidth, height, selected, c, dark),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _track(double width, double height, int selected, AppColors c, bool dark) {
    final items = widget.items;
    final n = items.length;

    // Har bir elementning tinch holatdagi kengligi (>= 48 dp); qolgan joy faol elementga beriladi.
    final base = [for (final it in items) it.emphasized ? 56.0 : 48.0];
    final sumBase = base.fold<double>(0, (a, b) => a + b);
    final shrink = sumBase > width ? width / sumBase : 1.0;
    final b = [for (final w in base) w * shrink];
    final extra = math.max(0.0, width - sumBase);

    // k-element faol bo'lganda "tomchi" chegaralari.
    final la = <double>[];
    final ra = <double>[];
    var acc = 0.0;
    for (var k = 0; k < n; k++) {
      la.add(acc);
      ra.add(acc + b[k] + extra);
      acc += b[k];
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_soft, _fast, _lens]),
      builder: (context, _) {
        final pLayout = _soft.value.clamp(0.0, n - 1.0).toDouble();
        final lens = math.max(0.0, _lens.value);

        // Squash & stretch: harakat yo'nalishidagi chet tez (lead), orqadagisi sekin (trail).
        final pLeft = _dir < 0 ? _fast.value : _soft.value;
        final pRight = _dir > 0 ? _fast.value : _soft.value;
        final left = _at(la, pLeft).clamp(0.0, width).toDouble();
        final right = math.max(left + 1, _at(ra, pRight).clamp(0.0, width).toDouble());

        final children = <Widget>[
          Positioned(
            left: left,
            width: right - left,
            top: 0,
            bottom: 0,
            child: _indicator(height, lens, c, dark),
          ),
        ];

        var x = 0.0;
        for (var i = 0; i < n; i++) {
          final a = (1 - (pLayout - i).abs()).clamp(0.0, 1.0).toDouble();
          final w = b[i] + extra * a;
          children.add(Positioned(
            left: x,
            width: w,
            top: 0,
            bottom: 0,
            child: _cell(i, a, i == selected, lens, c),
          ));
          x += w;
        }

        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }

  Widget _indicator(double height, double lens, AppColors c, bool dark) {
    final radius = BorderRadius.circular(height / 2);
    double a(double v) => v.clamp(0.0, 1.0).toDouble();

    return Transform.scale(
      scale: 1 + 0.12 * lens,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              c.cta.withValues(alpha: a((dark ? 0.34 : 0.20) + 0.10 * lens)),
              c.cta.withValues(alpha: a((dark ? 0.20 : 0.10) + 0.08 * lens)),
            ],
          ),
          border: Border.all(color: c.cta.withValues(alpha: a((dark ? 0.45 : 0.28) + 0.20 * lens))),
          boxShadow: lens > 0.02
              ? [BoxShadow(color: c.cta.withValues(alpha: a(0.28 * lens)), blurRadius: 18, spreadRadius: -2)]
              : null,
        ),
        // Linza: bosib turganda yorqinroq.
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          color: Colors.white.withValues(alpha: a(0.16 * lens)),
        ),
      ),
    );
  }

  Widget _cell(int i, double a, bool selected, double lens, AppColors c) {
    final item = widget.items[i];
    final iconSize = item.emphasized ? 28.0 : 24.0;
    final color = Color.lerp(c.textSecondary, c.primary, a)!;
    final count = item.badgeCount;

    Widget icon = SizedBox(
      key: item.iconKey,
      width: iconSize,
      height: iconSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(a > 0.5 ? item.selectedIcon : item.icon, size: iconSize, color: color),
          if (count != null) Positioned(top: -8, right: -11, child: _DockBadge(count: count)),
        ],
      ),
    );
    icon = Transform.scale(scale: 1 + 0.12 * lens * a, child: icon);

    final label = a > 0.02
        ? ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: a,
              child: Opacity(
                opacity: (a * a).clamp(0.0, 1.0).toDouble(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    softWrap: false,
                    style: AppTypography.dockLabel().copyWith(color: c.primary),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    final semanticsLabel = count != null && count > 0 ? '${item.label}, $count' : item.label;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelected(i),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(mainAxisSize: MainAxisSize.min, children: [icon, label]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dock belgisi (badge): paydo bo'lganda va son o'zgarganda bouncy prujina bilan sakraydi.
class _DockBadge extends StatefulWidget {
  const _DockBadge({required this.count});

  final int count;

  @override
  State<_DockBadge> createState() => _DockBadgeState();
}

class _DockBadgeState extends State<_DockBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController.unbounded(vsync: this, value: widget.count > 0 ? 1 : 0);

  @override
  void didUpdateWidget(_DockBadge old) {
    super.didUpdateWidget(old);
    if (old.count == widget.count) return;
    final reduced = AppMotion.reduced(context);
    if (widget.count <= 0) {
      if (reduced) {
        _c.value = 0;
      } else {
        _c.springTo(0, description: AppMotion.snappy);
      }
      return;
    }
    if (reduced) {
      _c.value = 1;
      return;
    }
    _c.value = old.count <= 0 ? 0 : 0.55;
    _c.springTo(1, description: AppMotion.bouncy);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = widget.count > 99 ? '99+' : '${widget.count}';

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final s = _c.value;
        if (s <= 0.01) return const SizedBox.shrink();
        return Transform.scale(
          scale: s,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.cta,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: c.surface, width: 1.5),
            ),
            child: Text(
              label,
              style: AppTypography.ui(10.5, FontWeight.w800, height: 1.1).copyWith(color: c.onCta),
            ),
          ),
        );
      },
    );
  }
}