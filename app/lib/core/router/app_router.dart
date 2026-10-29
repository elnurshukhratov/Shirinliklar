import 'package:flutter/foundation.dart';
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
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/profile_form_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/catalog/presentation/product_detail_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/home_screen.dart';
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
import 'app_page.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/splash';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const home = '/';
  static const settings = '/settings';
  static const legalPrivacy = '/legal/privacy';
  static const legalRefund = '/legal/refund';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
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

/// Splash kamida bir lahza ko'rinib turishi uchun.
final splashDoneProvider = StateProvider<bool>((ref) => false);

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => refresh.value++);
  ref.listen(splashDoneProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  String? redirect(GoRouterState state) {
    final auth = ref.read(authControllerProvider);
    final splashDone = ref.read(splashDoneProvider);
    final loc = state.matchedLocation;

    if (!splashDone || auth.status == AuthStatus.loading || auth.status == AuthStatus.failed) {
      return loc == AppRoutes.splash ? null : AppRoutes.splash;
    }

    // Sozlamalar va huquqiy sahifalar kirmasdan ham ochiladi.
    if (loc == AppRoutes.settings || loc == AppRoutes.legalPrivacy || loc == AppRoutes.legalRefund) return null;

    final user = auth.user;
    if (auth.status != AuthStatus.signedIn || user == null) {
      return loc == AppRoutes.login ? null : AppRoutes.login;
    }

    if (!user.isProfileComplete) {
      return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
    }

    if (loc == AppRoutes.splash || loc == AppRoutes.login || loc == AppRoutes.onboarding) {
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
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => appPage(state, const ProfileFormScreen(onboarding: true)),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => appPage(state, const HomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.cart,
        pageBuilder: (context, state) => appPage(state, const CartScreen()),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (context, state) => appPage(state, const CheckoutScreen()),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        redirect: (context, state) => state.extra is PlacedOrder ? null : AppRoutes.home,
        pageBuilder: (context, state) =>
            appPage(state, OrderSuccessScreen(order: state.extra! as PlacedOrder)),
      ),
      GoRoute(
        path: AppRoutes.payPattern,
        pageBuilder: (context, state) =>
            appPage(state, PaymentScreen(orderId: state.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        pageBuilder: (context, state) => appPage(state, const FavoritesScreen()),
      ),
      GoRoute(
        path: AppRoutes.myOrders,
        pageBuilder: (context, state) => appPage(state, const MyOrdersScreen()),
      ),
      GoRoute(
        path: AppRoutes.myOrderPattern,
        pageBuilder: (context, state) =>
            appPage(state, MyOrderDetailScreen(orderId: state.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.productPattern,
        pageBuilder: (context, state) =>
            appPage(state, ProductDetailScreen(productId: state.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.reviewPattern,
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
        pageBuilder: (context, state) => appPage(state, const SettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.legalPrivacy,
        pageBuilder: (context, state) => appPage(state, const LegalScreen(doc: LegalDoc.privacy)),
      ),
      GoRoute(
        path: AppRoutes.legalRefund,
        pageBuilder: (context, state) => appPage(state, const LegalScreen(doc: LegalDoc.refund)),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) => appPage(state, const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        pageBuilder: (context, state) => appPage(state, const ProfileFormScreen(onboarding: false)),
      ),
      GoRoute(
        path: AppRoutes.admin,
        pageBuilder: (context, state) => appPage(state, const AdminHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminPromos,
        pageBuilder: (context, state) => appPage(state, const AdminPromosScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminStaff,
        pageBuilder: (context, state) => appPage(state, const AdminStaffScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminStats,
        pageBuilder: (context, state) => appPage(state, const AdminStatsScreen()),
      ),
      // "new" yo'li ":id" dan oldin turishi shart.
      GoRoute(
        path: AppRoutes.adminProductNew,
        pageBuilder: (context, state) => appPage(state, const ProductFormScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminProductPattern,
        pageBuilder: (context, state) =>
            appPage(state, ProductFormScreen(productId: state.pathParameters['id'])),
      ),
      GoRoute(
        path: AppRoutes.adminOrderPattern,
        pageBuilder: (context, state) =>
            appPage(state, AdminOrderDetailScreen(orderId: state.pathParameters['id']!)),
      ),
    ],
  );
});