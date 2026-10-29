import '../../../core/widgets/glass/glass_container.dart';
import '../../../core/widgets/glass/glass_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../application/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).signIn();
    } catch (e) {
      if (!mounted) return;
      final l10n = context.l10n;
      setState(() {
        _error = e is ApiException ? describeError(l10n, e).message : l10n.authSignInFailed;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GlassIconButton(
                  tooltip: l10n.settingsTitle,
                  onPressed: () => context.push(AppRoutes.settings),
                  child: const Icon(Icons.settings_outlined),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
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
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.authLoginTitle,
                          textAlign: TextAlign.center,
                          style: text.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.authLoginSubtitle,
                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(color: c.error),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              AppButton(
                label: l10n.authContinueWithGoogle,
                icon: Icons.login_rounded,
                isLoading: _busy,
                onPressed: _signIn,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.push(AppRoutes.legalPrivacy),
                    child: Text(l10n.legalPrivacyTitle),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.legalRefund),
                    child: Text(l10n.legalRefundTitle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}