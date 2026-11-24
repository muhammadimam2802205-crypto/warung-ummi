# Kedai Ummi — Figma Import Kit

Folder ini berisi paket untuk membuat file Figma dari 5 layar yang sudah final di aplikasi:

1. **Splash**
2. **Onboarding — Welcome**
3. **Onboarding — Menu**
4. **Onboarding — Order**
5. **Login**

Semua frame berukuran **412 × 915** (Android), memakai warna, font, dan foto asli project Flutter.

---

## 1. Isi folder

| File | Fungsi |
|---|---|
| `index.html` | Design board 5 frame + Foundations. Sumber import ke Figma. |
| `tokens/kedai-ummi.tokens.json` | Design tokens format **Tokens Studio**. |
| `FIGMA_GUIDE.md` | Panduan import, struktur file, komponen, prototype, dan fix-up. |
| `../assets/images/products/` | Foto makanan asli yang dipakai di frame. |
| `../assets/fonts/` | Poppins & Pacifico yang dipakai di HTML. |

---

## 2. Import ke Figma (langkah cepat)

### A. Jalankan preview lokal

Dari root project:

```powershell
cd D:\ProjectFlutter\ummie
python -m http.server 8080
```

Buka:

```text
http://localhost:8080/figma/
```

Pastikan foto dan font tampil. Jangan tutup terminal selama import.

### B. Import dengan html.to.design

1. Install plugin **html.to.design** dari Figma Community.
2. Buat file Figma baru → jalankan plugin → **Import from URL**.
3. Masukkan `http://localhost:8080/figma/`.
4. Pilih opsi **Full page** dan **Create frames** (jika tersedia).
5. Setelah import, cari layer bernama `phone` (ada 6). Untuk setiap layer:
   - klik layer `phone`,
   - tekan **Ctrl + Alt + G** (Frame selection),
   - rename sesuai daftar frame di bawah.

> Jika plugin hanya mengimpor bagian viewport, atur lebar halaman ke **1400 px** dan tinggi **2300 px** sebelum import.

### C. Siapkan font

Install/aktifkan font berikut di Figma:

- **Poppins** (Regular, Medium, SemiBold, Bold, ExtraBold)
- **Pacifico**

Keduanya tersedia di Google Fonts. Jika teks hasil import jatuh ke font lain, pilih semua teks → set ke Poppins/Pacifico.

---

## 3. Struktur file Figma yang disarankan

```text
Kedai Ummi — Design System
├─ 00 Cover
├─ 01 Foundations
├─ 02 Components
├─ 03 Customer Flow
│  ├─ 01 · Splash
│  ├─ 02 · Onboarding — Welcome
│  ├─ 03 · Onboarding — Menu
│  ├─ 04 · Onboarding — Order
│  └─ 05 · Login
└─ 99 Prototype
```

### Nama & ukuran frame

| No | Nama frame | Width | Height | Catatan |
|---|---|---:|---:|---|
| 00 | `00 · Foundations` | 412 | 915 | Referensi token & style |
| 01 | `01 · Splash` | 412 | 915 | Full-bleed dark |
| 02 | `02 · Onboarding — Welcome` | 412 | 915 | Cream |
| 03 | `03 · Onboarding — Menu` | 412 | 915 | Cream |
| 04 | `04 · Onboarding — Order` | 412 | 915 | Cream |
| 05 | `05 · Login` | 412 | 915 | Dark + cream card |

Safe area yang disarankan: **24 px atas** dan **24 px bawah**. Konten utama sudah berada di dalam area itu.

---

## 4. Komponen yang perlu dibuat

Gunakan **Auto Layout** dan **Variants**.

### Button

| Properti | Nilai |
|---|---|
| Height | 54 (primary), 52 (secondary) |
| Radius | 20 (primary), 16–20 (secondary) |
| Padding horizontal | 20 |
| Font | Poppins ExtraBold 14.5 |
| Primary fill | `linear-gradient(180deg, #B96D43 0%, #A65D3F 46%, #85452F 100%)` |
| Primary shadow | `0 8 18 rgba(166,93,63,.28)` + `0 16 30 rgba(56,37,29,.14)` |
| Arrow circle | 26 × 26, fill `#FFF4E6`, icon `#85452F` |
| Variants | Default, Pressed (scale 0.975), Loading, Disabled (`#E8D8C8`, text `#9B8574`) |

### Field

| Properti | Nilai |
|---|---|
| Height | 56 |
| Radius | 16 |
| Fill | `#FFFBF4` |
| Border default | `#E8D8C8`, 1 px |
| Border focus | `#A65D3F`, 1.5 px |
| Focus shadow | `0 6 18 rgba(166,93,63,.16)` |
| Text | Poppins Medium 13.5, placeholder `#A38F80` |
| Variants | Default, Focus, Error, Filled |

### Login card

| Properti | Nilai |
|---|---|
| Width | 372 (margin 20 kiri/kanan) |
| Radius | 30 |
| Padding | 22 kiri/kanan, 14 atas, 20 bawah |
| Fill | `linear-gradient(180deg, #FFFDF9 0%, #FFF8EF 56%, #FCF2E7 100%)` |
| Border | 1 px `rgba(255,255,255,.70)` |
| Shadow | `0 22 44 rgba(20,10,4,.55)` + `0 4 12 rgba(20,10,4,.35)` |
| Gloss line | 1.2 px, gradient putih transparan → putih → transparan |

### Onboarding

