import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

class AdminDeliveryPage extends ConsumerStatefulWidget {
  const AdminDeliveryPage({super.key});

  @override
  ConsumerState<AdminDeliveryPage> createState() => _AdminDeliveryPageState();
}

class _AdminDeliveryPageState extends ConsumerState<AdminDeliveryPage> {
  int _tab = 0;

  Future<void> _editZone({DeliveryZone? zone}) async {
    final nameController = TextEditingController(text: zone?.name ?? '');
    final feeController = TextEditingController(
      text: (zone?.fee ?? 0) == 0 ? '' : '${zone!.fee}',
    );
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(zone == null ? 'Zona Baru' : 'Edit Zona'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama zona',
                  hintText: 'Contoh: Dalam Kota (2-7 km)',
                  prefixIcon: Icon(Icons.map_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: feeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Tarif pengiriman',
                  prefixText: 'Rp ',
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    error!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  setDialogState(() => error = 'Nama zona wajib diisi');
                  return;
                }
                final fee = int.tryParse(feeController.text);
                if (fee == null || fee <= 0) {
                  setDialogState(() => error = 'Tarif harus lebih dari 0');
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      ref
          .read(zonesProvider.notifier)
          .saveZone(
            DeliveryZone(
              id: zone?.id ?? newId('zone'),
              name: nameController.text.trim(),
              fee: int.parse(feeController.text),
              active: zone?.active ?? true,
            ),
          );
      showAppSnack(context, 'Zona pengiriman disimpan.');
    }
    nameController.dispose();
    feeController.dispose();
  }

  Future<void> _deleteZone(DeliveryZone zone) async {
    final used = ref
        .read(localStoreProvider)
        .addresses
        .where((address) => address.zoneId == zone.id)
        .length;
    if (used > 0) {
      showAppSnack(
        context,
        'Zona masih dipakai oleh $used alamat pelanggan. Nonaktifkan saja jika tidak digunakan.',
        error: true,
      );
      return;
    }
    final confirmed = await confirmDialog(
      context,
      title: 'Hapus zona?',
      message: 'Zona "${zone.name}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (confirmed) {
      ref.read(zonesProvider.notifier).deleteZone(zone.id);
      if (mounted) showAppSnack(context, 'Zona dihapus.');
    }
  }

  Future<void> _editCourier({Courier? courier}) async {
    final nameController = TextEditingController(text: courier?.name ?? '');
    final phoneController = TextEditingController(text: courier?.phone ?? '');
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(courier == null ? 'Kurir Baru' : 'Edit Kurir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama kurir',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor HP',
                  prefixText: '08',
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    error!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  setDialogState(() => error = 'Nama kurir wajib diisi');
                  return;
                }
                if (phoneController.text.trim().length < 8) {
                  setDialogState(() => error = 'Nomor HP tidak valid');
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      ref
          .read(couriersProvider.notifier)
          .saveCourier(
            Courier(
              id: courier?.id ?? newId('courier'),
              name: nameController.text.trim(),
              phone: phoneController.text.trim(),
              active: courier?.active ?? true,
              available: courier?.available ?? true,
            ),
          );
      showAppSnack(context, 'Data kurir disimpan.');
    }
    nameController.dispose();
    phoneController.dispose();
  }

  Future<void> _deleteCourier(Courier courier) async {
    final activeOrders = ref
        .read(ordersProvider)
        .where(
          (order) => order.courierId == courier.id && !order.status.isFinished,
        )
        .length;
    if (activeOrders > 0) {
      showAppSnack(
        context,
        'Kurir masih menangani $activeOrders pesanan aktif.',
        error: true,
      );
      return;
    }
    final confirmed = await confirmDialog(
      context,
      title: 'Hapus kurir?',
      message: 'Data kurir "${courier.name}" akan dihapus.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (confirmed) {
      ref.read(couriersProvider.notifier).deleteCourier(courier.id);
      if (mounted) showAppSnack(context, 'Kurir dihapus.');
    }
  }

  Future<void> _editTable({TableSpot? table}) async {
    final codeController = TextEditingController(text: table?.code ?? '');
    final labelController = TextEditingController(text: table?.label ?? '');
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(table == null ? 'Meja Baru' : 'Edit Meja'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Kode meja',
                  hintText: 'Contoh: A1',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Label meja',
                  hintText: 'Contoh: Meja A1',
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    error!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final code = codeController.text.trim().toUpperCase();
                if (code.isEmpty) {
                  setDialogState(() => error = 'Kode meja wajib diisi');
                  return;
                }
                final duplicate = ref
                    .read(tablesProvider)
                    .any(
                      (item) =>
                          item.code.toUpperCase() == code &&
                          item.id != table?.id,
                    );
                if (duplicate) {
                  setDialogState(() => error = 'Kode meja sudah digunakan');
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      ref
          .read(tablesProvider.notifier)
          .saveTable(
            TableSpot(
              id: table?.id ?? newId('table'),
              code: codeController.text.trim().toUpperCase(),
              label: labelController.text.trim().isEmpty
                  ? 'Meja ${codeController.text.trim().toUpperCase()}'
                  : labelController.text.trim(),
              active: table?.active ?? true,
            ),
          );
      showAppSnack(context, 'Meja disimpan.');
    }
    codeController.dispose();
    labelController.dispose();
  }

  Future<void> _deleteTable(TableSpot table) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Hapus meja?',
      message: 'Meja ${table.code} akan dihapus.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (confirmed) {
      ref.read(tablesProvider.notifier).deleteTable(table.id);
      if (mounted) showAppSnack(context, 'Meja dihapus.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesProvider);
    final couriers = ref.watch(couriersProvider);
    final tables = ref.watch(tablesProvider);
    final availableCouriers = couriers
        .where((courier) => courier.active && courier.available)
        .length;
    final activeTables = tables.where((table) => table.active).length;

    final addLabel = switch (_tab) {
      0 => 'Tambah Zona',
      1 => 'Tambah Kurir',
      _ => 'Tambah Meja',
    };
    final addAction = switch (_tab) {
      0 => () => _editZone(),
      1 => () => _editCourier(),
      _ => () => _editTable(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengiriman & Meja'),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                color: AppColors.espresso,
                borderColor: AppColors.espresso,
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryStat(
                        label: 'Zona aktif',
                        value: '${zones.where((zone) => zone.active).length}',
                      ),
                    ),
                    _SummaryDivider(),
                    Expanded(
                      child: _SummaryStat(
                        label: 'Kurir siap',
                        value: '$availableCouriers',
                      ),
                    ),
                    _SummaryDivider(),
                    Expanded(
                      child: _SummaryStat(
                        label: 'Meja aktif',
                        value: '$activeTables',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _TabPill(
                      label: 'Zona',
                      icon: Icons.map_outlined,
                      selected: _tab == 0,
                      onTap: () => setState(() => _tab = 0),
                    ),
                    _TabPill(
                      label: 'Kurir',
                      icon: Icons.delivery_dining_outlined,
                      selected: _tab == 1,
                      onTap: () => setState(() => _tab = 1),
                    ),
                    _TabPill(
                      label: 'Meja',
                      icon: Icons.table_restaurant_outlined,
                      selected: _tab == 2,
                      onTap: () => setState(() => _tab = 2),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    switch (_tab) {
                      0 => '${zones.length} zona pengiriman',
                      1 => '${couriers.length} kurir internal',
                      _ => '${tables.length} meja dine-in',
                    },
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownSoft,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: addAction,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(
                      addLabel,
                      style: const TextStyle(fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (_tab) {
                0 => _buildZones(zones),
                1 => _buildCouriers(couriers),
                _ => _buildTables(tables),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZones(List<DeliveryZone> zones) {
    if (zones.isEmpty) {
      return EmptyState(
        icon: Icons.map_outlined,
        eyebrow: 'Area pengiriman',
        title: 'Belum ada zona',
        message:
            'Tambahkan zona dan tarif agar pelanggan dapat memilih delivery.',
        actionLabel: 'Tambah Zona',
        onAction: () => _editZone(),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      itemCount: zones.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final zone = zones[index];
        return Reveal(
          index: index,
          offset: 0.03,
          child: AppCard(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: zone.active
                        ? AppColors.terracottaSoft
                        : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    size: 20,
                    color: zone.active ? AppColors.terracotta : AppColors.muted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brown,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Tarif ${rupiah(zone.fee)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: zone.active,
                  onChanged: (value) => ref
                      .read(zonesProvider.notifier)
                      .saveZone(zone.copyWith(active: value)),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: AppColors.muted,
                  ),
                  onSelected: (value) => value == 'edit'
                      ? _editZone(zone: zone)
                      : _deleteZone(zone),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit zona')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Hapus zona',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCouriers(List<Courier> couriers) {
    if (couriers.isEmpty) {
      return EmptyState(
        icon: Icons.delivery_dining_outlined,
        eyebrow: 'Tim pengantar',
        title: 'Belum ada kurir',
        message: 'Tambahkan kurir internal untuk mengantar pesanan delivery.',
        actionLabel: 'Tambah Kurir',
        onAction: () => _editCourier(),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      itemCount: couriers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final courier = couriers[index];
        return Reveal(
          index: index,
          offset: 0.03,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppAvatar(name: courier.name, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courier.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brown,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            courier.phone,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: AppColors.muted,
                      ),
                      onSelected: (value) => value == 'edit'
                          ? _editCourier(courier: courier)
                          : _deleteCourier(courier),
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit kurir')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Hapus kurir',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TogglePill(
                      label: courier.active ? 'Aktif' : 'Nonaktif',
                      active: courier.active,
                      onTap: () => ref
                          .read(couriersProvider.notifier)
                          .saveCourier(
                            courier.copyWith(active: !courier.active),
                          ),
                    ),
                    _TogglePill(
                      label: courier.available ? 'Siap antar' : 'Sedang sibuk',
                      active: courier.available,
                      onTap: () => ref
                          .read(couriersProvider.notifier)
                          .saveCourier(
                            courier.copyWith(available: !courier.available),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTables(List<TableSpot> tables) {
    if (tables.isEmpty) {
      return EmptyState(
        icon: Icons.table_restaurant_outlined,
        eyebrow: 'Layanan dine-in',
        title: 'Belum ada meja',
        message: 'Tambahkan identitas meja untuk layanan dine-in.',
        actionLabel: 'Tambah Meja',
        onAction: () => _editTable(),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      itemCount: tables.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final table = tables[index];
        return Reveal(
          index: index,
          offset: 0.03,
          child: AppCard(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: table.active
                        ? AppColors.beigeSoft
                        : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    table.code,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: table.active
                          ? AppColors.terracotta
                          : AppColors.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    table.label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brown,
                    ),
                  ),
                ),
                Switch(
                  value: table.active,
                  onChanged: (value) => ref
                      .read(tablesProvider.notifier)
                      .saveTable(
                        TableSpot(
                          id: table.id,
                          code: table.code,
                          label: table.label,
                          active: value,
                        ),
                      ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: AppColors.muted,
                  ),
                  onSelected: (value) => value == 'edit'
                      ? _editTable(table: table)
                      : _deleteTable(table),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit meja')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Hapus meja',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.standard,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.espresso : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? AppColors.white : AppColors.muted,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.white : AppColors.brownSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.successSoft : AppColors.beigeSoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active
                  ? Icons.check_circle_rounded
                  : Icons.pause_circle_outline_rounded,
              size: 14,
              color: active ? AppColors.success : AppColors.muted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.success : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
