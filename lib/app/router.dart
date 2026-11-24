import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/motion/page_transitions.dart';
import '../data/models.dart';
import '../features/admin/admin_categories_page.dart';
import '../features/admin/admin_delivery_page.dart';
import '../features/admin/admin_order_detail_page.dart';
import '../features/admin/admin_orders_page.dart';
import '../features/admin/admin_products_page.dart';
import '../features/admin/admin_settings_page.dart';
import '../features/admin/dashboard_page.dart';
import '../features/admin/product_form_page.dart';
import '../features/admin/reports_page.dart';
import '../features/auth/auth_pages.dart';
import '../features/auth/login_page.dart';
import '../features/cart/cart_page.dart';
import '../features/cart/checkout_page.dart';
import '../features/home/home_page.dart';
import '../features/menu/menu_page.dart';
import '../features/menu/product_detail_page.dart';
import '../features/orders/order_detail_page.dart';
import '../features/orders/orders_page.dart';
import '../features/profile/addresses_page.dart';
import '../features/profile/profile_page.dart';
import '../features/shell/app_shells.dart';
import '../features/startup/onboarding_page.dart';
import '../features/startup/splash_page.dart';
import '../features/style_guide/style_guide_page.dart';
import '../state/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AppUser?>(authProvider, (previous, next) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  Page<void> detailPage(GoRouterState state, Widget child) {
    return KedaiTransitions.detail(key: state.pageKey, child: child);
  }

  Page<void> fadePage(GoRouterState state, Widget child) {
    return KedaiTransitions.fade(key: state.pageKey, child: child);
  }

  Page<void> slidePage(GoRouterState state, Widget child) {
    return KedaiTransitions.slide(key: state.pageKey, child: child);
  }

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = ref.read(authProvider);
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';
      final isStartupRoute = location == '/splash' || location == '/onboarding';

      if (isStartupRoute) return null;

      if (user == null) {
        return isAuthRoute ? null : '/login';
      }
      if (isAuthRoute) {
        return user.role == UserRole.admin ? '/admin' : '/home';
      }
      final isAdminRoute = location.startsWith('/admin');
      if (user.role == UserRole.admin && !isAdminRoute) return '/admin';
      if (user.role == UserRole.customer && isAdminRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => fadePage(state, const SplashPage()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            fadePage(state, const OnboardingPage()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => slidePage(state, const LoginPage()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => slidePage(state, const RegisterPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            CustomerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                builder: (context, state) => MenuPage(
                  initialCategoryId: state.uri.queryParameters['category'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        pageBuilder: (context, state) => detailPage(
          state,
          ProductDetailPage(
            productId: state.pathParameters['id']!,
            heroTag: state.extra is String ? state.extra as String : null,
          ),
        ),
      ),
      GoRoute(
        path: '/checkout',
        pageBuilder: (context, state) =>
            detailPage(state, const CheckoutPage()),
      ),
      GoRoute(
        path: '/orders/:id',
        pageBuilder: (context, state) => detailPage(
          state,
          OrderDetailPage(orderId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/addresses',
        pageBuilder: (context, state) =>
            detailPage(state, const AddressesPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminDashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/orders',
                builder: (context, state) => const AdminOrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/menu',
                builder: (context, state) => const AdminProductsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/settings',
                builder: (context, state) => const AdminSettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/admin/order/:id',
        pageBuilder: (context, state) => detailPage(
          state,
          AdminOrderDetailPage(orderId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin/products/new',
        pageBuilder: (context, state) =>
            detailPage(state, const ProductFormPage()),
      ),
      GoRoute(
        path: '/admin/products/:id/edit',
        pageBuilder: (context, state) => detailPage(
          state,
          ProductFormPage(productId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/admin/categories',
        pageBuilder: (context, state) =>
            detailPage(state, const AdminCategoriesPage()),
      ),
      GoRoute(
        path: '/admin/delivery',
        pageBuilder: (context, state) =>
            detailPage(state, const AdminDeliveryPage()),
      ),
      GoRoute(
        path: '/admin/reports',
        pageBuilder: (context, state) => detailPage(state, const ReportsPage()),
      ),
      GoRoute(
        path: '/admin/style-guide',
        pageBuilder: (context, state) =>
            detailPage(state, const StyleGuidePage()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Halaman tidak ditemukan'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Kembali ke Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
