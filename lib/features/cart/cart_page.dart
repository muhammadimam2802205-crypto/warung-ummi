import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  Future<void> _clearCart(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Kosongkan keranjang?',
      message: 'Semua item akan dihapus dari keranjang.',
      confirmLabel: 'Kosongkan',
      destructive: true,
    );
    if (confirmed) {
      ref.read(cartProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final settings = ref.watch(settingsProvider);
    final totalQty = items.fold<int>(0, (sum, item) => sum + item.qty);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PESANAN ANDA',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.terracotta,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Keranjang',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items.isEmpty
                              ? 'Belum ada menu yang dipilih'
                              : '$totalQty porsi dari ${items.length} menu',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (items.isNotEmpty)
                    TextButton(
                      onPressed: () => _clearCart(context, ref),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Kosongkan'),
                    ),
                ],
              ),
            ),
            if (!settings.isOpen)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kedai sedang tutup. Checkout tersedia saat kedai buka kembali.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: items.isEmpty
                  ? EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      eyebrow: 'Mulai dari sini',
                      title: 'Keranjang masih kosong',
                      message:
                          'Yuk pilih menu favoritmu dan tambahkan ke keranjang terlebih dahulu.',
                      actionLabel: 'Lihat Menu',
                      onAction: () => context.go('/menu'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Reveal(
                          index: index,
                          offset: 0.03,
                          child: _CartItemCard(item: item),
                        );
                      },
                    ),
            ),
            if (items.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.float,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brownSoft,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Belum termasuk biaya pengiriman',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRupiah(
                          value: subtotal,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                            color: AppColors.brown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      label: settings.isOpen
                          ? 'Lanjut ke Checkout'
                          : 'Kedai Sedang Tutup',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: settings.isOpen
                          ? () => context.push('/checkout')
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  const _CartItemCard({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      shadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ProductImage(
                path: item.image,
                emoji: item.emoji,
                size: 78,
                radius: 16,
              ),
              if (item.qty > 1)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.espresso.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${item.qty}x',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: AppColors.brown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () =>
                          ref.read(cartProvider.notifier).removeItem(item.id),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.variantName != null) ...[
                  const SizedBox(height: 3),
                  AppBadge(
                    label: item.variantName!,
                    background: AppColors.beigeSoft,
                    foreground: AppColors.brownSoft,
                    compact: true,
                  ),
                ],
                if (item.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '"${item.note}"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    QuantityStepper(
                      compact: true,
                      value: item.qty,
                      onChanged: (value) => ref
                          .read(cartProvider.notifier)
                          .changeQty(item.id, value),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (item.qty > 1)
                          Text(
                            '${rupiah(item.unitPrice)} / porsi',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 9.5),
                          ),
                        Text(
                          rupiah(item.lineTotal),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.terracottaDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
