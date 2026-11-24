# PRODUCT REQUIREMENTS DOCUMENT (PRD)
# KEDAI UMMI

**Nama Produk:** Kedai Ummi  
**Jenis Produk:** Aplikasi Pemesanan Makanan UMKM  
**Platform:** Android  
**Versi Dokumen:** 1.1  
**Status:** Revisi untuk tahap perencanaan dan desain  
**Target Pengguna:** Customer dan Admin Kedai Ummi

---

# 1. PROJECT OVERVIEW

## 1.1 Latar Belakang

Kedai Ummi merupakan usaha UMKM yang menyediakan berbagai jenis makanan dan minuman, seperti kebab, burger, bakso, mi ayam, lotek, nasi goreng, serta aneka minuman.

Aplikasi Kedai Ummi dikembangkan untuk mempermudah pelanggan melihat menu, melakukan pemesanan, memilih metode pembayaran, dan memantau status pesanan.

Aplikasi juga menyediakan sistem administrasi untuk membantu pemilik kedai mengelola produk, harga, pesanan, pembayaran, pengiriman, serta laporan penjualan.

Kedai Ummi akan hadir dengan tampilan aplikasi yang modern, premium, interaktif, dan berorientasi pada pengalaman pengguna. Visual makanan menjadi daya tarik utama dengan menggunakan fotografi makanan asli yang ditampilkan secara menarik melalui efek kedalaman dan animasi antarmuka.

## 1.2 Tujuan Produk

1. Mempermudah pelanggan melihat dan memesan makanan.
2. Menyediakan sistem pemesanan yang terstruktur.
3. Mempermudah admin mengelola menu dan transaksi.
4. Menyediakan layanan dine-in, takeaway, dan delivery.
5. Menampilkan visual makanan yang menarik dan realistis.
6. Memberikan pengalaman penggunaan yang nyaman melalui animasi interaktif.
7. Membantu pencatatan transaksi dan laporan penjualan.

## 1.3 Visi Produk

Menjadikan Kedai Ummi sebagai aplikasi pemesanan makanan UMKM yang modern, menarik, praktis, dan mudah digunakan, dengan pengalaman visual yang memberikan kesan premium tanpa mengorbankan kesederhanaan.

---

# 2. TARGET PENGGUNA DAN ROLE

Aplikasi menggunakan satu aplikasi Android dengan dua role utama.

## 2.1 Customer

Pelanggan dapat:
- Registrasi dan login.
- Melihat seluruh menu makanan dan minuman.
- Mencari dan memfilter produk.
- Melihat detail produk dan harga.
- Memilih varian produk.
- Menambahkan produk ke keranjang.
- Melakukan checkout.
- Memilih dine-in, takeaway, atau delivery.
- Memilih metode pembayaran.
- Mengunggah bukti pembayaran.
- Memantau status pesanan.
- Melihat riwayat transaksi.
- Mengelola profil dan alamat.

## 2.2 Admin

Admin dapat:
- Login menggunakan akun admin.
- Melihat dashboard operasional.
- Mengelola produk dan kategori.
- Mengubah harga dan ketersediaan.
- Mengelola pesanan.
- Menerima atau menolak pesanan.
- Memperbarui status pesanan.
- Memverifikasi pembayaran.
- Mengatur zona dan tarif pengiriman.
- Mengelola kurir internal.
- Mengatur informasi toko.
- Melihat laporan penjualan.

**Ketentuan keamanan:** Akun admin tidak boleh dibuat melalui registrasi pelanggan biasa. Pembuatan akun dan pemberian role admin harus melalui mekanisme yang memiliki otorisasi.

---

# 3. DAFTAR MENU DAN HARGA

Daftar berikut menjadi katalog awal aplikasi Kedai Ummi berdasarkan menu yang telah diberikan.

Seluruh harga menggunakan Rupiah (IDR).

## 3.1 Makanan

### A. Kebab

| Varian | Harga |
|---|---:|
| Kebab Daging | Rp7.000 |
| Kebab Telur | Rp7.000 |
| Kebab Keju | Rp7.000 |
| Kebab Daging Keju | Rp9.000 |
| Kebab Daging Telur | Rp9.000 |
| Kebab Spesial | Rp11.000 |

