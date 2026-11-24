import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../state/providers.dart';

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _taglineController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _hoursController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _bankNumberController;
  late final TextEditingController _bankHolderController;
  late final TextEditingController _qrisController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _nameController = TextEditingController(text: settings.name);
    _taglineController = TextEditingController(text: settings.tagline);
    _descriptionController = TextEditingController(text: settings.description);
    _addressController = TextEditingController(text: settings.address);
    _phoneController = TextEditingController(text: settings.phone);
    _hoursController = TextEditingController(text: settings.openHours);
    _bankNameController = TextEditingController(text: settings.bankName);
    _bankNumberController = TextEditingController(text: settings.bankNumber);
    _bankHolderController = TextEditingController(text: settings.bankHolder);
    _qrisController = TextEditingController(text: settings.qrisNote);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _hoursController.dispose();
    _bankNameController.dispose();
    _bankNumberController.dispose();
    _bankHolderController.dispose();
    _qrisController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final current = ref.read(settingsProvider);
    ref
        .read(settingsProvider.notifier)
        .save(
          current.copyWith(
            name: _nameController.text.trim(),
            tagline: _taglineController.text.trim(),
            description: _descriptionController.text.trim(),
            address: _addressController.text.trim(),
            phone: _phoneController.text.trim(),
            openHours: _hoursController.text.trim(),
            bankName: _bankNameController.text.trim(),
            bankNumber: _bankNumberController.text.trim(),
            bankHolder: _bankHolderController.text.trim(),
            qrisNote: _qrisController.text.trim(),
          ),
        );
    showAppSnack(context, 'Pengaturan kedai disimpan.');
  }

  Future<void> _logout() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Keluar dari akun admin?',
      message: 'Anda perlu masuk kembali untuk mengelola kedai.',
      confirmLabel: 'Keluar',
      destructive: true,
    );
    if (confirmed) {
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PENGATURAN',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.terracotta,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Setelan Kedai',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Informasi, pembayaran, dan operasional.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: AppAvatar(name: user?.name ?? 'Ummi', size: 42),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    AppAvatar(name: user?.name ?? 'Admin', size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Admin',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brown,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            user?.email ?? '-',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const AppBadge(
                      label: 'Admin',
                      icon: Icons.shield_outlined,
                      background: AppColors.beige,
                      foreground: AppColors.terracottaDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.fromLTRB(14, 11, 8, 11),
                color: settings.isOpen
                    ? AppColors.successSoft
                    : AppColors.dangerSoft,
                borderColor: settings.isOpen
                    ? AppColors.success.withValues(alpha: 0.22)
                    : AppColors.danger.withValues(alpha: 0.22),
                shadow: false,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        settings.isOpen
                            ? Icons.storefront_rounded
                            : Icons.store_mall_directory_rounded,
                        size: 20,
                        color: settings.isOpen
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.isOpen ? 'Kedai Buka' : 'Kedai Tutup',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: settings.isOpen
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            settings.isOpen
                                ? 'Pelanggan dapat mengirim pesanan baru.'
                                : 'Pesanan baru diblokir sampai toko dibuka.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 10,
                                  color: AppColors.brownSoft,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: settings.isOpen,
                      onChanged: (value) =>
                          ref.read(settingsProvider.notifier).toggleOpen(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _SettingsSection(
                eyebrow: 'Identitas',
                title: 'Informasi Kedai',
                subtitle: 'Tampil pada halaman pelanggan',
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Nama kedai',
                    icon: Icons.storefront_outlined,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Nama kedai wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _taglineController,
                    label: 'Tagline',
                    icon: Icons.short_text_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Deskripsi',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _addressController,
                    label: 'Alamat',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _phoneController,
                    label: 'Nomor telepon',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _hoursController,
                    label: 'Jam operasional',
                    hint: 'Contoh: 09.00 - 21.00',
                    icon: Icons.schedule_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsSection(
                eyebrow: 'Keuangan',
                title: 'Pembayaran',
                subtitle: 'Rekening dan QRIS untuk verifikasi manual',
                children: [
                  AppTextField(
                    controller: _bankNameController,
                    label: 'Nama bank',
                    icon: Icons.account_balance_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _bankNumberController,
                    label: 'Nomor rekening',
                    icon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _bankHolderController,
                    label: 'Atas nama',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _qrisController,
                    label: 'Informasi QRIS',
                    icon: Icons.qr_code_2_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 5, 6, 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delivery_dining_outlined,
                          size: 18,
                          color: AppColors.brownSoft,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Layanan delivery',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                settings.deliveryEnabled
                                    ? 'Aktif — pelanggan dapat memesan antar.'
                                    : 'Nonaktif — hanya dine-in & takeaway.',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: settings.deliveryEnabled,
                          onChanged: (value) => ref
                              .read(settingsProvider.notifier)
                              .save(settings.copyWith(deliveryEnabled: value)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Simpan Pengaturan',
                icon: Icons.save_outlined,
                onPressed: _save,
              ),
              const SizedBox(height: 24),
              const SectionHeader(eyebrow: 'Pintasan', title: 'Operasional'),
              const SizedBox(height: 10),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.category_outlined,
                      title: 'Kategori Menu',
                      subtitle: 'Tambah, ubah, dan hapus kategori',
                      onTap: () => context.push('/admin/categories'),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.delivery_dining_outlined,
                      title: 'Zona, Kurir & Meja',
                      subtitle: 'Atur tarif dan penugasan kurir',
                      onTap: () => context.push('/admin/delivery'),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.bar_chart_rounded,
                      title: 'Laporan Penjualan',
                      subtitle: 'Ringkasan pendapatan dan produk terlaris',
                      onTap: () => context.push('/admin/reports'),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.palette_outlined,
                      title: 'Panduan Desain',
                      subtitle: 'Referensi warna, tipografi, dan komponen',
                      onTap: () => context.push('/admin/style-guide'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                padding: EdgeInsets.zero,
                child: _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Keluar',
                  subtitle: 'Keluar dari akun admin',
                  color: AppColors.danger,
                  onTap: _logout,
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'Kedai Ummi Admin • v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppColors.brown,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color == AppColors.danger
              ? AppColors.dangerSoft
              : AppColors.beigeSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 17,
          color: color == AppColors.danger
              ? AppColors.danger
              : AppColors.terracottaDark,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.muted,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
