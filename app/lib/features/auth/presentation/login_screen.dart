import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass/glass_container.dart';
import '../../../core/widgets/glass/glass_icon_button.dart';
import '../application/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  bool _googleBusy = false;
  String? _error;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? context.l10n.fieldRequired : null;

  Future<void> _signInWithPassword() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).signInWithPassword(
            login: _login.text.trim(),
            password: _password.text,
          );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = describeError(context.l10n, e).message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleBusy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).signIn();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = describeError(context.l10n, e).message);
    } finally {
      if (mounted) setState(() => _googleBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final disabled = _busy || _googleBusy;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GlassIconButton(
                  tooltip: l10n.settingsTitle,
                  onPressed: () => context.push(AppRoutes.settings),
                  child: const Icon(Icons.settings_outlined),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GlassContainer(
                          level: GlassLevel.floating,
                          tint: c.cta,
                          borderRadius: BorderRadius.circular(30),
                          child: SizedBox(
                            width: 96,
                            height: 96,
                            child: Icon(Icons.cake_rounded, size: 52, color: c.onCta),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(AppConfig.appName, textAlign: TextAlign.center, style: text.headlineMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(l10n.authLoginTitle, textAlign: TextAlign.center, style: text.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.authLoginSubtitle,
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(color: c.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        controller: _login,
                        label: l10n.authLoginField,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        validator: _required,
                        enabled: !disabled,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        controller: _password,
                        label: l10n.authPassword,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: _required,
                        onSubmitted: (_) => _signInWithPassword(),
                        enabled: !disabled,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (_error != null) ...[
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(color: c.error),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      AppButton(
                        label: l10n.authLoginButton,
                        isLoading: _busy,
                        onPressed: _googleBusy ? null : _signInWithPassword,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: Text(l10n.authOr, style: text.bodySmall?.copyWith(color: c.textSecondary)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: l10n.authContinueWithGoogle,
                        icon: Icons.login_rounded,
                        variant: AppButtonVariant.secondary,
                        isLoading: _googleBusy,
                        onPressed: _busy ? null : _signInWithGoogle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: l10n.authRegister,
                        variant: AppButtonVariant.text,
                        onPressed: disabled ? null : () => context.push(AppRoutes.register),
                      ),
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
            ),
          ],
        ),
      ),
    );
  }
}