### B. Mozarella

| Varian | Harga |
|---|---:|
| Original | Rp7.000 |
| Coklat | Rp7.000 |
| Tiramisu | Rp7.000 |
| Greentea | Rp7.000 |

### C. Hottang

| Varian | Harga |
|---|---:|
| Sosis | Rp7.000 |
| Keju Mozarella | Rp7.000 |

### D. Sandwich

| Varian | Harga |
|---|---:|
| Sandwich | Rp7.000 |

### E. Burger

| Varian | Harga |
|---|---:|
| Burger Daging | Rp7.000 |
| Burger Daging Telur | Rp9.000 |
| Burger Daging Keju | Rp9.000 |
| Burger Daging Spesial | Rp11.000 |

### F. Bakso

| Varian | Harga |
|---|---:|
| Bakso Biasa | Rp8.000 |
| Bakso Urat | Rp11.000 |
| Bakso Telur | Rp11.000 |
| Bakso Komplit | Rp14.000 |

### G. Mie Ayam

| Varian | Harga |
|---|---:|
| Mie Ayam | Rp8.000 |
| Mie Ayam Bakso | Rp10.000 |
| Mie Ayam Telur | Rp13.000 |
| Mie Ayam Urat | Rp13.000 |
| Mie Ayam Komplit | Rp16.000 |

### H. Miso

| Varian | Harga |
|---|---:|
| Miso Biasa | Rp7.000 |
| Miso Bakso | Rp9.000 |
| Miso Telur | Rp12.000 |
| Miso Urat | Rp12.000 |
| Miso Komplit | Rp15.000 |
| Miso + Nasi | Rp10.000 |

### I. Lotek

| Varian | Harga |
|---|---:|
| Lotek Lontong | Rp10.000 |
| Lotek Biasa | Rp10.000 |
| Lotek Bakso | Rp12.000 |
| Lotek Urat | Rp13.000 |
| Lotek Telur | Rp13.000 |

### J. Nasi Goreng

| Varian | Harga |
|---|---:|
| Nasi Goreng Telur | Rp10.000 |
| Nasi Goreng Bakso | Rp13.000 |
| Nasi Goreng Ayam | Rp13.000 |
| Nasi Goreng Petai | Rp13.000 |
| Minas | Rp12.000 |

## 3.2 Minuman

### K. Es Jeruk

| Varian | Harga |
|---|---:|
| Original | Rp6.000 |
| Susu | Rp8.000 |
| Madu | Rp8.000 |
| Yakult | Rp9.000 |

### L. Jeruk Hangat

| Varian | Harga |
|---|---:|
| Original | Rp6.000 |
| Susu | Rp8.000 |
| Madu | Rp8.000 |
| Yakult | Rp9.000 |

### M. Juice Kurma

| Varian | Harga |
|---|---:|
| Original | Rp10.000 |
| Alpukat | Rp10.000 |
| Kurma Alpukat | Rp15.000 |
| Kurma Pisang | Rp15.000 |

**Ketentuan katalog:**
- Semua kategori dan varian harus dapat dikelola oleh admin.
- Harga dapat diubah melalui halaman administrasi.
- Harga transaksi harus disimpan sebagai snapshot ketika pesanan dibuat.
- Produk yang tidak tersedia dapat dinonaktifkan sementara.
- Nama dan harga di atas merupakan data awal, bukan pengganti validasi harga final dari pemilik kedai.

---

# 4. DESIGN DIRECTION DAN UI/UX

## 4.1 Konsep Utama

**Premium Modern Food Experience**

Aplikasi harus memiliki tampilan yang:
- Modern dan elegan.
- Terlihat premium tetapi tidak berlebihan.
- Minimalis dan tidak penuh elemen.
- Interaktif dengan animasi yang halus.
- Berfokus pada fotografi makanan.
- Nyaman digunakan dalam waktu lama.
- Konsisten pada seluruh halaman.

