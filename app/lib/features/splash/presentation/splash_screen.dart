import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/candy_backdrop.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  // Ikkalasi ham prujina bilan harakatlanadi (smooth).
  late final AnimationController _logo = AnimationController.unbounded(vsync: this, value: 0);
  late final AnimationController _name = AnimationController.unbounded(vsync: this, value: 0);
  Timer? _nameTimer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) ref.read(splashDoneProvider.notifier).state = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduced(context)) {
      _logo.value = 1;
      _name.value = 1;
      return;
    }
    _logo.springTo(1, description: AppMotion.smooth);
    _nameTimer = Timer(const Duration(milliseconds: 280), () {
      if (mounted) _name.springTo(1, description: AppMotion.smooth);
    });
  }

  @override
  void dispose() {
    _nameTimer?.cancel();
    _logo.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    final auth = ref.watch(authControllerProvider);

    if (auth.status == AuthStatus.failed) {
      final err = describeError(context.l10n, auth.error ?? Object());
      return Scaffold(
        body: ErrorState(
          title: err.title,
          message: err.message,
          retryLabel: context.l10n.commonRetry,
          onRetry: () => ref.read(authControllerProvider.notifier).restore(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Jonli fon: sekin suzuvchi shirinliklar (umumiy AmbientBackground ustida).
          const CandyBackdrop(calm: true),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_logo, _name]),
              builder: (context, _) {
                final l = _logo.value;
                final n = _name.value;
                final logoOpacity = (l * 2).clamp(0.0, 1.0).toDouble();
                final haloOpacity = (l * 0.9).clamp(0.0, 1.0).toDouble();
                final nameOpacity = n.clamp(0.0, 1.0).toDouble();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Belgi ortidagi yumshoq nur.
                          Opacity(
                            opacity: haloOpacity,
                            child: Transform.scale(
                              scale: 0.5 + 0.5 * l,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [c.cta.withValues(alpha: 0.38), c.cta.withValues(alpha: 0)],
                                  ),
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                          // Logo: silliq prujina bilan chiqadi.
                          Opacity(
                            opacity: logoOpacity,
                            child: Transform.scale(
                              scale: 0.45 + 0.55 * l,
                              child: const BrandMark(size: 112),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Nom: pastdan ko'tarilib paydo bo'ladi.
                    Opacity(
                      opacity: nameOpacity,
                      child: Transform.translate(
                        offset: Offset(0, 28 * (1 - n)),
                        child: Text(AppConfig.appName, style: text.displaySmall),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}