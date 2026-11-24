import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

const List<String> _emojiOptions = [
  '🌯',
  '🍔',
  '🍲',
  '🍜',
  '🍚',
  '🍢',
  '🥗',
  '🧋',
  '🍊',
  '🍤',
  '🍗',
  '🥤',
  '🍰',
  '🍽️',
];

class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _categoryId;
  String _emoji = '🍽️';
  String _image = '';
  bool _available = true;
  List<ProductVariant> _variants = [];
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.productId == null
        ? null
        : ref
              .read(productsProvider)
              .where((item) => item.id == widget.productId)
              .firstOrNull;
    final categories = ref.read(categoriesProvider);
    _categoryId =
        product?.categoryId ??
        (categories.isEmpty ? null : categories.first.id);
    if (product != null) {
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toString();
      _emoji = product.emoji;
      _image = product.image;
      _available = product.available;
      _variants = [...product.variants];
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1600,
      );
      if (picked != null && mounted) {
        setState(() => _image = picked.path);
      }
    } catch (_) {
      if (mounted) {
        showAppSnack(
          context,
          'Gagal memilih gambar. Periksa izin galeri.',
          error: true,
        );
      }
    }
  }

  Future<void> _showVariantDialog({int? index}) async {
    final existing = index == null ? null : _variants[index];
    final nameController = TextEditingController(text: existing?.name ?? '');
    final deltaController = TextEditingController(
      text: (existing?.priceDelta ?? 0).toString(),
    );
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Tambah Varian' : 'Edit Varian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama varian',
                  hintText: 'Contoh: Jumbo, Pedas',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deltaController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Tambahan harga (Rp)',
                  hintText: '0',
                  prefixText: '+ ',
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
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
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  setDialogState(() => error = 'Nama varian wajib diisi');
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

    if (saved == true && mounted) {
      final variant = ProductVariant(
        id: existing?.id ?? newId('var'),
        name: nameController.text.trim(),
        priceDelta: int.tryParse(deltaController.text) ?? 0,
      );
      setState(() {
        if (index == null) {
          _variants = [..._variants, variant];
        } else {
          final list = [..._variants];
          list[index] = variant;
          _variants = list;
        }
      });
    }
    nameController.dispose();
    deltaController.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final categories = ref.read(categoriesProvider);
    if (_categoryId == null || categories.isEmpty) {
      showAppSnack(context, 'Buat kategori terlebih dahulu.', error: true);
      return;
    }
    final products = ref.read(productsProvider);
    final existing = products
        .where((item) => item.id == widget.productId)
        .firstOrNull;
    setState(() => _saving = true);
    final product = Product(
      id: existing?.id ?? newId('prod'),
      categoryId: _categoryId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: int.tryParse(_priceController.text) ?? 0,
      image: _image,
      emoji: _emoji,
      available: _available,
      variants: _variants,
      sortOrder: existing?.sortOrder ?? products.length,
    );
    ref.read(productsProvider.notifier).saveProduct(product);
    showAppSnack(
      context,
      existing == null ? 'Produk ditambahkan.' : 'Produk diperbarui.',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final existing = widget.productId == null
        ? null
        : ref
              .watch(productsProvider)
              .where((item) => item.id == widget.productId)
              .firstOrNull;

    if (!_initialized) {
      return const Scaffold(body: LoadingView());
    }
    if (widget.productId != null && existing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Produk')),
        body: EmptyState(
          icon: Icons.no_food_outlined,
          title: 'Produk tidak ditemukan',
          actionLabel: 'Kembali',
          onAction: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? 'Produk Baru' : 'Edit Produk'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: AppButton(
          label: existing == null ? 'Tambah ke Menu' : 'Simpan Perubahan',
          icon: Icons.check_rounded,
          loading: _saving,
          onPressed: _save,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            _PhotoSection(
              image: _image,
              emoji: _emoji,
              onPick: _pickImage,
              onRemove: () => setState(() => _image = ''),
            ),
            const SizedBox(height: 18),
            _FormSection(
              eyebrow: 'Langkah 1',
              title: 'Informasi Menu',
              subtitle: 'Nama dan deskripsi yang dilihat pelanggan',
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Nama produk',
                  icon: Icons.restaurant_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      (value == null || value.trim().length < 3)
                      ? 'Nama produk minimal 3 karakter'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                  ),
                  items: [
                    for (final category in categories)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(
                          '${category.emoji}  ${category.name}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _categoryId = value),
                  validator: (value) =>
                      value == null ? 'Pilih kategori produk' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Deskripsi',
                  hint: 'Jelaskan bahan dan keunggulan produk',
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                  validator: (value) =>
                      (value == null || value.trim().length < 10)
                      ? 'Deskripsi minimal 10 karakter'
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormSection(
              eyebrow: 'Langkah 2',
              title: 'Harga & Ketersediaan',
              subtitle: 'Harga dasar sebelum tambahan varian',
              children: [
                AppTextField(
                  controller: _priceController,
                  label: 'Harga dasar',
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  prefixText: 'Rp ',
                  validator: (value) {
                    final price = int.tryParse(value ?? '');
                    if (price == null || price <= 0) {
                      return 'Harga harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 4, 6, 4),
                  decoration: BoxDecoration(
                    color: _available
                        ? AppColors.successSoft
                        : AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _available
                            ? Icons.check_circle_rounded
                            : Icons.pause_circle_outline_rounded,
                        size: 18,
                        color: _available
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _available ? 'Tersedia' : 'Sedang habis',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: _available
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                            Text(
                              _available
                                  ? 'Pelanggan dapat memesan menu ini.'
                                  : 'Menu disembunyikan dari pemesanan.',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.brownSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _available,
                        onChanged: (value) =>
                            setState(() => _available = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormSection(
              eyebrow: 'Langkah 3',
              title: 'Varian Menu',
              subtitle: _variants.isEmpty
                  ? 'Opsional. Contoh: Daging, Telur, Spesial.'
                  : '${_variants.length} varian • ketuk untuk mengubah',
              children: [
                if (_variants.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _variants.length; i++)
                        InputChip(
                          label: Text(
                            _variants[i].priceDelta == 0
                                ? _variants[i].name
                                : '${_variants[i].name} +${rupiah(_variants[i].priceDelta)}',
                          ),
                          onPressed: () => _showVariantDialog(index: i),
                          onDeleted: () => setState(() {
                            final list = [..._variants]..removeAt(i);
                            _variants = list;
                          }),
                          deleteIcon: const Icon(Icons.close_rounded, size: 16),
                          backgroundColor: AppColors.surfaceAlt,
                          side: const BorderSide(color: AppColors.border),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                OutlinedButton.icon(
                  onPressed: () => _showVariantDialog(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    _variants.isEmpty ? 'Tambah Varian' : 'Tambah Varian Lain',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormSection(
              eyebrow: 'Visual',
              title: 'Emoji Cadangan',
              subtitle: 'Dipakai saat foto produk belum tersedia',
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final emoji in _emojiOptions)
                      InkWell(
                        onTap: () => setState(() => _emoji = emoji),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: AppMotion.fast,
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _emoji == emoji
                                ? AppColors.terracottaSoft
                                : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _emoji == emoji
                                  ? AppColors.terracotta
                                  : AppColors.border,
                              width: _emoji == emoji ? 1.5 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(eyebrow: eyebrow, title: title, subtitle: subtitle),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.image,
    required this.emoji,
    required this.onPick,
    required this.onRemove,
  });

  final String image;
  final String emoji;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: SizedBox(
        height: 190,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ProductImage(path: image, emoji: emoji, hint: false),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xB32A1B13)],
                  stops: [0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          image.isEmpty ? 'FOTO PRODUK' : 'FOTO TERPASANG',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          image.isEmpty
                              ? 'Tambahkan foto asli agar menu lebih menggugah.'
                              : 'Foto produk akan tampil di halaman menu.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (image.isNotEmpty)
                    IconButton(
                      onPressed: onRemove,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        foregroundColor: AppColors.white,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 19),
                    ),
                  const SizedBox(width: 6),
                  FilledButton.icon(
                    onPressed: onPick,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.espresso,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                    label: Text(image.isEmpty ? 'Pilih Foto' : 'Ganti'),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: AppBadge(
                label: 'Pratinjau',
                background: Colors.white.withValues(alpha: 0.85),
                foreground: AppColors.brown,
                compact: true,
                icon: Icons.visibility_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
