# Macam-Macam Skrip

## Data Dapodik

Terdiri dengan berbagai file yaitu:

1. `disdik_entry.nim`, berlaku sebagai file utama yang akan digunakan untuk skrip-skrip lainnya.
2. `cache_disdik.nim`, mengambil data dari API Dapodik dan membuat database cadangan di server MANTRA.
3. `get_data_dapodik.nim` dan `get_data_dapodik_v2.nim`, memparsing data dapodik dari halaman http://dapodik.disdikkota.bandung.go.id dan membarukan database yang telah dibuat di poin 2.
4. 

### `app.js`
Berlaku sebagai prototipe untuk mikroservis yang kemudian dikembangkan dengan menggunakan _framework_ **Lumens**, PHP.
`app.js` adalah satu skrip _JavaScript_ sederhana dengan _NodeJs_ dengan menggunakan _framework_ **Express**.

### Testing API Simpeg/E-RK
Testing API Simpeg/E-RK adalah sekumpulan _files_ _JavaScript_ untuk mengetes API yang telah dipasang di MANTRA untuk kemudian disambungkan dengan server yang sebenarnya.
Kumpulan _files_ adalah sebagai berikut:
1. `fetchinglib.js` yang bertindak sebagai pustaka umum untuk fungsi-fungsi yang sering digunakan.
2. `tembak-mantra.js` bertindak sebagai pengetesan jalur API secara generik untuk mendapatkan data dari tabel-tabel yang ada di Simpeg/E-RK
3. `get_pegawai_portal.js` bertindak sebagai pengetesan API untuk mendapatkan informasi pegawai berdasarkan kata kunci yang cari.
Baik `tembak-mantra.js` maupun `get_pegawai_portal.js` menggunakan fungsi-fungsi umum yang ada di `fetchinglib.js`.

### `get_lpse_fields.js`
Adalah file untuk memparsing data hasil LPSE dan hasilnya dicatat di `lpse_fields.txt`
