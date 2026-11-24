import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

/// Referensi internal agar seluruh komponen tampil konsisten.
/// Diakses admin melalui Pengaturan → Panduan Desain.
class StyleGuidePage extends StatefulWidget {
  const StyleGuidePage({super.key});

  @override
  State<StyleGuidePage> createState() => _StyleGuidePageState();
}

class _StyleGuidePageState extends State<StyleGuidePage> {
  int _qty = 2;
  bool _switchValue = true;
  int _chipIndex = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan Desain'),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B2A1F), AppColors.espresso],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SISTEM DESAIN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: AppColors.gold.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Kedai Ummi 2.0',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 25,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Premium Modern Food Experience — hangat, tenang, '
                    'editorial, dan berfokus pada makanan.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: const [
                      AppBadge(
                        label: 'Serif display',
                        background: Color(0x1AFFFFFF),
                        foreground: AppColors.white,
                        compact: true,
                      ),
                      AppBadge(
                        label: 'Terracotta',
                        background: Color(0x1AFFFFFF),
                        foreground: AppColors.white,
                        compact: true,
                      ),
                      AppBadge(
                        label: '150–350 ms',
                        background: Color(0x1AFFFFFF),
                        foreground: AppColors.white,
                        compact: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            eyebrow: 'Fondasi',
            title: 'Palet Warna',
            subtitle: 'Warm cream, terracotta, dan cokelat hangat',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _ColorSwatch('Cream', AppColors.cream, AppColors.brown),
              _ColorSwatch('Cream Deep', AppColors.creamDeep, AppColors.brown),
              _ColorSwatch('Beige', AppColors.beige, AppColors.brown),
              _ColorSwatch('Terracotta', AppColors.terracotta, AppColors.white),
              _ColorSwatch('Espresso', AppColors.espresso, AppColors.white),
              _ColorSwatch('Gold', AppColors.gold, AppColors.espresso),
              _ColorSwatch('Success', AppColors.success, AppColors.white),
              _ColorSwatch('Danger', AppColors.danger, AppColors.white),
              _ColorSwatch('Info', AppColors.info, AppColors.white),
              _ColorSwatch('Warning', AppColors.warning, AppColors.white),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            eyebrow: 'Tipografi',
            title: 'Skala Teks',
            subtitle: 'Serif untuk judul, sans untuk isi',
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rasa Istimewa',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Headline — menu pilihan hari ini',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Title — informasi pesanan',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Body — setiap pesanan disiapkan dengan bahan segar dan '
                  'dikirim tepat waktu.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Caption — keterangan sekunder dan bantuan.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            eyebrow: 'Interaksi',
            title: 'Tombol',
            subtitle: 'Aksi utama, sekunder, dan keadaan muat',
          ),
          const SizedBox(height: 12),
          const AppButton(
            label: 'Tambah ke Keranjang',
            icon: Icons.shopping_bag_outlined,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Simpan Perubahan',
            variant: AppButtonVariant.dark,
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Batalkan Pesanan',
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Lihat Detail',
            variant: AppButtonVariant.ghost,
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          const AppButton(label: 'Memproses...', loading: true),
          const SizedBox(height: 24),
          const SectionHeader(
            eyebrow: 'Input',
            title: 'Form & Filter',
            subtitle: 'Kolom teks, validasi, chip, dan stepper',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _controller,
            label: 'Catatan pesanan',
            hint: 'Tulis permintaan khusus',
            icon: Icons.edit_outlined,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Nomor meja',
              errorText: 'Nomor meja wajib dipilih',
              prefixIcon: Icon(Icons.table_restaurant_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < 3; i++)
                CategoryChip(
                  label: ['Semua', 'Kebab', 'Minuman'][i],
                  emoji: i == 1 ? '🌯' : (i == 2 ? '🍊' : null),
                  selected: _chipIndex == i,
                  onTap: () => setState(() => _chipIndex = i),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kebab Spesial',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Atur jumlah porsi',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              QuantityStepper(
                value: _qty,
                onChanged: (value) => setState(() => _qty = value),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _switchValue,
            onChanged: (value) => setState(() => _switchValue = value),
            title: const Text(
              'Menu tersedia',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Mengikuti warna terracotta tema aplikasi.',
              style: TextStyle(fontSize: 11.5),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            eyebrow: 'Status',
            title: 'Badge & Label',
            subtitle: 'Warna status konsisten di seluruh aplikasi',
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                AppBadge(label: 'Netral'),
                AppBadge(
                  label: 'Lunas',
                  background: AppColors.successSoft,
                  foreground: AppColors.success,
                ),
                AppBadge(
                  label: 'Menunggu Bayar',
                  background: AppColors.warningSoft,
                  foreground: AppColors.warning,
                ),
                AppBadge(
                  label: 'Ditolak',
                  background: AppColors.dangerSoft,
                  foreground: AppColors.danger,
                ),
                AppBadge(
                  label: 'Verifikasi',
                  background: AppColors.infoSoft,
                  foreground: AppColors.info,
                ),
                AppBadge(
                  label: 'Sedang Diproses',
                  background: AppColors.terracottaSoft,
                  foreground: AppColors.terracottaDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            eyebrow: 'Keuangan',
            title: 'Kartu & Baris Biaya',
            subtitle: 'Ringkasan pembayaran pesanan',
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                MoneyRow(label: 'Subtotal', value: 25000),
                MoneyRow(label: 'Biaya pengiriman', value: 5000),
                const Divider(height: 18),
                MoneyRow(
                  label: 'Total Pembayaran',
                  value: 30000,
                  emphasize: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            eyebrow: 'Keadaan kosong',
            title: 'Empty State',
            subtitle: 'Selalu beri arahan langkah berikutnya',
          ),
          const SizedBox(height: 12),
          AppCard(
            child: EmptyState(
              icon: Icons.shopping_bag_outlined,
              eyebrow: 'Keranjang',
              title: 'Keranjang masih kosong',
              message: 'Tambahkan menu favorit untuk mulai membuat pesanan.',
              actionLabel: 'Jelajahi Menu',
              onAction: () {},
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Dokumentasi internal • Kedai Ummi 2.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(this.label, this.color, this.foreground);

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 74,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.bottomLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