Referensi pendekatan visual adalah aplikasi pemesanan makanan modern dengan komposisi visual yang kuat, ruang kosong yang cukup, tipografi tegas, serta navigasi sederhana.

## 4.2 Color Direction

Palet warna diarahkan pada nuansa hangat dan premium.

| Elemen | Warna |
|---|---|
| Primary | Terracotta / Warm Orange |
| Background | Warm Cream |
| Secondary | Soft Beige |
| Surface | White |
| Primary Text | Dark Brown |
| Secondary Text | Muted Brown |
| Accent | Deep Terracotta |

Warna final dan kode HEX ditentukan dalam `UI_UX_GUIDELINES.md`.

Hindari penggunaan terlalu banyak warna, gradient berlebihan, dan kombinasi warna yang mengganggu keterbacaan.

## 4.3 Typography

Gunakan tipografi modern dan mudah dibaca.

Ketentuan:
- Heading terlihat tegas dan memiliki hierarki jelas.
- Nama makanan mudah dikenali.
- Harga ditampilkan dengan jelas.
- Deskripsi menggunakan ukuran yang nyaman dibaca.
- Gunakan maksimal dua keluarga font utama.
- Hindari penggunaan font dekoratif berlebihan.

## 4.4 Real Food Photography

Visual produk merupakan bagian terpenting dari identitas aplikasi.

**Wajib menggunakan foto makanan asli, bukan gambar AI, kartun, anime, ilustrasi, atau karakter 3D buatan.**

Ketentuan fotografi:
- Makanan harus benar-benar sesuai dengan menu yang dijual Kedai Ummi.
- Foto menggunakan produk asli dari kedai.
- Tekstur makanan harus terlihat natural.
- Warna makanan tidak boleh dibuat terlalu artifisial.
- Piring, mangkuk, gelas, dan properti harus terlihat realistis.
- Pencahayaan harus natural dan menarik.
- Sudut pengambilan gambar dibuat konsisten.
- Setiap produk memiliki foto yang sesuai dengan produk tersebut.
- Jangan menggunakan satu gambar untuk mewakili makanan yang berbeda.
- Foto harus memiliki resolusi yang memadai dan dikompresi untuk Android.

**Arah visual:** Foto makanan asli dengan komposisi profesional, pencahayaan studio makanan, background bersih, dan objek makanan sebagai fokus utama.

### Efek visual yang diperbolehkan

Foto asli dapat ditampilkan menggunakan:
- Efek depth atau kedalaman.
- Shadow yang natural.
- Layering visual.
- Parallax ringan.
- Perspektif pada carousel.
- Transisi gambar yang halus.

Efek tersebut hanya mempercantik penyajian foto, bukan mengubah makanan menjadi objek kartun atau makanan 3D palsu.

Jika foto asli suatu produk belum tersedia, gunakan placeholder yang jelas. Jangan menggantinya dengan gambar AI.

---

# 5. ANIMATION AND INTERACTION SYSTEM

Animasi menjadi salah satu karakter utama aplikasi, tetapi tidak boleh mengurangi kenyamanan maupun performa.

## 5.1 Home Animation

- Hero section memiliki transisi masuk yang halus.
- Foto makanan dapat memiliki efek depth ringan.
- Carousel bergerak secara horizontal.
- Produk aktif tampil lebih menonjol.
- Produk di sebelahnya terlihat sebagian.
- Perubahan halaman menggunakan transisi lembut.

## 5.2 Product Carousel

Carousel menjadi elemen visual utama.

Ketentuan:
- Dapat digeser ke kiri dan kanan.
- Produk aktif tampil lebih besar.
- Produk di samping tampil sebagian.
- Perpindahan antarproduk memiliki efek scale dan opacity.
- Efek perspektif atau rotasi dibuat sangat ringan.
- Pengguna tetap dapat menekan produk untuk melihat detailnya.
- Tidak boleh menggunakan animasi otomatis yang mengganggu interaksi.

## 5.3 Product Interaction

- Tombol tambah keranjang memiliki feedback animasi.
- Perubahan jumlah produk memiliki transisi singkat.
- Foto produk dapat menggunakan transisi saat berpindah varian.
- Tombol dan kartu memiliki efek sentuh.
- Feedback keberhasilan ditampilkan dengan animasi sederhana.

