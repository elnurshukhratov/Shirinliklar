import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/expand/expand_scope.dart';
import '../../../core/widgets/glass/glass_search_bar.dart';
import '../../../core/widgets/glass/reveal.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/widgets/product_card.dart';

/// Qidiruv sahifasi: bosh sahifadagi pill'dan butun ekranga kengayadi. Mavjud qidiruv mantiqi
/// saqlangan (400 ms debounce -> `catalogListProvider.setSearch`); natijalar yangi mahsulot kartalarida.
/// Yopilganda qidiruv tozalanadi, bosh sahifa to'liq ro'yxatga qaytadi.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  Timer? _debounce;
  late final CatalogListController _notifier;
  ValueListenable<double>? _progress;
  bool _focusRequested = false;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(catalogListProvider.notifier);
    _controller.text = ref.read(catalogListProvider).search;
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.extentAfter < 400) _notifier.loadMore();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_progress != null || _focusRequested) return;
    final progress = ExpandScope.maybeOf(context)?.progress;
    if (progress == null) {
      _requestFocus();
    } else {
      _progress = progress;
      progress.addListener(_onProgress);
    }
  }

  /// Klaviatura kengayish tugagach ochiladi (animatsiya paytida emas).
  void _onProgress() {
    if (_progress != null && _progress!.value >= 0.96) {
      _progress!.removeListener(_onProgress);
      _requestFocus();
    }
  }

  void _requestFocus() {
    if (_focusRequested) return;
    _focusRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _progress?.removeListener(_onProgress);
    _scroll.dispose();
    _controller.dispose();
    _focus.dispose();
    final notifier = _notifier;
    Future<void>(() {
      if (notifier.mounted) notifier.setSearch('');
    });
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _notifier.setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(catalogListProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ExpandReveal(
              index: 0,
              offset: 12,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.sm, AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassSearchBar(
                        controller: _controller,
                        focusNode: _focus,
                        hint: l10n.catalogSearchHint,
                        onChanged: _onChanged,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(l10n.commonCancel),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: ExpandReveal(index: 1, child: _results(context, state))),
          ],
        ),
      ),
    );
  }

  Widget _results(BuildContext context, CatalogListState state) {
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewPadding.bottom + mq.viewInsets.bottom + AppSpacing.xl;

    if (state.loading && state.items.isEmpty) {
      return CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, bottomInset),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.md,
              childCount: 6,
              itemBuilder: (context, i) => SkeletonCard(aspectRatio: i.isEven ? 0.8 : 1),
            ),
          ),
        ],
      );
    }

    if (state.error != null && state.items.isEmpty) {
      final err = describeError(l10n, state.error!);
      return ErrorState(
        title: err.title,
        message: err.message,
        retryLabel: l10n.commonRetry,
        onRetry: _notifier.refresh,
      );
    }

    if (state.items.isEmpty) {
      return state.search.isNotEmpty
          ? EmptyState(
              title: l10n.noResultsTitle,
              message: l10n.noResultsMessage,
              icon: Icons.search_off_rounded,
            )
          : EmptyState(title: l10n.catalogEmptyTitle, message: l10n.catalogEmptyMessage);
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      // Clamping: tepada pastga tortish sahifani yopish harakati sifatida ExpandHost'ga yetib boradi.
      child: CustomScrollView(
        controller: _scroll,
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              state.loadingMore ? 0 : bottomInset,
            ),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.md,
              childCount: state.items.length,
              itemBuilder: (context, i) {
                final product = state.items[i];
                return Reveal(
                  key: ValueKey(product.id),
                  index: i % 6,
                  child: ProductCard(product: product, aspectRatio: i.isEven ? 0.8 : 1),
                );
              },
            ),
          ),
          if (state.loadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, AppSpacing.xl, 0, bottomInset),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}