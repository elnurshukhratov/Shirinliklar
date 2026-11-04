import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
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
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
      body: Center(
        // Yagona sahna: yorug'lik halqasi kengayadi, belgi sakrab chiqadi, so'ng nom ko'tarilib paydo bo'ladi.
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final haloT = AppMotion.emphasized.transform((t * 1.2).clamp(0.0, 1.0));
            final markT = AppMotion.springCurve.transform((t * 1.5).clamp(0.0, 1.0));
            final nameT = AppMotion.emphasized.transform(((t - 0.35) / 0.65).clamp(0.0, 1.0));
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Belgi ortidagi yumshoq nur: shisha aynan shu nurni sindiradi.
                      Opacity(
                        opacity: (haloT * 0.9).clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.55 + 0.45 * haloT,
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
                      Opacity(
                        opacity: (t * 2.5).clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.78 + 0.22 * markT,
                          child: const BrandMark(size: 112),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Opacity(
                  opacity: nameT,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - nameT)),
                    child: Text(AppConfig.appName, style: text.displaySmall),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
