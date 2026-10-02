# Plant Health Diagnosis App (Frontend) 🌱

Aplikasi ini adalah bagian dari proyek Capstone yang berfokus pada diagnosis kesehatan tanaman melalui pemindaian gambar. Pengguna dapat mendeteksi penyakit tanaman, mendapatkan rekomendasi perawatan, dan berdiskusi dengan sesama pengguna melalui fitur komunitas.

## 🏗 Penjelasan Sistem & Arsitektur

Aplikasi ini dibangun menggunakan framework **Flutter** dan menerapkan **Feature-First Clean Architecture**. Semua *business logic* dan *state management* dikelola sepenuhnya menggunakan **BLoC (Business Logic Component)**.

Pemisahan lapisan (layer) dalam arsitektur ini memastikan kode lebih modular, terstruktur, dan mudah dipelihara (*maintainable*). Setiap fitur diisolasi dan memiliki 3 lapisan utama:
- **Domain Layer:** Berisi abstraksi berupa *Entities* (Model) dan *UseCases* (Business Logic utama aplikasi).
- **Data Layer:** Berisi *Repositories* (Implementasi dari Domain) dan *Data Sources* (Pemanggilan Rest API HTTP).
- **Presentation Layer:** Berisi *BLoC / Events / States* (State Management) dan *Pages / UI* (Tampilan layar).

## ✨ Fitur Utama

1. **🔐 Autentikasi**
   - Login dan Register akun pengguna.
   - Manajemen sesi aman menggunakan JWT Token (`SharedPreferences`).

2. **🔍 Diagnosis Tanaman**
   - Pengambilan gambar langsung menggunakan integrasi kamera perangkat.
   - Menampilkan hasil diagnosis penyakit, golongan penyakit, dan nama ilmiah.
   - Menyediakan panduan dan rekomendasi perawatan tanaman yang terdiagnosis.
   - Menyimpan dan menampilkan riwayat diagnosis terbaru milik pengguna.

3. **👥 Komunitas & Diskusi**
   - Forum diskusi terbuka untuk bertanya atau membagikan info seputar tanaman.
   - Pengguna dapat membuat, mengedit, dan menghapus postingan mereka sendiri.
   - Pengguna dapat berinteraksi dengan melihat dan menambahkan komentar pada postingan lain.

4. **👤 Profil**
   - Menampilkan data informasi profil pengguna.
   - Dukungan logout dari sesi saat ini.

## 📁 Struktur Direktori

Proyek ini diorganisasikan dengan pendekatan *Feature-Driven*. Berikut adalah gambaran topologi struktur folder di dalam direktori `lib/`:

```text
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart       # Konfigurasi terpusat (contoh: Base URL API)
│   └── models/                      # Model data global (Diagnosis, Komunitas, dll)
│
├── features/
│   ├── auth/                        # Fitur Autentikasi (Login/Register)
│   │   ├── data/                    # Remote Data Source & Repo Impl
│   │   ├── domain/                  # UseCases & Repo Interface
│   │   └── presentation/            # AuthBloc & Tampilan Layar UI
│   │
│   ├── community/                   # Fitur Forum Komunitas
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── diagnosis/                   # Fitur Kamera, Hasil Diagnosis & Riwayat
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── profile/                     # Fitur Profil Pengguna
│   │   ├── data/
│   │   ├── domain/
│   └── presentation/
│   │
│   ├── home/                        # Fitur Halaman Utama (Home & Bottom Navigation)
│   └── splash/                      # Halaman Splash Screen awal
│
└── main.dart                        # Entry point aplikasi & injeksi MultiBlocProvider
```

## 🛠 Teknologi Utama

- **Flutter** - UI Framework
- **BLoC (flutter_bloc)** - Pattern State Management
- **equatable** - Untuk komparasi objek *state* BLoC
- **http** - Klien Rest API
- **shared_preferences** - Penyimpanan lokal (Token session)
- **camera** - Akses perangkat keras kamera
- **cached_network_image** - Optimasi performa gambar pada UI
