# AGENTS.md

Panduan ini digunakan oleh Claude Code / agent AI saat bekerja di repository **`invoice.swift`** — aplikasi invoice generator native macOS yang offline-first. Dokumen ini mengikuti struktur panduan agent pada repository lain, tetapi seluruh aturan dan isinya disesuaikan dengan project brief invoice ini.

**Dokumen sumber kebenaran:** [`docs/PROJECT_BRIEF_OFFLINE_MACOS_INVOICE_GENERATOR.md`](docs/PROJECT_BRIEF_OFFLINE_MACOS_INVOICE_GENERATOR.md). Kalau panduan ini bertabrakan dengan project brief, **project brief yang menang** — lalu perbaiki panduan ini.

## Ringkasan Proyek

`invoice.swift` adalah aplikasi utilitas macOS untuk membuat, menyimpan, mengelola, dan mengekspor invoice secara lokal.

Alur utama:

1. Pengguna membuka aplikasi.
2. Pengguna memilih atau membuat client.
3. Pengguna menambahkan produk/jasa ke invoice.
4. Pengguna mengatur metadata invoice, pajak, diskon, pembayaran, catatan, dan branding.
5. Pengguna melihat live preview saat mengedit.
6. Invoice disimpan otomatis secara lokal.
7. Invoice diekspor sebagai PDF atau PNG.
8. Status invoice dilacak sebagai draft, unpaid, paid, overdue, atau cancelled.

Produk ini harus terasa seperti aplikasi Mac yang fokus dan matang — bukan web app yang dibungkus menjadi desktop app, CRUD demo, atau dashboard SaaS generik.

## Status Repository Saat Ini

Repository saat ini masih berupa scaffold SwiftUI minimal:

- `invoice.swift/MyApp.swift` — app entry point.
- `invoice.swift/ContentView.swift` — view awal.
- `invoice.swift.xcodeproj/` — project Xcode.
- `docs/PROJECT_BRIEF_OFFLINE_MACOS_INVOICE_GENERATOR.md` — brief dan sumber kebenaran produk.

Struktur arsitektur pada bagian selanjutnya adalah target bertahap, bukan klaim bahwa seluruh folder atau fitur tersebut sudah ada. Jangan membuat refactor besar hanya untuk mencocokkan struktur target sebelum fase yang bersangkutan dikerjakan.

Sebelum Fase 1, verifikasi di Xcode bahwa target dan scheme memang dikonfigurasi sebagai aplikasi macOS. Project file saat ini masih berupa scaffold yang dibuat tool dan memuat setting Apple generik; jangan mengasumsikan destination, deployment target, atau perilaku iOS/Catalyst tanpa memeriksanya.

## Batas Produk yang Mengikat

Produk awal harus:

- sepenuhnya berfungsi tanpa internet;
- tidak membutuhkan account, login, backend, atau database remote;
- menyimpan data invoice, client, katalog, dan business profile di Mac pengguna;
- memakai Apple frameworks jika memungkinkan;
- menjaga data invoice tetap privat di device;
- menyediakan persistence lokal yang dapat dipulihkan;
- menghasilkan dokumen invoice yang layak dikirim ke client nyata;
- mendukung light mode dan dark mode untuk UI aplikasi, tetapi invoice tetap print-oriented;
- mendukung multi-currency dan locale-sensitive formatting;
- memprioritaskan data integrity, perhitungan uang, dan kualitas dokumen di atas fitur tambahan.

Jangan memasukkan web app, Android/iOS companion, online account, team collaboration, cloud backend, payment gateway, email delivery, recurring billing, accounting suite, inventory management, payroll, CRM, atau AI features ke MVP.

## Teknologi Utama

- **Platform:** macOS native.
- **Bahasa/UI:** Swift + SwiftUI.
- **Persistence:** SwiftData, kecuali ada alasan teknis yang terdokumentasi untuk memilih alternatif.
- **Dokumen:** PDFKit dan/atau Core Graphics sesuai kebutuhan renderer.
- **Pembayaran/entitlement:** StoreKit 2, tetapi hanya diisolasi di boundary entitlement.
- **Grafik:** Swift Charts hanya jika chart dashboard benar-benar diperlukan.
- **Interop:** AppKit hanya ketika SwiftUI tidak menyediakan perilaku native yang dibutuhkan.
- **Testing:** unit test untuk domain, persistence/backup, status, numbering, dan renderer yang deterministik bila memungkinkan.

