import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/premium_motion.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.productId, this.heroTag});

  final String productId;
  final String? heroTag;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _qty = 1;
  int _variantIndex = 0;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addToCart(Product product, ProductVariant? variant) {
    ref
        .read(cartProvider.notifier)
        .addItem(
          product,
          variant: variant,
          qty: _qty,
          note: _noteController.text.trim(),
        );
    showAppSnack(
      context,
      '${product.name} masuk keranjang',
      actionLabel: 'Lihat',
      onAction: () => context.go('/cart'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ref
        .watch(productsProvider)
        .where((item) => item.id == widget.productId)
        .firstOrNull;
    final settings = ref.watch(settingsProvider);
    final cartCount = ref.watch(cartCountProvider);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Produk')),
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Produk tidak ditemukan',
          message: 'Produk mungkin sudah dihapus oleh admin.',
          actionLabel: 'Kembali ke menu',
          onAction: () => context.go('/menu'),
        ),
      );
    }

    final category = ref
        .watch(categoriesProvider)
        .where((item) => item.id == product.categoryId)
        .firstOrNull;
    final variant = product.variants.isEmpty
        ? null
        : product.variants[_variantIndex.clamp(0, product.variants.length - 1)];
    final unitPrice = product.price + (variant?.priceDelta ?? 0);
    final total = unitPrice * _qty;
    final resolvedHeroTag = widget.heroTag ?? 'product-image-${product.id}';
    final canAdd = product.available && settings.isOpen;
    final buttonLabel = !product.available
        ? 'Stok Habis'
        : !settings.isOpen
        ? 'Kedai Sedang Tutup'
        : 'Tambah ke Keranjang';

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Stack(
                  children: [
                    Hero(
                      tag: resolvedHeroTag,
                      child: ProductImage(
                        path: product.image,
                        emoji: product.emoji,
                        width: double.infinity,
                        height: 320,
                        radius: 30,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 110,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00FFFFFF), Color(0x332A1B13)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: product.image.isEmpty
                                ? AppColors.border
                                : AppColors.gold.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              product.image.isEmpty
                                  ? Icons.image_outlined
                                  : Icons.verified_rounded,
                              size: 11,
                              color: product.image.isEmpty
                                  ? AppColors.brownSoft
                                  : AppColors.gold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.image.isEmpty
                                  ? 'Foto belum tersedia'
                                  : 'Foto menu asli',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    letterSpacing: 0.2,
                                    fontSize: 9,
                                    color: AppColors.brownSoft,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (category != null) ...[
                                Flexible(
                                  child: Text(
                                    '${category.emoji}  ${category.name.toUpperCase()}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.terracotta,
                                          letterSpacing: 1.4,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    color: AppColors.muted,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Text(
                                  'DIBUAT SEGAR',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(letterSpacing: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppBadge(
                          label: product.available ? 'Tersedia' : 'Habis',
                          background: product.available
                              ? AppColors.successSoft
                              : AppColors.dangerSoft,
                          foreground: product.available
                              ? AppColors.success
                              : AppColors.danger,
                          dot: true,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GradientText(
                      text: product.name,
                      style:
                          Theme.of(context).textTheme.headlineLarge ??
                          const TextStyle(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rupiah(unitPrice),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                            color: AppColors.terracottaDark,
                          ),
                        ),
                        if (product.variants.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '/ porsi',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: AppColors.brownSoft,
                      ),
                    ),
                    if (!settings.isOpen) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: AppColors.warningSoft,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 17,
                              color: AppColors.warning,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Kedai sedang tutup. Menu tetap dapat dilihat, namun pemesanan belum bisa dilakukan.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.warning,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    if (product.variants.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text(
                            'Pilih Varian',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brown,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Wajib dipilih',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < product.variants.length; i++)
                            CategoryChip(
                              label: product.variants[i].priceDelta == 0
                                  ? product.variants[i].name
                                  : '${product.variants[i].name}  +${rupiah(product.variants[i].priceDelta)}',
                              selected: _variantIndex == i,
                              onTap: () => setState(() => _variantIndex = i),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jumlah',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brown,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Subtotal ${rupiah(total)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        QuantityStepper(
                          value: _qty,
                          onChanged: (value) => setState(() => _qty = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _noteController,
                      hint: 'Catatan untuk kedai, mis. tanpa saus (opsional)',
                      icon: Icons.edit_note_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.beigeSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              size: 19,
                              color: AppColors.terracottaDark,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pembayaran aman & manual',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brown,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Bukti transfer atau QRIS diverifikasi langsung oleh admin kedai.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontSize: 10.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    _GlassButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go('/menu'),
                    ),
                    const Spacer(),
                    _GlassButton(
                      icon: Icons.shopping_bag_outlined,
                      badgeCount: cartCount,
                      onTap: () => context.go('/cart'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1438251D),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                ),
                AnimatedRupiah(
                  value: total,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.brown,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MagneticPress(
                enabled: canAdd,
                child: AppButton(
                  label: buttonLabel,
                  icon: Icons.shopping_bag_outlined,
                  onPressed: canAdd ? () => _addToCart(product, variant) : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surface.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: AppColors.brown),
        ),
      ),
    );
    if (badgeCount <= 0) return button;
    return BounceBadge(count: badgeCount, child: button);
  }
}
