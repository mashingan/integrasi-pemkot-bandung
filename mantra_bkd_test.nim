import unittest, uri, json
import mantra_test_vars

let
  bkd = "bkd"
  simpeg = "simpeg"
  tahun = "/tahun=2017"
  skpd = "&kode_skpd=1.02.01"

var response: JsonNode

proc getUrl(fungsi: string): string =
  $(urlmantra / bkd / simpeg / fungsi) & tahun

suite "API BKD (Badan Kepegawaian Daerah)":
  test "API mendapatkan data jumlah pegawai terkait tiap SKPD tahun dicari":
    runtestOf("x94vukzrqu", "laporan".getUrl & skpd)
  test "API mendapatkan jumlah satpol pp pada tahun tertentu":
    runtestOf("v20y4fg21b", "satpol_pp".getUrl)