Hindari third-party dependency. Setiap dependency baru harus memiliki alasan tertulis, manfaat yang jelas, dan penilaian terhadap ukuran binary, maintenance, privacy, serta kebutuhan offline.

## Struktur Folder Target

Gunakan struktur modular yang sederhana dan bertumbuh bersama fitur:

```text
invoice.swift/
├── App/
│   ├── AppEntry/
│   └── Navigation/
├── Domain/
│   ├── Models/
│   ├── Money/
│   ├── InvoiceCalculation/
│   └── Validation/
├── Data/
│   ├── Persistence/
│   ├── Repositories/
│   └── Backup/
├── Features/
│   ├── Dashboard/
│   ├── Invoices/
│   ├── Clients/
│   ├── Catalog/
│   ├── Business/
│   └── Settings/
├── Documents/
│   ├── Templates/
│   ├── Rendering/
│   ├── PDF/
│   └── ImageExport/
├── Services/
│   ├── Export/
│   ├── Backup/
│   ├── StoreKit/
│   └── FileSystem/
├── Shared/
│   ├── Components/
│   ├── Extensions/
│   └── Utilities/
└── Resources/
```

Arah dependensi yang diharapkan:

```text
SwiftUI Feature → Service/Repository → Domain
Documents Renderer → normalized document model → Domain snapshots
```

`Domain` tidak boleh bergantung pada SwiftUI view. Business logic tidak boleh diletakkan langsung di body view. Protocol hanya dibuat bila memberi testability, replaceability, atau boundary arsitektur yang nyata — bukan untuk abstraksi kosong.

## Perintah Penting

Sesuaikan scheme dan destination dengan konfigurasi Xcode yang sedang berlaku:

```bash
xcodebuild -list -project invoice.swift.xcodeproj
xcodebuild -project invoice.swift.xcodeproj -scheme invoice.swift -configuration Debug build
xcodebuild -project invoice.swift.xcodeproj -scheme invoice.swift -configuration Debug test -destination 'platform=macOS'
git diff --check
```

Kalau `xcodebuild` tidak tersedia karena environment hanya memiliki Command Line Tools, jangan menganggap itu sebagai kegagalan kode. Developer perlu menjalankan build/test dari Xcode dengan toolchain macOS yang sesuai.

## Prinsip Desain — Mengikat Seluruh Implementasi

**P1 — Offline adalah requirement inti.** Core functionality tidak boleh bergantung pada internet, API remote, account, analytics, cloud sync, atau database remote. Aplikasi harus tetap usable ketika network dimatikan.

**P2 — Data adalah milik pengguna.** Data invoice dan client tetap berada di Mac pengguna. Tidak ada invoice content, client information, atau business data yang dikirim keluar device tanpa aksi ekspor/share yang eksplisit.

**P3 — Uang harus deterministic dan money-safe.** Jangan gunakan `Double` atau `Float` untuk menyimpan atau menghitung uang. Gunakan `Decimal` atau representasi integer minor unit dengan aturan rounding yang eksplisit dan konsisten.

**P4 — Invoice historis tidak boleh berubah diam-diam.** Invoice harus menyimpan snapshot data client dan business profile yang relevan ketika dibuat/diterbitkan. Perubahan pada client, catalog item, atau business profile di masa depan tidak boleh mengubah dokumen invoice lama secara tidak terduga.

**P5 — Satu document model untuk semua output.** Live preview, PDF export, PNG export, dan print harus memakai normalized invoice document model serta rendering primitives yang sama sejauh praktis. Jangan memelihara layout preview dan export yang terpisah lalu membiarkannya menyimpang.

**P6 — Persistence dan backup harus dapat dipercaya.** Autosave tidak boleh mengorbankan integritas data. Backup harus divalidasi sebelum restore, operasi file penting dibuat seaman mungkin, dan restore tidak boleh mengganti data aktif dengan backup yang rusak atau tidak kompatibel.

**P7 — Nomor invoice tidak boleh bentrok.** Sistem harus mencegah duplicate invoice number, tidak boleh overwrite invoice lain, dan tidak boleh diam-diam memakai kembali nomor yang sudah pernah dialokasikan.

