# with -d:ssl

import unittest, httpclient, json, uri
import mantra_test_vars

suite "Test Dapodik API":
  var
    disdik = "disdik"
    dapodikapi = "dapodikapi"
    npsn = "npsn=20245103"
    response: JsonNode

  proc getUrl(apifungsi: string): string =
    $(urlmantra / disdik / dapodikapi / apifungsi)

  proc retStatus(resnode: JsonNode): bool =
    resnode.getNum == 1

  test "satu sekolah Dapodik publisher":
    let apifungsi = "satu_sekolah"
    let theurl = apifungsi.getUrl & "/" & npsn
    try:
      response = client.getContent(theurl).parseJson["response"]
      check: retStatus response["status"]
    except:
      echo getCurrentExceptionMsg()
      fail()

  test "list data sekolah dapodik":
    let
      apifungsi = "sekolah"
      theurl = apifungsi.getUrl &  "/" & "max_result=10&page=1"
    try:
      response = client.getContent(theurl).parseJson["response"]
      check: retStatus(response["status"])
    except:
      echo getCurrentExceptionMsg()
      fail()

  test "check slb":
    let
      apifungsi = "slb"
      theurl = apifungsi.getUrl
    try:
      response = client.getContent(theurl).parseJson["response"]
      check:
        retStatus response["status"]
        response["data"]["data"].len != 0
    except:
      echo getCurrentExceptionMsg()
      fail()

  test "cari sekolah untuk portal":
    let
      apifungsi = "sekolah_cari"
      limpa = "&limit=10&page=1"
      cariNama = "/q=dada" & limpa
      cariNpsn = "/q=191" & limpa
    var resNpsn: JsonNode
    try:
      response = client.getContent(apifungsi.getUrl & cariNama)
        .parseJson["response"]
      resNpsn = client.getContent(apifungsi.getUrl & cariNpsn)
        .parseJson["response"]
      check:
        retStatus response["status"]
        retStatus resNpsn["status"]
        response["data"]["list_sekolah"].len != 0
        resNpsn["data"]["list_sekolah"].len != 0
    except:
      echo getCurrentExceptionMsg()
      fail()

  test "satu sekolah dari dapodik_provider":
    let apifungsi = "satu_sekolah"
    dapodikapi = "dapodikapi2"
    let theurl = apifungsi.getUrl & "/" & npsn
    try:
      response = client.getContent(theurl).parseJson["response"]
      check: retStatus response["status"]
    except:
      echo getCurrentExceptionMsg()
      fail()

  test "lihat nama, alamat, dan jumlah siswa derajat SD":
    "".runtestOf("sd".getUrl)

  test "lihat nama, alamat, dan jumlah siswa derajat SMP":
    "".runtestOf("smp".getUrl)

  test "lihat nama, alamat, dan jumlah siswa derajat SMA":
    "".runtestOf("sma".getUrl)
