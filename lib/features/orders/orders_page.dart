import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/kedai_refresh.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import 'order_card.dart';

enum _OrderFilter { all, active, completed, closed }

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  _OrderFilter _filter = _OrderFilter.all;

  List<Order> _apply(List<Order> orders) {
    return switch (_filter) {
      _OrderFilter.all => orders,
      _OrderFilter.active => orders.where((o) => !o.status.isFinished).toList(),
      _OrderFilter.completed =>
        orders.where((o) => o.status == OrderStatus.completed).toList(),
      _OrderFilter.closed =>
        orders
            .where(
              (o) =>
                  o.status == OrderStatus.rejected ||
                  o.status == OrderStatus.cancelled,
            )
            .toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(myOrdersProvider);
    final filtered = _apply(orders);
    final activeCount = orders.where((o) => !o.status.isFinished).length;

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
                          'RIWAYAT & PELACAKAN',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.terracotta,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Pesanan Saya',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          activeCount > 0
                              ? '$activeCount pesanan sedang berjalan'
                              : 'Semua pesananmu ada di sini',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 20,
                      color: AppColors.terracottaDark,
                    ),
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
                  _FilterChip(
                    label: 'Semua',
                    count: orders.length,
                    selected: _filter == _OrderFilter.all,
                    onTap: () => setState(() => _filter = _OrderFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Aktif',
                    count: activeCount,
                    selected: _filter == _OrderFilter.active,
                    onTap: () => setState(() => _filter = _OrderFilter.active),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Selesai',
                    count: orders
                        .where((o) => o.status == OrderStatus.completed)
                        .length,
                    selected: _filter == _OrderFilter.completed,
                    onTap: () =>
                        setState(() => _filter = _OrderFilter.completed),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Dibatalkan',
                    count: orders
                        .where(
                          (o) =>
                              o.status == OrderStatus.rejected ||
                              o.status == OrderStatus.cancelled,
                        )
                        .length,
                    selected: _filter == _OrderFilter.closed,
                    onTap: () => setState(() => _filter = _OrderFilter.closed),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      eyebrow: orders.isEmpty
                          ? 'Belum ada riwayat'
                          : 'Filter kosong',
                      title: orders.isEmpty
                          ? 'Belum ada pesanan'
                          : 'Tidak ada pesanan di filter ini',
                      message: orders.isEmpty
                          ? 'Pesanan yang Anda buat akan muncul di halaman ini.'
                          : 'Coba pilih filter lain untuk melihat pesanan Anda.',
                      actionLabel: orders.isEmpty ? 'Mulai Pesan' : null,
                      onAction: orders.isEmpty
                          ? () => context.go('/menu')
                          : null,
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
                              onTap: () => context.push('/orders/${order.id}'),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CategoryChip(
      label: count == 0 ? label : '$label ($count)',
      selected: selected,
      onTap: onTap,
    );
  }
}