**P8 — Native macOS lebih penting daripada imitasi web.** Gunakan NavigationSplitView, sidebar, menu command, keyboard shortcut, focus state, context menu, file picker, drag-and-drop, undo/redo, semantic colors, dan native controls jika sesuai. Jangan mengubah aplikasi menjadi dashboard web dengan kartu dan dekorasi berlebihan.

**P9 — Core domain tidak boleh terikat StoreKit.** Feature gating diisolasi di balik boundary seperti `EntitlementProviding`. Invoice creation, local persistence, dan domain calculations tetap dapat diuji tanpa StoreKit dan tidak boleh mengandung logika pembelian.

**P10 — Kecepatan dan reliability adalah bagian dari UX.** Jangan memblokir main thread dengan PDF/image generation atau operasi file besar. App harus tetap responsif saat mengedit invoice besar, memuat banyak invoice, atau mengekspor dokumen.

**P11 — Correctness mengalahkan banyaknya fitur.** Urutan prioritas: data integrity, financial calculation, PDF/document correctness, persistence, native UX, performance, visual polish, lalu fitur tambahan.

## Aturan Wajib Saat Menulis/Mengubah Kode

1. **Gunakan `Decimal` untuk uang.** Semua subtotal, discount, tax, grand total, harga katalog, dan payment amount harus melewati calculation layer yang money-safe. Jangan melakukan intermediate calculation memakai binary floating point.

2. **Tetapkan aturan rounding secara eksplisit.** Rounding harus konsisten di calculation engine, preview, PDF, dan export lain. Tambahkan test untuk IDR, currency desimal, diskon, pajak, nol quantity, nol harga, serta kasus rounding.

3. **Snapshot data invoice.** Jangan hanya menyimpan reference live ke `Client`, `BusinessProfile`, atau `CatalogItem` bila perubahan entity tersebut dapat mengubah invoice historis. Simpan nilai client/business/item yang dibutuhkan untuk merekonstruksi dokumen lama.

4. **Jaga invoice numbering secara persisten.** Sequence, prefix, separator, year, padding, dan collision prevention harus berada di domain/service yang dapat diuji. Jangan membuat nomor hanya dari jumlah item di list atau timestamp tanpa mekanisme duplicate prevention.

5. **Status invoice harus mempunyai satu sumber kebenaran.** Status yang didukung: `draft`, `unpaid`, `paid`, `overdue`, dan `cancelled`. Overdue dihitung dari due date dan payment state sesuai kebijakan domain; jangan menduplikasi aturan status di banyak view.

6. **Pisahkan calculation engine dari UI.** View hanya mengedit state dan menampilkan hasil. Calculation engine tidak boleh bergantung pada SwiftUI, environment, atau layout view.

7. **Gunakan SwiftData dengan migration strategy yang disengaja.** Jangan mereset store, menghapus database pengguna, atau memakai destructive migration sebagai jalan pintas. Perubahan schema harus dipikirkan untuk data yang sudah ada.

8. **Restore backup harus aman.** Validasi format, versi schema, dan isi backup sebelum mengganti data aktif. Jika restore gagal, data aktif harus tetap utuh. Prefer atomic write/replace dan sediakan error yang dapat dipahami pengguna.

9. **Gunakan satu pipeline rendering.** Alur ideal:

   ```text
   Invoice Data
       ↓
   Normalized Invoice Document Model
       ↓
   Template Renderer
       ↓
   Live Preview / PDF / PNG / Print
   ```

   Renderer wajib menangani A4 sebagai default, US Letter, margin, typography, pagination, long descriptions, logo besar, notes multi-line, dan total yang berpindah halaman tanpa clipping.

10. **Jangan melakukan PDF/image generation berat di main thread.** Gunakan concurrency atau background work yang sesuai, lalu kembali ke main actor hanya untuk update UI.

11. **Currency dan locale tidak boleh hard-coded ke Indonesia.** Minimal dukung IDR, USD, EUR, SGD, dan MYR melalui currency code serta locale-sensitive formatting. Fitur PPN, istilah Indonesia, template Indonesia/Inggris, bank detail, dan QRIS boleh ditambahkan tanpa membuat asumsi Indonesia menjadi kewajiban model inti.

12. **Simpan file di lokasi macOS yang predictable.** Gunakan Application Support untuk data aplikasi dan backup internal. Jangan menulis ke lokasi acak atau mengandalkan current working directory.