## 5.4 Navigation Animation

- Perpindahan tab menggunakan transisi halus.
- Ikon navigasi memiliki feedback ketika dipilih.
- Halaman detail menggunakan transisi yang konsisten.
- Bottom navigation tidak boleh menghalangi konten.

## 5.5 Loading and Feedback

Gunakan:
- Skeleton loading.
- Loading indicator sederhana.
- Empty state yang informatif.
- Error state yang mudah dipahami.
- Success feedback.
- Konfirmasi sebelum tindakan penting.

## 5.6 Animation Rules

- Utamakan animasi 150–350 ms untuk interaksi umum.
- Hindari animasi terlalu cepat atau terlalu lambat.
- Jangan membuat semua elemen bergerak bersamaan.
- Hindari animasi looping yang tidak memiliki fungsi.
- Sediakan pendekatan minim animasi jika memungkinkan.
- Animasi harus tetap lancar pada perangkat Android kelas menengah.

---

# 6. CUSTOMER APPLICATION FEATURES

## 6.1 Authentication

- Registrasi.
- Login.
- Logout.
- Validasi data.
- Pengelolaan sesi.

## 6.2 Home

Menampilkan:
- Identitas Kedai Ummi.
- Informasi buka atau tutup.
- Banner informasi atau promosi.
- Kategori makanan.
- Produk unggulan.
- Produk populer.
- Carousel makanan.
- Akses cepat ke menu.

## 6.3 Menu

- Seluruh kategori makanan dan minuman.
- Daftar produk.
- Pencarian.
- Filter kategori.
- Harga.
- Foto produk.
- Ketersediaan.
- Varian produk.

## 6.4 Product Detail

- Foto produk asli.
- Nama dan deskripsi.
- Harga.
- Pilihan varian.
- Tambahan produk jika tersedia.
- Pengaturan jumlah.
- Tombol tambah ke keranjang.

## 6.5 Cart

- Daftar produk.
- Ubah jumlah.
- Hapus produk.
- Subtotal.
- Biaya tambahan.
- Total transaksi.

## 6.6 Checkout

- Pilihan layanan.
- Alamat delivery.
- Identitas meja dine-in.
- Ringkasan pesanan.
- Biaya pengiriman.
- Metode pembayaran.
- Konfirmasi pesanan.

## 6.7 Payment

Metode pembayaran:
1. Cash.
2. Transfer bank.
3. QRIS.

Ketentuan:
- Transfer dan QRIS menggunakan verifikasi manual.
- Pelanggan dapat mengunggah bukti pembayaran.
- Admin melakukan verifikasi.
- Upload bukti tidak otomatis menjadikan pembayaran berstatus Paid.
- Tidak menggunakan payment gateway pada MVP.

## 6.8 Order Tracking

Status:
1. Menunggu konfirmasi admin.
2. Dikonfirmasi.
3. Sedang diproses.
4. Siap diambil.
5. Sedang diantar.
6. Selesai.
7. Ditolak atau dibatalkan.

Tampilan status menggunakan timeline yang jelas dan mudah dipahami.

## 6.9 Order History

- Riwayat pesanan.
- Detail transaksi.
- Total pembayaran.
- Metode pembayaran.
- Status transaksi.

## 6.10 Profile

- Informasi akun.
- Edit profil.
- Kelola alamat.
- Logout.

---

# 7. ADMIN APPLICATION FEATURES

## 7.1 Dashboard

Menampilkan:
- Total pesanan.
- Pesanan masuk.
- Pesanan diproses.
- Pesanan selesai.
- Total penjualan.
- Ringkasan transaksi.

## 7.2 Product Management

Admin dapat:
- Menambahkan produk.
- Mengubah produk.
- Menghapus atau menonaktifkan produk.
- Mengunggah foto asli produk.
- Mengatur deskripsi.
- Mengatur harga.
- Mengatur kategori.
- Mengatur varian.
- Mengatur ketersediaan.

## 7.3 Category Management

