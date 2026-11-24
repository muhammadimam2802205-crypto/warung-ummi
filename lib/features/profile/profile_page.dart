import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion/page_transitions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
    await showKedaiSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _EditProfileSheet(),
    );
  }

  void _showStoreInfo(BuildContext context, StoreSettings settings) {
    showKedaiSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B2A1F), AppColors.espresso],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.6),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.storefront_rounded,
                        size: 21,
                        color: AppColors.gold,
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
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            settings.tagline,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppBadge(
                      label: settings.isOpen ? 'Buka' : 'Tutup',
                      background: settings.isOpen
                          ? AppColors.successSoft
                          : AppColors.dangerSoft,
                      foreground: settings.isOpen
                          ? AppColors.success
                          : AppColors.danger,
                      compact: true,
                      dot: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                settings.description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.brownSoft),
              ),
              const SizedBox(height: 12),
              InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Alamat',
                value: settings.address,
              ),
              InfoRow(
                icon: Icons.phone_outlined,
                label: 'Telepon',
                value: settings.phone,
              ),
              InfoRow(
                icon: Icons.schedule_rounded,
                label: 'Jam buka',
                value: settings.openHours,
              ),
              InfoRow(
                icon: Icons.delivery_dining_outlined,
                label: 'Delivery',
                value: settings.deliveryEnabled ? 'Tersedia' : 'Tidak tersedia',
              ),
              const SizedBox(height: 14),
              Text('Pembayaran', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${settings.bankName} • ${settings.bankNumber}\na.n. ${settings.bankHolder}',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownSoft,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      settings.qrisNote,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Keluar dari akun?',
      message: 'Anda perlu masuk kembali untuk melakukan pemesanan.',
      confirmLabel: 'Keluar',
      destructive: true,
    );
    if (confirmed) {
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    final orders = ref.watch(myOrdersProvider);
    final activeCount = orders.where((o) => !o.status.isFinished).length;
    final completedCount = orders
        .where((o) => o.status == OrderStatus.completed)
        .length;

    if (user == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.person_outline, title: 'Belum masuk'),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              'AKUN SAYA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.terracotta,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 5),
            Text('Profil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),
            _IdentityHero(
              user: user,
              orderCount: orders.length,
              activeCount: activeCount,
              completedCount: completedCount,
              onEdit: () => _editProfile(context, ref),
            ),
            const SizedBox(height: 24),
            const SectionHeader(eyebrow: 'Pengaturan', title: 'Akun'),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profil',
                    subtitle: 'Ubah nama dan nomor HP',
                    onTap: () => _editProfile(context, ref),
                  ),
                  const Divider(height: 1, indent: 64),
                  _MenuTile(
                    icon: Icons.location_on_outlined,
                    title: 'Alamat Pengiriman',
                    subtitle: 'Kelola alamat untuk delivery',
                    trailingLabel: '${ref.watch(addressesProvider).length}',
                    onTap: () => context.push('/addresses'),
                  ),
                  const Divider(height: 1, indent: 64),
                  _MenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Riwayat Pesanan',
                    subtitle: 'Lihat semua pesananmu',
                    trailingLabel: '${orders.length}',
                    onTap: () => context.go('/orders'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(eyebrow: 'Tentang kami', title: 'Kedai Ummi'),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.storefront_outlined,
                    title: 'Info Kedai',
                    subtitle: settings.isOpen
                        ? 'Buka • ${settings.openHours}'
                        : 'Sedang tutup • ${settings.openHours}',
                    onTap: () => _showStoreInfo(context, settings),
                  ),
                  const Divider(height: 1, indent: 64),
                  _MenuTile(
                    icon: Icons.payments_outlined,
                    title: 'Pembayaran',
                    subtitle: '${settings.bankName} • QRIS • Tunai',
                    onTap: () => _showStoreInfo(context, settings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: EdgeInsets.zero,
              shadow: false,
              child: _MenuTile(
                icon: Icons.logout_rounded,
                title: 'Keluar',
                subtitle: 'Keluar dari akun ini',
                color: AppColors.danger,
                onTap: () => _logout(context, ref),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    'KEDAI UMMI',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(letterSpacing: 2),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Versi 1.0.0 • Dibuat untuk UMKM lokal',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
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

class _IdentityHero extends StatelessWidget {
  const _IdentityHero({
    required this.user,
    required this.orderCount,
    required this.activeCount,
    required this.completedCount,
    required this.onEdit,
  });

  final AppUser user;
  final int orderCount;
  final int activeCount;
  final int completedCount;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B2A1F), AppColors.espresso],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -50,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.24),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -60,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.terracotta.withValues(alpha: 0.18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.7),
                          ),
                        ),
                        child: AppAvatar(
                          name: user.name,
                          size: 56,
                          backgroundColor: AppColors.beige,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 22,
                                height: 1.1,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                AppBadge(
                                  label: user.role.label,
                                  background: AppColors.gold.withValues(
                                    alpha: 0.16,
                                  ),
                                  foreground: AppColors.gold,
                                  compact: true,
                                ),
                                Text(
                                  'Sejak ${formatDate(user.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: Colors.white.withValues(alpha: 0.45),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconCircleButton(
                        icon: Icons.edit_outlined,
                        size: 36,
                        background: Colors.white.withValues(alpha: 0.08),
                        foreground: AppColors.white,
                        onTap: onEdit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: const Color(0x14FFFFFF)),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      _HeroStat(label: 'Pesanan', value: orderCount),
                      _HeroDivider(),
                      _HeroStat(label: 'Aktif', value: activeCount),
                      _HeroDivider(),
                      _HeroStat(label: 'Selesai', value: completedCount),
                    ],
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 26,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppColors.brown,
    this.trailingLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color == AppColors.danger
                    ? AppColors.dangerSoft
                    : AppColors.beigeSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                  ),
                ],
              ),
            ),
            if (trailingLabel != null) ...[
              AppBadge(
                label: trailingLabel!,
                background: AppColors.surfaceAlt,
                foreground: AppColors.brownSoft,
                compact: true,
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet();

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authProvider.notifier)
        .updateProfile(
          name: _nameController.text,
          phone: _phoneController.text,
        );
    showAppSnack(context, 'Profil diperbarui.');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'EDIT PROFIL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.terracotta,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Perbarui data diri',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                label: 'Nama lengkap',
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _phoneController,
                label: 'Nomor HP',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().length < 9) {
                    return 'Nomor HP tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppButton(label: 'Simpan Perubahan', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
