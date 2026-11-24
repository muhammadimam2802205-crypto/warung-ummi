import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion/page_transitions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/local_image.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

class AdminOrderDetailPage extends ConsumerWidget {
  const AdminOrderDetailPage({super.key, required this.orderId});

  final String orderId;

  Future<String?> _askRejectReason(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Berikan alasan agar pelanggan memahami penolakan pesanan.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Contoh: stok habis / kapasitas penuh',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.length < 3) return;
              Navigator.pop(context, value);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Tolak Pesanan'),
          ),
        ],
      ),
    );
    controller.dispose();
    return reason;
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, Order order) async {
    final reason = await _askRejectReason(context);
    if (reason == null || !context.mounted) return;
    ref
        .read(ordersProvider.notifier)
        .updateStatus(
          order.id,
          OrderStatus.rejected,
          rejectionReason: reason,
          note: 'Ditolak admin: $reason',
        );
    showAppSnack(context, 'Pesanan ditolak.');
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, Order order) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Batalkan pesanan?',
      message: 'Pesanan ${order.orderNumber} akan ditandai dibatalkan.',
      confirmLabel: 'Batalkan Pesanan',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    ref
        .read(ordersProvider.notifier)
        .updateStatus(
          order.id,
          OrderStatus.cancelled,
          note: 'Dibatalkan oleh admin.',
        );
    showAppSnack(context, 'Pesanan dibatalkan.');
  }

  Future<void> _assignCourier(
    BuildContext context,
    WidgetRef ref,
    Order order,
  ) async {
    final couriers = ref
        .read(couriersProvider)
        .where((courier) => courier.active && courier.available)
        .toList();
    if (couriers.isEmpty) {
      showAppSnack(
        context,
        'Tidak ada kurir yang tersedia. Atur ketersediaan kurir terlebih dahulu.',
        error: true,
      );
      return;
    }
    final selected = await showKedaiSheet<Courier>(
      context: context,
      isScrollControlled: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tugaskan Kurir',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih kurir internal yang akan mengantar pesanan ini.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            for (final courier in couriers) ...[
              AppCard(
                padding: const EdgeInsets.all(12),
                onTap: () => Navigator.pop(context, courier),
                child: Row(
                  children: [
                    AppAvatar(name: courier.name, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courier.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            courier.phone,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
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
    if (selected == null || !context.mounted) return;
    ref
        .read(ordersProvider.notifier)
        .updateStatus(
          order.id,
          OrderStatus.outForDelivery,
          courier: selected,
          note: 'Diserahkan ke kurir ${selected.name}.',
        );
    showAppSnack(context, 'Pesanan ditugaskan ke ${selected.name}.');
  }

  Future<void> _verifyPayment(
    BuildContext context,
    WidgetRef ref,
    Order order,
    bool approved,
  ) async {
    final confirmed = await confirmDialog(
      context,
      title: approved ? 'Verifikasi pembayaran?' : 'Tolak bukti pembayaran?',
      message: approved
          ? 'Pembayaran ${order.orderNumber} akan ditandai lunas.'
          : 'Pelanggan perlu mengunggah ulang bukti pembayaran.',
      confirmLabel: approved ? 'Ya, Verifikasi' : 'Tolak Bukti',
      destructive: !approved,
    );
    if (!confirmed || !context.mounted) return;
    ref.read(ordersProvider.notifier).verifyPayment(order.id, approved);
    showAppSnack(
      context,
      approved ? 'Pembayaran diverifikasi.' : 'Bukti pembayaran ditolak.',
    );
  }

  void _showProof(BuildContext context, String path) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: localImage(
                path,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Bukti pembayaran tidak dapat dimuat.'),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref
        .watch(ordersProvider)
        .where((item) => item.id == orderId)
        .firstOrNull;
    final settings = ref.watch(settingsProvider);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Pesanan tidak ditemukan',
          actionLabel: 'Kembali',
          onAction: () => context.go('/admin/orders'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        leading: IconButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin/orders'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          if (!order.status.isFinished)
            TextButton(
              onPressed: () => _cancel(context, ref, order),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Batalkan', style: TextStyle(fontSize: 12)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: _ActionBar(
        order: order,
        onAccept: () => ref
            .read(ordersProvider.notifier)
            .updateStatus(
              order.id,
              OrderStatus.confirmed,
              note: 'Pesanan diterima admin.',
            ),
        onReject: () => _reject(context, ref, order),
        onStartPreparing: () => ref
            .read(ordersProvider.notifier)
            .updateStatus(
              order.id,
              OrderStatus.preparing,
              note: 'Pesanan mulai diproses.',
            ),
        onReady: () => ref
            .read(ordersProvider.notifier)
            .updateStatus(
              order.id,
              OrderStatus.readyForPickup,
              note: 'Pesanan siap diambil.',
            ),
        onAssignCourier: () => _assignCourier(context, ref, order),
        onComplete: () => ref
            .read(ordersProvider.notifier)
            .updateStatus(
              order.id,
              OrderStatus.completed,
              note: 'Pesanan diselesaikan.',
            ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          _OrderHero(order: order),
          if ((order.rejectionReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Alasan penolakan: ${order.rejectionReason}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const SectionHeader(eyebrow: 'Pelanggan', title: 'Informasi Pesanan'),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    AppAvatar(name: order.customerName, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            order.customerPhone,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconCircleButton(
                      icon: Icons.phone_outlined,
                      size: 38,
                      background: AppColors.beigeSoft,
                      foreground: AppColors.terracottaDark,
                      onTap: () => showAppSnack(
                        context,
                        'Nomor pelanggan: ${order.customerPhone}',
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22),
                InfoRow(
                  icon: Icons.storefront_outlined,
                  label: 'Layanan',
                  value: order.serviceType.label,
                ),
                if (order.tableCode != null)
                  InfoRow(
                    icon: Icons.table_restaurant_outlined,
                    label: 'Meja',
                    value: order.tableCode!,
                  ),
                if (order.addressText != null)
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat',
                    value: order.addressText!,
                  ),
                if (order.zoneName != null)
                  InfoRow(
                    icon: Icons.map_outlined,
                    label: 'Zona',
                    value: order.zoneName!,
                  ),
                if (order.courierName != null)
                  InfoRow(
                    icon: Icons.delivery_dining_outlined,
                    label: 'Kurir',
                    value: order.courierName!,
                  ),
                if (order.note.isNotEmpty)
                  InfoRow(
                    icon: Icons.edit_note_rounded,
                    label: 'Catatan',
                    value: order.note,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(
            eyebrow: 'Rincian menu',
            title: 'Item Pesanan',
            subtitle: '${order.itemCount} item',
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                for (var i = 0; i < order.items.length; i++) ...[
                  if (i > 0) const Divider(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductImage(
                        path: order.items[i].image,
                        emoji: order.items[i].emoji,
                        size: 48,
                        radius: 12,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.items[i].name,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (order.items[i].variantName != null)
                              Text(
                                order.items[i].variantName!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (order.items[i].note.isNotEmpty)
                              Text(
                                'Catatan: ${order.items[i].note}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.items[i].qty} × ${rupiah(order.items[i].unitPrice)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        rupiah(order.items[i].lineTotal),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(
            eyebrow: 'Keuangan',
            title: 'Pembayaran',
            subtitle: 'Verifikasi manual oleh admin',
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.beigeSoft,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        switch (order.paymentMethod) {
                          PaymentMethod.cash => Icons.payments_outlined,
                          PaymentMethod.transfer =>
                            Icons.account_balance_outlined,
                          PaymentMethod.qris => Icons.qr_code_2_rounded,
                        },
                        size: 18,
                        color: AppColors.terracottaDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.paymentMethod.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            order.paymentMethod.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    PaymentStatusBadge(status: order.paymentStatus),
                  ],
                ),
                const SizedBox(height: 6),
                MoneyRow(label: 'Jumlah tagihan', value: order.total),
                if (order.paymentMethod == PaymentMethod.transfer) ...[
                  const Divider(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Transfer ke ${settings.bankName} ${settings.bankNumber} a.n. ${settings.bankHolder}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownSoft,
                      ),
                    ),
                  ),
                ],
                if (order.paymentMethod.needsProof) ...[
                  const SizedBox(height: 12),
                  Text(
                    'BUKTI PEMBAYARAN',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 7),
                  if (order.paymentProofPath == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Pelanggan belum mengunggah bukti pembayaran.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => _showProof(context, order.paymentProofPath!),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: localImage(
                              order.paymentProofPath!,
                              width: double.infinity,
                              height: 170,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                height: 110,
                                width: double.infinity,
                                color: AppColors.beigeSoft,
                                alignment: Alignment.center,
                                child: const Text('Bukti tidak dapat dimuat'),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.espresso.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.zoom_out_map_rounded,
                                  size: 12,
                                  color: AppColors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Perbesar',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
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
                if (order.paymentStatus ==
                    PaymentStatus.waitingVerification) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Tolak',
                          variant: AppButtonVariant.secondary,
                          compact: true,
                          onPressed: () =>
                              _verifyPayment(context, ref, order, false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          label: 'Verifikasi Pembayaran',
                          compact: true,
                          icon: Icons.verified_outlined,
                          onPressed: () =>
                              _verifyPayment(context, ref, order, true),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(eyebrow: 'Ringkasan', title: 'Rincian Biaya'),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                MoneyRow(label: 'Subtotal', value: order.subtotal),
                MoneyRow(label: 'Biaya pengiriman', value: order.deliveryFee),
                const Divider(height: 18),
                MoneyRow(
                  label: 'Total pembayaran',
                  value: order.total,
                  emphasize: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(
            eyebrow: 'Jejak pesanan',
            title: 'Riwayat Status',
          ),
          const SizedBox(height: 10),
          AppCard(child: StatusTimeline(order: order)),
        ],
      ),
    );
  }
}

class _OrderHero extends StatelessWidget {
  const _OrderHero({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final visual = statusVisual(order.status);
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
              top: -70,
              child: Container(
                width: 170,
                height: 170,
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
              bottom: -50,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.terracotta.withValues(alpha: 0.16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'PESANAN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                          color: AppColors.gold.withValues(alpha: 0.95),
                        ),
                      ),
                      const Spacer(),
                      AppBadge(
                        label: order.status.label,
                        background: visual.color.withValues(alpha: 0.22),
                        foreground: visual.background,
                        compact: true,
                        dot: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 21,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.serviceType.label} • ${formatDateTime(order.createdAt)}',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL PESANAN',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: Colors.white.withValues(alpha: 0.42),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              rupiah(order.total),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 27,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.8,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppBadge(
                        label: order.paymentStatus.label,
                        background: Colors.white.withValues(alpha: 0.08),
                        foreground: Colors.white.withValues(alpha: 0.75),
                        compact: true,
                        icon: Icons.payments_outlined,
                      ),
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

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onStartPreparing,
    required this.onReady,
    required this.onAssignCourier,
    required this.onComplete,
  });

  final Order order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onStartPreparing;
  final VoidCallback onReady;
  final VoidCallback onAssignCourier;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final (primaryLabel, primaryIcon, primaryAction) = switch (order.status) {
      OrderStatus.pendingConfirmation => (
        'Terima Pesanan',
        Icons.check_rounded,
        onAccept,
      ),
      OrderStatus.confirmed => (
        'Mulai Proses',
        Icons.soup_kitchen_outlined,
        onStartPreparing,
      ),
      OrderStatus.preparing =>
        order.serviceType == ServiceType.delivery
            ? (
                'Serahkan ke Kurir',
                Icons.delivery_dining_rounded,
                onAssignCourier,
              )
            : ('Tandai Siap Diambil', Icons.shopping_bag_outlined, onReady),
      OrderStatus.readyForPickup || OrderStatus.outForDelivery => (
        'Selesaikan Pesanan',
        Icons.task_alt_rounded,
        onComplete,
      ),
      OrderStatus.completed ||
      OrderStatus.rejected ||
      OrderStatus.cancelled => (null, null, null),
    };

    final secondary = switch (order.status) {
      OrderStatus.pendingConfirmation => ('Tolak', onReject),
      _ => (null, null),
    };

    if (primaryLabel == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: AppShadows.float,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (secondary.$1 != null) ...[
              Expanded(
                child: AppButton(
                  label: secondary.$1!,
                  variant: AppButtonVariant.secondary,
                  compact: true,
                  onPressed: secondary.$2,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              flex: secondary.$1 != null ? 2 : 1,
              child: AppButton(
                label: primaryLabel,
                icon: primaryIcon,
                compact: true,
                onPressed: primaryAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
