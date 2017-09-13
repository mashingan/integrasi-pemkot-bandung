import unittest, json, uri, times
import mantra_test_vars

let
  dlhk = "dlhk"
  aqms = "aqms"

var response: JsonNode

proc getUrl(fungsi: string): string =
  $(urlmantra / dlhk / aqms / fungsi) & "/"

suite "API DLHK (Dinas Lingkungan Hidup dan Kebersihan)":
  test "API akses AQMS":
    "".runtestOf(getUrl "info/lokasi=all&tipe_data=all")
  test "API melihat stations AQMS":
    "".runtestOf(getUrl "stations")
  test "API mendapatkan grafik info":
    let
      today = getLocalTime getTime()
      strformat = "dd-MM-yyyy"
      tgl_awal = format(today - 2.days, strformat)
      tgl_akhir = format(today - 1.days, strformat)

    "".runtestOf getUrl("grafik/tanggal_awal=" & tgl_awal &
      "&tanggal_akhir=" & tgl_akhir & "&lokasi=gedebage&tipe_data=NO")
