import httpclient
import times
import db_postgres
import json
import parseopt2
from strutils import strip

var token* =
  "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9" &
  "kYXBvZGlrLmRpc2Rpa2tvdGEuYmFuZHVuZy5nby5pZCIsImlhdCI6MTQ5MTgyMjE3N" &
  "CwiZXhwIjoxODA3MTgyMTc0LCJ1c2VybmFtZSI6ImRpc2tvbWluZm9iZGcifQ." &
  "VQAntH-Hb_VOPbEjVtFThG50Mcnfgbm71CRZAXOqLKA"

var client* = newHttpClient()
var sekolahApi* = "http://dapodik.disdikkota.bandung.go.id/api-dapodik" &
  "/sekolah"
var sekolahUrl* = sekolahApi & "?token=" & token

type
  Entry* = object
    id*, nama*, npsn*, namaKepsek*, nipKepsek*, alamat*, kelurahan* : string
    kecamatan*, lintang*, bujur*: string
    jumlahSiswaLakiLaki*, jumlahSiswaPerempuan*: BiggestInt
    lastModified*: Time

proc connectPostgres*(): DbConn =
  var options = """
Options that you must supply is:
  --user  , -u      username that will connect to postgres
  --port  , -p      port to connect
  --host  , -h      host ip address to connect to postgres
  --pass  , -pw     password to be supplied to postgres
  --dbname, -db     database that'll be connected in postgres

  --help  , -hlp    print this

Info:
  Each option acts as key while the value separator is ':' or '='.
  Any whitespace which separates between and key dan value is considered
  as different options altogether.

Example:
  $./executable_name -u:mashingan --port:5432 -pw=helloniceworld \ 
      -db:dapodik --host=127.0.0.1

Any connection error will quit the program with QuitFailure (-1) exit code.
"""
  var command = " "

  template toquit(exitcode: int): typed =
    echo options
    quit exitcode

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      discard
    of cmdLongOption, cmdShortOption:
      case key
      of "user", "u":     command &= "user=" & val & " "
      of "port", "p":     command &= "port=" & val & " "
      of "host", "h":     command &= "host=" & val & " "
      of "password", "pw":command &= "password=" & val & " "
      of "dbname", "db":  command &= "dbname=" & val & " "
      of "help", "hlp":   toquit QuitSuccess
    of cmdEnd:
      toquit QuitFailure

  command = command.strip
  if command == "":
    toquit QuitFailure

  try:
    result = db_postgres.open("", "", "", command)
  except DbError:
    echo getCurrentExceptionMsg()
    toquit QuitFailure


proc getEntry*(item: JsonNode): Entry =
  try:
    let sekolah = item["attributes"]

    # filling sekolah detail 1
    let
      id = sekolah["id"].getStr
      npsn = sekolah["npsn"].getStr
      nama = sekolah["nama"].getStr
      alamat = sekolah["alamat_jalan"].getStr
      kelurahan = sekolah["desa_kelurahan"].getStr
      lintang = sekolah["lintang"].getStr
      bujur = sekolah["bujur"].getStr

    var link: string
    try:
      link = item["links"]["self"].getStr()
    except KeyError:
      link = sekolahApi & "/" & id
    let detailSekolah = link & "?token=" & token
    #echo "detailSekolah: ", detailSekolah
    
    # getting and filling sekolah detail 2
    let
      detail = client.getContent(detailSekolah).
        parseJson["data"]["relationships"]
      kecamatan = detail["kecamatan"]["attributes"]["nama"].getStr

    # getting year and semester
    let
      now = getLocalTime getTime()
      beforeHalfYear = now.month <= mJun
      semester = if beforeHalfYear: 2 else: 1
      year = if beforeHalfYear: (now.year - 1) else: now.year

    # getting and filling sekolah kepsek
    let
      toKepsek = link & "/tahun/" & $year & "?token=" & token
    #echo "toKepsek ", toKepsek

    let
      kepsek = client.getContent(toKepsek).parseJson["data"]
      kepsekDataId = kepsek["attributes"]["kepala_sekolah_id"].getStr
    var kepsekNama, kepsekNip: string
    #echo "kepsek data id: ", kepsekDataId
    if kepsekDataId.isNil or kepsekDataId == "null" or kepsekDataId == "":
      kepsekNama = ""
      kepsekNip = ""
    else:
      let kepsekInfo =
        kepsek["relationships"]["kepala_sekola"]["attributes"]
      kepsekNama = kepsekInfo["nama"].getStr
      kepsekNip = kepsekInfo["nip"].getStr

    let
      toSemester = link & "/tahun/" & $year & "/semester/" &
        $year & $semester & "?token=" & token

    #echo "toSemester ", toSemester

    let
      detailSemester = client.getContent(toSemester).
        parseJson["data"]["attributes"]
      jumlahSiswaLakiLaki = detailSemester["jumlah_siswa_laki_laki"].getNum
      jumlahSiswaPerempuan = detailSemester["jumlah_siswa_perempuan"].getNum
    #[
    echo "nama sekolah ", nama
    echo "npsn sekolah ", npsn
    echo "nama kepsek ", kepsekNama
    echo "nip kepsek ", kepsekNip
    echo "alamat ", alamat
    echo "kelurahan ", kelurahan
    echo "kecamatan ", kecamatan
    echo "link sekolah ", link
    echo "lintang ", lintang
    echo "bujur ", bujur
    echo "Jumlah siswa laki-laki ", $ jumlahSiswaLakiLaki
    echo "Jumlah siswa perempuan ", $ jumlahSiswaPerempuan
    echo()
    ]#
    Entry(
      id: id,
      nama: nama,
      npsn: npsn,
      namaKepsek: kepsekNama,
      nipKepsek: kepsekNip,
      alamat: alamat,
      kelurahan: kelurahan,
      kecamatan: kecamatan,
      lintang: lintang,
      bujur: bujur,
      jumlahSiswaLakiLaki: jumlahSiswaLakiLaki,
      jumlahSiswaPerempuan: jumlahSiswaPerempuan,
      lastModified: getTime()
    )
  except KeyError:
    echo "error something happens: ", getCurrentExceptionMsg()
    Entry()


proc insertEntry*(db: DbConn, entry: Entry) =
  try:
    db.exec(sql("""
insert into public.sekolah
  (id, nama, npsn, nama_kepsek, nip_kepsek, alamat, kelurahan, kecamatan,
  lintang, bujur, jumlah_siswa_laki_laki, jumlah_siswa_perempuan,
  last_modified)
  values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"""),
      entry.id, entry.nama, entry.npsn, entry.namaKepsek, entry.nipKepsek,
      entry.alamat, entry.kelurahan, entry.kecamatan, entry.lintang,
      entry.bujur, entry.jumlahSiswaLakiLaki, entry.jumlahSiswaPerempuan,
      $entry.lastModified
    )
  except DbError:
    echo "error inserting: ", getCurrentExceptionMsg()


proc updateEntry*(db: DbConn, entry: Entry) =
  try:
    db.exec(sql"delete from sekolah where npsn = ?;", entry.npsn)
    db.insertEntry entry
  except DbError:
    echo "error happened: ", getCurrentExceptionMsg()
