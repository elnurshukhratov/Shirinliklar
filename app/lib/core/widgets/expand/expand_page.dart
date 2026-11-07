import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'expand_host.dart';
import 'expand_origin.dart';

/// go_router sahifasi: `state.extra` [ExpandOrigin] bo'lsa kartadan to'liq ekranga kengayadi,
/// bo'lmasa (deep link, oddiy push) yumshoq fade + pastdan ko'tarilish.
///
/// [sharedTarget] — umumiy rasm (ExpandOrigin.image) yetib boradigan to'rtburchak (ekran o'lchami bo'yicha).
Page<void> expandPage(
  GoRouterState state,
  Widget child, {
  Rect Function(Size screen)? sharedTarget,
}) {
  final extra = state.extra;
  return ExpandPage(
    key: state.pageKey,
    name: state.name ?? state.path,
    child: child,
    origin: extra is ExpandOrigin ? extra : null,
    sharedTarget: sharedTarget,
  );
}

class ExpandPage extends Page<void> {
  const ExpandPage({
    super.key,
    super.name,
    required this.child,
    this.origin,
    this.sharedTarget,
  });

  final Widget child;
  final ExpandOrigin? origin;
  final Rect Function(Size screen)? sharedTarget;

  @override
  Route<void> createRoute(BuildContext context) => ExpandRoute(this);
}

/// Animatsiyani sahifaning o'zi ([ExpandHost]) boshqaradi: shuning uchun marshrut shaffof
/// (opaque emas) va orqadagi sahifa bilan o'z-o'zidan o'tish qilmaydi.
class ExpandRoute extends PageRoute<void> {
  ExpandRoute(ExpandPage page) : super(settings: page);

  ExpandPage get _page => settings as ExpandPage;

  static bool get _reduced =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;

  /// Marshrutning animatsiya boshqaruvchisi: host drag va yig'ilishda shuni boshqaradi.
  AnimationController get driver => controller!;

  @override
  Duration get transitionDuration =>
      _reduced ? const Duration(milliseconds: 150) : const Duration(milliseconds: 500);

  @override
  Duration get reverseTransitionDuration =>
      _reduced ? const Duration(milliseconds: 150) : const Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  /// Orqadagi sahifani standart o'tish bilan xiralashtirmaymiz: [ExpandBackdrop] buni o'zi qiladi.
  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final page = _page;
    return ExpandHost(
      controller: driver,
      origin: page.origin,
      sharedTarget: page.sharedTarget,
      child: page.child,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}