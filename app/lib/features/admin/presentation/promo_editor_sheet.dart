import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/admin_promo_providers.dart';
import '../domain/admin_promo_models.dart';

/// Promokod yaratish va tahrirlash: chegirma (foiz yoki summa), muddat, foydalanish chegarasi.
class PromoEditorSheet extends ConsumerStatefulWidget {
  const PromoEditorSheet({super.key, this.promo});

  final AdminPromo? promo;

  @override
  ConsumerState<PromoEditorSheet> createState() => _PromoEditorSheetState();
}

class _PromoEditorSheetState extends ConsumerState<PromoEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _value;
  late final TextEditingController _limit;
  late bool _percent;
  late bool _isActive;
  DateTime? _expiresAt;
  bool _busy = false;
  String? _error;

  bool get _editing => widget.promo != null;

  @override
  void initState() {
    super.initState();
    final p = widget.promo;
    _code = TextEditingController(text: p?.code ?? '');
    _percent = p?.isPercent ?? true;
    _value = TextEditingController(
      text: p == null ? '' : (p.isPercent ? '${p.discountPercent}' : '${(p.discountAmount ?? 0).round()}'),
    );
    _limit = TextEditingController(text: p?.usageLimit?.toString() ?? '');
    _isActive = p?.isActive ?? true;
    _expiresAt = p?.expiresAt;
  }

  @override
  void dispose() {
    _code.dispose();
    _value.dispose();
    _limit.dispose();
    super.dispose();
  }

  String? _validateCode(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return context.l10n.fieldRequired;
    return RegExp(r'^[A-Za-z0-9_-]{3,32}$').hasMatch(s) ? null : context.l10n.adminPromoCodeInvalid;
  }

  String? _validateValue(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 1) return context.l10n.fieldRequired;
    if (_percent && n > 100) return context.l10n.adminPromoPercentInvalid;
    return null;
  }

  String? _validateLimit(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null;
    final n = int.tryParse(s);
    return (n == null || n < 1) ? context.l10n.adminPromoLimitInvalid : null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _expiresAt != null && _expiresAt!.isAfter(now) ? _expiresAt! : now.add(const Duration(days: 7));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (date == null || !mounted) return;
    // Muddat tanlangan kunning oxirigacha amal qiladi.
    setState(() => _expiresAt = DateTime(date.year, date.month, date.day, 23, 59, 59));
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final value = int.parse(_value.text.trim());
    final limitText = _limit.text.trim();
    final limit = limitText.isEmpty ? null : int.parse(limitText);
    final expires = _expiresAt?.toUtc().toIso8601String();

    // Yangi promokodda bo'sh maydonlar yuborilmaydi; tahrirda esa null — qiymatni tozalaydi.
    final body = <String, dynamic>{
      if (!_editing) 'code': _code.text.trim().toUpperCase(),
      if (_percent) 'discountPercent': value else 'discountAmount': value,
      if (_editing) (_percent ? 'discountAmount' : 'discountPercent'): null,
      if (_editing || expires != null) 'expiresAt': expires,
      if (_editing || limit != null) 'usageLimit': limit,
      'isActive': _isActive,
    };

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(adminPromoRepositoryProvider).save(id: widget.promo?.id, body: body);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminPromoSaved)));
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = describeError(l10n, e).message;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final expires = _expiresAt;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_editing ? l10n.adminPromoEdit : l10n.adminPromoNew, style: text.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _code,
                label: l10n.adminPromoCode,
                hint: 'SHIRIN10',
                maxLength: 32,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
                  TextInputFormatter.withFunction(
                    (old, value) => value.copyWith(text: value.text.toUpperCase()),
                  ),
                ],
                validator: _validateCode,
                enabled: !_busy && !_editing,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.adminPromoDiscountType, style: text.labelLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  AppChip(
                    label: l10n.adminPromoTypePercent,
                    selected: _percent,
                    onTap: _busy ? null : () => setState(() => _percent = true),
                  ),
                  AppChip(
                    label: l10n.adminPromoTypeAmount,
                    selected: !_percent,
                    onTap: _busy ? null : () => setState(() => _percent = false),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _value,
                label: _percent ? l10n.adminPromoValuePercent : l10n.adminPromoValueAmount,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: _percent ? 3 : 9,
                validator: _validateValue,
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _limit,
                label: l10n.adminPromoUsageLimit,
                hint: l10n.adminPromoUnlimited,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 7,
                validator: _validateLimit,
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.adminPromoExpiry, style: text.labelLarge),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: expires == null ? l10n.adminPromoNoExpiry : context.formatDate(expires),
                      icon: Icons.event_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: _busy ? null : _pickDate,
                    ),
                  ),
                  if (expires != null)
                    IconButton(
                      tooltip: l10n.adminPromoClearExpiry,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _busy ? null : () => setState(() => _expiresAt = null),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.adminPromoActiveSwitch),
                value: _isActive,
                onChanged: _busy ? null : (v) => setState(() => _isActive = v),
              ),
              if (_error != null) ...[
                Text(_error!, style: text.bodyMedium?.copyWith(color: c.error)),
                const SizedBox(height: AppSpacing.md),
              ],
              AppButton(label: l10n.commonSave, isLoading: _busy, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
