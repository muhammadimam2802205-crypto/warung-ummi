import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/kedai_refresh.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

enum _ReportPeriod { week, month, all }

const List<String> _weekdayShort = [
  'Sen',
  'Sel',
  'Rab',
  'Kam',
  'Jum',
  'Sab',
  'Min',
];

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  _ReportPeriod _period = _ReportPeriod.week;

  DateTime? get _cutoff {
    final now = DateTime.now();
    return switch (_period) {
      _ReportPeriod.week => now.subtract(const Duration(days: 7)),
      _ReportPeriod.month => now.subtract(const Duration(days: 30)),
      _ReportPeriod.all => null,
    };
  }

  String get _periodLabel => switch (_period) {
    _ReportPeriod.week => '7 hari terakhir',
    _ReportPeriod.month => '30 hari terakhir',
    _ReportPeriod.all => 'Semua periode',
  };

  @override
  Widget build(BuildContext context) {
    final cutoff = _cutoff;
    final allOrders = ref.watch(ordersProvider);
    final paidOrders = allOrders
        .where(
          (order) =>
              order.paymentStatus == PaymentStatus.paid &&
              order.status != OrderStatus.rejected &&
              order.status != OrderStatus.cancelled,
        )
        .toList();
    final orders = paidOrders
        .where((order) => cutoff == null || order.createdAt.isAfter(cutoff))
        .toList();

    final revenue = orders.fold(0, (sum, order) => sum + order.total);
    final itemCount = orders.fold(0, (sum, order) => sum + order.itemCount);
    final average = orders.isEmpty ? 0 : revenue ~/ orders.length;

    final qtyByProduct = <String, int>{};
    final revenueByProduct = <String, int>{};
    final emojiByProduct = <String, String>{};
    for (final order in orders) {
      for (final item in order.items) {
        qtyByProduct[item.name] = (qtyByProduct[item.name] ?? 0) + item.qty;
        revenueByProduct[item.name] =
            (revenueByProduct[item.name] ?? 0) + item.lineTotal;
        emojiByProduct[item.name] = item.emoji;
      }
    }
    final topProducts = qtyByProduct.keys.toList()
      ..sort((a, b) => qtyByProduct[b]!.compareTo(qtyByProduct[a]!));
    final maxQty = topProducts.isEmpty ? 1 : qtyByProduct[topProducts.first]!;

    final serviceCounts = <ServiceType, int>{
      for (final type in ServiceType.values) type: 0,
    };
    for (final order in orders) {
      serviceCounts[order.serviceType] = serviceCounts[order.serviceType]! + 1;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );
    final dailyRevenue = List<int>.filled(7, 0);
    for (final order in paidOrders) {
      final created = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );
      final index = days.indexWhere((day) => day == created);
      if (index >= 0) dailyRevenue[index] += order.total;
    }
    final maxDaily = dailyRevenue.fold(0, (a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: KedaiRefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            Row(
              children: [
                for (final period in _ReportPeriod.values) ...[
                  CategoryChip(
                    label: switch (period) {
                      _ReportPeriod.week => '7 Hari',
                      _ReportPeriod.month => '30 Hari',
                      _ReportPeriod.all => 'Semua',
                    },
                    selected: _period == period,
                    onTap: () => setState(() => _period = period),
                  ),
                  if (period != _ReportPeriod.values.last)
                    const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _RevenueHero(
              periodLabel: _periodLabel,
              revenue: revenue,
              orderCount: orders.length,
              itemCount: itemCount,
              average: average,
            ),
            const SizedBox(height: 14),
            _DailyChartCard(
              days: days,
              values: dailyRevenue,
              maxValue: maxDaily,
            ),
            const SizedBox(height: 22),
            SectionHeader(
              eyebrow: 'Insight',
              title: 'Produk Terlaris',
              subtitle: 'Berdasarkan jumlah item terjual',
            ),
            const SizedBox(height: 10),
            if (topProducts.isEmpty)
              const AppCard(
                child: Text(
                  'Belum ada transaksi pada periode ini.',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              )
            else
              AppCard(
                child: Column(
                  children: [
                    for (var i = 0; i < topProducts.length && i < 5; i++) ...[
                      if (i > 0) const Divider(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.beigeSoft,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              emojiByProduct[topProducts[i]] ?? '🍽️',
                              style: const TextStyle(fontSize: 19),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        topProducts[i],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      rupiah(revenueByProduct[topProducts[i]]!),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.brownSoft,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        child: LinearProgressIndicator(
                                          value:
                                              qtyByProduct[topProducts[i]]! /
                                              maxQty,
                                          minHeight: 5,
                                          backgroundColor: AppColors.beigeSoft,
                                          color: AppColors.terracotta,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${qtyByProduct[topProducts[i]]} pcs',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.terracottaDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 22),
            const SectionHeader(
              eyebrow: 'Saluran',
              title: 'Metode Layanan',
              subtitle: 'Sebaran transaksi per jenis layanan',
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Row(
                children: [
                  _ServiceStat(
                    label: 'Dine-In',
                    icon: Icons.table_restaurant_outlined,
                    count: serviceCounts[ServiceType.dineIn] ?? 0,
                    total: orders.length,
                  ),
                  _ServiceStat(
                    label: 'Takeaway',
                    icon: Icons.shopping_bag_outlined,
                    count: serviceCounts[ServiceType.takeaway] ?? 0,
                    total: orders.length,
                  ),
                  _ServiceStat(
                    label: 'Delivery',
                    icon: Icons.delivery_dining_outlined,
                    count: serviceCounts[ServiceType.delivery] ?? 0,
                    total: orders.length,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SectionHeader(
              eyebrow: 'Buku kas',
              title: 'Riwayat Transaksi',
              subtitle: '${orders.length} transaksi lunas',
            ),
            const SizedBox(height: 10),
            if (orders.isEmpty)
              EmptyState(
                icon: Icons.bar_chart_rounded,
                eyebrow: 'Belum ada data',
                title: 'Belum ada laporan',
                message:
                    'Transaksi dengan pembayaran lunas akan muncul di laporan.',
                actionLabel: 'Lihat semua periode',
                onAction: () => setState(() => _period = _ReportPeriod.all),
              )
            else
              for (final order in orders) ...[
                AppCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () => context.push('/admin/order/${order.id}'),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 19,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderNumber,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${formatDateTime(order.createdAt)} • ${order.serviceType.label}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        rupiah(order.total),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _RevenueHero extends StatelessWidget {
  const _RevenueHero({
    required this.periodLabel,
    required this.revenue,
    required this.orderCount,
    required this.itemCount,
    required this.average,
  });

  final String periodLabel;
  final int revenue;
  final int orderCount;
  final int itemCount;
  final int average;

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
              right: -50,
              top: -70,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.2),
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
                  color: AppColors.terracotta.withValues(alpha: 0.16),
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
                        'PENDAPATAN • ${periodLabel.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: AppColors.gold.withValues(alpha: 0.95),
                        ),
                      ),
                      const Spacer(),
                      AppBadge(
                        label: '$orderCount transaksi',
                        background: Colors.white.withValues(alpha: 0.08),
                        foreground: Colors.white.withValues(alpha: 0.75),
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rupiah(revenue),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 33,
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
                  Row(
                    children: [
                      _MiniStat(label: 'Item terjual', value: '$itemCount'),
                      const SizedBox(width: 8),
                      _MiniStat(label: 'Rata-rata', value: rupiah(average)),
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyChartCard extends StatelessWidget {
  const _DailyChartCard({
    required this.days,
    required this.values,
    required this.maxValue,
  });

  final List<DateTime> days;
  final List<int> values;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final safeMax = maxValue <= 0 ? 1 : maxValue;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren 7 Hari',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brown,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pendapatan harian terverifikasi',
                      style: TextStyle(fontSize: 10.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: rupiah(values.fold(0, (a, b) => a + b)),
                compact: true,
                background: AppColors.beigeSoft,
                foreground: AppColors.terracottaDark,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 104,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++) ...[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 6 + (72 * values[i] / safeMax),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: values[i] == 0
                                ? AppColors.beige
                                : (i == days.length - 1
                                      ? AppColors.espresso
                                      : AppColors.terracotta),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                              bottom: Radius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _weekdayShort[days[i].weekday - 1],
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceStat extends StatelessWidget {
  const _ServiceStat({
    required this.label,
    required this.icon,
    required this.count,
    required this.total,
  });

  final String label;
  final IconData icon;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (count * 100 / total).round();
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.beigeSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: AppColors.terracottaDark),
          ),
          const SizedBox(height: 7),
          Text(
            '$count',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 19,
              fontWeight: FontWeight.w600,
              height: 1,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.brownSoft,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$percent%',
            style: const TextStyle(fontSize: 9, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
