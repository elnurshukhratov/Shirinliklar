import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/domain/admin_models.dart';
import '../../features/admin/presentation/admin_home_screen.dart';
import '../../features/admin/presentation/admin_order_detail_screen.dart';
import '../../features/admin/presentation/admin_promos_screen.dart';
import '../../features/admin/presentation/admin_staff_screen.dart';
import '../../features/admin/presentation/admin_stats_screen.dart';
import '../../features/admin/presentation/product_form_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/credentials_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/profile_form_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/catalog/presentation/product_detail_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/search_screen.dart';
import '../../features/order/domain/order_models.dart';
import '../../features/order/presentation/checkout_screen.dart';
import '../../features/order/presentation/my_order_detail_screen.dart';
import '../../features/order/presentation/my_orders_screen.dart';
import '../../features/order/presentation/order_success_screen.dart';
import '../../features/order/presentation/payment_screen.dart';
import '../../features/review/presentation/review_form_screen.dart';
import '../../features/legal/domain/legal_content.dart';
import '../../features/legal/presentation/legal_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../widgets/expand/expand_backdrop.dart';
import '../widgets/expand/expand_page.dart';
import 'app_page.dart';
import 'app_shell.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const home = '/';
  static const search = '/search';
  static const settings = '/settings';
  static const legalPrivacy = '/legal/privacy';
  static const legalRefund = '/legal/refund';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const profileCredentials = '/profile/credentials';
  static const admin = '/admin';
  static const adminPromos = '/admin/promos';
  static const adminStaff = '/admin/staff';
  static const adminStats = '/admin/stats';
  static const adminProductNew = '/admin/product/new';
  static const adminProductPattern = '/admin/product/:id';
  static String adminProduct(String id) => '/admin/product/$id';
  static const adminOrderPattern = '/admin/order/:id';
  static String adminOrder(String id) => '/admin/order/$id';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderSuccess = '/order-success';
  static const payPattern = '/pay/:id';
  static String pay(String id) => '/pay/$id';
  static const favorites = '/favorites';
  static const myOrders = '/orders';
  static const myOrderPattern = '/orders/:id';
  static String myOrder(String id) => '/orders/$id';
  static const productPattern = '/product/:id';
  static String product(String id) => '/product/$id';
  static const reviewPattern = '/review/:productId';
  static String review(String productId) => '/review/$productId';
}

/// Ildiz navigator: to'liq ekranli sahifalar (mahsulot, checkout, to'lov va h.k.) dock ustidan shu orqali ochiladi.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Splash kamida bir lahza ko'rinib turishi uchun.
final splashDoneProvider = StateProvider<bool>((ref) => false);

/// Login/Register sahifasi tugmadagi "muvaffaqiyat" animatsiyasini ko'rsatib bo'lguncha
/// router kirgan foydalanuvchini bosh sahifaga o'tkazmay turadi.
final authSuccessHoldProvider = StateProvider<bool>((ref) => false);

