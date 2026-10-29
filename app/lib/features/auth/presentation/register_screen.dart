import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/auth_controller.dart';
import 'map_picker_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static final _usernameRe = RegExp(r'^[a-zA-Z0-9_.]{3,24}$');
  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  LatLng? _pickedPoint;
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _username, _email, _phone, _address, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? context.l10n.fieldRequired : null;

  String? _usernameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    return _usernameRe.hasMatch(v.trim()) ? null : context.l10n.usernameInvalid;
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    return _emailRe.hasMatch(v.trim()) ? null : context.l10n.emailInvalid;
  }

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 15) return context.l10n.phoneInvalid;
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return context.l10n.fieldRequired;
    return v.length < 8 ? context.l10n.passwordTooShort : null;
  }

  String? _confirmValidator(String? v) {
    if (v == null || v.isEmpty) return context.l10n.fieldRequired;
    return v == _password.text ? null : context.l10n.passwordMismatch;
  }

  Future<void> _pickAddress() async {
    FocusScope.of(context).unfocus();
    final picked = await Navigator.of(context).push<PickedAddress>(
      MaterialPageRoute(builder: (_) => MapPickerScreen(initial: _pickedPoint)),
    );
    if (picked == null || !mounted) return;
    _pickedPoint = LatLng(picked.latitude, picked.longitude);
    setState(() => _address.text = picked.address);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).register(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            username: _username.text.trim().toLowerCase(),
            email: _email.text.trim().toLowerCase(),
            phone: _phone.text.trim(),
            address: _address.text.trim(),
            password: _password.text,
            passwordConfirm: _confirm.text,
          );
      // Muvaffaqiyatli bo'lsa router o'zi bosh sahifaga o'tkazadi.
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = describeError(context.l10n, e).message);
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
      appBar: AppBar(title: Text(l10n.authRegisterTitle)),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(l10n.authRegisterSubtitle, style: text.bodyMedium?.copyWith(color: c.textSecondary)),
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
              controller: _username,
              label: l10n.authUsername,
              hint: l10n.authUsernameHint,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newUsername],
              maxLength: 24,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_.]'))],
              validator: _usernameValidator,
              enabled: !_busy,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _email,
              label: l10n.authEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              maxLength: 254,
              validator: _emailValidator,
              enabled: !_busy,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _phone,
              label: l10n.profilePhone,
              hint: l10n.profilePhoneHint,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              maxLength: 20,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]'))],
              validator: _phoneValidator,
              enabled: !_busy,
            ),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _busy ? null : _pickAddress,
              child: AbsorbPointer(
                child: AppTextField(
                  controller: _address,
                  label: l10n.authAddressFromMap,
                  hint: l10n.authAddressFromMapHint,
                  maxLines: 2,
                  validator: _required,
                  suffixIcon: const Icon(Icons.map_outlined),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
              onSubmitted: (_) => _submit(),
              enabled: !_busy,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_error != null) ...[
              Text(_error!, style: text.bodyMedium?.copyWith(color: c.error)),
              const SizedBox(height: AppSpacing.md),
            ],
            AppButton(
              label: l10n.authRegister,
              isLoading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}