- Tambah kategori.
- Edit kategori.
- Hapus kategori.
- Atur nama dan gambar kategori.

## 7.4 Order Management

- Melihat pesanan masuk.
- Melihat detail pesanan.
- Menerima atau menolak pesanan.
- Memperbarui status.
- Melihat informasi pelanggan.
- Melihat jenis layanan.
- Melihat pembayaran.

## 7.5 Payment Verification

- Melihat bukti transfer.
- Melihat bukti QRIS.
- Menyetujui pembayaran.
- Menolak pembayaran.
- Memperbarui status pembayaran.

## 7.6 Delivery Management

- Mengelola zona.
- Mengatur tarif.
- Mengaktifkan atau menonaktifkan zona.
- Melihat pesanan delivery.
- Mengelola kurir.
- Menugaskan kurir.
- Memperbarui status pengiriman.

## 7.7 Courier Management

- Menambahkan kurir.
- Mengubah data kurir.
- Mengaktifkan atau menonaktifkan kurir.
- Mengatur ketersediaan.
- Menugaskan kurir secara manual.

## 7.8 Sales Report

- Total penjualan.
- Jumlah transaksi.
- Produk terlaris.
- Pendapatan berdasarkan periode.
- Riwayat transaksi.

## 7.9 Store Settings

- Informasi kedai.
- Status buka atau tutup.
- Informasi rekening.
- Informasi QRIS.
- Konfigurasi operasional.

---

# 8. ORDER SERVICE

Aplikasi menyediakan tiga jenis layanan.

## 8.1 Dine-In

1. Pelanggan datang ke kedai.
2. Memindai QR Code meja.
3. Sistem membaca identitas meja.
4. Memilih menu.
5. Checkout.
6. Admin mengonfirmasi.
7. Kedai memproses pesanan.
8. Pesanan disajikan kepada pelanggan.

QR Code harus dapat digunakan kembali dan hanya menyimpan identitas meja.

## 8.2 Takeaway

1. Pelanggan memilih takeaway.
2. Memilih menu.
3. Checkout.
4. Admin mengonfirmasi.
5. Kedai menyiapkan pesanan.
6. Pelanggan mengambil pesanan.

## 8.3 Delivery

1. Pelanggan memilih delivery.
2. Memilih atau memasukkan alamat.
3. Sistem menentukan zona.
4. Sistem menghitung tarif.
5. Pelanggan checkout.
6. Admin mengonfirmasi.
7. Kedai mempersiapkan pesanan.
8. Admin menugaskan kurir.
9. Kurir mengantarkan pesanan.
10. Pesanan diselesaikan.

MVP tidak menggunakan GPS tracking real-time dan tidak memerlukan aplikasi khusus kurir.

---

# 9. BUSINESS RULES

## 9.1 Order Rules

1. Pelanggan harus login untuk memesan.
2. Produk harus tersedia.
3. Nomor transaksi harus unik.
4. Detail produk dan jumlah wajib tersimpan.
5. Harga disimpan sebagai snapshot transaksi.
6. Perubahan harga tidak memengaruhi transaksi lama.
7. Admin wajib mengonfirmasi pesanan.
8. Admin dapat menolak pesanan jika terdapat kendala.
9. Total transaksi dihitung dan divalidasi backend.

## 9.2 Payment Rules

Status pembayaran:
- Pending.
- Menunggu verifikasi.
- Paid.
- Rejected.
- Unpaid.

Status pembayaran dipisahkan dari status pesanan.

## 9.3 Delivery Rules

1. Delivery hanya tersedia pada zona aktif.
2. Tarif ditentukan berdasarkan zona.
3. Biaya pengiriman disimpan dalam transaksi.
4. Admin menugaskan kurir.
5. Kurir tidak tersedia tidak dapat ditugaskan.

## 9.4 Store Rules

1. Admin dapat mengatur status buka atau tutup.
2. Menu tetap dapat dilihat ketika toko tutup.
3. Pelanggan tidak dapat mengirim pesanan baru ketika toko tutup.
4. Ketersediaan produk dikelola secara terpisah.

---

# 10. DATA REQUIREMENTS