/// Tab ildizlari: o'tishsiz (dock o'zi harakatni boshqaradi).
Page<void> _tabPage(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => refresh.value++);
  ref.listen(splashDoneProvider, (_, __) => refresh.value++);
  ref.listen(authSuccessHoldProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  String? redirect(GoRouterState state) {
    final auth = ref.read(authControllerProvider);
    final splashDone = ref.read(splashDoneProvider);
    final hold = ref.read(authSuccessHoldProvider);
    final loc = state.matchedLocation;

    if (!splashDone || auth.status == AuthStatus.loading || auth.status == AuthStatus.failed) {
      return loc == AppRoutes.splash ? null : AppRoutes.splash;
    }

    // Sozlamalar va huquqiy sahifalar kirmasdan ham ochiladi.
    if (loc == AppRoutes.settings || loc == AppRoutes.legalPrivacy || loc == AppRoutes.legalRefund) return null;

    // Kirish muvaffaqiyatli: tugmadagi animatsiya tugaguncha shu sahifada qolamiz.
    if (hold && (loc == AppRoutes.login || loc == AppRoutes.register)) return null;

    final user = auth.user;
    if (auth.status != AuthStatus.signedIn || user == null) {
      return (loc == AppRoutes.login || loc == AppRoutes.register) ? null : AppRoutes.login;
    }

    if (!user.isProfileComplete) {
      return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
    }

    if (loc == AppRoutes.splash ||
        loc == AppRoutes.login ||
        loc == AppRoutes.register ||
        loc == AppRoutes.onboarding) {
      return AppRoutes.home;
    }
    if (loc.startsWith(AppRoutes.admin) && !user.isAdmin) return AppRoutes.home;
    // Statistika, promokodlar va xodimlar bo'limi faqat do'kon egasi uchun.
    if ((loc == AppRoutes.adminPromos || loc == AppRoutes.adminStaff || loc == AppRoutes.adminStats) &&
        !user.isOwner) {
      return AppRoutes.admin;
    }
    return null;
  }

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => redirect(state),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => appPage(state, const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => appPage(state, const LoginScreen()),
      ),
      // Alohida RegisterScreen yo'q: shu sahifaning ikkinchi segmenti ochiladi.
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) =>
            appPage(state, const LoginScreen(initialMode: AuthMode.register)),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => appPage(state, const ProfileFormScreen(onboarding: true)),
      ),

      // ---- Doimiy dock: 5 ta tab ildizi (Bosh, Sevimlilar, Savat, Buyurtmalar, Profil) ----
      // Kengayuvchi sahifa ochilganda dock bilan birga ~0.94 ga kichrayib xiralashadi (ExpandBackdrop).
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) =>
            appPage(state, ExpandBackdrop(child: AppShell(navigationShell: navigationShell))),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (context, state) => _tabPage(state, const HomeScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.favorites,
              pageBuilder: (context, state) => _tabPage(state, const FavoritesScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.cart,
              pageBuilder: (context, state) => _tabPage(state, const CartScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.myOrders,
              pageBuilder: (context, state) => _tabPage(state, const MyOrdersScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              pageBuilder: (context, state) => _tabPage(state, const ProfileScreen()),
            ),
          ]),
        ],
      ),

      // ---- To'liq ekranli sahifalar: dock ustidan (ildiz navigatorda) ochiladi ----
      GoRoute(
        path: AppRoutes.checkout,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(state, const CheckoutScreen()),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) => state.extra is PlacedOrder ? null : AppRoutes.home,
        pageBuilder: (context, state) =>
            appPage(state, OrderSuccessScreen(order: state.extra! as PlacedOrder)),
      ),
      GoRoute(
        path: AppRoutes.payPattern,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            appPage(state, PaymentScreen(orderId: state.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.myOrderPattern,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            appPage(state, MyOrderDetailScreen(orderId: state.pathParameters['id']!)),
      ),
      // Qidiruv: pill'dan butun ekranga kengayadi.
      GoRoute(
        path: AppRoutes.search,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => expandPage(state, const SearchScreen()),
      ),
      // Mahsulot: kartadan kengayadi (extra bo'lmasa — fade + pastdan ko'tarilish).
      GoRoute(
        path: AppRoutes.productPattern,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => expandPage(
          state,
          ProductDetailScreen(productId: state.pathParameters['id']!),
          sharedTarget: ProductDetailScreen.galleryRect,
        ),
      ),
      GoRoute(
        path: AppRoutes.reviewPattern,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(
          state,
          ReviewFormScreen(
            productId: state.pathParameters['productId']!,
            productName: state.extra is LocalizedText ? state.extra! as LocalizedText : null,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(state, const SettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.legalPrivacy,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(state, const LegalScreen(doc: LegalDoc.privacy)),
      ),
      GoRoute(
        path: AppRoutes.legalRefund,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(state, const LegalScreen(doc: LegalDoc.refund)),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(state, const ProfileFormScreen(onboarding: false)),
      ),
      GoRoute(
        path: AppRoutes.profileCredentials,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(state, const CredentialsScreen()),
      ),

      // ---- Admin: o'z navigatsiyasi bilan, dock'siz ----
      GoRoute(
        path: AppRoutes.admin,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(state, const AdminHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminPromos,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(state, const AdminPromosScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminStaff,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(state, const AdminStaffScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminStats,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(state, const AdminStatsScreen()),
      ),
      // "new" yo'li ":id" dan oldin turishi shart.
      GoRoute(
        path: AppRoutes.adminProductNew,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => appPage(state, const ProductFormScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminProductPattern,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            appPage(state, ProductFormScreen(productId: state.pathParameters['id'])),
      ),
      GoRoute(
        path: AppRoutes.adminOrderPattern,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            appPage(state, AdminOrderDetailScreen(orderId: state.pathParameters['id']!)),
      ),
    ],
  );
});