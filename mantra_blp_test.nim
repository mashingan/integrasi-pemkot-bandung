import unittest, uri, json
import mantra_test_vars

let
  tahun = "/tahun=2017"
  blp = "blp"

var response: JsonNode

proc urlPejabat(fungsi: string): string =
  $(urlmantra / blp / "pejabat" / fungsi) & tahun
proc urlPekerjaan(fungsi: string): string =
  $(urlmantra / blp / "pekerjaan" / fungsi)

suite "Test BLP API (Badan Layanan Pengadaan)":
  test "API mendapatkan pengguna anggaran tahun tertentu":
    runtestOf("26m3vhl101", "pengguna_anggaran".urlPejabat)
  test "API mendapatkan pejabat pembuat komitmen tahun tertentu":
    runtestOf("yc99v54kh9", "pembuat_komitmen".urlPejabat)
  test "API mendapatkan pejabat pengadaan barang/jasa tahun tertentu":
    runtestOf("e71araol25", "pengadaan_barang_jasa".urlPejabat)
  test "API mendapatkan pejabat penerima hasil pekerjaan tahun tertentu":
    runtestOf("6wj8kj2ee5", "penerima_hasil_pekerjaan".urlPejabat)
  test "API mendapatkan aset dengan dinas dan tahun tertentu":
    runtestOf("tv8geflfeh", $(urlmantra / blp / "asset" / "dinas") &
      tahun & "&dinas=Dinas%20Komunikasi%20dan%20Informatika")

  test "API melihat pekerjaan pada halaman tertentu":
    runtestOf("dcjk4di2q4", "get_pekerjaan".urlPekerjaan & tahun &
      "&kode_unit=2.10.01.01&page=1&limit=5")
  test "API melihat rincian pekerjaan":
    runtestOf("7x3hz6whkq", "rincian_pekerjaan".urlPekerjaan & "/pid=33204")
