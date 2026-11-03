import '../../../core/widgets/brand_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) ref.read(splashDoneProvider.notifier).state = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
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
        // Yagona sahna: belgi sakrab chiqadi, so'ng nom yumshoq ko'tarilib paydo bo'ladi.
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.of(context, const Duration(milliseconds: 900)),
          curve: Curves.linear,
          builder: (context, t, _) {
            final markT = AppMotion.spring.transform((t * 1.6).clamp(0.0, 1.0));
            final nameT = AppMotion.emphasized.transform(((t - 0.35) / 0.65).clamp(0.0, 1.0));
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: (t * 2.5).clamp(0.0, 1.0),
                  child: Transform.scale(scale: 0.8 + 0.2 * markT, child: const BrandMark(size: 104)),
                ),
                const SizedBox(height: AppSpacing.xl),
                Opacity(
                  opacity: nameT,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - nameT)),
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
