import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/glass/glass_navigation_bar.dart';
import '../../auth/application/auth_controller.dart';
import 'admin_categories_tab.dart';
import 'admin_manage_tab.dart';
import 'admin_orders_tab.dart';
import 'admin_products_tab.dart';
import 'admin_reviews_tab.dart';

enum _AdminTab { orders, products, categories, reviews, manage }

/// Admin panelning asosiy ramkasi: pastki navigatsiya va bo'limlar.
/// Xodim buyurtma, mahsulot va izohlar bilan ishlaydi (toifalarni faqat ko'radi);
/// «Boshqaruv» bo'limi (promokod, xodimlar) faqat do'kon egasiga ko'rinadi.
class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOwner = ref.watch(authControllerProvider).user?.isOwner ?? false;

    final tabs = [
      _AdminTab.orders,
      _AdminTab.products,
      _AdminTab.categories,
      _AdminTab.reviews,
      if (isOwner) _AdminTab.manage,
    ];
    final index = _index.clamp(0, tabs.length - 1).toInt();
    final current = tabs[index];

    Widget body(_AdminTab t) => switch (t) {
          _AdminTab.orders => const AdminOrdersTab(),
          _AdminTab.products => const AdminProductsTab(),
          _AdminTab.categories => AdminCategoriesTab(readOnly: !isOwner),
          _AdminTab.reviews => const AdminReviewsTab(),
          _AdminTab.manage => const AdminManageTab(),
        };

    GlassNavItem item(_AdminTab t) => switch (t) {
          _AdminTab.orders => GlassNavItem(
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long_rounded,
              label: l10n.adminTabOrders,
            ),
          _AdminTab.products => GlassNavItem(
              icon: Icons.cookie_outlined,
              selectedIcon: Icons.cookie_rounded,
              label: l10n.adminTabProducts,
            ),
          _AdminTab.categories => GlassNavItem(
              icon: Icons.category_outlined,
              selectedIcon: Icons.category_rounded,
              label: l10n.adminTabCategories,
            ),
          _AdminTab.reviews => GlassNavItem(
              icon: Icons.rate_review_outlined,
              selectedIcon: Icons.rate_review_rounded,
              label: l10n.adminTabReviews,
            ),
          _AdminTab.manage => GlassNavItem(
              icon: Icons.tune_outlined,
              selectedIcon: Icons.tune_rounded,
              label: l10n.adminTabManage,
            ),
        };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPanelTitle)),
      body: IndexedStack(
        index: index,
        children: [for (final t in tabs) body(t)],
      ),
      floatingActionButton: switch (current) {
        _AdminTab.products => FloatingActionButton.extended(
            onPressed: () => context.push(AppRoutes.adminProductNew),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.adminAddProduct),
          ),
        _AdminTab.categories when isOwner => FloatingActionButton.extended(
            onPressed: () => openCategoryEditor(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.adminAddCategory),
          ),
        _ => null,
      },
      bottomNavigationBar: GlassNavigationBar(
        selectedIndex: index,
        onSelected: (i) => setState(() => _index = i),
        items: [for (final t in tabs) item(t)],
      ),
    );
  }
}
