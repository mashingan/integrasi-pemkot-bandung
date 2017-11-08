import httpclient
import times
import db_postgres
import json
import parseopt2
from strutils import strip
import tables

var token* =
  "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9" &
  "kYXBvZGlrLmRpc2Rpa2tvdGEuYmFuZHVuZy5nby5pZCIsImlhdCI6MTQ5MTgyMjE3N" &
  "CwiZXhwIjoxODA3MTgyMTc0LCJ1c2VybmFtZSI6ImRpc2tvbWluZm9iZGcifQ." &
  "VQAntH-Hb_VOPbEjVtFThG50Mcnfgbm71CRZAXOqLKA"

var
  listKepemilikan = {0: "", 1: "Pemerintah Pusat", 2: "Pemerintah Daerah",
    3: "Yayasan", 4: "Lainnya"}.toTable
  listGolongan = newTable[int, string]()
  listJenjang = {0: "Tidak Sekolah", 1: "PAUD", 2: "TK / sederajat",
    3: "Putus SD", 4: "SD / sederajat", 5: "SMP / sederajat",
    6: "SMA / sederajat", 7: "Paket A", 8: "Paket B", 9: "Paket C",
    20: "D1", 21: "D2", 22: "D3", 23: "D4", 30: "S1", 35: "S2", 40: "S3",
    90: "Non formal", 91: "Informal", 98: "(tidak diisi)",
    99: "Lainnya"}.toTable

proc golGenerator(i: int): string =
  let
    gol = ["I", "II", "III", "IV"]
    alp = "abcd"
  gol[i div gol.len] & "/"  & alp[i mod alp.len]

listGolongan[0] = ""
for i in 1 .. 16:
  listGolongan[i] = golGenerator(i-1)
listGolongan[17] = "IV/e"
listGolongan[99] = "-"

let
  dapodikApi* = "http://dapodik.disdikkota.bandung.go.id/api-dapodik/"
  sekolahApi* = dapodikApi & "sekolah"
  sekolahUrl* = sekolahApi & "?token=" & token

type
  Entry* = object
    id*, nama*, npsn*, namaKepsek*, nipKepsek*, alamat*, kelurahan* : string
    kecamatan*, lintang*, bujur*: string
    jumlahSiswaLakiLaki*, jumlahSiswaPerempuan*: BiggestInt
    lastModified*: Time
    link*, emailKepsek*, hpKepsek*, nikKepsek*: string
    pangkatGolonganId*, jenjangId*: BiggestInt
    pangkatGolongan*, jenjang*, statusKepemilikan: string


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


