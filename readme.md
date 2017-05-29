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

### `tembak-mantra.js`
Adalah _file_ untuk mengetes API E-RK yang dibuat untuk MANTRA dan koneksinya ke server tempat aplikasi E-RK.

### `get_lpse_fields.js`
Adalah file untuk memparsing data hasil LPSE dan hasilnya dicatat di `lpse_fields.txt`
