# PC Logo 1.0.0

PC Logo adalah aplikasi Flutter Android untuk mengelola Shizuku, memilih target Free Fire Normal/MAX, mencari port lokal yang tersedia, menulis/menghapus `localconfig.json` melalui Shizuku, serta menjalankan server HTTP diagnostik lokal dengan log real-time.

## Catatan kompatibilitas

Workflow menggunakan Flutter 3.27.0, Java 17, Gradle 8.7, dan AGP 8.5.0.

`shizuku_api` 1.2.1 digunakan karena kompatibel dengan Dart 3.x yang dipakai Flutter 3.27. Plugin tersebut mensyaratkan minSdk 24. Android 9+ tetap didukung dan menjadi target penggunaan utama.

## Yang benar-benar diimplementasikan

- Splash screen dark aesthetic.
- Popup informasi pertama kali dibuka dengan link WhatsApp dan Telegram yang dapat diganti di `lib/core/constants.dart`.
- Monitoring binder dan izin Shizuku setiap 5 detik.
- Dialog permintaan izin Shizuku dan keluar dari aplikasi jika ditolak.
- Start/Stop service.
- Port 5030 diprioritaskan; jika terpakai, aplikasi mencari port lain yang tersedia.
- Penulisan dan penghapusan `localconfig.json` menggunakan `shizuku_api`.
- Pilihan Free Fire Normal atau MAX.
- Server HTTP nyata pada `0.0.0.0:<port>`.
- Endpoint diagnostik `/Ping` dan `/health`.
- Log request, response, error, start/stop, dan perubahan port.
- Tombol clear log.
- Endpoint `/MajorLogin` sengaja menolak dengan HTTP 501 dan tidak memproses kredensial/autentikasi game.
- Event Vercel opsional hanya mengirim metadata HTTP yang sudah disanitasi; isi body autentikasi tidak dikirim.

## Batasan keamanan

Project ini tidak menyertakan implementasi dekripsi/intersepsi/modifikasi/replay traffic `MajorLogin`, perubahan protobuf `GameData`, `EMULATOR_FIELDS`, ataupun forwarding hasil autentikasi ke endpoint eksternal. Komponen tersebut dapat digunakan untuk memodifikasi atau membypass autentikasi game.

`assets/diagnostic_server.py` hanya merupakan referensi server diagnostik yang aman. Android/Flutter tidak menyediakan Python runtime secara default, sehingga runtime on-device menggunakan `HttpServer` Dart di `lib/core/request_handler.dart`.

## Struktur

```text
lib/
├── main.dart
├── core/
│   ├── constants.dart
│   ├── request_handler.dart
│   └── utils.dart
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   └── log_screen.dart
├── services/
│   ├── shizuku_service.dart
│   ├── port_service.dart
│   ├── config_service.dart
│   ├── python_service.dart
│   └── vercel_service.dart
├── widgets/
│   ├── info_popup.dart
│   ├── log_viewer.dart
│   ├── animated_button.dart
│   └── server_status_card.dart
└── models/
    ├── log_entry.dart
    └── server_config.dart
```

## Setup

1. Install Flutter 3.27.0 dan Android SDK.
2. Pastikan Java 17 tersedia.
3. Install Shizuku pada perangkat Android.
4. Jalankan:

```bash
flutter pub get
flutter analyze
flutter build apk --release
```

APK release ada di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## GitHub Actions

File `.github/workflows/build_apk.yml` menyediakan workflow manual yang menerima `zip_url` dan `chat_id`, memverifikasi `OWNER_CHAT_ID`, build APK, upload artifact, lalu mengirim hasil/APK ke Telegram.

Secrets yang diperlukan:

- `OWNER_CHAT_ID`
- `TELEGRAM_BOT_TOKEN`

## Mengubah channel support

Edit:

```dart
lib/core/constants.dart
```

Lalu ubah:

```dart
static const whatsappChannel = 'https://whatsapp.com/channel/REPLACE_ME';
static const telegramChannel = 'https://t.me/REPLACE_ME';
```
