import db_postgres
import httpclient
import json
from os import paramCount, paramStr
from strutils import parseInt
import times

import disdik_entry

var sekolahDapodik* = sekolahUrl & "&page="

proc nextPage(page: int): string =
  sekolahDapodik & $page


#for page in 1 .. 55:
#var page = 1
when isMainModule:
  #[
  var page: int
  if paramCount() < 1:
    echo "Please supply the page number"
    echo "The page number must be before all postgre server connection ",
      "options"
    quit QuitFailure
  else:
    page = try:
            paramStr(1).parseInt
          except ValueError:
            -1

  if page == -1:
    echo "Wrong value supplied ", paramStr(1)
    quit QuitFailure

  ]#
  let db = connectPostgres()
  db.exec(sql"drop table if exists public.sekolah2")

  var noTable = true

  try:
    db.exec(sql"""create table if not exists public.sekolah2 (
      id varchar(50) not null,
      nama varchar(50) not null,
      npsn varchar(50) not null,
      nama_kepsek varchar(50),
      nip_kepsek varchar(50),
      nik_kepsek varchar(50),
      pangkat_golongan_id int,
      pangkat_golongan varchar(20),
      no_hp varchar(20),
      email varchar(50),
      link text,
      last_modified timestamp not null,
      alamat text,
      kelurahan varchar(50),
      kecamatan varchar(50),
      lintang varchar(20),
      bujur varchar(20),
      status_kepemilikan varchar(20),
      jenjang_id int,
      jenjang varchar(20),
      jumlah_siswa_laki_laki int,
      jumlah_siswa_perempuan int
      )""")
    noTable = false
  except DbError:
    echo "Cannot create table: ", getCurrentExceptionMsg()
    noTable = true

  var
    start = cpuTime()
    count = 0
    client = newHttpClient()

  var page = 1
  while page <= 55:
  #for page in 1 .. 55:
    if noTable:
      break
    echo "dispatch time ", page, " at ", $getTime()
    var dataSekolah: JsonNode
    try:
      dataSekolah = client.getContent(nextPage page).parseJson["data"]
    except:
      client = newHttpClient()
      continue
    #let dataSekolah = client.getContent(nextPage page).parseJson["data"]
    for item in dataSekolah.items:

      #echo "fetching ok"
      #echo item
      echo "process item ", count+1, " at ", $getTime()
      var entry = item.getEntry client
      echo entry
      echo()
      db.insertEntry "public.sekolah2", entry
      inc count
    inc page
  echo "elapsed time ", cpuTime() - start
  echo count, " items processed"