proc getEntry*(item: JsonNode, client: var HttpClient): Entry =
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
      sekolahMilik =
        listKepemilikan[sekolah["status_kepemilikan_id"].getNum.int]
      sekolahJenjangId = sekolah["jenjang_pendidikan_id"].getNum
      sekolahJenjang = listJenjang[sekolahJenjangId.int]

    let
      link = sekolahApi & "/" & id
      detailSekolah = link & "?token=" & token
    #echo "detailSekolah: ", detailSekolah
    
    # getting and filling sekolah detail 2
    var detail: JsonNode
    while true:
      try:
        detail = client.getContent(detailSekolah).
          parseJson["data"]["relationships"]
        break
      except:
        echo "getEntry.detail: ", getCurrentExceptionMsg()
        client = newHttpClient()

    let
      #[
      detail = client.getContent(detailSekolah).
        parseJson["data"]["relationships"]
      ]#
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

    var kepsek: JsonNode
    while true:
      try:
        kepsek = client.getContent(toKepsek).parseJson["data"]
        break
      except:
        echo "getEntry.kepsek: ", getCurrentExceptionMsg()
        client = newHttpClient()
    let
      #kepsek = client.getContent(toKepsek).parseJson["data"]
      kepsekDataId = kepsek["attributes"]["kepala_sekolah_id"].getStr
    var
      kepsekNama, kepsekNip, kepsekNik: string
      kepsekGolId: BiggestInt
      kepsekGol, kepsekHp, kepsekEmail: string
    #echo "kepsek data id: ", kepsekDataId
    if kepsekDataId.isNil or kepsekDataId == "null" or kepsekDataId == "":
      kepsekNama = ""
      kepsekNip = ""
      kepsekNik = ""
      kepsekGolId = 0
      kepsekGol = listGolongan[99]
      kepsekEmail = ""
      kepsekHp = ""
    else:
      let kepsekInfo =
        kepsek["relationships"]["kepala_sekola"]["attributes"]
      kepsekNama = kepsekInfo["nama"].getStr
      kepsekNip = kepsekInfo["nip"].getStr
      kepsekNik = kepsekInfo["nik"].getStr
      kepsekGolId = kepsekInfo["pangkat_golongan_id"].getNum
      kepsekHp = kepsekInfo["no_hp"].getStr
      kepsekEmail = kepsekInfo["email"].getStr
      kepsekGol = listGolongan[kepsekGolId.int]

    let
      toSemester = link & "/tahun/" & $year & "/semester/" &
        $year & $semester & "?token=" & token

    #echo "toSemester ", toSemester

    var detailSemester: JsonNode
    while true:
      try:
        detailSemester = client.getContent(toSemester).
          parseJson["data"]["attributes"]
        break
      except:
        echo "getEntry.detailSemester: ", getCurrentExceptionMsg()
        client = newHttpClient()
    let
      #[
      detailSemester = client.getContent(toSemester).
        parseJson["data"]["attributes"]
      ]#
      jumlahSiswaLakiLaki = detailSemester["jumlah_siswa_laki_laki"].getNum
      jumlahSiswaPerempuan = detailSemester["jumlah_siswa_perempuan"].getNum

    Entry(
      id: id,
      nama: nama,
      npsn: npsn,
      namaKepsek: kepsekNama,
      nipKepsek: kepsekNip,
      link: link,
      emailKepsek: kepsekEmail,
      hpKepsek: kepsekHp,
      nikKepsek: kepsekNik,
      alamat: alamat,
      kelurahan: kelurahan,
      kecamatan: kecamatan,
      lintang: lintang,
      bujur: bujur,
      jumlahSiswaLakiLaki: jumlahSiswaLakiLaki,
      jumlahSiswaPerempuan: jumlahSiswaPerempuan,
      lastModified: getTime(),
      pangkatGolonganId: kepsekGolId,
      pangkatGolongan: kepsekGol,
      statusKepemilikan: sekolahMilik,
      jenjangId: sekolahJenjangId,
      jenjang: sekolahJenjang
    )
  except KeyError:
    echo "getEntry.KeyError: ", getCurrentExceptionMsg()
    Entry()
  # end of `proc getEntry`


proc insertEntry*(db: DbConn, tableName: string, entry: Entry) =
  try:
    db.exec(sql("""
insert into """ & tableName & """
  (id, nama, npsn, nama_kepsek, nip_kepsek, alamat, kelurahan, kecamatan,
  lintang, bujur, jumlah_siswa_laki_laki, jumlah_siswa_perempuan,
  last_modified, nik_kepsek, pangkat_golongan_id, pangkat_golongan,
  no_hp, email, link, status_kepemilikan, jenjang_id, jenjang)
  values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
  ?, ?, ?, ?);"""),
      entry.id, entry.nama, entry.npsn, entry.namaKepsek, entry.nipKepsek,
      entry.alamat, entry.kelurahan, entry.kecamatan, entry.lintang,
      entry.bujur, entry.jumlahSiswaLakiLaki, entry.jumlahSiswaPerempuan,
      $entry.lastModified, entry.nikKepsek, $entry.pangkatGolonganId,
      entry.pangkatGolongan, entry.hpKepsek, entry.emailKepsek, entry.link,
      entry.statusKepemilikan, $entry.jenjangId, entry.jenjang
    )
  except DbError:
    echo "error inserting: ", getCurrentExceptionMsg()


proc updateEntry*(db: DbConn, tableName: string, entry: Entry) =
  try:
    db.exec(sql"delete from sekolah where npsn = ?;", entry.npsn)
    db.insertEntry tableName, entry
  except DbError:
    echo "update error: ", getCurrentExceptionMsg()