Entitas utama:
- users
- addresses
- categories
- products
- product_variants
- carts
- cart_items
- orders
- order_items
- payments
- deliveries
- delivery_zones
- couriers
- tables
- reviews (opsional)
- store_settings

Ketentuan:
- Relasi data harus konsisten.
- Harga transaksi disimpan sebagai snapshot.
- Data transaksi lama tidak boleh hilang akibat perubahan produk.
- Total dihitung backend.
- Bukti pembayaran disimpan dengan aman.
- Penghapusan data mempertimbangkan riwayat transaksi.

Detail struktur berada di `DATABASE_DESIGN.md`.

---

# 11. NON-FUNCTIONAL REQUIREMENTS

## 11.1 Performance

- Berjalan lancar pada Android kelas menengah.
- Gambar dioptimalkan dan menggunakan format efisien seperti WebP.
- Hindari gambar resolusi berlebihan.
- Animasi harus ringan.
- Hindari rendering yang tidak diperlukan.
- Pengambilan data dilakukan secara efisien.
- Hindari efek visual berat yang terus berjalan.

## 11.2 Security

- Password menggunakan hashing aman.
- Autentikasi menggunakan mekanisme aman.
- Endpoint memiliki otorisasi berdasarkan role.
- Data pelanggan dan bukti pembayaran dilindungi.
- Validasi dilakukan pada backend.
- Komunikasi production menggunakan HTTPS.

## 11.3 Reliability

- Transaksi konsisten.
- Tidak ada pesanan setengah tersimpan.
- Perubahan status divalidasi.
- Kesalahan jaringan ditangani dengan baik.

## 11.4 Maintainability

- Struktur kode terorganisir.
- Komponen UI reusable.
- Logika bisnis terpisah dari tampilan.
- Dokumentasi diperbarui ketika terjadi perubahan.

## 11.5 Compatibility

- Fokus pada Android.
- Mendukung berbagai ukuran layar.
- Nyaman pada perangkat spesifikasi menengah.

---

# 12. TECHNOLOGY STACK

| Bagian | Teknologi |
|---|---|
| Mobile | Flutter |
| Language | Dart |
| Backend API | Laravel |
| Backend Language | PHP |
| Database | MySQL |
| Authentication | Laravel Sanctum |
| Image Storage | Laravel Storage |
| State Management | Provider atau Riverpod |
| Notification | Firebase Cloud Messaging (opsional) |

Arsitektur backend menggunakan **Modular Monolith**.

Modul utama:
- Authentication.
- Product.
- Category.
- Cart.
- Order.
- Payment.
- Delivery.
- Courier.
- Report.
- Store Settings.

---

# 13. MVP SCOPE

## Included

**Customer:**
- Authentication.
- Menu dan kategori.
- Detail produk dan varian.
- Keranjang.
- Checkout.
- Dine-in, takeaway, delivery.
- Cash, transfer, QRIS.
- Upload bukti pembayaran.
- Status pesanan.
- Riwayat.
- Profil dan alamat.

**Admin:**
- Login.
- Dashboard.
- CRUD produk dan kategori.
- Pengelolaan ketersediaan.
- Manajemen pesanan.
- Verifikasi pembayaran.
- Zona dan tarif delivery.
- Manajemen kurir.
- Pengaturan toko.
- Laporan sederhana.

**UI/UX:**
- Modern premium interface.
- Fotografi makanan asli.
- Carousel interaktif.
- Animasi transisi.
- Feedback interaksi.
- Skeleton loading.
- Layout responsif.
- Optimasi performa.

## Excluded

- GPS tracking real-time.
- Aplikasi khusus kurir.
- Payment gateway otomatis.
- Loyalty dan poin.
- Rekomendasi AI.
- Multi-cabang.
- Integrasi pihak ketiga.
- Voucher kompleks.
- Live chat.

---

# 14. ACCEPTANCE CRITERIA

Aplikasi dinyatakan memenuhi MVP apabila:

