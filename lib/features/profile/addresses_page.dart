import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/page_transitions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

class AddressesPage extends ConsumerWidget {
  const AddressesPage({super.key});

  Future<void> _openEditor(BuildContext context, {Address? address}) async {
    await showKedaiSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddressSheet(address: address),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Address address,
  ) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Hapus alamat?',
      message: 'Alamat "${address.label}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (confirmed) {
      ref.read(addressesProvider.notifier).deleteAddress(address.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    final zones = ref.watch(zonesProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Row(
                children: [
                  IconCircleButton(
                    icon: Icons.arrow_back_rounded,
                    size: 40,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DELIVERY',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.terracotta,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Alamat Pengiriman',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconCircleButton(
                    icon: Icons.add_rounded,
                    size: 40,
                    background: AppColors.espresso,
                    foreground: AppColors.white,
                    onTap: () => _openEditor(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Row(
                children: [
                  Text(
                    '${addresses.length} alamat tersimpan',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: user == null
                  ? const EmptyState(
                      icon: Icons.lock_outline_rounded,
                      title: 'Silakan masuk',
                    )
                  : addresses.isEmpty
                  ? EmptyState(
                      icon: Icons.location_off_outlined,
                      eyebrow: 'Belum ada alamat',
                      title: 'Tambahkan alamat pertamamu',
                      message:
                          'Alamat pengiriman diperlukan agar pesanan delivery dapat diantar dengan tepat.',
                      actionLabel: 'Tambah Alamat',
                      onAction: () => _openEditor(context),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: addresses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        DeliveryZone? zone;
                        for (final item in zones) {
                          if (item.id == address.zoneId) zone = item;
                        }
                        return Reveal(
                          index: index,
                          offset: 0.03,
                          child: _AddressCard(
                            address: address,
                            zone: zone,
                            onEdit: () =>
                                _openEditor(context, address: address),
                            onDelete: () => _delete(context, ref, address),
                            onSetPrimary: () => ref
                                .read(addressesProvider.notifier)
                                .saveAddress(address.copyWith(isPrimary: true)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.zone,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });

  final Address address;
  final DeliveryZone? zone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      shadow: false,
      borderColor: address.isPrimary
          ? AppColors.terracotta.withValues(alpha: 0.5)
          : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: address.isPrimary
                      ? AppColors.terracottaSoft
                      : AppColors.beigeSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  address.isPrimary
                      ? Icons.home_rounded
                      : Icons.location_on_outlined,
                  size: 19,
                  color: AppColors.terracottaDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brown,
                      ),
                    ),
                    Text(
                      '${address.recipient} • ${address.phone}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              if (address.isPrimary)
                const AppBadge(
                  label: 'Utama',
                  background: AppColors.terracottaSoft,
                  foreground: AppColors.terracottaDark,
                  compact: true,
                  icon: Icons.star_rounded,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            address.detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.5,
              color: AppColors.brownSoft,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.map_outlined,
                size: 13,
                color: zone == null ? AppColors.danger : AppColors.muted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  zone == null
                      ? 'Zona pengiriman belum ditentukan'
                      : '${zone!.name} • ${rupiah(zone!.fee)}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: zone == null ? AppColors.danger : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            children: [
              _ActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: onEdit,
              ),
              if (!address.isPrimary) ...[
                const SizedBox(width: 4),
                _ActionButton(
                  icon: Icons.star_outline_rounded,
                  label: 'Jadikan Utama',
                  onTap: onSetPrimary,
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 19,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.terracottaDark),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.terracottaDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressSheet extends ConsumerStatefulWidget {
  const _AddressSheet({this.address});

  final Address? address;

  @override
  ConsumerState<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends ConsumerState<_AddressSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _recipientController;
  late final TextEditingController _phoneController;
  late final TextEditingController _detailController;
  String? _zoneId;
  late bool _isPrimary;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    final zones = ref.read(zonesProvider);
    final activeZones = zones.where((zone) => zone.active).toList();
    final user = ref.read(authProvider);
    _labelController = TextEditingController(text: address?.label ?? '');
    _recipientController = TextEditingController(
      text: address?.recipient ?? user?.name ?? '',
    );
    _phoneController = TextEditingController(
      text: address?.phone ?? user?.phone ?? '',
    );
    _detailController = TextEditingController(text: address?.detail ?? '');
    _zoneId =
        address?.zoneId ?? (activeZones.isEmpty ? null : activeZones.first.id);
    _isPrimary = address?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authProvider);
    if (user == null) return;
    final address = Address(
      id: widget.address?.id ?? newId('addr'),
      userId: user.id,
      label: _labelController.text.trim(),
      recipient: _recipientController.text.trim(),
      phone: _phoneController.text.trim(),
      detail: _detailController.text.trim(),
      zoneId: _zoneId,
      isPrimary: _isPrimary,
    );
    ref.read(addressesProvider.notifier).saveAddress(address);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesProvider);

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
                widget.address == null ? 'ALAMAT BARU' : 'UBAH ALAMAT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.terracotta,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.address == null ? 'Tambah Alamat' : 'Edit Alamat',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _labelController,
                label: 'Label alamat',
                hint: 'Rumah, Kantor, dll.',
                icon: Icons.label_outline_rounded,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Label wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _recipientController,
                label: 'Nama penerima',
                icon: Icons.person_outline_rounded,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Nama penerima wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _phoneController,
                label: 'Nomor HP penerima',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.trim().length < 9)
                    ? 'Nomor HP tidak valid'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _detailController,
                label: 'Alamat lengkap',
                hint: 'Jalan, nomor rumah, RT/RW, kelurahan, patokan',
                icon: Icons.home_outlined,
                maxLines: 3,
                validator: (value) =>
                    (value == null || value.trim().length < 10)
                    ? 'Alamat terlalu singkat, mohon lengkapi'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _zoneId,
                decoration: const InputDecoration(
                  labelText: 'Zona pengiriman',
                  prefixIcon: Icon(Icons.map_outlined, size: 20),
                ),
                items: [
                  for (final zone in zones)
                    DropdownMenuItem(
                      value: zone.id,
                      child: Text(
                        '${zone.name} • ${rupiah(zone.fee)}${zone.active ? '' : ' (nonaktif)'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _zoneId = value),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isPrimary,
                onChanged: (value) => setState(() => _isPrimary = value),
                title: const Text(
                  'Jadikan alamat utama',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Alamat utama dipilih otomatis saat checkout.',
                  style: TextStyle(fontSize: 11.5),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(label: 'Simpan Alamat', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