13. **Jaga privacy dalam logging.** Jangan log invoice content, nama client, nomor telepon, alamat, tax ID, payment details, atau business data. Error log harus cukup untuk diagnosis tanpa membocorkan data sensitif.

14. **Gunakan native macOS interaction.** Shortcut dan menu harus memiliki perilaku nyata. Tombol Save tidak boleh kosmetik bila autosave digunakan; jelaskan atau implementasikan semantics-nya dengan benar.

15. **Hindari giant SwiftUI views.** Pecah view berdasarkan konsep yang bermakna, bukan membuat abstraksi kecil untuk setiap baris. Jangan memindahkan business logic ke view hanya demi memperpendek file.

16. **StoreKit hanya di boundary entitlement.** Implementasi Pro/free tidak boleh mengunci data model inti ke produk StoreKit. One-time purchase lebih disukai daripada subscription bila monetisasi diimplementasikan.

17. **Tambahkan test bersama domain kritis.** Jangan menunda test calculation, numbering, status, backup validation, dan invariants persistence sampai akhir seluruh project.

18. **Commit message wajib Bahasa Inggris.** Percakapan dan komentar kode boleh Bahasa Indonesia, tetapi commit message harus singkat, deskriptif, dan dalam Bahasa Inggris.

## Model Domain Minimum

Model awal yang diharapkan:

```text
BusinessProfile
Client
CatalogItem
Invoice
InvoiceLineItem
PaymentRecord        # dapat sederhana pada MVP; dukung partial payment nanti
AppSettings
```

`Invoice` setidaknya perlu menampung:

- client snapshot;
- business profile snapshot;
- invoice number;
- issue date dan due date;
- currency;
- line items;
- subtotal, discount, tax, dan total yang dapat direkonstruksi;
- payment state dan paid date;
- notes, payment details, dan custom fields bila sudah diaktifkan;
- template dan appearance settings yang dibutuhkan untuk mereproduksi dokumen.

`Client` minimal memiliki display name, company name, email, phone, billing address, optional tax ID, dan notes. `CatalogItem` minimal memiliki name, description, default price, optional SKU/unit, dan default tax behavior.

## Dokumen dan Rendering

Invoice adalah output utama produk. Kualitas renderer diperlakukan setara dengan kualitas UI.

Aturan renderer:

- A4 adalah default untuk target pengguna Indonesia; US Letter juga harus didukung.
- Template Minimal, Mono, Modern, dan Classic memakai data model yang sama.
- Business logic tidak boleh diduplikasi di setiap template.
- Template hanya bertanggung jawab atas presentation.
- Preview harus mendukung zoom, fit-to-page, dan multiple pages.
- Export harus mempertahankan page size, typography, margin, logo, spacing, dan pagination.
- Uji 1 item, 50+ item, deskripsi multi-line, company name panjang, logo besar/tidak ada, kombinasi discount + tax, notes panjang, dan total yang overflow.
- Preview dan hasil PDF harus diverifikasi bersamaan; perubahan hanya pada salah satu pipeline tidak dianggap selesai.

## Persistence, Backup, dan Recovery

Gunakan SwiftData secara default. Pertimbangkan lokasi data seperti:

```text
Application Support/
└── AppName/
    ├── Data/
    └── Backups/
        ├── Daily/
        ├── Weekly/
        └── Monthly/
```

MVP harus menuju perilaku berikut:

- autosave selama editing normal;
- rolling daily backups;
- beberapa daily version terakhir;
- weekly snapshot;
- monthly snapshot;
- `Export Backup`;
- `Restore Backup`;
- validasi backup sebelum restore;
- penanganan backup corrupt, versi tidak didukung, dan file logo yang rusak tanpa crash.

Backup yang belum pernah diuji restore belum dianggap sebagai backup yang dapat dipercaya.

## Peta Fase Implementasi

Implementasi harus mengikuti urutan berikut. Fase berikutnya tidak dimulai hanya karena sebagian file fase sebelumnya sudah ada; fase sebelumnya harus memenuhi kriteria selesai dan telah diverifikasi developer.

### Fase 1 — Foundation

Ruang lingkup:

- project structure dan application shell;
- navigation/sidebar native;
- SwiftData models dan persistence boundary;
- Business Profile;
- Clients;
- Catalog;
- Invoice domain model;
- money-safe invoice calculation engine;
- unit tests untuk calculation dan invariants domain.

