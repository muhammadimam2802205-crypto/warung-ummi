import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  Future<void> _editCategory(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final emojiController = TextEditingController(
      text: category?.emoji ?? '🍽️',
    );
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(category == null ? 'Kategori Baru' : 'Edit Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emojiController,
                textAlign: TextAlign.center,
                maxLength: 2,
                style: const TextStyle(fontSize: 28),
                decoration: const InputDecoration(
                  labelText: 'Emoji',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: nameController,
                label: 'Nama kategori',
                hint: 'Contoh: Minuman',
                icon: Icons.category_outlined,
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    error!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  setDialogState(() => error = 'Nama kategori wajib diisi');
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && context.mounted) {
      final categories = ref.read(categoriesProvider);
      final value = Category(
        id: category?.id ?? newId('cat'),
        name: nameController.text.trim(),
        emoji: emojiController.text.trim().isEmpty
            ? '🍽️'
            : emojiController.text.trim(),
        sortOrder: category?.sortOrder ?? categories.length,
        active: category?.active ?? true,
      );
      ref.read(categoriesProvider.notifier).saveCategory(value);
      showAppSnack(context, 'Kategori disimpan.');
    }
    nameController.dispose();
    emojiController.dispose();
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final usedBy = ref
        .read(productsProvider)
        .where((product) => product.categoryId == category.id)
        .length;
    if (usedBy > 0) {
      showAppSnack(
        context,
        'Kategori masih dipakai oleh $usedBy produk. Pindahkan produk terlebih dahulu.',
        error: true,
      );
      return;
    }
    final confirmed = await confirmDialog(
      context,
      title: 'Hapus kategori?',
      message: 'Kategori "${category.name}" akan dihapus.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (confirmed) {
      ref.read(categoriesProvider.notifier).deleteCategory(category.id);
      if (context.mounted) showAppSnack(context, 'Kategori dihapus.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);
    final active = categories.where((category) => category.active).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Menu'),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _editCategory(context, ref),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tambah'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: AppCard(
              padding: const EdgeInsets.all(15),
              color: AppColors.espresso,
              borderColor: AppColors.espresso,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      size: 20,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${categories.length} kategori',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$active aktif • ${products.length} produk terdaftar',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? EmptyState(
                    icon: Icons.category_outlined,
                    eyebrow: 'Struktur menu',
                    title: 'Belum ada kategori',
                    message:
                        'Kategori membantu pelanggan menemukan menu lebih cepat.',
                    actionLabel: 'Tambah Kategori',
                    onAction: () => _editCategory(context, ref),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final count = products
                          .where((product) => product.categoryId == category.id)
                          .length;
                      return Reveal(
                        index: index,
                        offset: 0.03,
                        child: AppCard(
                          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: category.active
                                      ? AppColors.beigeSoft
                                      : AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  category.emoji,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: category.active
                                        ? null
                                        : AppColors.muted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.brown,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Text(
                                          '$count produk',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        const SizedBox(width: 7),
                                        AppBadge(
                                          label: category.active
                                              ? 'Aktif'
                                              : 'Nonaktif',
                                          compact: true,
                                          dot: true,
                                          background: category.active
                                              ? AppColors.successSoft
                                              : AppColors.surfaceAlt,
                                          foreground: category.active
                                              ? AppColors.success
                                              : AppColors.muted,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: category.active,
                                onChanged: (value) => ref
                                    .read(categoriesProvider.notifier)
                                    .saveCategory(
                                      category.copyWith(active: value),
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
                                    _editCategory(
                                      context,
                                      ref,
                                      category: category,
                                    );
                                  } else {
                                    _delete(context, ref, category);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit kategori'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Hapus kategori',
                                      style: TextStyle(color: AppColors.danger),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
