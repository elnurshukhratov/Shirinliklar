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

/// Birinchi kirishdan keyingi ma'lumot to'ldirish (onboarding) va profilni tahrirlash uchun umumiy ekran.
class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({super.key, required this.onboarding});

  final bool onboarding;

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _landmark;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authControllerProvider).user;
    _firstName = TextEditingController(text: u?.firstName ?? '');
    _lastName = TextEditingController(text: u?.lastName ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
    _address = TextEditingController(text: u?.address ?? '');
    _landmark = TextEditingController(text: u?.landmark ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _address.dispose();
    _landmark.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? context.l10n.fieldRequired : null;

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 15) return context.l10n.phoneInvalid;
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final l10n = context.l10n;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            phone: _phone.text.trim(),
            address: _address.text.trim(),
            landmark: _landmark.text.trim(),
          );
      if (!mounted) return;
      if (!widget.onboarding) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
        router.pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = describeError(l10n, e).message);
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
      appBar: AppBar(
        automaticallyImplyLeading: !widget.onboarding,
        title: Text(widget.onboarding ? l10n.onboardingTitle : l10n.profileEditTitle),
        actions: [
          if (widget.onboarding)
            IconButton(
              tooltip: l10n.authSignOut,
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (widget.onboarding) ...[
              Text(
                l10n.onboardingSubtitle,
                style: text.bodyMedium?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
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
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              maxLength: 20,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]'))],
              validator: _phoneValidator,
              enabled: !_busy,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _address,
              label: l10n.profileAddress,
              hint: l10n.profileAddressHint,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.next,
              maxLines: 2,
              maxLength: 255,
              validator: _required,
              enabled: !_busy,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _landmark,
              label: l10n.profileLandmark,
              hint: l10n.profileLandmarkHint,
              textInputAction: TextInputAction.done,
              maxLength: 255,
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