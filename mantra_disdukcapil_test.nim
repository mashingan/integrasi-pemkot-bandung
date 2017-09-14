import unittest, json, uri
import mantra_test_vars

let
  diskominfo = "diskominfo"
  nik = "/nik=3273150911930002"
var response: JsonNode

proc getUrl(layanan, fungsi: string): string =
  $(urlmantra / diskominfo / layanan / fungsi)

suite "API Disdukcapil":
  test "API data penduduk dengan menggunakan NIK":
    runtestOf("bv8t25r1yh", "disdukcapil".getUrl("rsud") & nik)
  test "API data penduduk untuk Dapodik dengan NIK":
    runtestOf("h9v6thxprj", "dapodik".getUrl("disdikcapil") & nik)
  test "API data penduduk untuk sample":
    runtestOf("", "disdukcapil".getUrl("nama") & nik)

  let disdukcapilurl = $urlmantra & "disdukcapil/data/"
  test "API untuk dapat range umur":
    "".runtestOf(disdukcapilurl & "range_umur")
  test "API untuk dapat angkatan kerja":
    "".runtestOf(disdukcapilurl & "angkatan_kerja")
  test "API untuk rekapitulasi data":
    "".runtestOf(disdukcapilurl & "rekap")
