# Kedai Ummi

Aplikasi pemesanan makanan untuk UMKM **Kedai Ummi** (Flutter, Android).
Dibangun berdasarkan `docs/prd.md` — mendukung layanan **dine-in**, **takeaway**, dan
**delivery**, dengan peran **pelanggan** dan **admin kedai**.

> Aplikasi berjalan dengan **penyimpanan lokal perangkat** (`shared_preferences`).
> Seluruh lapisan data diisolasi di `lib/data/` agar mudah dihubungkan ke API produksi.

## Menjalankan

```bash
flutter pub get
flutter run                 # perangkat/emulator Android
flutter run -d chrome       # versi web (Chrome)
flutter build apk --release # build/app/outputs/flutter-apk/app-release.apk
flutter build web --release # build/web
```

Untuk presentasi versi web tanpa debug service (lebih stabil):

```bash
flutter build web --release
cd build/web
python -m http.server 8080
# buka http://localhost:8080
```

Pemeriksaan kualitas:

```bash
flutter analyze
flutter test
```

## Akun Akses

Akun berikut tersedia pada data awal aplikasi:

| Peran | Email | Kata sandi |
|---|---|---|
| Admin kedai | `admin@kedaiummi.id` | `admin123` |
| Pelanggan | `budi@mail.com` | `123456` |

Registrasi dari aplikasi **hanya membuat akun pelanggan**; akun admin tidak dapat
dibuat dari halaman daftar.

## Fitur Utama

**Pelanggan**
- Home bertema (status buka/tutup, banner, kategori, carousel menu)
- Menu dengan pencarian, filter kategori, dan status ketersediaan
- Detail produk: varian, jumlah, catatan
- Keranjang & checkout tiga layanan
  - Dine-in: kode meja (validasi) + pemilih meja aktif
  - Takeaway
  - Delivery: alamat → zona → tarif
- Pembayaran tunai / transfer / QRIS (verifikasi manual oleh admin)
- Upload bukti bayar, pelacakan status, riwayat pesanan
- Profil & CRUD alamat pengiriman

**Admin**
- Dashboard operasional (pesanan masuk/diproses/selesai, penjualan)
- Kelola pesanan: terima/tolak, transisi status, tugaskan kurir
- Verifikasi / tolak bukti pembayaran
- CRUD produk (termasuk varian, foto, ketersediaan) & kategori
- CRUD zona pengiriman, kurir, dan meja
- Pengaturan toko: buka/tutup, info kedai, rekening, QRIS
- Laporan penjualan: periode, pendapatan, produk terlaris
- Panduan desain internal (`/admin/style-guide`)

## Struktur Proyek

```
lib/
├── app/            # MaterialApp + router (go_router, guard role)
├── core/           # tema, formatter, pricing, widget reusable
├── data/           # model, seed, LocalStore (shared_preferences)
├── features/       # auth, home, menu, cart, orders, profile, admin, style_guide
├── state/          # Riverpod notifier & provider
└── main.dart
```

## Catatan

- Data awal (menu, harga, alamat, rekening) merupakan contoh realistis untuk
  presentasi. Ganti dengan data asli kedai sebelum digunakan operasional.
- Setiap menu memakai **foto makanan nyata** di `assets/images/products/`.
  Kredit, lisensi, dan tautan sumber ada di
  [`docs/PHOTO_CREDITS.md`](docs/PHOTO_CREDITS.md). Admin tetap dapat mengganti
  foto lewat form produk (galeri perangkat).
- Jika foto gagal dimuat, aplikasi otomatis kembali ke placeholder emoji +
  gradient, sehingga tampilan tidak pernah kosong.
- Bukti pembayaran disimpan di penyimpanan perangkat; integrasi unggah ke server
  dapat ditambahkan tanpa mengubah alur verifikasi admin.
- Versi web menggunakan `local_image_web.dart` (blob URL) agar unggah bukti
  pembayaran tetap berjalan tanpa `dart:io`.
- Status progres pengembangan ada di [`docs/REDESIGN_PROGRESS.md`](docs/REDESIGN_PROGRESS.md).
