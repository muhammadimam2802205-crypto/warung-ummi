# REDESIGN PROGRESS — KEDAI UMMI 2.0

**Acuan:** `docs/prd.md` (v1.1)
**Konsep:** Premium Modern Food Experience
**Status:** Selesai — siap dipresentasikan

Legenda:

- `[ ]` belum dikerjakan
- `[~]` sedang dikerjakan
- `[x]` selesai
- `[!]` butuh keputusan / data dari pemilik kedai

---

## 0. FONDASI DESAIN

- [x] 0.1 Design token baru (warna, tipografi, radius, shadow, motion)
- [x] 0.2 Pustaka widget reusable (tombol, kartu, input, badge, stepper, timeline, skeleton, empty state)
- [x] 0.3 Navigasi bawah premium (customer & admin)
- [x] 0.4 Transisi halaman & animasi masuk yang halus
- [x] 0.5 Foto produk nyata untuk seluruh menu + fallback placeholder emoji

## 1. AUTENTIKASI

- [x] 1.1 Login — hero brand, form premium, validasi
- [x] 1.2 Registrasi — alur pelanggan, validasi, catatan keamanan admin

## 2. PELANGGAN

- [x] 2.1 Home — hero, status kedai, pencarian, kategori, carousel, menu populer
- [x] 2.2 Menu — pencarian, filter kategori, grid produk, status ketersediaan
- [x] 2.3 Detail produk — foto besar, varian, jumlah, catatan, CTA lengket
- [x] 2.4 Keranjang — item, ubah jumlah, ringkasan, state kosong
- [x] 2.5 Checkout — layanan, meja/alamat, zona, pembayaran, ringkasan
- [x] 2.6 Daftar pesanan — filter status, kartu pesanan, state kosong
- [x] 2.7 Detail pesanan — status hero, pelacakan progres, pembayaran, timeline
- [x] 2.8 Profil — kartu identitas, statistik, menu akun & kedai
- [x] 2.9 Alamat — daftar, tambah/edit, zona, alamat utama

## 3. ADMIN

- [x] 3.1 Dashboard — status kedai, KPI, penjualan, pesanan terbaru, aksi cepat
- [x] 3.2 Pesanan — filter antrean, kartu pesanan, akses detail
- [x] 3.3 Detail pesanan admin — aksi status, verifikasi bayar, penugasan kurir
- [x] 3.4 Produk — pencarian, filter kategori, ketersediaan, edit/hapus
- [x] 3.5 Form produk — media, informasi, harga, varian
- [x] 3.6 Kategori — tambah/edit/hapus, status aktif, jumlah produk
- [x] 3.7 Zona, kurir & meja — tab, tarif, ketersediaan, CRUD
- [x] 3.8 Laporan — periode, pendapatan, grafik harian, produk terlaris, transaksi
- [x] 3.9 Pengaturan — profil admin, status toko, info kedai, pembayaran, operasional

## 4. PENUTUP

- [x] 4.1 Panduan desain (`/admin/style-guide`) diperbarui
- [x] 4.2 `flutter analyze` bersih
- [x] 4.3 `flutter test` lulus (24 tes)
- [x] 4.4 Build Android release berhasil (`build/app/outputs/flutter-apk/app-release.apk`, 55 MB)
- [x] 4.5 Dokumentasi proyek diperbarui (`README.md`, kredit foto, dan dokumen ini)

## 5. PENINGKATAN VISUAL PREMIUM

- [x] 5.1 Foto makanan nyata untuk 13 menu, tersimpan di `assets/images/products/`
- [x] 5.2 Kredit & lisensi foto terdokumentasi di `docs/PHOTO_CREDITS.md`
- [x] 5.3 Foto fade-in halus saat dimuat + placeholder gradient/emoji
- [x] 5.4 Hero home: medali foto menu, ring emas berputar, badge rating, animasi masuk
- [x] 5.5 Kartu kategori dengan gradien espresso + aksen emas
- [x] 5.6 Badge “PILIHAN” pada carousel unggulan & label “Foto menu asli” di detail
- [x] 5.7 Login/registrasi: latar foto makanan dengan overlay sinematik
- [x] 5.8 Navigasi bawah: skala ikon aktif + glow lembut
- [x] 5.9 Dashboard admin: kartu tren penjualan 7 hari dengan bar animasi
- [x] 5.10 Build web release berhasil (`build/web`)
- [x] 5.11 Verifikasi akhir: `flutter analyze` bersih, 24 tes lulus
- [x] 5.12 Verifikasi visual di Chrome: login, home, menu, detail produk, keranjang, dan dashboard admin
- [x] 5.13 Perbaikan label header home (nama kedai tidak lagi tampil ganda)

## 6. MOTION & ANIMATION SYSTEM

- [x] 6.1 Token motion terpusat (instant, fast, normal, smooth, emphasis, cinematic, stagger; curve standard, emphasized, gentle, spring, overshoot)
- [x] 6.2 Transisi halaman terpusat: fade, slide untuk autentikasi, detail (fade + scale + slide), dan AnimationStyle bottom sheet
- [x] 6.3 Splash sinematik: logo scale/fade, tagline, food slide-up, ring orbit, status loading bertahap
- [x] 6.4 Loading terhubung inisialisasi `SharedPreferences` yang sebenarnya (bukan progress palsu)
- [x] 6.5 Onboarding 3 halaman: parallax, layered food cards, phone mockup, page indicator, Lewati/Selanjutnya/Mulai Sekarang, swipe
- [x] 6.6 Persistensi onboarding (`onboarding_seen` + `onboarding_completed`) agar tidak tampil berulang
- [x] 6.7 Micro-interaction: haptic + press scale, animated rupiah, bounce cart badge, floating snackbar premium
- [x] 6.8 Pull-to-refresh beridentitas chef hat + ring emas + animasi sukses (home, menu, pesanan, admin)
- [x] 6.9 Skeleton shimmer pada loading menu
- [x] 6.10 Reduced-motion dihormati pada controller dan animasi berulang
- [x] 6.11 `flutter analyze` bersih dan 24 tes lulus (termasuk pull-to-refresh, counter, dan onboarding)

## 7. FIGMA HANDOFF

- [x] 7.1 Import kit HTML/CSS 5 frame (splash, onboarding 1–3, login) di `figma/index.html`
- [x] 7.2 Design tokens Tokens Studio di `figma/tokens/kedai-ummi.tokens.json`
- [x] 7.3 Panduan import, komponen, prototype, dan fix-up di `figma/FIGMA_GUIDE.md`
- [x] 7.4 Verifikasi visual board 1440 × 2300 di Chrome

---

## Catatan Data yang Masih Menunggu Pemilik Kedai

Sesuai PRD bagian 16, data berikut sudah diisi contoh realistis agar aplikasi
dapat dipresentasikan, namun **wajib diganti data asli** sebelum operasional:

- [!] Harga final seluruh menu
- [!] Foto resmi Kedai Ummi (saat ini memakai foto stok berlisensi — lihat `docs/PHOTO_CREDITS.md`)
- [!] Jam operasional
- [!] Jumlah meja & QR Code
- [!] Zona & tarif pengiriman
- [!] Jumlah kurir internal
- [!] Rekening bank & QRIS resmi
- [!] Kebijakan pembatalan / refund / cash
