import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/auth_controller.dart';

/// Username va parolni o'zgartirish (masalan, do'kon egasi boshlang'ich admin/admin ni almashtiradi).
class CredentialsScreen extends ConsumerStatefulWidget {
  const CredentialsScreen({super.key});

  @override
  ConsumerState<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends ConsumerState<CredentialsScreen> {
  static final _usernameRe = RegExp(r'^[a-zA-Z0-9_.]{3,24}$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username;
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _username = TextEditingController(text: ref.read(authControllerProvider).user?.username ?? '');
  }

  @override
  void dispose() {
    _username.dispose();
    _current.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.isEmpty) ? context.l10n.fieldRequired : null;

  String? _usernameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    return _usernameRe.hasMatch(v.trim()) ? null : context.l10n.usernameInvalid;
  }

  String? _newPasswordValidator(String? v) {
    if (v == null || v.isEmpty) return null;
    return v.length < 8 ? context.l10n.passwordTooShort : null;
  }

  String? _confirmValidator(String? v) {
    if (_newPassword.text.isEmpty) return null;
    return v == _newPassword.text ? null : context.l10n.passwordMismatch;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final l10n = context.l10n;
    final currentUsername = ref.read(authControllerProvider).user?.username;
    final username = _username.text.trim().toLowerCase();
    final changedUsername = username != currentUsername;
    final changedPassword = _newPassword.text.isNotEmpty;

    if (!changedUsername && !changedPassword) {
      router.pop();
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).changeCredentials(
            currentPassword: _current.text,
            username: changedUsername ? username : null,
            newPassword: changedPassword ? _newPassword.text : null,
          );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.credentialsSaved)));
      router.pop();
    } catch (e) {
      if (!mounted) return;
      final base = describeError(l10n, e).message;
      setState(() => _error = kDebugMode ? '$base\n[$e]' : base);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.credentialsTitle)),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              controller: _username,
              label: l10n.authUsername,
              hint: l10n.authUsernameHint,
              textInputAction: TextInputAction.next,
              maxLength: 24,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_.]'))],
              validator: _usernameValidator,
              enabled: !_busy,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _newPassword,
              label: l10n.credentialsNewPassword,
              obscureText: _obscure,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              maxLength: 128,
              validator: _newPasswordValidator,
              enabled: !_busy,
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _confirm,
              label: l10n.authPasswordRepeat,
              obscureText: _obscure,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              maxLength: 128,
              validator: _confirmValidator,
              enabled: !_busy,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              controller: _current,
              label: l10n.credentialsCurrentPassword,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              maxLength: 128,
              validator: _required,
              onSubmitted: (_) => _submit(),
              enabled: !_busy,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_error != null) ...[
              Text(_error!, style: text.bodyMedium?.copyWith(color: c.error)),
              const SizedBox(height: AppSpacing.md),
            ],
            AppButton(
              label: l10n.commonSave,
              isLoading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}