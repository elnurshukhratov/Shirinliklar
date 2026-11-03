import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/auth_controller.dart';

/// Ro'yxatdan o'tish 3 qadamda: 1) ism, familya, telefon  2) username  3) parol (ikki marta).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static final _usernameRe = RegExp(r'^[a-zA-Z0-9_.]{4,24}$');

  final _infoKey = GlobalKey<FormState>();
  final _usernameKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  int _step = 0;
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _phone, _username, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  String _t(String uz, String ru, String en) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'ru':
        return ru;
      case 'en':
        return en;
      default:
        return uz;
    }
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? context.l10n.fieldRequired : null;

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 15) return context.l10n.phoneInvalid;
    return null;
  }

  String? _usernameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    return _usernameRe.hasMatch(v.trim())
        ? null
        : _t(
            "4–24 ta belgi: lotin harflari, raqam, _ va .",
            '4–24 символа: латиница, цифры, _ и .',
            '4–24 characters: Latin letters, digits, _ and .',
          );
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return context.l10n.fieldRequired;
    return v.length < 8 ? context.l10n.passwordTooShort : null;
  }

  String? _confirmValidator(String? v) {
    if (v == null || v.isEmpty) return context.l10n.fieldRequired;
    return v == _password.text ? null : context.l10n.passwordMismatch;
  }

  String _describe(Object e) {
    final base = describeError(context.l10n, e).message;
    return kDebugMode ? '$base\n[$e]' : base;
  }

  void _goTo(int step) => setState(() {
        _step = step;
        _error = null;
      });

  Future<void> _next() async {
    FocusScope.of(context).unfocus();

    if (_step == 0) {
      if (!(_infoKey.currentState?.validate() ?? false)) return;
      _goTo(1);
      return;
    }

    if (_step == 1) {
      if (!(_usernameKey.currentState?.validate() ?? false)) return;
      setState(() {
        _busy = true;
        _error = null;
      });
      try {
        final free = await ref
            .read(authControllerProvider.notifier)
            .isUsernameAvailable(_username.text.trim().toLowerCase());
        if (!mounted) return;
        if (!free) {
          setState(() => _error = context.l10n.errorUsernameTaken);
          return;
        }
        _goTo(2);
      } catch (e) {
        if (!mounted) return;
        setState(() => _error = _describe(e));
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      return;
    }

    if (!(_passwordKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).register(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            phone: _phone.text.trim(),
            username: _username.text.trim().toLowerCase(),
            password: _password.text,
            passwordConfirm: _confirm.text,
          );
      // Muvaffaqiyatli bo'lsa router o'zi bosh sahifaga o'tkazadi.
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _describe(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _stepForm(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    switch (_step) {
      case 0:
        return Form(
          key: _infoKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_t('Ma\'lumotlaringiz', 'Ваши данные', 'Your details'), style: text.titleLarge),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _firstName,
                label: l10n.profileFirstName,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
                maxLength: 60,
                validator: _required,
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _lastName,
                label: l10n.profileLastName,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
                maxLength: 60,
                validator: _required,
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _phone,
                label: l10n.profilePhone,
                hint: l10n.profilePhoneHint,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumber],
                maxLength: 20,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]'))],
                validator: _phoneValidator,
                onSubmitted: (_) => _next(),
                enabled: !_busy,
              ),
            ],
          ),
        );
      case 1:
        return Form(
          key: _usernameKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_t('Username tanlang', 'Придумайте username', 'Choose a username'), style: text.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _t(
                  'Kamida 4 ta belgi. Keyin shu username bilan kirasiz.',
                  'Минимум 4 символа. Дальше вы будете входить с этим username.',
                  'At least 4 characters. You will sign in with this username.',
                ),
                style: text.bodyMedium?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _username,
                label: l10n.authUsername,
                hint: l10n.authUsernameHint,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newUsername],
                maxLength: 24,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_.]'))],
                validator: _usernameValidator,
                onSubmitted: (_) => _next(),
                enabled: !_busy,
              ),
            ],
          ),
        );
      default:
        return Form(
          key: _passwordKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_t('Parol yarating', 'Создайте пароль', 'Create a password'), style: text.titleLarge),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _password,
                label: l10n.authPassword,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                maxLength: 128,
                validator: _passwordValidator,
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
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                maxLength: 128,
                validator: _confirmValidator,
                onSubmitted: (_) => _next(),
                enabled: !_busy,
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final isLast = _step == 2;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy) _goTo(_step - 1);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.authRegisterTitle)),
        body: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: (_step + 1) / 3),
              duration: AppMotion.of(context, AppMotion.slow),
              curve: AppMotion.emphasized,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 6,
                borderRadius: AppRadius.borderPill,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedSwitcher(
              duration: AppMotion.of(context, AppMotion.slow),
              switchInCurve: AppMotion.emphasized,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(anim),
                  child: child,
                ),
              ),
              child: KeyedSubtree(key: ValueKey(_step), child: _stepForm(context)),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_error != null) ...[
              Text(_error!, style: text.bodyMedium?.copyWith(color: c.error)),
              const SizedBox(height: AppSpacing.md),
            ],
            AppButton(
              label: isLast ? l10n.authRegister : _t('Davom etish', 'Продолжить', 'Continue'),
              isLoading: _busy,
              onPressed: _next,
            ),
          ],
        ),
      ),
    );
  }
}