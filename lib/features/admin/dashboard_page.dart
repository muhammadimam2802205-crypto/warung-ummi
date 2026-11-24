import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/kedai_refresh.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../orders/order_card.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final stats = ref.watch(adminStatsProvider);
    final orders = ref.watch(ordersProvider);
    final user = ref.watch(authProvider);
    final recent = orders.take(3).toList();
    final waitingPayment = orders
        .where((o) => o.paymentStatus == PaymentStatus.waitingVerification)
        .length;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const dayInitials = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    final weekly = <double>[];
    final weeklyLabels = <String>[];
    for (var i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: 6 - i));
      weeklyLabels.add(dayInitials[day.weekday - 1]);
      weekly.add(
        orders
            .where(
              (order) =>
                  order.paymentStatus == PaymentStatus.paid &&
                  order.createdAt.year == day.year &&
                  order.createdAt.month == day.month &&
                  order.createdAt.day == day.day,
            )
            .fold<double>(0, (sum, order) => sum + order.total),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: KedaiRefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminStatsProvider);
            ref.invalidate(ordersProvider);
            await Future<void>.delayed(const Duration(milliseconds: 240));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                          'PANEL OPERASIONAL',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.terracotta,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Halo, ${user?.name.split(' ').first ?? 'Ummi'}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formatDateLong(DateTime.now()),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
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
              _StoreStatusCard(settings: settings),
              const SizedBox(height: 14),
              _RevenueCard(stats: stats),
              if (waitingPayment > 0) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => context.go('/admin/orders'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 18,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            '$waitingPayment pembayaran menunggu verifikasi',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: AppColors.info,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              const SectionHeader(
                eyebrow: 'Ringkasan hari ini',
                title: 'Antrean Pesanan',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Pesanan Masuk',
                      value: '${stats.incoming}',
                      icon: Icons.inbox_rounded,
                      color: AppColors.warning,
                      background: AppColors.warningSoft,
                      onTap: () => context.go('/admin/orders'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Sedang Diproses',
                      value: '${stats.processing}',
                      icon: Icons.soup_kitchen_rounded,
                      color: AppColors.terracotta,
                      background: AppColors.terracottaSoft,
                      onTap: () => context.go('/admin/orders'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Siap / Diantar',
                      value: '${stats.ready}',
                      icon: Icons.delivery_dining_rounded,
                      color: AppColors.info,
                      background: AppColors.infoSoft,
                      onTap: () => context.go('/admin/orders'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Selesai',
                      value: '${stats.completed}',
                      icon: Icons.task_alt_rounded,
                      color: AppColors.success,
                      background: AppColors.successSoft,
                      onTap: () => context.go('/admin/orders'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _WeeklyCard(weekly: weekly, labels: weeklyLabels),
              const SizedBox(height: 24),
              SectionHeader(
                eyebrow: 'Terbaru',
                title: 'Pesanan Terbaru',
                actionLabel: 'Lihat semua',
                onAction: () => context.go('/admin/orders'),
              ),
              const SizedBox(height: 10),
              if (recent.isEmpty)
                const AppCard(
                  child: Text(
                    'Belum ada pesanan masuk.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                )
              else
                for (var i = 0; i < recent.length; i++) ...[
                  Reveal(
                    index: i,
                    offset: 0.03,
                    child: OrderCard(
                      order: recent[i],
                      showCustomer: true,
                      onTap: () => context.push('/admin/order/${recent[i].id}'),
                    ),
                  ),
                  if (i != recent.length - 1) const SizedBox(height: 9),
                ],
              const SizedBox(height: 24),
              const SectionHeader(eyebrow: 'Pintasan', title: 'Aksi Cepat'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.restaurant_menu_rounded,
                      label: 'Kelola Menu',
                      subtitle: 'Produk & harga',
                      onTap: () => context.go('/admin/menu'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.category_rounded,
                      label: 'Kategori',
                      subtitle: 'Kelompok menu',
                      onTap: () => context.push('/admin/categories'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.delivery_dining_rounded,
                      label: 'Zona & Kurir',
                      subtitle: 'Atur pengiriman',
                      onTap: () => context.push('/admin/delivery'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.insights_rounded,
                      label: 'Laporan',
                      subtitle: 'Performa kedai',
                      onTap: () => context.push('/admin/reports'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreStatusCard extends ConsumerWidget {
  const _StoreStatusCard({required this.settings});

  final StoreSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      color: settings.isOpen ? AppColors.successSoft : AppColors.dangerSoft,
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
              color: settings.isOpen ? AppColors.success : AppColors.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: settings.isOpen
                            ? AppColors.success
                            : AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
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
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  settings.isOpen
                      ? 'Pelanggan dapat mengirim pesanan baru.'
                      : 'Pesanan baru diblokir sampai toko dibuka.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppColors.brownSoft,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: settings.isOpen,
              onChanged: (value) =>
                  ref.read(settingsProvider.notifier).toggleOpen(value),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
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
              top: -60,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.22),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 26,
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
              padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'TOTAL PENJUALAN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                          color: AppColors.gold.withValues(alpha: 0.95),
                        ),
                      ),
                      const Spacer(),
                      AppBadge(
                        label: '${stats.totalOrders} pesanan',
                        background: Colors.white.withValues(alpha: 0.08),
                        foreground: Colors.white.withValues(alpha: 0.75),
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rupiah(stats.revenue),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 34,
                      height: 1.05,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Dari pembayaran terverifikasi',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.today_rounded,
                          size: 14,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Hari ini • ${stats.todayOrders} pesanan',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                        Text(
                          rupiah(stats.todayRevenue),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
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
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.weekly, required this.labels});

  final List<double> weekly;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final maxWeekly = weekly.fold<double>(0, (m, v) => v > m ? v : m);
    final totalWeekly = weekly.fold<double>(0, (sum, v) => sum + v);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.terracottaSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 18,
                  color: AppColors.terracottaDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tren Penjualan',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '7 hari terakhir • pesanan lunas',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rupiah(totalWeekly.round()),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.terracottaDark,
                    ),
                  ),
                  Text(
                    maxWeekly == 0
                        ? 'belum ada data'
                        : 'tertinggi ${rupiah(maxWeekly.round())}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 8.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < weekly.length; i++) ...[
                  Expanded(
                    child: _MiniBar(
                      value: weekly[i],
                      max: maxWeekly,
                      active: i == weekly.length - 1,
                    ),
                  ),
                  if (i != weekly.length - 1) const SizedBox(width: 7),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                Expanded(
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: i == labels.length - 1
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: i == labels.length - 1
                          ? AppColors.terracottaDark
                          : AppColors.muted,
                    ),
                  ),
                ),
                if (i != labels.length - 1) const SizedBox(width: 7),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.value,
    required this.max,
    required this.active,
  });

  final double value;
  final double max;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final ratio = max <= 0 ? 0.12 : (value / max).clamp(0.12, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: ratio),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 44 * progress,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: active
                    ? const [AppColors.terracottaDark, AppColors.terracotta]
                    : const [AppColors.beige, AppColors.beigeSoft],
              ),
              border: active
                  ? null
                  : Border.all(color: AppColors.border, width: 0.8),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(13),
        shadow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: color),
                ),
                const Spacer(),
                Icon(
                  Icons.north_east_rounded,
                  size: 14,
                  color: AppColors.muted.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: AppColors.brown,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        shadow: false,
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.beigeSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: AppColors.terracottaDark),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brown,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.muted,
                    ),
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
