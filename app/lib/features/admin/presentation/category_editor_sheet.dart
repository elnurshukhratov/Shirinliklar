import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';

class CategoryEditorSheet extends ConsumerStatefulWidget {
  const CategoryEditorSheet({super.key, this.category});

  final AdminCategory? category;

  @override
  ConsumerState<CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends ConsumerState<CategoryEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _uz;
  late final TextEditingController _en;
  late final TextEditingController _ru;
  late final TextEditingController _sort;
  late bool _isActive;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _uz = TextEditingController(text: c?.name.uz ?? '');
    _en = TextEditingController(text: c?.name.en ?? '');
    _ru = TextEditingController(text: c?.name.ru ?? '');
    _sort = TextEditingController(text: (c?.sortOrder ?? 0).toString());
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _uz.dispose();
    _en.dispose();
    _ru.dispose();
    _sort.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? context.l10n.fieldRequired : null;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(adminRepositoryProvider).saveCategory(
        id: widget.category?.id,
        body: {
          'name': {'uz': _uz.text.trim(), 'en': _en.text.trim(), 'ru': _ru.text.trim()},
          'sortOrder': int.tryParse(_sort.text.trim()) ?? 0,
          'isActive': _isActive,
        },
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminCategorySaved)));
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
              Text(
                widget.category == null ? l10n.adminCategoryNew : l10n.adminCategoryEdit,
                style: text.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _uz,
                label: '${l10n.adminFieldName} · UZ',
                maxLength: 80,
                textInputAction: TextInputAction.next,
                validator: _required,
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _en,
                label: '${l10n.adminFieldName} · EN',
                maxLength: 80,
                textInputAction: TextInputAction.next,
                validator: _required,
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _ru,
                label: '${l10n.adminFieldName} · RU',
                maxLength: 80,
                textInputAction: TextInputAction.next,
                validator: _required,
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _sort,
                label: l10n.adminCategorySortOrder,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 5,
                enabled: !_busy,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.adminFieldVisible),
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