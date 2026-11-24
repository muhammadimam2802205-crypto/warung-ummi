import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/local_image.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  bool _uploading = false;

  Future<void> _uploadProof(Order order) async {
    setState(() => _uploading = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1600,
      );
      if (picked == null) return;
      ref
          .read(ordersProvider.notifier)
          .submitPaymentProof(order.id, picked.path);
      if (!mounted) return;
      showAppSnack(
        context,
        'Bukti pembayaran diunggah. Menunggu verifikasi admin.',
      );
    } catch (error) {
      if (!mounted) return;
      showAppSnack(
        context,
        'Gagal mengambil gambar. Pastikan izin galeri diberikan.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showProof(String path) {
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

  Future<void> _cancelOrder(Order order) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Batalkan pesanan?',
      message:
          'Pesanan ${order.orderNumber} akan dibatalkan. Tindakan ini tidak dapat diurungkan.',
      confirmLabel: 'Batalkan Pesanan',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    ref.read(ordersProvider.notifier).cancelByCustomer(order.id);
    showAppSnack(context, 'Pesanan dibatalkan.');
  }

  void _copy(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    showAppSnack(context, '$label disalin.');
  }

  @override
  Widget build(BuildContext context) {
    final order = ref
        .watch(ordersProvider)
        .where((item) => item.id == widget.orderId)
        .firstOrNull;
    final user = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);

    if (order == null || user == null || order.userId != user.id) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Pesanan tidak ditemukan',
          message: 'Pesanan mungkin sudah tidak tersedia.',
          actionLabel: 'Lihat Pesanan',
          onAction: () => context.go('/orders'),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            Row(
              children: [
                IconCircleButton(
                  icon: Icons.arrow_back_rounded,
                  size: 40,
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go('/orders'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DETAIL PESANAN',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.terracotta,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.orderNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
                PaymentStatusBadge(status: order.paymentStatus, compact: true),
              ],
            ),
            const SizedBox(height: 16),
            _StatusHero(order: order),
            if (order.status == OrderStatus.rejected &&
                (order.rejectionReason ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Alasan penolakan: ${order.rejectionReason}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!order.status.isFinished ||
                order.status == OrderStatus.completed) ...[
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Progres Pesanan',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brown,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'LIVE',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.success,
                                letterSpacing: 1.4,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OrderProgressRail(order: order),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            const SectionHeader(eyebrow: 'Rincian', title: 'Informasi Pesanan'),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.storefront_outlined,
                    label: 'Jenis layanan',
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
                      label: 'Zona pengiriman',
                      value: order.zoneName!,
                    ),
                  if (order.courierName != null)
                    InfoRow(
                      icon: Icons.delivery_dining_outlined,
                      label: 'Kurir',
                      value: order.courierName!,
                    ),
                  InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Nomor HP',
                    value: order.customerPhone,
                  ),
                  InfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'Waktu pesan',
                    value: formatDateTime(order.createdAt),
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
            const SizedBox(height: 22),
            SectionHeader(
              eyebrow: 'Yang kamu pesan',
              title: 'Detail Menu',
              subtitle: '${order.itemCount} item dipesan',
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  for (var i = 0; i < order.items.length; i++) ...[
                    if (i > 0) const Divider(height: 18),
                    _OrderItemRow(item: order.items[i]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            SectionHeader(
              eyebrow: 'Verifikasi manual',
              title: 'Pembayaran',
              subtitle: order.paymentMethod.label,
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.beigeSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          switch (order.paymentMethod) {
                            PaymentMethod.cash => Icons.payments_outlined,
                            PaymentMethod.transfer =>
                              Icons.account_balance_outlined,
                            PaymentMethod.qris => Icons.qr_code_2_rounded,
                          },
                          size: 20,
                          color: AppColors.terracottaDark,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.paymentMethod.label,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              order.paymentMethod.description,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      PaymentStatusBadge(status: order.paymentStatus),
                    ],
                  ),
                  if (order.paymentMethod == PaymentMethod.transfer) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${settings.bankName} • ${settings.bankNumber}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _copy(
                                  settings.bankNumber,
                                  'Nomor rekening',
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.all(3),
                                  child: Icon(
                                    Icons.copy_rounded,
                                    size: 16,
                                    color: AppColors.terracotta,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'a.n. ${settings.bankHolder}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'Nominal: ${rupiah(order.total)}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.terracottaDark,
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => _copy('${order.total}', 'Nominal'),
                                child: const Icon(
                                  Icons.copy_rounded,
                                  size: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (order.paymentMethod == PaymentMethod.qris) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.qr_code_2_rounded,
                            size: 20,
                            color: AppColors.terracotta,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              settings.qrisNote,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (order.paymentMethod == PaymentMethod.cash) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Pembayaran tunai dicatat oleh admin sesuai proses operasional kedai.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (order.paymentProofPath != null) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => _showProof(order.paymentProofPath!),
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
                                height: 120,
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
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Lihat bukti',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (order.paymentMethod.needsProof &&
                      (order.paymentStatus == PaymentStatus.pending ||
                          order.paymentStatus == PaymentStatus.rejected)) ...[
                    const SizedBox(height: 14),
                    AppButton(
                      label: order.paymentStatus == PaymentStatus.rejected
                          ? 'Unggah Ulang Bukti'
                          : 'Unggah Bukti Pembayaran',
                      icon: Icons.upload_file_rounded,
                      loading: _uploading,
                      onPressed: () => _uploadProof(order),
                    ),
                  ],
                  if (order.paymentStatus ==
                      PaymentStatus.waitingVerification) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.infoSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.hourglass_top_rounded,
                            size: 16,
                            color: AppColors.info,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bukti pembayaran sedang menunggu verifikasi admin. Status akan berubah setelah diperiksa.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionHeader(eyebrow: 'Transparan', title: 'Rincian Biaya'),
            const SizedBox(height: 10),
            AppCard(
              color: AppColors.beigeSoft,
              borderColor: AppColors.beige,
              child: Column(
                children: [
                  MoneyRow(label: 'Subtotal', value: order.subtotal),
                  MoneyRow(label: 'Biaya pengiriman', value: order.deliveryFee),
                  const Divider(height: 18),
                  MoneyRow(
                    label: 'Total',
                    value: order.total,
                    emphasize: true,
                    valueColor: AppColors.terracottaDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionHeader(
              eyebrow: 'Perjalanan pesanan',
              title: 'Riwayat Status',
            ),
            const SizedBox(height: 10),
            AppCard(child: StatusTimeline(order: order)),
            if (order.status == OrderStatus.pendingConfirmation) ...[
              const SizedBox(height: 20),
              AppButton(
                label: 'Batalkan Pesanan',
                variant: AppButtonVariant.secondary,
                icon: Icons.close_rounded,
                onPressed: () => _cancelOrder(order),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final visual = statusVisual(order.status);
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
              right: -34,
              top: -44,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: visual.color.withValues(alpha: 0.22),
                ),
              ),
            ),
            Positioned(
              right: 36,
              bottom: -54,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: visual.color.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Icon(visual.icon, size: 22, color: visual.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.status.label,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 23,
                                height: 1.12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.status.customerHint,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.45,
                                color: Colors.white.withValues(alpha: 0.62),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: const Color(0x14FFFFFF)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _HeroChip(
                        icon: switch (order.serviceType) {
                          ServiceType.dineIn => Icons.table_restaurant_rounded,
                          ServiceType.takeaway => Icons.shopping_bag_rounded,
                          ServiceType.delivery => Icons.delivery_dining_rounded,
                        },
                        label: order.serviceType.label,
                      ),
                      _HeroChip(
                        icon: Icons.schedule_rounded,
                        label: formatDateTime(order.createdAt),
                      ),
                      if (order.tableCode != null)
                        _HeroChip(
                          icon: Icons.qr_code_rounded,
                          label: 'Meja ${order.tableCode}',
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

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.gold),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductImage(path: item.image, emoji: item.emoji, size: 48, radius: 13),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brown,
                ),
              ),
              if (item.variantName != null)
                Text(
                  item.variantName!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                ),
              if (item.note.isNotEmpty)
                Text(
                  '"${item.note}"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                '${item.qty} × ${rupiah(item.unitPrice)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rupiah(item.lineTotal),
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: AppColors.terracottaDark,
          ),
        ),
      ],
    );
  }
}
