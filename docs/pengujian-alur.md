# Pengujian alur siswa–guru

Tanggal: 16 Oktober 2026.

Pengujian dilakukan pada build web di `http://127.0.0.1:7357`, dengan viewport
390 × 844. Test widget tambahan memakai ukuran 390 × 844 dan 320 × 844.
Perangkat yang terdeteksi: Windows, Chrome, dan Edge. Tidak ada perangkat Android
terhubung ataupun sumber emulator Android, sehingga pengujian native Android
masih perlu dilakukan saat perangkat/emulator tersedia.

## Hasil

| Skenario | Hasil | Bukti |
| --- | --- | --- |
| Siswa mengirim karya; karya masuk antrean guru | Lulus | Browser dan test antarmuka |
| Guru menolak dengan catatan; siswa membaca catatan dan mengirim revisi | Lulus | Browser dan test antarmuka |
| Guru menyetujui revisi; karya masuk showcase dan mendapat poin satu kali | Lulus | Browser untuk showcase, test untuk status dan poin |
| Siswa membuat tiket; guru membalas; siswa memilih jawaban sampai Solved | Lulus | Browser dan test antarmuka |
| Karya disetujui dan jawaban diterima tetap tersedia setelah aplikasi dimuat ulang | Lulus | Reload browser/IndexedDB dan pembukaan ulang repository pada test |
| URL karya tidak valid menampilkan error di formulir dan bisa diperbaiki | Lulus | Test antarmuka |
| Tiket dengan judul berupa spasi ditolak tanpa pesan sukses/poin tambahan | Lulus | Test antarmuka |
| Balasan gagal dikirim mempertahankan draft | Lulus | Test antarmuka; simulasi tiket ditutup sebelum pengiriman |
| Navigasi siswa, filter, kartu karya, dan balasan Solved pada lebar 320 piksel | Lulus | Test layout widget |

Data uji browser dipertahankan untuk peninjauan: karya `Uji Alur Karya Revisi`
dan tiket `Uji Tiket Alur 16 Oktober`. Pergantian akun dilakukan melalui logout
dan login antarmuka pada origin yang sama; ini menguji penyimpanan lokal bersama,
bukan sinkronisasi lintas perangkat.

## Perbaikan dari hasil pengujian

- Filter klinik, status/kategori, identitas penulis, nama pembalas, dan penanda
  jawaban terbaik menyesuaikan lebar layar.
- Header formulir dan kategori kartu showcase tidak lagi melebar keluar layar kecil.
- Error unggah ditampilkan di dalam formulir agar tidak tertutup bottom sheet.
- Pembuatan tiket memeriksa hasil provider sebelum menutup formulir atau
  menampilkan sukses. Balasan gagal tidak lagi menghapus draft.
- Kartu tiket memiliki semantik tombol; tombol unggah, logout guru, dan kirim
  balasan memiliki label aksesibilitas.

## Pemeriksaan yang dapat diulang

```sh
flutter test --no-pub test/application_flows_test.dart
flutter test --no-pub
flutter analyze --no-pub
flutter build web --no-pub --no-wasm-dry-run
```

Hasil akhir: 151 test lulus, termasuk 6 test antarmuka baru; analyzer bersih dan
build web berhasil. Test alur menggunakan aplikasi lengkap, `LocalRepository`,
dan `StateStoreStub`, serta login/logout melalui layar aplikasi. Test file database
nyata tetap tercakup dalam `local_persistence_test.dart`.

Pengujian Android fisik, keyboard perangkat, pemilih gambar native, dan lifecycle
Android belum diverifikasi pada tahap ini.