Kriteria selesai:

- app dapat dibuka dengan shell native macOS;
- navigasi dasar tersedia tanpa dashboard berlebihan;
- business profile, client, catalog item, dan invoice dapat disimpan lokal;
- calculation engine terpisah dari view dan memiliki test untuk subtotal, discount, tax, total, rounding, IDR, dan currency desimal;
- snapshot boundary invoice sudah ditentukan;
- tidak ada network/backend/StoreKit yang diperlukan.

Verifikasi manual oleh developer:

1. Buat business profile, client, catalog item, dan invoice.
2. Tutup lalu buka kembali app dan pastikan data tetap ada.
3. Ubah client/catalog setelah invoice dibuat dan pastikan aturan snapshot yang disepakati tidak merusak data invoice.
4. Coba input angka uang dan currency utama yang didukung, lalu cocokkan hasil perhitungan dengan expected result.

### Fase 2 — Invoice Workflow

Ruang lingkup:

- invoice list;
- create/edit/duplicate/delete invoice;
- split invoice editor;
- client selection;
- catalog selection dan manual item entry;
- line item add/remove/reorder;
- invoice numbering;
- draft/unpaid/paid/overdue/cancelled;
- autosave;
- search, filter, dan sort dasar bila tidak mengganggu workflow inti.

Kriteria selesai:

- pengguna dapat menyelesaikan satu invoice dari awal sampai tersimpan;
- nomor invoice tidak duplicate, overwrite, atau reuse diam-diam;
- perubahan editor tersimpan otomatis dan tidak menghilang saat navigasi normal;
- perubahan status menghasilkan perilaku domain yang konsisten;
- invoice list dapat menemukan invoice yang telah dibuat;
- business logic tetap berada di domain/service, bukan tersebar di view.

Verifikasi manual oleh developer:

1. Buat dua invoice berturut-turut dan pastikan numbering sequence benar.
2. Tutup dan buka ulang app di tengah editing draft; pastikan data terakhir yang valid tersimpan.
3. Duplicate invoice lalu pastikan nomor baru tidak bentrok.
4. Uji paid, unpaid, overdue berdasarkan tanggal, draft, dan cancelled.
5. Cari, filter, sort, dan hapus invoice; pastikan invoice lain tidak ikut berubah.

### Fase 3 — Document Engine

Ruang lingkup:

- normalized invoice document model;
- satu template fungsional pertama;
- live preview;
- zoom dan fit-to-page dasar;
- multi-page pagination;
- A4 support;
- PDF export;
- print support.

**Jangan memperluas jumlah template sebelum renderer dan template pertama stabil.**

Kriteria selesai:

- preview berubah segera ketika invoice diedit;
- preview, PDF, dan print memakai sumber data serta rendering primitives yang sama;
- dokumen A4 tidak clipping atau overlap;
- line item panjang, notes panjang, logo, dan total yang berpindah halaman ditangani;
- PDF dapat dibuka dan dicetak dengan page size yang benar;
- export tidak membuat UI hang pada invoice besar.

Verifikasi manual oleh developer:

1. Bandingkan live preview dengan PDF hasil export untuk invoice pendek dan panjang.
2. Uji invoice dengan 1 item, 50+ item, deskripsi multi-line, logo besar, tanpa logo, discount + tax, dan notes panjang.
3. Uji perpindahan subtotal/total ke halaman berikutnya.
4. Buka PDF di Preview dan cetak ke PDF; pastikan ukuran halaman, margin, font, dan isi konsisten.
5. Ubah ukuran window dan pastikan preview tetap usable.

### Fase 4 — Product Polish

Ruang lingkup:

- dashboard ringan dengan total invoiced, total paid, outstanding, overdue, invoice count, dan recent invoices;
- template tambahan;
- zoom controls yang lebih lengkap;
- drag reorder;
- keyboard shortcuts dan native menu commands;
- search/filter yang lebih lengkap;
- dark mode polish;
- empty states;
- validation dan user-facing error handling;
- accessibility labels dan keyboard-only flow.

Kriteria selesai:

