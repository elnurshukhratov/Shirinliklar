import '../../../core/widgets/glass/glass_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../catalog/presentation/widgets/product_image.dart';
import '../../promo/application/promo_controller.dart';
import '../../promo/presentation/promo_section.dart';
import '../../store/application/store_providers.dart';
import '../../store/presentation/store_closed_banner.dart';
import '../application/cart_controller.dart';
import '../domain/cart_models.dart';
import 'widgets/quantity_stepper.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate(showError: true));
  }

  Future<void> _validate({bool showError = false}) async {
    if (_checking || ref.read(cartProvider).items.isEmpty) return;
    setState(() => _checking = true);
    final error = await ref.read(cartProvider.notifier).validate();
    if (!mounted) return;
    setState(() => _checking = false);
    if (error != null && showError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeError(context.l10n, error).message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cart = ref.watch(cartProvider);
    final closed = !(ref.watch(storeStatusProvider).valueOrNull?.acceptingOrders ?? true);
    final promo = ref.watch(appliedPromoProvider);
    final discount = promo?.discountFor(cart.total) ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cartTitle)),
      body: Column(
        children: [
          if (_checking) const LinearProgressIndicator(minHeight: 2),
          if (cart.hasNotice) _NoticeBanner(state: cart),
          if (closed && cart.items.isNotEmpty)
            const StoreClosedNotice(
              margin: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
            ),
          Expanded(
            child: cart.items.isEmpty
                ? EmptyState(
                    title: l10n.cartEmptyTitle,
                    message: l10n.cartEmptyMessage,
                    icon: Icons.shopping_bag_outlined,
                    actionLabel: l10n.cartGoToCatalog,
                    onAction: () => context.go(AppRoutes.home),
                  )
                : RefreshIndicator(
                    onRefresh: () => _validate(showError: true),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: cart.items.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) {
                        if (i == cart.items.length) return PromoSection(subtotal: cart.total);
                        return _CartItemCard(
                          key: ValueKey(cart.items[i].key),
                          item: cart.items[i],
                        );
                      },
                    ),
                  ),
          ),
          if (cart.items.isNotEmpty) _SummaryBar(
              count: cart.count,
              total: cart.total,
              discount: discount,
              onCheckout: closed ? null : () => context.push(AppRoutes.checkout),
            ),
        ],
      ),
    );
  }
}

class _NoticeBanner extends ConsumerWidget {
  const _NoticeBanner({required this.state});

  final CartState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;

    final lines = <String>[
      if (state.removed.isNotEmpty)
        l10n.cartRemovedNotice(state.removed.map((e) => e.forLanguage(lang)).join(', ')),
      if (state.reduced) l10n.cartReducedNotice,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.xs, AppSpacing.md),
        decoration: BoxDecoration(
          color: c.secondary.withAlpha(110),
          borderRadius: AppRadius.borderBase,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.info_outline_rounded, size: 20, color: c.error),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(lines.join('\n'), style: text.bodyMedium?.copyWith(height: 1.4)),
            ),
            IconButton(
              tooltip: l10n.commonClose,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: ref.read(cartProvider.notifier).dismissNotice,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  const _CartItemCard({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final notifier = ref.read(cartProvider.notifier);

    final variants = item.variantNames.map((e) => e.forLanguage(lang)).join(' · ');

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppRadius.borderSmall,
                child: SizedBox(width: 72, height: 72, child: ProductImage(url: item.image)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name.forLanguage(lang), maxLines: 2, overflow: TextOverflow.ellipsis, style: text.titleSmall),
                    if (variants.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        variants,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelMedium?.copyWith(color: c.textSecondary),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.formatPrice(item.unitPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.cartRemoveItem,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.delete_outline_rounded, color: c.textSecondary),
                onPressed: () => notifier.remove(item.key),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              QuantityStepper(
                value: item.quantity,
                max: notifier.maxFor(item),
                onChanged: (q) {
                  final applied = notifier.setQuantity(item.key, q);
                  if (applied < q) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(l10n.cartStockLimit(applied))));
                  }
                },
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.of(context),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: Align(
                    key: ValueKey(item.lineTotal),
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        context.formatPrice(item.lineTotal),
                        maxLines: 1,
                        style: text.titleSmall?.copyWith(color: c.primary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.count,
    required this.total,
    required this.discount,
    required this.onCheckout,
  });

  final int count;
  final double total;

  /// Promokod chegirmasi (0 — promokod yo'q).
  final double discount;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return GlassBottomBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (discount > 0) ...[
                Row(
                  children: [
                    Expanded(child: Text(l10n.promoDiscountLabel, style: text.bodyMedium)),
                    Text(
                      '−${context.formatPrice(discount)}',
                      style: text.titleSmall?.copyWith(color: c.success),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.productTotal, style: text.titleMedium),
                        Text(
                          l10n.piecesCount(count),
                          style: text.labelMedium?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: AppMotion.of(context),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: Text(
                      context.formatPrice(total - discount),
                      key: ValueKey(total - discount),
                      style: text.titleLarge?.copyWith(color: c.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(label: l10n.cartCheckout, onPressed: onCheckout),
            ],
          ),
    );
  }
}
