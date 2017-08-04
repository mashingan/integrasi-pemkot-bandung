import unittest, httpclient, json, uri
from securehash import secureHash, `$`
from tables import toTable, `[]`
from strutils import toLowerAscii
from times import epochTime

import mantra_test_vars

const
  keys = {"7na9aj3awo": "ib57tkh5rdjk4mj"}.toTable
  idk = "7na9aj3awo"

proc encodeValue(now: string): string =
  ($secureHash(keys[idk] & now)).toLowerAscii

proc now(): string = $(epochTime() * 1000)

suite "Test BKPP API (Badan Kepegawaian Pendidikan Pelatihan)":

  var
    timenow = now()
    codeval = timenow.encodeValue
    idparam = "&id=" & idk
    keyparam = "&key=" & codeval
    timeparam = "&time=" & timenow
    bkpp = "bkpp"
    limit = "/limit=10"
    page = "&page=1"
    order = "&order=none"
    filter = "&filter=none"
    genparm = limit & page & order & filter & idparam & keyparam &
      timeparam
    response: JsonNode

  proc getUrl(apifungsi, param: string): string =
    $(urlmantra / bkpp / apifungsi / "lihat_isi") & genparm & param

  test "API generik melihat jenis dan laporan aktifitas untuk SILAKIP":
    let
      tableparam = "&table=pegawai"
      fields = "&fields=nip-nama-unit_kerja-nama_jabatan"
      theurl = "erk_aktifitas".getUrl(tableparam & fields)
    runtestOf("3n728l4n6i", theurl)

  test "API generik melihat jenis dan laporan perbulan untuk SILAKIP":
    let
      bulanke = "&ke=3"
      tableparam = "&table=pegawai"
      fields = "&fields=peg_nip-peg_nama-jabatan"
      theurl = "erk_bulan".getUrl(tableparam & fields & bulanke)
    runtestOf("myyayw8xk1", theurl)

  test "API generik melihat jenis dan laporan analisis untuk SILAKIP":
    let
      tableparam = "&table=monitoring_pegawai"
      fields = "&fields=peg_nip-peg_nama-jabatan"
      theurl = "erk_analitik".getUrl(tableparam & fields)
    runtestOf("9p2rtpe7bp", theurl)

  test "API generik melihat jenis dan laporan data pegawai di SIMPEG":
    let
      tableparam = "&table=spg_pegawai"
      fields = "&fields=peg_nip-peg_nama-peg_jenis_kelamin-peg_status_perkawinan"
      theurl = $(urlmantra / bkpp / "simpeg" / "lihat_isi") & genparm &
        tableparam & fields
    runtestOf("ycksjuekk8", theurl)
  test "API untuk mendapatkan query pegawai untuk portal":
    let theurl = $(urlmantra / "diskominfo" / "portal" / "query_pegawai") &
      "/limit=10&page=1&q=sehat"
    runtestOf("", theurl)
