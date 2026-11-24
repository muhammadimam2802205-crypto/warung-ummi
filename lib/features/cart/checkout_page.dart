import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion/page_transitions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/pricing.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final TextEditingController _tableController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  ServiceType _serviceType = ServiceType.takeaway;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  Address? _selectedAddress;
  DeliveryZone? _selectedZone;
  bool _placing = false;

  @override
  void dispose() {
    _tableController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showError(String message) =>
      showAppSnack(context, message, error: true);

  Future<void> _pickTable() async {
    final tables = ref
        .read(tablesProvider)
        .where((table) => table.active)
        .toList();
    final selected = await showKedaiSheet<String>(
      context: context,
      isScrollControlled: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Meja', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Pilih nomor meja sesuai QR Code yang terpasang di meja Anda.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (tables.isEmpty)
              const Text('Belum ada meja aktif.')
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final table in tables)
                    SizedBox(
                      width: (MediaQuery.sizeOf(context).width - 60) / 2,
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        onTap: () => Navigator.pop(context, table.code),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.beigeSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.table_restaurant_rounded,
                                size: 17,
                                color: AppColors.terracotta,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    table.label,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    table.code,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      _tableController.text = selected;
      setState(() {});
    }
  }

  Future<void> _pickAddress(List<Address> addresses) async {
    if (addresses.isEmpty) {
      await context.push('/addresses');
      return;
    }
    final selected = await showKedaiSheet<Address>(
      context: context,
      isScrollControlled: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pilih Alamat',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) this.context.push('/addresses');
                  },
                  child: const Text('Kelola'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final address in addresses) ...[
              AppCard(
                padding: const EdgeInsets.all(12),
                onTap: () => Navigator.pop(context, address),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.terracotta,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            address.detail,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (address.isPrimary)
                      const AppBadge(
                        label: 'Utama',
                        background: AppColors.beige,
                        foreground: AppColors.terracottaDark,
                        compact: true,
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
    if (selected != null) {
      setState(() {
        _selectedAddress = selected;
        _selectedZone = null;
      });
    }
  }

  String? _validate(
    StoreSettings settings,
    DeliveryZone? zone,
    Address? address,
  ) {
    if (!settings.isOpen) {
      return 'Kedai sedang tutup. Silakan coba lagi saat kedai buka.';
    }
    if (_serviceType == ServiceType.dineIn) {
      final code = _tableController.text.trim().toUpperCase();
      if (code.isEmpty) return 'Masukkan kode meja Anda terlebih dahulu.';
      if (ref.read(tablesProvider.notifier).byCode(code) == null) {
        return 'Kode meja "$code" tidak valid. Periksa kembali QR meja Anda.';
      }
    }
    if (_serviceType == ServiceType.delivery) {
      if (!settings.deliveryEnabled) {
        return 'Layanan delivery sedang tidak tersedia.';
      }
      if (_selectedAddress == null && address == null) {
        return 'Pilih alamat pengiriman terlebih dahulu.';
      }
      if (zone == null) return 'Zona pengiriman belum tersedia.';
    }
    for (final item in ref.read(cartProvider)) {
      final product = ref.read(productsProvider.notifier).byId(item.productId);
      if (product == null || !product.available) {
        return '${item.name} sedang tidak tersedia. Hapus dari keranjang terlebih dahulu.';
      }
    }
    return null;
  }

  void _placeOrder(
    StoreSettings settings,
    DeliveryZone? zone,
    Address? address,
  ) {
    final error = _validate(settings, zone, address);
    if (error != null) {
      _showError(error);
      return;
    }
    final user = ref.read(authProvider);
    if (user == null) {
      _showError('Sesi berakhir. Silakan masuk kembali.');
      return;
    }

    setState(() => _placing = true);
    final deliveryAddress = _serviceType == ServiceType.delivery
        ? address
        : null;
    final order = ref
        .read(ordersProvider.notifier)
        .createOrder(
          user: user,
          items: ref.read(cartProvider),
          serviceType: _serviceType,
          paymentMethod: _paymentMethod,
          note: _noteController.text.trim(),
          tableCode: _serviceType == ServiceType.dineIn
              ? _tableController.text.trim().toUpperCase()
              : null,
          addressText: deliveryAddress == null
              ? null
              : '${deliveryAddress.label} • ${deliveryAddress.detail}',
          zone: _serviceType == ServiceType.delivery ? zone : null,
        );
    ref.read(cartProvider.notifier).clear();
    if (!mounted) return;
    showAppSnack(context, 'Pesanan ${order.orderNumber} berhasil dibuat.');
    context.go('/orders/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final settings = ref.watch(settingsProvider);
    final addresses = ref.watch(addressesProvider);
    final activeZones = ref
        .watch(zonesProvider)
        .where((zone) => zone.active)
        .toList();

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Tidak ada item untuk checkout',
          message: 'Tambahkan menu ke keranjang terlebih dahulu.',
          actionLabel: 'Lihat Menu',
          onAction: () => context.go('/menu'),
        ),
      );
    }

    final address = _selectedAddress ?? addresses.firstOrNull;
    DeliveryZone? zone = _selectedZone;
    if (zone == null && address != null) {
      zone = activeZones.where((item) => item.id == address.zoneId).firstOrNull;
    }
    zone ??= activeZones.firstOrNull;

    final deliveryFee = deliveryFeeFor(_serviceType, zone);
    final total = cartSubtotal(items) + deliveryFee;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Row(
              children: [
                IconCircleButton(
                  icon: Icons.arrow_back_rounded,
                  size: 40,
                  onTap: () => context.pop(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LANGKAH TERAKHIR',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.terracotta,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Checkout',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                AppBadge(
                  label: '${items.length} menu',
                  background: AppColors.beigeSoft,
                  foreground: AppColors.brownSoft,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const SectionHeader(
              eyebrow: 'Cara menikmati',
              title: 'Jenis Layanan',
              subtitle: 'Pilih bagaimana pesanan Anda dinikmati',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final type in ServiceType.values) ...[
                  Expanded(
                    child: _ServiceCard(
                      type: type,
                      selected: _serviceType == type,
                      enabled:
                          type != ServiceType.delivery ||
                          settings.deliveryEnabled,
                      onTap: () => setState(() => _serviceType = type),
                    ),
                  ),
                  if (type != ServiceType.values.last) const SizedBox(width: 8),
                ],
              ],
            ),
            if (_serviceType == ServiceType.dineIn) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.beigeSoft,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.table_restaurant_outlined,
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
                                'Identitas Meja',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Masukkan kode dari QR Code di meja Anda.',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tableController,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z0-9]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              hintText: 'Contoh: A1',
                              prefixIcon: Icon(Icons.qr_code_rounded, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: _pickTable,
                            icon: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 17,
                            ),
                            label: const Text('Pilih'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (_serviceType == ServiceType.delivery) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.beigeSoft,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: AppColors.terracottaDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Alamat Pengiriman',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _pickAddress(addresses),
                          child: Text(address == null ? 'Tambah' : 'Ubah'),
                        ),
                      ],
                    ),
                    if (address == null)
                      Text(
                        'Belum ada alamat. Tambahkan alamat pengiriman Anda.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
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
                              '${address.label} • ${address.recipient}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              address.detail,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                            Text(
                              address.phone,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey(zone?.id ?? 'zone-empty'),
                      initialValue: zone?.id,
                      decoration: const InputDecoration(
                        labelText: 'Zona pengiriman',
                        prefixIcon: Icon(Icons.map_outlined, size: 20),
                      ),
                      items: [
                        for (final item in activeZones)
                          DropdownMenuItem(
                            value: item.id,
                            child: Text(
                              '${item.name} • ${rupiah(item.fee)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedZone = activeZones
                              .where((item) => item.id == value)
                              .firstOrNull;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            const SectionHeader(
              eyebrow: 'Aman & terverifikasi',
              title: 'Metode Pembayaran',
              subtitle: 'Pembayaran diverifikasi manual oleh admin',
            ),
            const SizedBox(height: 12),
            for (final method in PaymentMethod.values) ...[
              _PaymentTile(
                method: method,
                selected: _paymentMethod == method,
                onTap: () => setState(() => _paymentMethod = method),
              ),
              if (_paymentMethod == method) ...[
                if (method == PaymentMethod.transfer)
                  _PaymentNote(
                    icon: Icons.account_balance_outlined,
                    lines: [
                      '${settings.bankName} • ${settings.bankNumber}',
                      'a.n. ${settings.bankHolder}',
                      'Unggah bukti transfer setelah pesanan dibuat.',
                    ],
                  ),
                if (method == PaymentMethod.qris)
                  _PaymentNote(
                    icon: Icons.qr_code_2_rounded,
                    lines: [settings.qrisNote],
                  ),
                if (method == PaymentMethod.cash)
                  const _PaymentNote(
                    icon: Icons.storefront_outlined,
                    lines: [
                      'Pembayaran dilakukan langsung di kedai sesuai proses operasional.',
                    ],
                  ),
              ],
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            AppTextField(
              controller: _noteController,
              hint: 'Catatan pesanan (opsional)',
              icon: Icons.edit_note_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Ringkasan Pesanan',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      AppBadge(
                        label: '${items.length} menu',
                        background: AppColors.beigeSoft,
                        foreground: AppColors.brownSoft,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final item in items.take(3))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text(
                            '${item.qty}x',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.terracotta,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.brownSoft,
                              ),
                            ),
                          ),
                          Text(
                            rupiah(item.lineTotal),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brownSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (items.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+ ${items.length - 3} menu lainnya',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                      ),
                    ),
                  const Divider(height: 20),
                  MoneyRow(label: 'Subtotal', value: subtotal),
                  MoneyRow(label: 'Biaya pengiriman', value: deliveryFee),
                  const Divider(height: 18),
                  MoneyRow(
                    label: 'Total Pembayaran',
                    value: total,
                    emphasize: true,
                    valueColor: AppColors.terracottaDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1438251D),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                ),
                AnimatedRupiah(
                  value: total,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.brown,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                label: settings.isOpen ? 'Buat Pesanan' : 'Kedai Tutup',
                icon: Icons.check_circle_outline_rounded,
                loading: _placing,
                onPressed: settings.isOpen
                    ? () => _placeOrder(settings, zone, address)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.type,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final ServiceType type;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      ServiceType.dineIn => Icons.table_restaurant_outlined,
      ServiceType.takeaway => Icons.shopping_bag_outlined,
      ServiceType.delivery => Icons.delivery_dining_outlined,
    };
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: PressScale(
        child: Material(
          color: selected ? AppColors.espresso : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? AppColors.espresso : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 23,
                    color: selected ? AppColors.gold : AppColors.terracotta,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.white : AppColors.brown,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type.description,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5,
                      color: selected
                          ? AppColors.white.withValues(alpha: 0.6)
                          : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (method) {
      PaymentMethod.cash => Icons.payments_outlined,
      PaymentMethod.transfer => Icons.account_balance_outlined,
      PaymentMethod.qris => Icons.qr_code_2_rounded,
    };
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      onTap: onTap,
      shadow: false,
      borderColor: selected ? AppColors.terracotta : AppColors.border,
      color: selected ? AppColors.terracottaSoft : AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: selected ? AppColors.surface : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: selected ? AppColors.terracotta : AppColors.border,
              ),
            ),
            child: Icon(icon, size: 19, color: AppColors.terracottaDark),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  method.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: AppMotion.fast,
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: selected ? AppColors.terracotta : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.terracotta : AppColors.borderStrong,
                width: 1.5,
              ),
            ),
            child: selected
                ? const Icon(
                    Icons.check_rounded,
                    size: 13,
                    color: AppColors.white,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _PaymentNote extends StatelessWidget {
  const _PaymentNote({required this.icon, required this.lines});

  final IconData icon;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6, bottom: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.terracotta),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.brownSoft,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
