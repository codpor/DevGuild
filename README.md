# DevGuild

Aplikasi Flutter untuk showcase karya, klinik kode, dan pengelolaan siswa PPLG.

## Menjalankan

```sh
flutter pub get
flutter run
```

Untuk web, gunakan origin dan port yang sama agar database browser yang sama dibuka:

```sh
flutter run -d chrome --web-port 7357
```

Akun demo siswa: NIS `2201`, password `password123`.
Akun demo guru: NIS `9999`, password `admin123`.

## Penyimpanan lokal

Aplikasi menggunakan Sembast. Pada Android, iOS, dan desktop, database `devguild.db`
berada di direktori application support milik aplikasi. Pada web, database `devguild`
disimpan di IndexedDB browser. Data demo hanya diisi jika database belum memiliki state.

Data tersimpan meliputi akun dan hash password, status aktif, foto profil,
karya dan screenshot, revisi serta catatan guru, tiket beserta balasan,
permohonan role, poin, badge, like, dan riwayat aktivitas.
Gambar disimpan sebagai byte database sehingga tidak bergantung pada lokasi file asli.
Pengguna masuk kembali setelah aplikasi dibuka; sesi login tidak disimpan.

Perubahan provider memicu autosave. Notifikasi dalam satu aksi digabungkan, lalu
seluruh state ditulis dalam satu transaksi. Indikator penyimpanan tetap tampil sampai
penulisan selesai. Jika penyimpanan gagal, aplikasi menampilkan pesan dan tombol coba
lagi, sementara database terakhir yang berhasil disimpan tetap dipertahankan.
Penutupan normal desktop menunggu penyimpanan; pemaksaan berhenti saat indikator
masih tampil dapat kehilangan perubahan yang belum selesai ditulis.

Format data memiliki `schemaVersion` (saat ini `1`). Data rusak atau versi yang tidak
didukung menghentikan proses membuka database dan menampilkan opsi coba lagi;
aplikasi tidak menghapus atau mengganti data tersebut dengan data demo.
Pada web, pemeriksaan revisi mencegah tab lama menimpa perubahan dari tab lain.
Saat konflik, buka kembali aplikasi untuk memuat data terbaru. Gunakan satu instance
aplikasi native untuk satu database file.

Database ini berlaku per instalasi/perangkat atau origin browser. Menghapus data
aplikasi/browser menghapus database lokal. Sinkronisasi antarperangkat dan autentikasi
server membutuhkan integrasi backend pada tahap berikutnya.

## Pemeriksaan

```sh
flutter analyze --no-pub
flutter test --no-pub
```

`local_persistence_test.dart` memeriksa alur provider setelah repository dibuka ulang,
kegagalan penyimpanan, konflik revisi, dan penutupan/pembukaan database file nyata.
`storage_ui_test.dart` memeriksa tampilan gagal membuka, gagal menyimpan, dan retry.
`application_flows_test.dart` menguji alur siswa–guru lengkap dan regresi layar kecil.
Hasil dan batas pengujian perangkat tercatat di [laporan pengujian alur](docs/pengujian-alur.md).
