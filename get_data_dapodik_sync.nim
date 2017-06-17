from strutils import strip
from xmltree import `$`, findAll, innerText
from htmlparser import parseHtml
from os import sleep
import json, db_postgres, httpclient, tables, times

import disdik_entry

type
  IdMod = object
    id: string
    lastMod: TimeInfo
  NpsnInfo = TableRef[string, TimeInfo]

const totalPage = 55
let
  dapodik = "http://dapodik.disdikkota.bandung.go.id/?page="
  dbtable = "public.sekolah"
var dbModSekolah = newTable[string, IdMod]()

proc updateOrInsert(db: DbConn, entry: Entry, update = true) =
  if update:
    echo "update entry ", entry
    db.updateEntry dbtable, entry
  else:
    echo "insert entry ", entry
    db.insertEntry dbtable, entry
  echo()

proc getEntry(link: string, client: HttpClient, update = true): Entry =
  if update:
    client.getContent(link).parseJson["data"].getEntry
  else:
    client.getContent(link).parseJson["data"][0].getEntry

proc insertSekolah(db: DbConn, client: HttpClient, npsn: string) =
  let npsnurl = sekolahUrl & "&filter[npsn]=" & npsn
  updateOrInsert(db, npsnurl.getEntry(client, false), false)

proc retrieveSekolah(db: DbConn, client: HttpClient, id: string) =
  let link = sekolahApi & "/" & id & "?token=" & token
  updateOrInsert(db, link.getEntry client)

proc processEntry(db: DbConn, client: HttpClient, themod: NpsnInfo) =
  for npsn, newMod in themod.pairs:
    if npsn in dbModSekolah:
      let
        oldObj = dbModSekolah[npsn]
        oldMod = oldObj.lastMod.toTime
      if oldMod < newMod.toTime:
        retrieveSekolah db, client, oldObj.id
    else:
      insertSekolah db, client, npsn

proc processData(db: DbConn, client: HttpClient, url: string) =
  var
    toprocess = newTable[string, TimeInfo]()
    html = client.get(url).bodyStream.parseHtml
    tbody = html.findAll("tbody")[0]

  for tr in tbody.findAll("tr"):
    let
      info = tr.findAll("td")
      npsn = info[0].innerText.strip
      last = info[2].innerText.strip
      thetime = last.parse("yyyy-MM-dd' 'HH:mm:ss")

    toprocess[npsn] = thetime
  db.processEntry client, toprocess

when isMainModule:
  var db = connectPostgres()

  for row in db.fastRows(sql"select id, npsn, last_modified from sekolah;"):
    if not row.isNil and row.len >= 3:
      let
        id = row[0]
        npsn = row[1]
        lastMod = row[2].parse("yyyy-MM-dd' 'HH:mm:ss")
      dbModSekolah[npsn] = IdMod(id: id, lastMod: lastMod)

  for page in 1 .. totalPage:
    echo "dispatch times: ", page, " at ", $getTime()
    var client = newHttpClient()
    db.processData(client, dapodik & $page)
    echo()
    client.close
    sleep 1000