| Elemen | Nilai |
|---|---|
| Hero card | 368 × 452, radius 34 |
| Drink accent | 82 × 82, border 2 `#FFFCF7` |
| Layered cards | 168 × 202 / 166 × 200 / 208 × 240, border 3 putih |
| Phone mockup | 208 × 362, radius 36, padding 6 |
| Success chip | radius 16, fill `#FFFCF7`, border `#EADCCB` |
| Dots | inactive 8 × 8, active 26 × 8, radius 999 |

### Komponen lain (untuk layar berikutnya)

- Bottom navigation 5 item dengan active pill gradient.
- Product card (image 4:3, nama, harga, tombol tambah).
- Quantity stepper (28/34 px button, angka di tengah).
- Snackbar espresso radius 18 dengan ikon emas.
- Pull-to-refresh chef bubble 52 × 52.
- Skeleton shimmer 118 × 12, radius 8.

---

## 5. Design tokens

### A. Tokens Studio

1. Install plugin **Tokens Studio for Figma**.
2. Buka plugin → **Import** → pilih `tokens/kedai-ummi.tokens.json`.
3. Gunakan tombol **Create styles** bila tersedia, atau buat style manual dari nilai token.
4. Terapkan ke frame:
   - Color styles → fill & stroke.
   - Text styles → tipografi.
   - Effect styles → shadow.
   - Spacing/radius → Auto Layout dan corner radius.

### B. Style manual (jika tidak memakai plugin)

Gunakan frame **00 · Foundations** sebagai acuan:

- Color: 10 swatch utama + status.
- Typography: Display 26/800, Title 19/800, Body 14/500, Label 12/700, Eyebrow 9.5/800.
- Radius: 16 / 20 / 24 / 30 / 32 / 999.
- Shadow: Card, Float, Button.
- Motion: 150 / 250 / 350 / 500 / 2350 ms.

---

## 6. Prototype & Smart Animate

| Interaksi | Timing | Catatan |
|---|---|---|
| Splash → Onboarding | 2350 ms | Setelah animasi selesai; Smart Animate 350 ms |
| Logo splash masuk | 2350 ms | Scale `0.65 → 1`, easeOutBack, fade-in |
| Food splash | 2350 ms | Slide-up 40 px + fade + scale `0.88 → 1` |
| Onboarding swipe / Next | 350 ms | easeOutQuint; parallax layer ±22 px |
| Onboarding → Login | 250 ms | Fade + slide 5.5% dari kanan |
| Login button press | 150 ms | Scale `0.975`; loading spinner setelah tap |
| Snackbar muncul | 520 ms | Slide dari bawah + scale `0.94 → 1` (elasticOut) |
| Snackbar dismiss | 2800 ms | Auto-dismiss; swipe horizontal |
| Pull-to-refresh | 0–110 px | Chef hat mengikuti tarikan; ring terisi |
| Refresh selesai | 720 ms | Ring → check hijau |
| Product card → detail | 350 ms | Shared element (Smart Animate pada image) |

**Tips Smart Animate:** beri nama layer yang sama di frame asal/tujuan (contoh `hero-food`, `login-card`, `brand-logo`), lalu aktifkan Smart Animate pada prototype.

---

## 7. Fix-up checklist setelah import

Hasil html.to.design biasanya 85–95% mirip. Rapikan item berikut:

- [ ] **Background blur**: pilih foto latar splash/login → Layer blur 12–15 px.
- [ ] **Food plate**: ganti inset shadow HTML dengan **ellipse mask** + radial feather agar tepi melebur ke latar.
- [ ] **Gradient text logo**: HTML memakai Pacifico + gradient + stroke. Jika Figma mengimpornya sebagai teks solid, ganti dengan logo vektor resmi atau image fill.
- [ ] **Emoji 👋** di “Selamat Datang”: pastikan font emoji aktif; jika tidak, ganti dengan ikon vektor.
- [ ] **Glow**: pastikan ellipse radial gradient, bukan warna solid.
- [ ] **Shadow**: samakan dengan effect style dari tokens.
- [ ] **Radius**: cek field 16, button 20, card 24/30, hero 34.
- [ ] **Foto**: jika ada yang kosong, drag dari `assets/images/products/` lalu set sebagai image fill.
- [ ] **Auto Layout**: aktifkan pada card, field, tombol, dan teks agar responsif.

---

## 8. Handoff

- Frame tetap **412 × 915**; jangan scale isi secara manual.
- Export aset **2×** atau **3×** (PNG/WebP).
- Nama frame disarankan sama dengan route aplikasi:
  - `01 · Splash` → `/splash`
  - `02 · Onboarding — Welcome` → `/onboarding` (page 0)
  - `03 · Onboarding — Menu` → `/onboarding` (page 1)
  - `04 · Onboarding — Order` → `/onboarding` (page 2)
  - `05 · Login` → `/login`
- Simpan foto asli di `assets/images/products/`; jangan pakai placeholder.
- Catatan: logo pada HTML adalah rekonstruksi CSS dari `BrandMark` Flutter. Untuk produksi, gunakan logo vektor resmi. Maskot chef 3D belum tersedia sebagai aset.

---

## 9. Kenapa bukan file `.fig`?

Figma tidak menyediakan API publik untuk membuat file `.fig` dari luar. Paket ini dibuat agar bisa **diimpor menjadi layer Figma yang bisa diedit** lewat html.to.design, lalu dirapikan dengan tokens dan panduan di atas.
