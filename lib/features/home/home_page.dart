import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion/page_transitions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/kedai_refresh.dart';
import '../../core/widgets/premium_motion.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

/// Tag unik untuk kartu produk di beranda agar tidak bentrok dengan grid Menu.
String homeProductHeroTag(String productId) => 'home-product-image-$productId';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.82);
  int _activePage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshHome() async {
    ref.invalidate(productsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(settingsProvider);
    await Future<void>.delayed(const Duration(milliseconds: 240));
  }

  void _openProduct(Product product) {
    context.push(
      '/product/${product.id}',
      extra: homeProductHeroTag(product.id),
    );
  }

  void _quickAdd(Product product) {
    if (product.variants.isNotEmpty) {
      _openProduct(product);
      return;
    }
    ref.read(cartProvider.notifier).addItem(product);
    showAppSnack(
      context,
      '${product.name} masuk keranjang',
      actionLabel: 'Lihat',
      onAction: () => context.go('/cart'),
    );
  }

  void _showNotifications() {
    showKedaiSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    final categories = ref
        .watch(categoriesProvider)
        .where((category) => category.active)
        .toList();
    final products = ref
        .watch(productsProvider)
        .where((product) => product.available)
        .toList();
    final featured = products.take(6).toList();
    final popular = products.skip(2).take(6).toList();
    final firstName = user?.name.split(' ').first ?? 'Kawan';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: KedaiRefreshIndicator(
          onRefresh: _refreshHome,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Reveal(
                    index: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      LivePulseDot(
                                        color: AppColors.terracotta,
                                        size: 5,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          settings.name.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: AppColors.terracotta,
                                                letterSpacing: 1.5,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  GradientText(
                                    text: 'Mau makan apa,\n$firstName?',
                                    style:
                                        Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(height: 1.12) ??
                                        const TextStyle(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            _NotificationBell(onTap: _showNotifications),
                            const SizedBox(width: 8),
                            GlowFrame(
                              radius: 999,
                              strokeWidth: 1.2,
                              colors: const <Color>[
                                AppColors.gold,
                                AppColors.terracotta,
                                AppColors.gold,
                              ],
                              child: GestureDetector(
                                onTap: () => context.go('/profile'),
                                child: AppAvatar(
                                  name: user?.name ?? 'Kedai Ummi',
                                  size: 48,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _StoreStatusPill(settings: settings),
                        const SizedBox(height: 16),
                        AppSearchField(
                          hint: 'Cari kebab, bakso, atau minuman...',
                          readOnly: true,
                          onTap: () => context.go('/menu'),
                        ),
                        const SizedBox(height: 16),
                        _HeroBanner(
                          settings: settings,
                          onOrder: () => context.go('/menu'),
                        ),
                        const SizedBox(height: 14),
                        _StatsStrip(menuCount: products.length),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                  child: Reveal(
                    index: 1,
                    child: SectionHeader(
                      eyebrow: 'Jelajahi rasa',
                      title: 'Kategori',
                      actionLabel: 'Semua menu',
                      onAction: () => context.go('/menu'),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 104,
                  child: Reveal(
                    index: 2,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _CategoryTile(
                          category: category,
                          onTap: () =>
                              context.go('/menu?category=${category.id}'),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Reveal(index: 3, child: const _PromoTicker()),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                  child: Reveal(
                    index: 4,
                    child: SectionHeader(
                      eyebrow: 'Pilihan hari ini',
                      title: 'Paling Dicari',
                      subtitle: 'Menu favorit pelanggan Kedai Ummi',
                      actionLabel: 'Lihat semua',
                      onAction: () => context.go('/menu'),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Reveal(
                  index: 5,
                  child: SizedBox(
                    height: 312,
                    child: featured.isEmpty
                        ? const Center(child: Text('Belum ada menu tersedia'))
                        : Column(
                            children: [
                              Expanded(
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: featured.length,
                                  onPageChanged: (index) =>
                                      setState(() => _activePage = index),
                                  itemBuilder: (context, index) {
                                    final product = featured[index];
                                    return AnimatedBuilder(
                                      animation: _pageController,
                                      builder: (context, child) {
                                        double delta;
                                        if (_pageController.hasClients &&
                                            _pageController
                                                .position
                                                .haveDimensions) {
                                          delta =
                                              (_pageController.page ?? 0) -
                                              index;
                                        } else {
                                          delta = index == 0 ? 0 : 1;
                                        }
                                        final scale = (1 - delta.abs() * 0.08)
                                            .clamp(0.9, 1.0);
                                        final opacity = (1 - delta.abs() * 0.35)
                                            .clamp(0.6, 1.0);
                                        return Transform.scale(
                                          scale: scale,
                                          child: Opacity(
                                            opacity: opacity,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: _FeaturedCard(
                                        product: product,
                                        onTap: () => _openProduct(product),
                                        onAdd: () => _quickAdd(product),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var i = 0; i < featured.length; i++)
                                    AnimatedContainer(
                                      duration: AppMotion.normal,
                                      curve: AppMotion.standard,
                                      width: i == _activePage ? 22 : 6,
                                      height: 5,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: i == _activePage
                                            ? AppColors.espresso
                                            : AppColors.beige,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                  child: Reveal(
                    index: 6,
                    child: SectionHeader(
                      eyebrow: 'Cepat & enak',
                      title: 'Menu Populer',
                      actionLabel: 'Semua',
                      onAction: () => context.go('/menu'),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Reveal(
                  index: 7,
                  child: SizedBox(
                    height: 236,
                    child: popular.isEmpty
                        ? const Center(child: Text('Belum ada menu tersedia'))
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: popular.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final product = popular[index];
                              return _PopularCard(
                                product: product,
                                onTap: () => _openProduct(product),
                                onAdd: () => _quickAdd(product),
                              );
                            },
                          ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Reveal(index: 8, child: const _TrustStrip()),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                  child: Reveal(
                    index: 9,
                    child: _StoreInfoCard(
                      settings: settings,
                      onTap: () => context.go('/profile'),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              const SliverToBoxAdapter(child: _HomeFooter()),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends ConsumerWidget {
  const _NotificationBell({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref
        .watch(myOrdersProvider)
        .where(
          (order) =>
              order.status == OrderStatus.pendingConfirmation ||
              order.status == OrderStatus.confirmed ||
              order.status == OrderStatus.preparing ||
              order.status == OrderStatus.readyForPickup ||
              order.status == OrderStatus.outForDelivery,
        )
        .length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.card,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: AppColors.brown,
                ),
              ),
            ),
          ),
        ),
        if (active > 0)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: AppColors.terracotta,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.cream, width: 1.5),
              ),
              child: Text(
                active > 9 ? '9+' : '$active',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationsSheet extends ConsumerWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider).take(3).toList();

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Notifikasi',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: AppColors.brown,
                        ),
                      ),
                    ),
                    if (orders.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.terracottaSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'BARU',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.terracottaDark,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Pembaruan pesanan dan promo untukmu',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brownSoft,
                  ),
                ),
                const SizedBox(height: 16),
                if (orders.isEmpty)
                  Reveal(
                    index: 0,
                    child: _NotificationTile(
                      icon: Icons.storefront_rounded,
                      color: AppColors.terracotta,
                      background: AppColors.terracottaSoft,
                      title: 'Selamat datang di Kedai Ummi',
                      message: 'Yuk pesan menu favoritmu hari ini.',
                      onTap: () {
                        final router = GoRouter.of(context);
                        Navigator.of(context).pop();
                        router.go('/menu');
                      },
                    ),
                  )
                else
                  for (var i = 0; i < orders.length; i++) ...[
                    Reveal(
                      index: i,
                      child: _NotificationTile(
                        icon: Icons.receipt_long_rounded,
                        color: statusVisual(orders[i].status).color,
                        background: statusVisual(orders[i].status).background,
                        title: 'Pesanan ${orders[i].orderNumber}',
                        message:
                            '${orders[i].status.label} · ${orders[i].items.length} item',
                        onTap: () {
                          final router = GoRouter.of(context);
                          Navigator.of(context).pop();
                          router.push('/orders/${orders[i].id}');
                        },
                      ),
                    ),
                    const SizedBox(height: 9),
                  ],
                Reveal(
                  index: orders.length,
                  child: _NotificationTile(
                    icon: Icons.local_offer_rounded,
                    color: AppColors.warning,
                    background: AppColors.warningSoft,
                    title: 'Promo Spesial',
                    message: 'Burger lezat diskon 50% — khusus hari ini.',
                    onTap: () {
                      final router = GoRouter.of(context);
                      Navigator.of(context).pop();
                      router.go('/menu');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.message,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brownSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreStatusPill extends StatelessWidget {
  const _StoreStatusPill({required this.settings});

  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    final open = settings.isOpen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: open ? AppColors.successSoft : AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: open
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.danger.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          open
              ? LivePulseDot(color: AppColors.success, size: 5)
              : Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
          const SizedBox(width: 6),
          Text(
            open ? 'Buka sekarang' : 'Sedang tutup',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: open ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'â€¢ ${settings.openHours}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: (open ? AppColors.success : AppColors.danger).withValues(
                  alpha: 0.72,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.menuCount});

  final int menuCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surface, AppColors.surfaceAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.star_rounded,
              color: AppColors.gold,
              value: 4.9,
              decimals: 1,
              label: 'Rating tamu',
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.bolt_rounded,
              color: AppColors.terracotta,
              value: 30,
              suffix: ' mnt',
              label: 'Estimasi saji',
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatItem(
              icon: Icons.restaurant_menu_rounded,
              color: AppColors.success,
              value: menuCount.toDouble(),
              label: 'Menu pilihan',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.decimals = 0,
    this.suffix = '',
  });

  final IconData icon;
  final Color color;
  final double value;
  final String label;
  final int decimals;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 12, color: color),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: CountUpNumber(
                value: value,
                decimals: decimals,
                suffix: suffix,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: AppColors.brown,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontSize: 9, letterSpacing: 0.4),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: AppColors.border);
  }
}

class _PromoTicker extends StatelessWidget {
  const _PromoTicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B2A1F), AppColors.espresso],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
        boxShadow: AppShadows.float,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 15,
            color: AppColors.gold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: MarqueeText(
              text:
                  'GRATIS ONGKIR MIN. 50RB     HALAL & HIGIENIS     DIMASAK FRESH SETIAP HARI     BAYAR DI TEMPAT',
              speed: 42,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, Color)>[
      (Icons.verified_rounded, '100% Halal', AppColors.success),
      (Icons.eco_rounded, 'Fresh Daily', AppColors.terracotta),
      (Icons.rocket_launch_rounded, 'Cepat & Mudah', AppColors.gold),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    items[i].$3.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: items[i].$3.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(items[i].$1, size: 17, color: items[i].$3),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    items[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brownSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.borderStrong,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'KEDAI UMMI  â€¢  RASA RUMAHAN, SETIAP HARI',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontSize: 8.5, letterSpacing: 1.2),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.settings, required this.onOrder});

  final StoreSettings settings;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    return GlowFrame(
      radius: 30,
      strokeWidth: 1.3,
      colors: const <Color>[
        Color(0x66C6A05B),
        Color(0xB3FFE6A8),
        Color(0x66BE5B37),
        Color(0x66C6A05B),
      ],
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ShineSweep(
          enabled: false,
          interval: const Duration(milliseconds: 7200),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 224),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: AuroraBackdrop(
                    baseColors: <Color>[Color(0xFF3B2A1F), AppColors.espresso],
                    colors: <Color>[
                      Color(0xFF8E4A2F),
                      AppColors.terracotta,
                      AppColors.gold,
                      Color(0xFF6B3A24),
                    ],
                    duration: Duration(seconds: 28),
                    showParticles: true,
                    opacity: 0.48,
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x002A1B13), Color(0x662A1B13)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -40,
                  top: -50,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.22),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(19, 18, 14, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LivePulseDot(
                                    color: AppColors.gold,
                                    size: 3.5,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      settings.isOpen
                                          ? 'DAPUR BUKA · PESAN SEKARANG'
                                          : 'PESAN LANGSUNG DARI HP',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.9,
                                        color: Color(0xFFF0D5A8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Dine-in, takeaway,\natau delivery?',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 21,
                                height: 1.14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                color: Color(0xFFFFF6E8),
                              ),
                            ),
                            const SizedBox(height: 9),
                            const Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _ServicePill(
                                  icon: Icons.table_restaurant_rounded,
                                  label: 'Dine-in',
                                ),
                                _ServicePill(
                                  icon: Icons.shopping_bag_rounded,
                                  label: 'Takeaway',
                                ),
                                _ServicePill(
                                  icon: Icons.delivery_dining_rounded,
                                  label: 'Delivery',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            MagneticPress(
                              onTap: onOrder,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.terracotta.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Pesan sekarang',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      _HeroEmblem(onTap: onOrder),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Medali foto signature pada hero: cincin emas dengan badge rating.
/// Sepenuhnya statis â€” tanpa rotasi atau gerakan otomatis saat idle.
class _HeroEmblem extends StatelessWidget {
  const _HeroEmblem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 116,
        height: 132,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Halo lembut di belakang medali.
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.2),
                    AppColors.gold.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            Container(
              width: 92,
              height: 92,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE8C77E),
                    AppColors.gold,
                    Color(0xFFA8843E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/products/kebab.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.terracottaSoft,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 34,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B2A1F), AppColors.espresso],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                    SizedBox(width: 3),
                    Text(
                      '4.9',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicePill extends StatelessWidget {
  const _ServicePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.gold),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xE6FFF3E2),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 86,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.beigeSoft, Color(0xFFE8D8D3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.beige.withValues(alpha: 0.55),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ShineSweep(
        enabled: false,
        interval: const Duration(milliseconds: 8600),
        child: PressScale(
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Hero(
                              tag: homeProductHeroTag(product.id),
                              child: ProductImage(
                                path: product.image,
                                emoji: product.emoji,
                                radius: 20,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              left: 10,
                              top: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(
                                    alpha: 0.92,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  rupiah(product.price),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.terracottaDark,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.espresso.withValues(
                                    alpha: 0.72,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColors.gold.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 11,
                                      color: AppColors.gold,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'PILIHAN',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 12, 10, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                    color: AppColors.brown,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: AppColors.espresso,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: onAdd,
                              child: const SizedBox(
                                width: 38,
                                height: 38,
                                child: Icon(
                                  Icons.add_rounded,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 172,
      child: PressScale(
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 124,
                    child: ProductImage(
                      path: product.image,
                      emoji: product.emoji,
                      radius: 0,
                      width: double.infinity,
                      height: 124,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(11, 10, 8, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brown,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                rupiah(product.price),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.terracotta,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.beigeSoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 17,
                              color: AppColors.terracottaDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreInfoCard extends StatelessWidget {
  const _StoreInfoCard({required this.settings, required this.onTap});

  final StoreSettings settings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.beigeSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              size: 21,
              color: AppColors.terracottaDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brown,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${settings.openHours} â€¢ ${settings.address}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}