- UI terasa native, tenang, compact tetapi breathable;
- tidak bergantung pada warna saja untuk menyampaikan status;
- shortcut seperti `⌘N`, `⌘S`, `⌘P`, `⌘E`, `⌘D`, `⌘F`, dan `⌘,` memiliki perilaku yang benar jika diaktifkan;
- template tambahan tidak menduplikasi calculation/business logic;
- error yang dapat dipulihkan ditampilkan dengan pesan yang dapat dipahami pengguna;
- Light Mode dan Dark Mode tidak merusak editor atau preview print-oriented.

Verifikasi manual oleh developer:

1. Jalankan workflow utama hanya dengan keyboard.
2. Uji context menu, menu bar commands, undo/redo, dan drag reorder.
3. Uji Light Mode dan Dark Mode pada editor, list, dan preview.
4. Uji empty state, invalid input, file logo rusak, dan error export.
5. Uji VoiceOver labels dan contrast pada kontrol penting.

### Fase 5 — Data Safety dan Pro Features

Ruang lingkup:

- automatic local backup;
- backup/restore UI;
- StoreKit 2 integration;
- `EntitlementProviding` dan feature gates;
- PNG export;
- premium templates;
- advanced backup options bila diperlukan.

Kriteria selesai:

- backup berjalan sesuai retention policy tanpa memblokir editing;
- backup corrupt atau versi tidak didukung ditolak sebelum data aktif diganti;
- export dan restore dapat diuji secara deterministik;
- StoreKit tidak masuk ke domain core;
- free workflow tetap jelas dan usable;
- Pro gate tidak menyebabkan data hilang atau invoice tidak dapat dibuka;
- PNG memakai visual representation yang sama dengan template invoice.

Verifikasi manual oleh developer:

1. Export backup, ubah data, lalu restore backup dan pastikan state kembali dengan benar.
2. Coba restore file corrupt, file bukan backup, dan backup versi tidak didukung; pastikan data aktif tetap aman.
3. Verifikasi daily/weekly/monthly retention yang diterapkan.
4. Uji entitlement free dan Pro, termasuk app tanpa koneksi internet.
5. Bandingkan PNG dengan preview/PDF pada invoice pendek dan multi-page.

## Milestone Pengembangan Pertama

Milestone pertama memvalidasi vertical slice berikut:

- native app shell;
- sidebar;
- invoice list;
- client model;
- business model;
- invoice model;
- invoice calculation engine;
- basic invoice editor;
- satu template invoice fungsional;
- live preview;
- local persistence.

Milestone ini **bukan izin untuk mengerjakan semua fase sekaligus**. Deliverable-nya dibangun bertahap melalui Fase 1, Fase 2, lalu bagian renderer yang diperlukan dari Fase 3. StoreKit, analytics, advanced templates, cloud feature, dan Pro feature tidak masuk milestone ini.

## Checklist Sebelum Fase Dianggap Selesai

- [ ] Perubahan hanya menyentuh scope fase aktif.
- [ ] Build/debug configuration berhasil, atau keterbatasan toolchain dijelaskan.
- [ ] Unit test untuk domain kritis berhasil dan tidak bergantung pada network.
- [ ] Tidak ada `Double`/`Float` untuk uang atau intermediate money calculation.
- [ ] Tidak ada data invoice historis yang berubah diam-diam karena reference live.
- [ ] Invoice numbering mencegah duplicate dan reuse yang tidak disengaja.
- [ ] Perubahan SwiftData memiliki migration strategy yang jelas.
- [ ] Preview, PDF, PNG, dan print tidak memiliki pipeline data yang menyimpang.
- [ ] Operasi file/background work tidak memblokir main thread secara tidak perlu.
- [ ] Tidak ada invoice/client/business data yang dikirim ke luar device.
- [ ] Manual verification oleh developer telah dilakukan sesuai fase.
- [ ] Commit terpisah dibuat untuk fase aktif.

## Aturan Pengujian oleh Developer

Verifikasi fungsional dan visual dilakukan **manual oleh developer**, bukan oleh AI model. Tujuannya memastikan app diuji di macOS/Xcode, dengan window system, file picker, Preview, printing, VoiceOver, serta data yang benar.

AI boleh:

- membaca dan menginspeksi repository;
- menjalankan static validation, `git diff --check`, build, dan unit test hermetic bila toolchain tersedia;
- menambahkan unit test;
- memeriksa struktur model, migration plan, dan hasil diff.

AI tidak boleh tanpa instruksi eksplisit developer:

