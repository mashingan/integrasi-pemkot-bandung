import unittest, uri
from json import JsonNode
import mantra_test_vars

suite "Test BPKA API":
  var
    skpd = "/kode_skpd=1.02.01"
    bpka = "bpka"
    jenis = ["budgeting", "realisasi"]
    response: JsonNode

  proc getUrl(apifungsi: string, idx: int): string =
    $(urlmantra / bpka / jenis[idx] / apifungsi)

  template listingUnit(acckey, fungsi: string) =
    runtestOf(acckey, fungsi.getUrl 0)
  template listingPerUnit(acckey, fungsi: string) =
    runtestOf(acckey, fungsi.getUrl(0) & skpd)

  test "API untuk melihat kode skpd unit":
    listingUnit("48d5stdaae", "get_unit")
  test "API untuk melihat kode subunit skpd":
    listingUnit("3msv1421lb", "get_subunit")
  test "API untuk melihat kode program skpd":
    listingUnit("9hzpxbqkhy", "get_program")

  test "API untuk melihat anggaran dpa untuk 1 skpd":
    listingPerUnit("4pmnf8qba", "get_dpa_perunit")
  test "API untuk melihat anggaran kegiatan untuk 1 skpd":
    listingPerUnit("16ar3g33e9", "get_kegiatan_perunit")
  test "API untuk melihat anggaran program untuk 1 skpd":
    listingPerUnit("jxu1fzqabo", "get_program_perunit")

  let tahun = "tahun=2017"
  let periode = "&periode=triwulan"
  template listingRealisasi(acckey, fungsi: string) =
    runtestOf(acckey, fungsi.getUrl(1) & skpd & "&" & tahun & periode)
  test "API untuk melihat realisasi kegiatan 1 skpd tahun tertentu":
    listingRealisasi("ns7h585nsg", "kegiatan")
  test "API untuk melihat realisasi program 1 skpd tahun tertentu":
    listingRealisasi("s3kt3ntp7l", "program")
  test "API untuk melihat realisasi keseluruhan 1 skpd tahun tertentu":
    listingRealisasi("qi6u02q66i", "skpd")
  
  test "API untuk mendapatkan data hibah semua nama penerima dan no_sp2d":
    runtestOf("2sd0vmf8by", "hibah".getUrl(1) & "/" & tahun & "")
    skip()
    #TODO: cari no_sp2d

  template listingBelanja(acckey, fungsi: string) =
    runtestOf(acckey, fungsi.getUrl(1) & "/" & tahun)
  test "API realisasi belanja per skpd per tahun":
    listingBelanja("j1elayu0t4", "belanja_skpd")
  test "API realisasi belanja modal per skpd per tahun":
    listingBelanja("3ps5o0ik1d", "belanja_modal")
  test "API realisasi belanja pemeliharaan per skpd per tahun":
    listingBelanja("ar1xyhouky", "belanja_pemeliharan")
  test "API realisasi belanja barang jasa per skpd per tahun":
    listingBelanja("0mww388ahm", "belanja_barang_jasa")

  test "API total anggaran per skpd per tahun":
    runtestOf("3ybshlgjko", "total_anggaran_skpd".getUrl(0) & "/" & tahun)
  test "API total APBD per tahun":
    runtestOf("engz37rc76", "total_apbd".getUrl(0) & "/" & tahun)

  test "API realisasi program and kegiatan skpd per tahun":
    listingRealisasi("078rqobwao", "program_kegiatan")
