import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/candy_backdrop.dart';
import '../../../core/widgets/glass/glass_container.dart';
import '../../../core/widgets/glass/glass_icon_button.dart';
import '../../../core/widgets/glass/glass_panel.dart';
import '../../../core/widgets/glass/reveal.dart';
import '../application/auth_controller.dart';
import 'widgets/shake.dart';

/// Bitta sahifadagi ikki rejim: Kirish va Ro'yxatdan o'tish.
enum AuthMode { login, register }

enum _Field { login, loginPassword, firstName, lastName, phone, username, password, confirm }

/// To'liq ekranli jonli fon, ustida suzuvchi shirinliklar va pastdan shisha varaq.
/// Ro'yxatdan o'tish 3 qadamda: 1) ism, familya, telefon  2) username  3) parol (ikki marta).
/// Auth mantig'i va validatsiya avvalgidek; faqat taqdimot yangilandi.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialMode = AuthMode.login});

  final AuthMode initialMode;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  static final _usernameRe = RegExp(r'^[a-zA-Z0-9_.]{4,24}$');

 final _formKey = GlobalKey<FormState>();
  final _login = TextEditingController();
  final _loginPassword = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _pan = ValueNotifier<Offset>(Offset.zero);
  final Map<_Field, int> _shakes = {for (final f in _Field.values) f: 0};
  late final AnimationController _sheetIn = AnimationController.unbounded(vsync: this, value: 0);
  late final StateController<bool> _hold;

  late AuthMode _mode = widget.initialMode;
  int _step = 0;
  bool _obscure = true;
  bool _busy = false;
  bool _success = false;
  bool _holdOn = false;
  bool _started = false;
  String? _error;
  String _lastError = '';

  @override
  void initState() {
    super.initState();
    _hold = ref.read(authSuccessHoldProvider.notifier);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduced(context)) {
      _sheetIn.value = 1;
    } else {
      _sheetIn.springTo(1, description: AppMotion.smooth);
    }
  }

  @override
  void dispose() {
    if (_holdOn) {
      final hold = _hold;
      Future.microtask(() {
        try {
          hold.state = false;
        } catch (_) {}
      });
    }
    _pan.dispose();
    _sheetIn.dispose();
    for (final c in [_login, _loginPassword, _firstName, _lastName, _phone, _username, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---- Validatsiya (avvalgi mantiq) ------------------------------------------------------------

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? context.l10n.fieldRequired : null;

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 15) return context.l10n.phoneInvalid;
    return null;
  }

  String? _usernameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    return _usernameRe.hasMatch(v.trim()) ? null : context.l10n.authUsernameInvalid;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return context.l10n.fieldRequired;
    return v.length < 8 ? context.l10n.passwordTooShort : null;
  }

  String? _confirmValidator(String? v) {
    if (v == null || v.isEmpty) return context.l10n.fieldRequired;
    return v == _password.text ? null : context.l10n.passwordMismatch;
  }

  TextEditingController _ctrl(_Field f) => switch (f) {
        _Field.login => _login,
        _Field.loginPassword => _loginPassword,
        _Field.firstName => _firstName,
        _Field.lastName => _lastName,
        _Field.phone => _phone,
        _Field.username => _username,
        _Field.password => _password,
        _Field.confirm => _confirm,
      };

  FormFieldValidator<String> _validatorFor(_Field f) => switch (f) {
        _Field.login || _Field.loginPassword || _Field.firstName || _Field.lastName => _required,
        _Field.phone => _phoneValidator,
        _Field.username => _usernameValidator,
        _Field.password => _passwordValidator,
        _Field.confirm => _confirmValidator,
      };

  /// Hozir ko'rinib turgan maydonlar.
  List<_Field> get _activeFields {
    if (_mode == AuthMode.login) return const [_Field.login, _Field.loginPassword];
    return switch (_step) {
      0 => const [_Field.firstName, _Field.lastName, _Field.phone],
      1 => const [_Field.username],
      _ => const [_Field.password, _Field.confirm],
    };
  }

  Set<_Field> _invalid(Iterable<_Field> fields) => {
        for (final f in fields)
          if (_validatorFor(f)(_ctrl(f).text) != null) f,
      };

  // ---- Yordamchilar ----------------------------------------------------------------------------

  String _describe(Object e, {bool login = false}) {
    final l10n = context.l10n;
    final base = login
        ? (e is ApiException ? describeError(l10n, e).message : l10n.authSignInFailed)
        : describeError(l10n, e).message;
    return kDebugMode ? '$base\n[$e]' : base;
  }

  void _showError(String? message) {
    _error = message;
    if (message != null) _lastError = message;
  }

  void _setHold(bool value) {
    _holdOn = value;
    try {
      _hold.state = value;
    } catch (_) {}
  }

  /// Tegishli maydonlarni silkitadi. [later] — maydon hali ochilmagan bo'lsa (qadam almashgach).
  void _shake(Iterable<_Field> fields, {bool later = false}) {
    void bump() {
      if (!mounted) return;
      setState(() {
        for (final f in fields) {
          _shakes[f] = _shakes[f]! + 1;
        }
      });
      HapticFeedback.lightImpact();
    }

    if (later) {
      Future<void>.delayed(const Duration(milliseconds: 360), bump);
    } else {
      bump();
    }
  }

  _Field? _fieldFor(Object e) {
    if (e is! ApiException) return null;
    switch (e.message) {
      case 'USERNAME_TAKEN':
        return _Field.username;
      case 'INVALID_PHONE':
      case 'PHONE_REQUIRED':
        return _Field.phone;
      case 'WEAK_PASSWORD':
        return _Field.password;
    }
    return null;
  }

  void _goTo(int step) => setState(() {
        _step = step;
        _showError(null);
      });

  void _setMode(AuthMode mode) {
    if (_busy || mode == _mode) return;
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    setState(() {
      _mode = mode;
      _step = 0;
      _showError(null);
    });
  }

  // ---- Yuborish --------------------------------------------------------------------------------

  Future<void> _submit() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();

    final bad = _invalid(_activeFields);
    _formKey.currentState?.validate();
    if (bad.isNotEmpty) {
      _shake(bad);
      return;
    }

    if (_mode == AuthMode.login) {
      await _signIn();
    } else if (_step == 0) {
      _goTo(1);
    } else if (_step == 1) {
      await _checkUsername();
    } else {
      await _register();
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _showError(null);
    });
    _setHold(true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithPassword(
            login: _login.text.trim(),
            password: _loginPassword.text,
          );
      await _celebrate();
    } catch (e) {
      _setHold(false);
      if (!mounted) return;
      final quiet = e is ApiException && (e.code == 'NETWORK_ERROR' || e.code == 'TOO_MANY_REQUESTS');
      setState(() {
        _busy = false;
        _success = false;
        _showError(_describe(e, login: true));
      });
      if (!quiet) _shake(const [_Field.login, _Field.loginPassword]);
    }
  }

  Future<void> _checkUsername() async {
    setState(() {
      _busy = true;
      _showError(null);
    });
    try {
      final free = await ref
          .read(authControllerProvider.notifier)
          .isUsernameAvailable(_username.text.trim().toLowerCase());
      if (!mounted) return;
      if (!free) {
        setState(() => _showError(context.l10n.errorUsernameTaken));
        _shake(const [_Field.username]);
        return;
      }
      _goTo(2);
    } catch (e) {
      if (!mounted) return;
      setState(() => _showError(_describe(e)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _register() async {
    setState(() {
      _busy = true;
      _showError(null);
    });
    _setHold(true);
    try {
      await ref.read(authControllerProvider.notifier).register(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            phone: _phone.text.trim(),
            username: _username.text.trim().toLowerCase(),
            password: _password.text,
            passwordConfirm: _confirm.text,
          );
      await _celebrate();
    } catch (e) {
      _setHold(false);
      if (!mounted) return;
      final field = _fieldFor(e);
      final stepChanged = field == _Field.username || field == _Field.phone;
      setState(() {
        _busy = false;
        _success = false;
        if (field == _Field.username) _step = 1;
        if (field == _Field.phone) _step = 0;
        _showError(_describe(e));
      });
      if (field != null) _shake([field], later: stepChanged);
    }
  }

  /// Tugma "success" holatini ko'rsatadi, so'ng router bosh sahifaga o'tkazadi.
  Future<void> _celebrate() async {
    if (!mounted) return;
    final wait = AppMotion.reduced(context)
        ? const Duration(milliseconds: 250)
        : const Duration(milliseconds: 950);
    setState(() => _success = true);
    await Future<void>.delayed(wait);
    _setHold(false);
  }

  // ---- UI --------------------------------------------------------------------------------------

  Widget get _eye => IconButton(
        icon: AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.fast),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            key: ValueKey(_obscure),
          ),
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );

  Widget _shaken(_Field f, Widget child) => Shake(trigger: _shakes[f]!, child: child);

  double _c1(double v) => v.clamp(-1.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final mq = MediaQuery.of(context);
    final kb = mq.viewInsets.bottom;
    final keyboardOpen = kb > 0;
    final safeTop = mq.padding.top;
    final bottomSafe = keyboardOpen ? 0.0 : mq.viewPadding.bottom;
    final maxSheet = (mq.size.height - kb - safeTop - 72).clamp(220.0, 4000.0).toDouble();
    final register = _mode == AuthMode.register;

    final String title;
    final String? subtitle;
    if (!register) {
      title = l10n.authLoginTitle;
      subtitle = l10n.authLoginSubtitle;
    } else if (_step == 0) {
      title = l10n.authStepInfoTitle;
      subtitle = l10n.authRegisterSubtitle;
    } else if (_step == 1) {
      title = l10n.authStepUsernameTitle;
      subtitle = l10n.authStepUsernameHint;
    } else {
      title = l10n.authStepPasswordTitle;
      subtitle = null;
    }
    final showSubtitle = subtitle != null && !keyboardOpen;

    final primaryLabel = !register
        ? l10n.authLoginButton
        : (_step < 2 ? l10n.authContinue : l10n.authRegister);

    // Parallax: rejim, qadam va klaviaturaga qarab fon qatlamlari chuqurlikka mos siljiydi.
    final baseShift = Offset(
      register ? -0.45 - 0.2 * _step : 0.35,
      -(kb / 320).clamp(0.0, 1.0).toDouble(),
    );

    // Maydonlar ketma-ket (stagger) paydo bo'ladi: ko'rinadigan har bir maydon o'z navbati bilan.
    var k = 2;
    Widget slot(bool visible, Widget child) {
      final order = visible ? k++ : 0;
      return _Collapse(
        visible: visible,
        delay: AppMotion.stagger * order,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: child,
        ),
      );
    }

    final fields = <Widget>[
      slot(
        !register,
        _shaken(
          _Field.login,
          AppTextField(
            controller: _login,
            label: l10n.authLoginField,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            validator: _required,
            enabled: !_busy,
          ),
        ),
      ),
      slot(
        !register,
        _shaken(
          _Field.loginPassword,
          AppTextField(
            controller: _loginPassword,
            label: l10n.authPassword,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            validator: _required,
            onSubmitted: (_) => _submit(),
            enabled: !_busy,
            suffixIcon: _eye,
          ),
        ),
      ),
      slot(
        register && _step == 0,
        _shaken(
          _Field.firstName,
          AppTextField(
            controller: _firstName,
            label: l10n.profileFirstName,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            maxLength: 60,
            validator: _required,
            enabled: !_busy,
          ),
        ),
      ),
      slot(
        register && _step == 0,
        _shaken(
          _Field.lastName,
          AppTextField(
            controller: _lastName,
            label: l10n.profileLastName,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
            maxLength: 60,
            validator: _required,
            enabled: !_busy,
          ),
        ),
      ),
      slot(
        register && _step == 0,
        _shaken(
          _Field.phone,
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
            onSubmitted: (_) => _submit(),
            enabled: !_busy,
          ),
        ),
      ),
      slot(
        register && _step == 1,
        _shaken(
          _Field.username,
          AppTextField(
            controller: _username,
            label: l10n.authUsername,
            hint: l10n.authUsernameHint,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newUsername],
            maxLength: 24,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_.]'))],
            validator: _usernameValidator,
            onSubmitted: (_) => _submit(),
            enabled: !_busy,
          ),
        ),
      ),
      slot(
        register && _step == 2,
        _shaken(
          _Field.password,
          AppTextField(
            controller: _password,
            label: l10n.authPassword,
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            maxLength: 128,
            validator: _passwordValidator,
            enabled: !_busy,
            suffixIcon: _eye,
          ),
        ),
      ),
      slot(
        register && _step == 2,
        _shaken(
          _Field.confirm,
          AppTextField(
            controller: _confirm,
            label: l10n.authPasswordRepeat,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            maxLength: 128,
            validator: _confirmValidator,
            onSubmitted: (_) => _submit(),
            enabled: !_busy,
          ),
        ),
      ),
    ];

    final sheet = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 520, maxHeight: maxSheet),
      child: GlassContainer(
        level: GlassLevel.sheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet + 4)),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg + bottomSafe),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sarlavha: rejim/qadamga qarab silliq almashadi.
                Reveal(
                  index: 0,
                  child: AnimatedSize(
                    duration: AppMotion.of(context, AppMotion.slow),
                    curve: AppMotion.smoothCurve,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: AppMotion.of(context, AppMotion.slow),
                      switchInCurve: AppMotion.smoothCurve,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim),
                          child: child,
                        ),
                      ),
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.topLeft,
                        children: [...previous, if (current != null) current],
                      ),
                      child: SizedBox(
                        key: ValueKey('$_mode-$_step-$showSubtitle'),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: text.titleLarge),
                            if (showSubtitle) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                subtitle,
                                style: text.bodyMedium?.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Reveal(
                  index: 1,
                  child: GlassSegmented<AuthMode>(
                    options: [
                      (AuthMode.login, l10n.authLoginButton),
                      (AuthMode.register, l10n.authRegister),
                    ],
                    value: _mode,
                    onChanged: _setMode,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _Collapse(
                  visible: register,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _StepDots(step: _step, total: 3),
                  ),
                ),
                ...fields,
                _Collapse(
                  visible: _error != null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _error ?? _lastError,
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(color: c.error),
                      ),
                    ),
                  ),
                ),
                Reveal(
                  index: k,
                  child: AppButton(
                    label: primaryLabel,
                    isLoading: _busy && !_success,
                    isSuccess: _success,
                    onPressed: _submit,
                  ),
                ),
                _Collapse(
                  visible: register && _step > 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: AppButton(
                      label: l10n.commonBack,
                      variant: AppButtonVariant.text,
                      onPressed: _busy ? null : () => _goTo(_step - 1),
                    ),
                  ),
                ),
                _Collapse(
                  visible: !keyboardOpen,
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Wrap(
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return PopScope(
      canPop: !(register && _step > 0),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy) _goTo(_step - 1);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Fon: suzuvchi shirinliklar. Sudralganda parallax; bo'sh joyga tegilsa klaviatura yopiladi.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusScope.of(context).unfocus(),
                onPanUpdate: (d) => _pan.value = Offset(
                  _c1(_pan.value.dx + d.delta.dx / 180),
                  _c1(_pan.value.dy + d.delta.dy / 180),
                ),
                onPanEnd: (_) => _pan.value = Offset.zero,
                onPanCancel: () => _pan.value = Offset.zero,
                child: ValueListenableBuilder<Offset>(
                  valueListenable: _pan,
                  builder: (context, pan, _) => CandyBackdrop(parallax: baseShift + pan),
                ),
              ),
            ),
            // Brend: klaviatura chiqqanda xiralashadi.
            Positioned(
              top: safeTop + 72,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: keyboardOpen ? 0 : 1,
                  duration: AppMotion.of(context, AppMotion.slow),
                  child: Column(
                    children: [
                      const Reveal(index: 0, child: BrandMark(size: 88)),
                      const SizedBox(height: AppSpacing.sm),
                      Reveal(
                        index: 1,
                        child: Text(AppConfig.appName, textAlign: TextAlign.center, style: text.displaySmall),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                  child: GlassIconButton(
                    tooltip: l10n.settingsTitle,
                    onPressed: () => context.push(AppRoutes.settings),
                    child: const Icon(Icons.settings_outlined),
                  ),
                ),
              ),
            ),
            // Shisha varaq: pastdan chiqadi, klaviatura chiqqanda tepaga suriladi.
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: kb),
                child: AnimatedBuilder(
                  animation: _sheetIn,
                  child: sheet,
                  builder: (context, child) => FractionalTranslation(
                    translation: Offset(0, 1 - _sheetIn.value),
                    child: child,
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

/// Maydon/blok "morf": kerak bo'lmaganda yig'iladi (balandlik 0 ga), kerak bo'lganda ochiladi.
/// [delay] — ochilishdagi kechikish (ketma-ket paydo bo'lish uchun). Yig'ilganda bola daraxtdan chiqadi,
/// shuning uchun Form faqat ko'rinib turgan maydonlarni tekshiradi.
class _Collapse extends StatefulWidget {
  const _Collapse({required this.visible, required this.child, this.delay = Duration.zero});

  final bool visible;
  final Duration delay;
  final Widget child;

  @override
  State<_Collapse> createState() => _CollapseState();
}

class _CollapseState extends State<_Collapse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController.unbounded(vsync: this, value: 0);
  Timer? _timer;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    _apply();
  }

  @override
  void didUpdateWidget(_Collapse old) {
    super.didUpdateWidget(old);
    if (old.visible != widget.visible) _apply();
  }

  void _apply() {
    _timer?.cancel();
    final target = widget.visible ? 1.0 : 0.0;
    if (AppMotion.reduced(context)) {
      _c.value = target;
      return;
    }
    if (_c.value == target && !_c.isAnimating) return;
    if (widget.visible && widget.delay > Duration.zero) {
      _timer = Timer(widget.delay, () {
        if (mounted) _c.springTo(1, description: AppMotion.smooth);
      });
    } else {
      _c.springTo(target, description: AppMotion.smooth);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final v = _c.value.clamp(0.0, 1.0).toDouble();
        if (v < 0.002) return const SizedBox.shrink();
        return ClipRect(
          clipBehavior: v >= 0.999 ? Clip.none : Clip.hardEdge,
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: v,
            child: Opacity(
              opacity: v,
              child: Transform.translate(offset: Offset(0, (1 - v) * -10), child: child),
            ),
          ),
        );
      },
    );
  }
}

/// Ro'yxatdan o'tish qadamlari ko'rsatkichi: faol qadam cho'ziladi.
class _StepDots extends StatelessWidget {
  const _StepDots({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Semantics(
      label: context.l10n.authStepProgress(step + 1, total),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < total; i++)
            AnimatedContainer(
              duration: AppMotion.of(context, AppMotion.slow),
              curve: AppMotion.smoothCurve,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: i == step ? 26 : 8,
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderPill,
                color: i <= step ? c.cta : c.textSecondary.withValues(alpha: 0.25),
              ),
            ),
        ],
      ),
    );
  }
}