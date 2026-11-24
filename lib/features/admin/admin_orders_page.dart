import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/kedai_refresh.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../orders/order_card.dart';

enum _AdminFilter { incoming, processing, ready, payment, completed, all }

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  _AdminFilter _filter = _AdminFilter.incoming;

  List<Order> _apply(List<Order> orders) {
    return switch (_filter) {
      _AdminFilter.incoming =>
        orders
            .where((o) => o.status == OrderStatus.pendingConfirmation)
            .toList(),
      _AdminFilter.processing =>
        orders
            .where(
              (o) =>
                  o.status == OrderStatus.confirmed ||
                  o.status == OrderStatus.preparing,
            )
            .toList(),
      _AdminFilter.ready =>
        orders
            .where(
              (o) =>
                  o.status == OrderStatus.readyForPickup ||
                  o.status == OrderStatus.outForDelivery,
            )
            .toList(),
      _AdminFilter.payment =>
        orders
            .where((o) => o.paymentStatus == PaymentStatus.waitingVerification)
            .toList(),
      _AdminFilter.completed =>
        orders
            .where(
              (o) =>
                  o.status == OrderStatus.completed ||
                  o.status == OrderStatus.rejected ||
                  o.status == OrderStatus.cancelled,
            )
            .toList(),
      _AdminFilter.all => orders,
    };
  }

  int _count(List<Order> orders, _AdminFilter filter) {
    return switch (filter) {
      _AdminFilter.incoming =>
        orders.where((o) => o.status == OrderStatus.pendingConfirmation).length,
      _AdminFilter.processing =>
        orders
            .where(
              (o) =>
                  o.status == OrderStatus.confirmed ||
                  o.status == OrderStatus.preparing,
            )
            .length,
      _AdminFilter.ready =>
        orders
            .where(
              (o) =>
                  o.status == OrderStatus.readyForPickup ||
                  o.status == OrderStatus.outForDelivery,
            )
            .length,
      _AdminFilter.payment =>
        orders
            .where((o) => o.paymentStatus == PaymentStatus.waitingVerification)
            .length,
      _AdminFilter.completed =>
        orders.where((o) => o.status == OrderStatus.completed).length,
      _AdminFilter.all => orders.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);
    final filtered = _apply(orders);
    final incoming = _count(orders, _AdminFilter.incoming);

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
                          'ANTREAN KEDAI',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.terracotta,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Pesanan',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          incoming > 0
                              ? '$incoming pesanan menunggu konfirmasi'
                              : 'Tidak ada pesanan baru',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconCircleButton(
                    icon: Icons.inbox_rounded,
                    badgeCount: incoming,
                    background: incoming > 0
                        ? AppColors.terracotta
                        : AppColors.surface,
                    foreground: incoming > 0
                        ? AppColors.white
                        : AppColors.brown,
                    onTap: () =>
                        setState(() => _filter = _AdminFilter.incoming),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final filter in _AdminFilter.values) ...[
                    CategoryChip(
                      label:
                          '${_filterLabel(filter)} (${_count(orders, filter)})',
                      selected: _filter == filter,
                      onTap: () => setState(() => _filter = filter),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} pesanan',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownSoft,
                    ),
                  ),
                  const Spacer(),
                  if (_filter == _AdminFilter.payment)
                    const AppBadge(
                      label: 'Verifikasi manual',
                      background: AppColors.infoSoft,
                      foreground: AppColors.info,
                      compact: true,
                      icon: Icons.verified_outlined,
                    ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.inbox_outlined,
                      eyebrow: 'Antrean kosong',
                      title: 'Tidak ada pesanan',
                      message: 'Pesanan dengan status ini akan muncul di sini.',
                    )
                  : KedaiRefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final order = filtered[index];
                          return Reveal(
                            index: index,
                            offset: 0.03,
                            child: OrderCard(
                              order: order,
                              showCustomer: true,
                              onTap: () =>
                                  context.push('/admin/order/${order.id}'),
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

  String _filterLabel(_AdminFilter filter) => switch (filter) {
    _AdminFilter.incoming => 'Masuk',
    _AdminFilter.processing => 'Diproses',
    _AdminFilter.ready => 'Siap',
    _AdminFilter.payment => 'Pembayaran',
    _AdminFilter.completed => 'Selesai',
    _AdminFilter.all => 'Semua',
  };
}
