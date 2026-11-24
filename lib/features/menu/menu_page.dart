import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/kedai_refresh.dart';
import '../../core/widgets/premium_motion.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key, this.initialCategoryId});

  final String? initialCategoryId;

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _categoryId;
  String _query = '';
  bool _loading = true;
  Timer? _skeletonTimer;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _skeletonTimer = Timer(const Duration(milliseconds: 380), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(productsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(settingsProvider);
    await Future<void>.delayed(const Duration(milliseconds: 320));
  }

  @override
  void didUpdateWidget(covariant MenuPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategoryId != oldWidget.initialCategoryId) {
      setState(() => _categoryId = widget.initialCategoryId);
    }
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilter() {
    _searchController.clear();
    setState(() {
      _query = '';
      _categoryId = null;
    });
  }

  void _quickAdd(Product product) {
    if (product.variants.isNotEmpty) {
      context.push(
        '/product/${product.id}',
        extra: 'product-image-${product.id}',
      );
      return;
    }
    ref.read(cartProvider.notifier).addItem(product);
    showAppSnack(context, '${product.name} masuk keranjang');
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref
        .watch(categoriesProvider)
        .where((category) => category.active)
        .toList();
    final cartCount = ref.watch(cartCountProvider);
    final settings = ref.watch(settingsProvider);
    var products = ref.watch(productsProvider);

    if (_categoryId != null) {
      products = products
          .where((product) => product.categoryId == _categoryId)
          .toList();
    }
    if (_query.trim().isNotEmpty) {
      final query = _query.toLowerCase();
      products = products
          .where(
            (product) =>
                product.name.toLowerCase().contains(query) ||
                product.description.toLowerCase().contains(query),
          )
          .toList();
    }

    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 900 ? 4 : (width >= 640 ? 3 : 2);
    final hasFilter = _query.trim().isNotEmpty || _categoryId != null;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KATALOG KEDAI UMMI',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.terracotta,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: 5),
                        GradientText(
                          text: 'Menu Kami',
                          style:
                              Theme.of(context).textTheme.headlineMedium ??
                              const TextStyle(),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${products.length} pilihan siap dipesan hari ini',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  GlowFrame(
                    radius: 999,
                    strokeWidth: 1.2,
                    child: IconCircleButton(
                      icon: Icons.shopping_bag_outlined,
                      badgeCount: cartCount,
                      onTap: () => context.go('/cart'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppSearchField(
                controller: _searchController,
                hint: 'Cari kebab, bakso, atau minuman...',
                onChanged: (value) => setState(() => _query = value),
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  CategoryChip(
                    label: 'Semua',
                    selected: _categoryId == null,
                    onTap: () => setState(() => _categoryId = null),
                  ),
                  for (final category in categories) ...[
                    const SizedBox(width: 8),
                    CategoryChip(
                      label: category.name,
                      emoji: category.emoji,
                      selected: _categoryId == category.id,
                      onTap: () => setState(() => _categoryId = category.id),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  Text(
                    hasFilter
                        ? '${products.length} hasil ditemukan'
                        : 'Semua menu',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownSoft,
                    ),
                  ),
                  const Spacer(),
                  if (hasFilter)
                    GestureDetector(
                      onTap: _resetFilter,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: AppColors.terracotta,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.terracotta,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (!settings.isOpen)
                    const AppBadge(
                      label: 'Kedai tutup',
                      background: AppColors.warningSoft,
                      foreground: AppColors.warning,
                      dot: true,
                      compact: true,
                    ),
                ],
              ),
            ),
            Expanded(
              child: KedaiRefreshIndicator(
                onRefresh: _refresh,
                child: AnimatedSwitcher(
                  duration: adaptiveDuration(context, AppMotion.slow),
                  switchInCurve: AppMotion.standard,
                  switchOutCurve: AppMotion.standard,
                  transitionBuilder: (child, animation) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: AppMotion.standard,
                      reverseCurve: Curves.easeInCubic,
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.985,
                          end: 1,
                        ).animate(curved),
                        child: child,
                      ),
                    );
                  },
                  child: _loading
                      ? _MenuSkeleton(
                          key: const ValueKey('menu-skeleton'),
                          columns: columns,
                        )
                      : SizedBox.expand(
                          key: ValueKey('menu-$_categoryId-$_query'),
                          child: products.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(top: 40),
                                  children: [
                                    EmptyState(
                                      icon: Icons.search_off_rounded,
                                      title: 'Menu tidak ditemukan',
                                      message:
                                          'Coba kata kunci lain atau pilih kategori yang berbeda.',
                                      actionLabel: 'Reset filter',
                                      onAction: _resetFilter,
                                    ),
                                  ],
                                )
                              : GridView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    2,
                                    20,
                                    24,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 0.68,
                                      ),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    return Reveal(
                                      index: index > 6 ? 6 : index,
                                      offset: 0.03,
                                      child: _MenuProductCard(
                                        product: product,
                                        onTap: () => context.push(
                                          '/product/${product.id}',
                                          extra: 'product-image-${product.id}',
                                        ),
                                        onAdd:
                                            product.available && settings.isOpen
                                            ? () => _quickAdd(product)
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSkeleton extends StatelessWidget {
  const _MenuSkeleton({super.key, required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: columns * 2,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSkeleton(height: 118, radius: 15),
              const SizedBox(height: 10),
              AppSkeleton(width: 86 + (index % 2) * 22, height: 12),
              const SizedBox(height: 7),
              const AppSkeleton(width: 118, height: 9),
              const Spacer(),
              Row(
                children: [
                  const AppSkeleton(width: 54, height: 12),
                  const Spacer(),
                  const AppSkeleton(width: 30, height: 30, radius: 15),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuProductCard extends StatelessWidget {
  const _MenuProductCard({
    required this.product,
    required this.onTap,
    this.onAdd,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return PressScale(
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(7, 7, 7, 0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'product-image-${product.id}',
                          child: ProductImage(
                            path: product.image,
                            emoji: product.emoji,
                            radius: 17,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        if (!product.available)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                color: AppColors.espresso.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Stok habis',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (product.available && product.variants.isNotEmpty)
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(
                                  alpha: 0.92,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${product.variants.length} varian',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.terracottaDark,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 9, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
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
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              rupiah(product.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.terracottaDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Material(
                            color: onAdd == null
                                ? AppColors.beigeSoft
                                : AppColors.espresso,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: onAdd,
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: Icon(
                                  product.variants.isNotEmpty
                                      ? Icons.tune_rounded
                                      : Icons.add_rounded,
                                  size: 17,
                                  color: onAdd == null
                                      ? AppColors.muted
                                      : AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
