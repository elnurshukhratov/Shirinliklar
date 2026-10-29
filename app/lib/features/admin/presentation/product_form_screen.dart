import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';
import 'widgets/admin_image.dart';

const _maxImages = 8;
const _langLabels = ['UZ', 'EN', 'RU'];

List<TextEditingController> _controllersFor(LocalizedText t) => [
      TextEditingController(text: t.uz),
      TextEditingController(text: t.en),
      TextEditingController(text: t.ru),
    ];

LocalizedText _read(List<TextEditingController> c) =>
    LocalizedText(uz: c[0].text.trim(), en: c[1].text.trim(), ru: c[2].text.trim());

class _VariantDraft {
  _VariantDraft({
    this.id,
    this.group = VariantGroup.size,
    this.isActive = true,
    LocalizedText? name,
    double delta = 0,
  })  : names = _controllersFor(name ?? const LocalizedText()),
        delta = TextEditingController(text: delta == 0 ? '' : delta.round().toString());

  final String? id;
  VariantGroup group;
  final bool isActive;
  final List<TextEditingController> names;
  final TextEditingController delta;

  void dispose() {
    for (final c in names) {
      c.dispose();
    }
    delta.dispose();
  }
}

/// Mahsulot yaratish (productId yo'q) va tahrirlash formasi.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final Map<String, List<TextEditingController>> _texts = {
    'name': _controllersFor(const LocalizedText()),
    'description': _controllersFor(const LocalizedText()),
    'ingredients': _controllersFor(const LocalizedText()),
    'allergens': _controllersFor(const LocalizedText()),
  };
  final _price = TextEditingController();
  final _stock = TextEditingController();

  final List<String> _images = [];
  final List<_VariantDraft> _variants = [];
  final List<_VariantDraft> _removedVariants = [];

  int _lang = 0;
  String? _categoryId;
  bool _isActive = true;

  bool _loading = false;
  Object? _loadError;
  bool _uploading = false;
  bool _saving = false;
  bool _showLangError = false;
  String? _saveError;

  bool get _isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _load();
  }

  @override
  void dispose() {
    for (final list in _texts.values) {
      for (final c in list) {
        c.dispose();
      }
    }
    _price.dispose();
    _stock.dispose();
    for (final v in [..._variants, ..._removedVariants]) {
      v.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final p = await ref.read(adminRepositoryProvider).product(widget.productId!);
      if (!mounted) return;
      _fill(p);
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e;
      });
    }
  }

  void _setTexts(String key, LocalizedText t) {
    final c = _texts[key]!;
    c[0].text = t.uz;
    c[1].text = t.en;
    c[2].text = t.ru;
  }

  void _fill(AdminProduct p) {
    _setTexts('name', p.name);
    _setTexts('description', p.description);
    _setTexts('ingredients', p.ingredients);
    _setTexts('allergens', p.allergens);
    _price.text = p.price.round().toString();
    _stock.text = p.stock.toString();
    _images
      ..clear()
      ..addAll(p.images);
    _isActive = p.isActive;
    _categoryId = p.categoryId;
    _removedVariants.addAll(_variants);
    _variants
      ..clear()
      ..addAll(p.variants.map(
        (v) => _VariantDraft(
          id: v.id,
          group: v.group,
          isActive: v.isActive,
          name: v.name,
          delta: v.priceDelta,
        ),
      ));
  }

  // ---- Rasmlar ----

  Future<void> _pickImages() async {
    final room = _maxImages - _images.length;
    if (room <= 0) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(adminRepositoryProvider);

    final files = await _picker.pickMultiImage(maxWidth: 1600, imageQuality: 85);
    if (files.isEmpty || !mounted) return;

    setState(() => _uploading = true);
    try {
      final urls = await repo.uploadImages(files.take(room).toList());
      if (!mounted) return;
      setState(() => _images.addAll(urls));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
  }

  // ---- Tekshiruv va saqlash ----

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? context.l10n.fieldRequired : null;

  String? _priceValidator(String? v) {
    if (v == null || v.trim().isEmpty) return context.l10n.fieldRequired;
    final n = int.tryParse(v.trim());
    if (n == null || n < 0) return context.l10n.adminNumberInvalid;
    return null;
  }

  String? _stockValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return int.tryParse(v.trim()) == null ? context.l10n.adminNumberInvalid : null;
  }

  String? _deltaValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return int.tryParse(v.trim()) == null ? context.l10n.adminNumberInvalid : null;
  }

  /// Nom (va variant nomlari) uchala tilda to'ldirilganini tekshiradi.
  int? _firstIncompleteLanguage() {
    for (var i = 0; i < 3; i++) {
      if (_texts['name']![i].text.trim().isEmpty) return i;
      if (_variants.any((v) => v.names[i].text.trim().isEmpty)) return i;
    }
    return null;
  }

  Map<String, dynamic> _buildBody() {
    return {
      'name': _read(_texts['name']!).toJson(),
      'description': _read(_texts['description']!).toJson(),
      'ingredients': _read(_texts['ingredients']!).toJson(),
      'allergens': _read(_texts['allergens']!).toJson(),
      'price': int.parse(_price.text.trim()),
      'stock': int.tryParse(_stock.text.trim()) ?? 0,
      'images': _images,
      'isActive': _isActive,
      'categoryId': _categoryId,
      'variants': [
        for (var i = 0; i < _variants.length; i++)
          {
            if (_variants[i].id != null) 'id': _variants[i].id,
            'group': _variants[i].group.api,
            'name': _read(_variants[i].names).toJson(),
            'priceDelta': int.tryParse(_variants[i].delta.text.trim()) ?? 0,
            'sortOrder': i,
            'isActive': _variants[i].isActive,
          },
      ],
    };
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final missing = _firstIncompleteLanguage();
    if (missing != null) {
      setState(() {
        _lang = missing;
        _showLangError = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _formKey.currentState?.validate());
      return;
    }
    if (_showLangError) setState(() => _showLangError = false);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final repo = ref.read(adminRepositoryProvider);
    final list = ref.read(adminProductListProvider.notifier);

    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await repo.saveProduct(id: widget.productId, body: _buildBody());
      await list.refresh();
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminProductSaved)));
      if (mounted) router.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saveError = describeError(l10n, e).message;
        _saving = false;
      });
    }
  }

  // ---- Interfeys ----

  String _groupLabel(AppLocalizations l10n, VariantGroup g) => switch (g) {
        VariantGroup.size => l10n.adminVariantSize,
        VariantGroup.cream => l10n.adminVariantCream,
        VariantGroup.inscription => l10n.adminVariantInscription,
      };

  Widget _langField(
    String key,
    String label, {
    int maxLines = 1,
    int? maxLength,
    bool required = false,
  }) {
    return AppTextField(
      key: ValueKey('$key-$_lang'),
      controller: _texts[key]![_lang],
      label: label,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
      validator: required ? _required : null,
      enabled: !_saving,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.adminProductEdit : l10n.adminProductNew)),
      body: _buildBody2(context),
    );
  }

  Widget _buildBody2(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_loadError != null) {
      final err = describeError(l10n, _loadError!);
      return ErrorState(
        title: err.title,
        message: err.message,
        retryLabel: l10n.commonRetry,
        onRetry: _load,
      );
    }

    final categories = ref.watch(adminCategoriesProvider);
    const gap = SizedBox(height: AppSpacing.lg);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Rasmlar
          Text(l10n.adminImages, style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 104,
            child: Row(
              children: [
                _AddImageTile(
                  uploading: _uploading,
                  enabled: !_uploading && !_saving && _images.length < _maxImages,
                  onTap: _pickImages,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    onReorder: _reorderImages,
                    itemBuilder: (context, i) => Padding(
                      key: ValueKey(_images[i]),
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: _ImageThumb(
                        url: _images[i],
                        isMain: i == 0,
                        onRemove: () => setState(() => _images.removeAt(i)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.adminImagesHint(_maxImages),
            style: text.bodySmall?.copyWith(color: c.textSecondary),
          ),
          gap,

          // Til tanlash
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (var i = 0; i < 3; i++) ButtonSegment(value: i, label: Text(_langLabels[i])),
              ],
              selected: {_lang},
              onSelectionChanged: (s) => setState(() => _lang = s.first),
            ),
          ),
          if (_showLangError) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.adminFillAllLanguages, style: text.bodySmall?.copyWith(color: c.error)),
          ],
          gap,

          _langField('name', l10n.adminFieldName, maxLength: 150, required: true),
          gap,
          _langField('description', l10n.adminFieldDescription, maxLines: 4, maxLength: 4000),
          gap,
          _langField('ingredients', l10n.adminFieldIngredients, maxLines: 3, maxLength: 2000),
          gap,
          _langField('allergens', l10n.adminFieldAllergens, maxLines: 2, maxLength: 500),
          gap,

          // Narx va miqdor
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  controller: _price,
                  label: l10n.adminFieldPrice,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                  validator: _priceValidator,
                  enabled: !_saving,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  controller: _stock,
                  label: l10n.adminFieldStock,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 6,
                  validator: _stockValidator,
                  enabled: !_saving,
                ),
              ),
            ],
          ),
          gap,

          // Toifa
          Text(l10n.adminFieldCategory, style: text.labelLarge),
          const SizedBox(height: 6),
          categories.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text(
              describeError(l10n, e).message,
              style: text.bodyMedium?.copyWith(color: c.error),
            ),
            data: (list) {
              final ids = list.map((e) => e.id).toSet();
              final value = ids.contains(_categoryId) ? _categoryId : null;
              final lang = Localizations.localeOf(context).languageCode;
              return DropdownButtonFormField<String?>(
                value: value,
                isExpanded: true,
                decoration: const InputDecoration(),
                items: [
                  DropdownMenuItem<String?>(value: null, child: Text(l10n.adminNoCategory)),
                  for (final cat in list)
                    DropdownMenuItem<String?>(
                      value: cat.id,
                      child: Text(cat.name.forLanguage(lang), overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: _saving ? null : (v) => setState(() => _categoryId = v),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.adminFieldVisible),
            value: _isActive,
            onChanged: _saving ? null : (v) => setState(() => _isActive = v),
          ),
          gap,

          // Variantlar
          Row(
            children: [
              Expanded(child: Text(l10n.adminVariants, style: text.titleMedium)),
              TextButton.icon(
                onPressed: _saving ? null : () => setState(() => _variants.add(_VariantDraft())),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.adminAddVariant),
              ),
            ],
          ),
          for (var i = 0; i < _variants.length; i++) ...[
            const SizedBox(height: AppSpacing.sm),
            _variantCard(context, i),
          ],
          const SizedBox(height: AppSpacing.xl),

          if (_saveError != null) ...[
            Text(_saveError!, style: text.bodyMedium?.copyWith(color: c.error)),
            const SizedBox(height: AppSpacing.md),
          ],
          AppButton(
            label: l10n.commonSave,
            isLoading: _saving,
            onPressed: _uploading ? null : _submit,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _variantCard(BuildContext context, int index) {
    final l10n = context.l10n;
    final d = _variants[index];

    return AppCard(
      key: ObjectKey(d),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<VariantGroup>(
                  value: d.group,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.adminVariantGroup),
                  items: [
                    for (final g in VariantGroup.values)
                      DropdownMenuItem(value: g, child: Text(_groupLabel(l10n, g))),
                  ],
                  onChanged: _saving ? null : (g) => setState(() => d.group = g ?? d.group),
                ),
              ),
              IconButton(
                tooltip: l10n.commonDelete,
                icon: Icon(Icons.delete_outline_rounded, color: context.colors.error),
                onPressed: _saving
                    ? null
                    : () => setState(() {
                          _variants.removeAt(index);
                          _removedVariants.add(d);
                        }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            key: ValueKey('variant-${identityHashCode(d)}-$_lang'),
            controller: d.names[_lang],
            label: '${l10n.adminVariantName} · ${_langLabels[_lang]}',
            maxLength: 80,
            validator: _required,
            enabled: !_saving,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: d.delta,
            label: l10n.adminVariantPriceDelta,
            hint: l10n.adminVariantPriceDeltaHint,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
            maxLength: 11,
            validator: _deltaValidator,
            enabled: !_saving,
          ),
        ],
      ),
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({required this.uploading, required this.enabled, required this.onTap});

  final bool uploading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Semantics(
      button: true,
      enabled: enabled,
      label: context.l10n.adminImages,
      excludeSemantics: true,
      child: Material(
        color: c.secondary,
        borderRadius: AppRadius.borderBase,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 104,
            height: 104,
            child: Center(
              child: uploading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.add_photo_alternate_outlined, color: c.textPrimary, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.url, required this.isMain, required this.onRemove});

  final String url;
  final bool isMain;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        children: [
          ClipRRect(borderRadius: AppRadius.borderBase, child: AdminImage(url: url, size: 104)),
          if (isMain)
            Positioned(
              left: 6,
              bottom: 6,
              child: AppBadge(label: context.l10n.adminMainImage, tone: AppBadgeTone.primary),
            ),
          Positioned(
            right: 4,
            top: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
                child: Icon(Icons.close_rounded, size: 16, color: c.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}