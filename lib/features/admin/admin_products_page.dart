import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/kedai_refresh.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

class AdminProductsPage extends ConsumerStatefulWidget {
  const AdminProductsPage({super.key});

  @override
  ConsumerState<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends ConsumerState<AdminProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _categoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _delete(Product product) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Hapus produk?',
      message:
          '${product.name} akan dihapus dari menu. Riwayat pesanan lama tetap aman karena harga tersimpan sebagai snapshot.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (confirmed) {
      ref.read(productsProvider.notifier).deleteProduct(product.id);
      if (mounted) showAppSnack(context, 'Produk dihapus.');
    }
  }

  List<Product> _filter(List<Product> products) {
    final query = _query.trim().toLowerCase();
    return products.where((product) {
      final matchesCategory =
          _categoryId == null || product.categoryId == _categoryId;
      final matchesQuery =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);
    final filtered = _filter(products);
    final available = products.where((product) => product.available).length;
    final emptyStock = products.length - available;

    final categoryNames = <String, String>{
      for (final category in categories) category.id: category.name,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KATALOG KEDAI',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.terracotta,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Menu',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${products.length} produk • $available tersedia'
                          '${emptyStock > 0 ? ' • $emptyStock habis' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconCircleButton(
                    icon: Icons.add_rounded,
                    background: AppColors.terracotta,
                    foreground: AppColors.white,
                    onTap: () => context.push('/admin/products/new'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: AppSearchField(
                controller: _searchController,
                hint: 'Cari nama atau deskripsi menu...',
                onChanged: (value) => setState(() => _query = value),
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
            ),
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
                  Expanded(
                    child: Text(
                      '${filtered.length} produk ditampilkan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownSoft,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => context.push('/admin/categories'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.category_outlined, size: 15),
                    label: const Text(
                      'Kategori',
                      style: TextStyle(fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.restaurant_menu_rounded,
                      eyebrow: products.isEmpty
                          ? 'Menu kosong'
                          : 'Tidak ada hasil',
                      title: products.isEmpty
                          ? 'Belum ada produk'
                          : 'Produk tidak ditemukan',
                      message: products.isEmpty
                          ? 'Tambahkan produk pertama untuk mulai berjualan.'
                          : 'Coba kata kunci atau kategori lain.',
                      actionLabel: products.isEmpty
                          ? 'Tambah Produk'
                          : 'Reset filter',
                      onAction: products.isEmpty
                          ? () => context.push('/admin/products/new')
                          : () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _categoryId = null;
                              });
                            },
                    )
                  : KedaiRefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return Reveal(
                            index: index,
                            offset: 0.03,
                            child: PressScale(
                              child: AppCard(
                                padding: const EdgeInsets.all(10),
                                onTap: () => context.push(
                                  '/admin/products/${product.id}/edit',
                                ),
                                child: Row(
                                  children: [
                                    ProductImage(
                                      path: product.image,
                                      emoji: product.emoji,
                                      size: 62,
                                      radius: 14,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.brown,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${categoryNames[product.categoryId] ?? 'Tanpa kategori'} • ${rupiah(product.price)}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                          const SizedBox(height: 7),
                                          Row(
                                            children: [
                                              _AvailabilityPill(
                                                available: product.available,
                                                onTap: () => ref
                                                    .read(
                                                      productsProvider.notifier,
                                                    )
                                                    .toggleAvailability(
                                                      product.id,
                                                    ),
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  product.variants.isEmpty
                                                      ? 'Tanpa varian'
                                                      : '${product.variants.length} varian',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.muted,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert_rounded,
                                        size: 20,
                                        color: AppColors.muted,
                                      ),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          context.push(
                                            '/admin/products/${product.id}/edit',
                                          );
                                        } else if (value == 'delete') {
                                          _delete(product);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit produk'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            'Hapus produk',
                                            style: TextStyle(
                                              color: AppColors.danger,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.available, required this.onTap});

  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: available ? AppColors.successSoft : AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: available ? AppColors.success : AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              available ? 'Tersedia' : 'Habis',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: available ? AppColors.success : AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
