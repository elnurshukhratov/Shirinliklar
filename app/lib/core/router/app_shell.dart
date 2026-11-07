import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/application/cart_controller.dart';
import '../../features/cart/application/cart_icon_key.dart';
import '../../features/cart/presentation/widgets/mini_cart_pill.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_motion.dart';
import '../theme/app_tokens.dart';
import '../widgets/glass/glass_navigation_bar.dart';

/// Joriy tab qayta bosilganda (index, hisoblagich) yangilanadi: tab sahifasi tepaga aylantirishi mumkin.
final tabReselectedProvider = StateProvider<(int, int)>((ref) => (-1, 0));

/// Doimiy dock: StatefulShellRoute ichidagi BITTA navigatsiya paneli.
/// Tablar: 0 Bosh, 1 Sevimlilar, 2 Savat (markazda), 3 Buyurtmalar, 4 Profil.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const int _cartIndex = 2;

  /// Dock kapsulasining ichki balandligi (GlassNavigationBar bilan bir xil).
  static const double _dockInner = 62;
  static const double _pillSpace = 56;

  bool _scrollHidden = false;

  @override
  void didUpdateWidget(AppShell old) {
    super.didUpdateWidget(old);
    if (old.navigationShell.currentIndex != widget.navigationShell.currentIndex) {
      _scrollHidden = false;
    }
  }

  void _setHidden(bool value) {
    if (_scrollHidden == value) return;
    _scrollHidden = value;
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  /// Pastga aylantirganda dock yashiriladi, tepaga aylantirganda yoki ro'yxat boshida qaytadi.
  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    if (n is UserScrollNotification) {
      if (n.direction == ScrollDirection.reverse) {
        _setHidden(true);
      } else if (n.direction == ScrollDirection.forward) {
        _setHidden(false);
      }
    }
    if (n.metrics.pixels <= n.metrics.minScrollExtent + 4) _setHidden(false);
    return false;
  }

  void _select(int i) {
    final shell = widget.navigationShell;
    final reselect = i == shell.currentIndex;
    if (reselect) {
      final current = ref.read(tabReselectedProvider);
      ref.read(tabReselectedProvider.notifier).state = (i, current.$2 + 1);
    }
    shell.goBranch(i, initialLocation: reselect);
    _setHidden(false);
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    final index = shell.currentIndex;
    final l10n = context.l10n;
    final cartCount = ref.watch(cartProvider.select((s) => s.count));
    final cartKey = ref.watch(cartIconKeyProvider);

    final mq = MediaQuery.of(context);
    final keyboardOpen = mq.viewInsets.bottom > 0;
    final hide = _scrollHidden || keyboardOpen;
    final pillVisible = cartCount > 0 && index != _cartIndex;
    final scale = mq.textScaler.scale(1).clamp(1.0, 1.3).toDouble();

    // Tab sahifalari dock balandligicha pastki bo'sh joy oladi (safe area allaqachon ichida).
    final extra = AppSpacing.md + 12 + _dockInner * scale + AppSpacing.lg + (pillVisible ? _pillSpace : 0);
    final padded = mq.copyWith(
      padding: mq.padding.copyWith(bottom: mq.padding.bottom + extra),
      viewPadding: mq.viewPadding.copyWith(bottom: mq.viewPadding.bottom + extra),
    );

    final items = [
      GlassNavItem(
        icon: Icons.storefront_outlined,
        selectedIcon: Icons.storefront_rounded,
        label: l10n.navHome,
      ),
      GlassNavItem(
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
        label: l10n.favoritesTitle,
      ),
      GlassNavItem(
        icon: Icons.shopping_bag_outlined,
        selectedIcon: Icons.shopping_bag_rounded,
        label: l10n.cartTitle,
        badgeCount: cartCount,
        emphasized: true,
        iconKey: cartKey,
      ),
      GlassNavItem(
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long_rounded,
        label: l10n.myOrdersTitle,
      ),
      GlassNavItem(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: l10n.profileTitle,
      ),
    ];

    final dock = Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            alignment: Alignment.bottomCenter,
            duration: AppMotion.of(context, AppMotion.slow),
            curve: AppMotion.smoothCurve,
            child: AnimatedSwitcher(
              duration: AppMotion.of(context, AppMotion.slow),
              switchInCurve: AppMotion.smoothCurve,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
                  child: child,
                ),
              ),
              child: pillVisible
                  ? Padding(
                      key: const ValueKey('mini-cart'),
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: MiniCartPill(onTap: () => _select(_cartIndex)),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-mini-cart')),
            ),
          ),
          GlassNavigationBar(items: items, selectedIndex: index, onSelected: _select),
        ],
      ),
    );

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Stack(
          children: [
            Positioned.fill(child: MediaQuery(data: padded, child: shell)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: hide,
                child: SpringBuilder(
                  value: hide ? 1 : 0,
                  description: AppMotion.smooth,
                  child: dock,
                  builder: (context, v, child) => FractionalTranslation(
                    translation: Offset(0, v * 1.4),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}