1. Pelanggan dapat registrasi dan login.
2. Menu dan detail produk dapat dilihat.
3. Varian dan jumlah produk dapat dipilih.
4. Produk dapat dimasukkan ke keranjang.
5. Checkout dapat dilakukan.
6. Ketiga jenis layanan berfungsi.
7. Perhitungan total benar.
8. Pesanan masuk ke admin.
9. Admin dapat menerima dan menolak pesanan.
10. Status pesanan dapat diperbarui.
11. Pelanggan dapat memantau pesanan.
12. Transfer dan QRIS dapat diverifikasi.
13. Tarif pengiriman dapat dikelola.
14. Kurir dapat ditugaskan.
15. Ketersediaan produk dapat diatur.
16. Status toko dapat diatur.
17. Riwayat transaksi tersimpan.
18. Hak akses berdasarkan role berjalan.
19. Foto produk sesuai dengan makanan asli.
20. Animasi berjalan lancar dan tidak mengganggu.
21. Navigasi mudah dipahami.
22. Aplikasi berjalan baik pada perangkat Android kelas menengah.

---

# 15. DEVELOPMENT PHASES

## Phase 1: Planning
- Finalisasi PRD.
- UI/UX Guidelines.
- Database Design.
- API Specification.
- Project Structure.
- Validasi daftar menu dan harga.

## Phase 2: UI/UX
- Desain customer.
- Desain admin.
- Design system.
- Komponen reusable.
- Persiapan fotografi makanan asli.
- Implementasi prototipe animasi.
- Pengujian kenyamanan navigasi.

## Phase 3: Backend
- Setup Laravel.
- Setup MySQL.
- Authentication.
- Product dan Category.
- Cart dan Order.
- Payment.
- Delivery dan Courier.
- Report.

## Phase 4: Flutter
- Authentication.
- Home.
- Menu.
- Product Detail.
- Cart.
- Checkout.
- Payment.
- Order Tracking.
- Profile.
- Admin Application.
- Integrasi API.

## Phase 5: Testing
- Functional Testing.
- API Testing.
- Authentication Testing.
- Transaction Testing.
- Payment Testing.
- Delivery Testing.
- UI/UX Testing.
- Animation Performance Testing.
- Android Performance Testing.

## Phase 6: Deployment
- Backend Production.
- Database Production.
- Storage.
- Build APK.
- Uji coba bersama pemilik Kedai Ummi.

---

# 16. PENDING VALIDATION

Hal yang harus dikonfirmasi kepada pemilik:
1. Harga final seluruh menu.
2. Foto asli seluruh produk.
3. Jam operasional.
4. Jumlah meja dan QR Code.
5. Zona pengiriman.
6. Tarif pengiriman.
7. Jumlah kurir internal.
8. Jam dan kapasitas delivery.
9. Rekening bank.
10. QRIS resmi.
11. Kebijakan pembatalan.
12. Kebijakan pengembalian dana.
13. Aturan pembayaran cash.

Sistem tidak boleh mengasumsikan informasi tersebut.

---

# 17. FINAL PRODUCT DEFINITION

Kedai Ummi merupakan aplikasi pemesanan makanan UMKM berbasis Android yang mengintegrasikan proses pemesanan pelanggan dan pengelolaan operasional kedai.

Aplikasi menyediakan layanan dine-in, takeaway, dan delivery dengan dua role utama, yaitu Customer dan Admin.

Dari sisi tampilan, Kedai Ummi mengusung konsep **Premium Modern Food Experience**, dengan fotografi makanan asli, tampilan minimalis, animasi interaktif, carousel dengan efek kedalaman, serta navigasi yang nyaman.

Prinsip utama pengembangan:

- Visual menarik tanpa membuat tampilan ramai.
- Gunakan foto makanan asli, bukan gambar AI.
- Animasi harus memiliki fungsi dan tidak mengganggu.
- Prioritaskan kenyamanan pengguna.
- Pertahankan performa Android.
- Utamakan fungsi dan konsistensi transaksi.
- Hindari penambahan fitur di luar ruang lingkup tanpa persetujuan.

**Dokumen:** PRD.md  
**Project:** Kedai Ummi  
**Version:** 1.1

**END OF DOCUMENT**