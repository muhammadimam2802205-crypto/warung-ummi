import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/models.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.showCustomer = false,
  });

  final Order order;
  final VoidCallback onTap;
  final bool showCustomer;

  @override
  Widget build(BuildContext context) {
    final serviceIcon = switch (order.serviceType) {
      ServiceType.dineIn => Icons.table_restaurant_outlined,
      ServiceType.takeaway => Icons.shopping_bag_outlined,
      ServiceType.delivery => Icons.delivery_dining_outlined,
    };
    final visual = statusVisual(order.status);
    final previewItems = order.items.take(3).toList();

    return PressScale(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
        shadow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: visual.background,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(visual.icon, size: 17, color: visual.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brown,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        showCustomer
                            ? '${order.customerName} • ${formatDateTime(order.createdAt)}'
                            : formatDateTime(order.createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: OrderStatusBadge(
                      status: order.status,
                      compact: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  if (previewItems.isNotEmpty)
                    SizedBox(
                      width: 30.0 + (previewItems.length - 1) * 18,
                      height: 30,
                      child: Stack(
                        children: [
                          for (var i = 0; i < previewItems.length; i++)
                            Positioned(
                              left: i * 18.0,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.beigeSoft,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface,
                                    width: 1.6,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  previewItems[i].emoji,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          previewItems.isEmpty
                              ? 'Pesanan'
                              : previewItems
                                    .map((item) => item.name)
                                    .join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownSoft,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              serviceIcon,
                              size: 11,
                              color: AppColors.terracotta,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                [
                                  order.serviceType.label,
                                  '${order.itemCount} item',
                                  if (order.tableCode != null)
                                    'Meja ${order.tableCode}',
                                ].join(' • '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 9.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    rupiah(order.total),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: AppColors.brown,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: PaymentStatusBadge(
                      status: order.paymentStatus,
                      compact: true,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted,
                  size: 19,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