- mengirim data ke network atau menambahkan backend/analytics;
- menghapus SwiftData store pengguna;
- menjalankan destructive migration terhadap data nyata;
- menghapus backup atau invoice pengguna;
- menganggap build berhasil hanya karena source terlihat benar;
- menggantikan verifikasi manual PDF, print, backup restore, accessibility, atau dark mode.

Setelah menyelesaikan satu fase, AI wajib menyerahkan langkah **Verifikasi manual oleh developer** yang bernomor dan diturunkan dari kriteria selesai fase tersebut. Developer menjalankan verifikasi itu dan melaporkan hasilnya sebelum fase berikutnya dimulai.

## Aturan Wajib di Setiap Implementation Plan

Setiap kali AI membuat implementation plan, wajib menyertakan blok berikut apa adanya:

```text
ATURAN PENGERJAAN — WAJIB DIBACA
JANGAN KERJAKAN SEMUA FASE SEKALIGUS.
Kerjakan SATU FASE PER SESI. Setelah satu fase selesai dan diverifikasi, berhenti dan laporkan. Tunggu instruksi sebelum lanjut ke fase berikutnya.
Fase aktif harus mengikuti scope dan Kriteria Selesai yang tertulis di AGENTS.md dan project brief.
Kalau plan membutuhkan perubahan schema SwiftData, jelaskan migration strategy sebelum implementasi.
Checklist di akhir SETIAP fase

1. Build dan unit test yang relevan berhasil, atau kegagalan toolchain dijelaskan
2. Perhitungan uang tetap Decimal/money-safe dan test-nya ada
3. Preview/export tetap memakai document model dan renderer yang sama
4. AI tidak mengirim data ke network, menghapus data pengguna, atau menjalankan verifikasi manual yang menjadi tanggung jawab developer
5. Developer menjalankan Verifikasi manual oleh developer sesuai bagian Kriteria Selesai di fase tersebut
6. Commit terpisah per fase

Larangan umum

* Jangan mengerjakan fase berikutnya dalam sesi fase aktif
* Jangan refactor file di luar daftar "File yang disentuh" pada fase aktif tanpa alasan yang ditulis
* Jangan memakai Double/Float untuk uang
* Jangan mengubah invoice historis melalui reference live yang tidak disengaja
* Jangan mereset SwiftData store atau memakai destructive migration sebagai jalan pintas
* Jangan membuat preview dan PDF dengan dua sumber kebenaran yang berbeda
* Jangan menambah dependency, backend, cloud sync, analytics, atau account flow tanpa scope dan alasan tertulis
* Jangan menambahkan StoreKit ke domain core
* Jangan "sekalian merapikan" kode yang tidak diminta
```

## Aturan Saat Membuat Implementation Plan

Sebelum mengimplementasikan subsystem besar, plan harus menjelaskan:

1. tanggung jawab subsystem;
2. data flow;
3. boundary dengan domain/UI/persistence/renderer;
4. trade-off penting;
5. expected failure cases;
6. file yang disentuh;
7. cara unit test dan manual verification;
8. risiko terhadap data historis dan migration.

Plan harus menyelesaikan satu vertical workflow yang nyata, bukan membuat banyak screen kosong. Jangan meninggalkan placeholder architecture yang lebih rumit daripada kebutuhan fase aktif.

## Definition of Done MVP

MVP usable ketika pengguna dapat:

1. install dan membuka app;
2. mengatur business profile;
3. menambahkan client;
4. menambahkan produk/jasa;
5. membuat invoice;
6. melihat invoice berubah live saat diedit;
7. menerapkan discount dan tax;
8. memilih template;
9. menyimpan invoice lokal;
10. menutup dan membuka kembali app tanpa kehilangan data;
11. mengekspor PDF profesional;
12. mencetak invoice;
13. menandai invoice sebagai paid;
14. mencari invoice lama;
15. mengekspor dan me-restore backup.

Hasil invoice harus cukup baik untuk dikirim langsung ke client nyata tanpa cleanup manual.

## Standar Produk Akhir

Aplikasi akhir harus terasa seperti small, focused Mac app yang layak dibeli dari Mac App Store.

Benchmark-nya adalah:

- clarity;
- reliability;
- document quality;
- polish;
- speed;
- native interaction;
- attention to detail.

Banyaknya fitur bukan benchmark utama. Jangan mengorbankan correctness dokumen atau keamanan data demi UI yang lebih kompleks.
