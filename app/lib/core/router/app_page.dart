import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';
import '../widgets/glass/ambient_background.dart';

/// Sahifalar orasida yumshoq o'tish: yangi sahifa pastdan ozgina ko'tarilib xiralikdan chiqadi,
/// eski sahifa esa orqaga yengil kichrayib xiralashadi (chuqurlik hissi).
/// Har sahifa o'z ambient fonini olib yuradi, shuning uchun o'tishda ikki fon aralashib ketmaydi.
///
/// [horizontal] — Login va Register kabi "qardosh" sahifalar uchun: yangi sahifa o'ngdan suriladi,
/// eskisi chapga ketadi (bir tekislikdagi o'tish hissi).
CustomTransitionPage<void> appPage(GoRouterState state, Widget child, {bool horizontal = false}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: AmbientBackground(child: child),
    transitionDuration: AppMotion.page,
    reverseTransitionDuration: AppMotion.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (AppMotion.reduced(context)) return child;
      final enter = CurvedAnimation(parent: animation, curve: AppMotion.emphasized);
      final behind = CurvedAnimation(parent: secondaryAnimation, curve: AppMotion.emphasized);
      if (horizontal) {
        return SlideTransition(
          position: Tween<Offset>(begin: Offset.zero, end: const Offset(-0.12, 0)).animate(behind),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(behind),
            child: FadeTransition(
              opacity: enter,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.14, 0), end: Offset.zero).animate(enter),
                child: child,
              ),
            ),
          ),
        );
      }
      return ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.97).animate(behind),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0.6).animate(behind),
          child: FadeTransition(
            opacity: enter,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero).animate(enter),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
