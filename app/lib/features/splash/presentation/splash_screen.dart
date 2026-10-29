import '../../../core/widgets/glass/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
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
    final c = context.colors;
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
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.of(context, AppMotion.slow),
          curve: AppMotion.curve,
          builder: (context, value, child) => Opacity(opacity: value, child: child),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassContainer(
                level: GlassLevel.floating,
                tint: c.cta,
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Icon(Icons.cake_rounded, size: 52, color: c.onCta),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(AppConfig.appName, style: text.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }
}