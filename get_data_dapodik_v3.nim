from strutils import strip
from xmltree import `$`, findAll, innerText
from htmlparser import parseHtml
from times import parse, Time, TimeInfo, `$`
from xmlparser import parseXml
from os import sleep
import httpclient
import threadpool
import tables

import times
import json
import db_postgres

import disdik_entry

type
  NpsnMod = TableRef[string, TimeInfo]
  IdMod = object
    id: string
    lastMod: TimeInfo

const totalPage = 55
let dapodik = "http://dapodik.disdikkota.bandung.go.id/?page="


var
  flowpages = newSeq[FlowVar[NpsnMod]](totalPage)
  newData = newTable[string, TimeInfo]()
  oldData = newTable[string, IdMod]()

  syncdata = newTable[string, TimeInfo]()

proc getData(page: int): NpsnMod =
  result = newTable[string, TimeInfo]()
  var
    client = newHttpClient()
    content = client.get(dapodik & $page).bodyStream.parseHtml
    tbody = content.findAll("tbody")[0]

  for tr in tbody.findAll("tr"):
    let
      info = tr.findAll("td")
      npsn = info[0].innerText.strip
      last = info[2].innerText.strip
      thetime = last.parse("yyyy-MM-dd' 'HH:mm:ss")

    result[npsn] = thetime

#enable this if all other parts are ok
proc updateOrInsert(db: DbConn, entry: Entry, update = true) =
  if update:
    echo "update entry ", entry
    db.updateEntry entry
    echo()
  else:
    echo "insert entry ", entry
    db.insertEntry entry
    echo()

proc getEntry(link: string, update = true): Entry =
  if update:
    result = client.getContent(link).parseJson["data"].getEntry
  else:
    result = client.getContent(link).parseJson["data"][0].getEntry

proc insertSekolah(db: DbConn, npsn: string) =
  let npsnurl = sekolahUrl & "&filter[npsn]=" & npsn
  updateOrInsert(db, npsnurl.getEntry false, false)

proc retrieveSekolah(db: DbConn, id: string) =
  let link = sekolahApi & "/" & id & "?token=" & token
  updateOrInsert db, link.getEntry

proc main(db: DbConn) =
  var start: float
  start = cpuTime()
  for page in 1 .. totalPage:
    echo "dispatch times: ", page
    flowpages[page-1] = spawn(getData page)

  for row in db.fastRows(sql"select id, npsn, last_modified from sekolah;"):
    echo row
    if not row.isNil and row.len >= 3:
      let
        id = row[0]
        npsn = row[1]
        lastMod = row[2].parse("yyyy-MM-dd' 'HH:mm:ss")
      oldData[npsn] = IdMod(id: id, lastMod: lastMod)

  for page in flowpages:
    var tabledata = ^page
    for key, val in tabledata.pairs:
      newData[key] = val

  echo "async fetch is ", cpuTime() - start
  echo "newData length is ", newData.len
  #echo $allData

  for npsn, newMod in newData.pairs:
    if npsn in oldData:
      let
        oldObj = oldData[npsn]
        oldMod = oldObj.lastMod.toTime
      if oldMod < newMod.toTime:
        retrieveSekolah db, oldObj.id
    else:
      insertSekolah db, npsn

proc toMilliseconds(hour = 0, minute = 0, second = 0): int =
  template tsec(x: int): untyped = x * 1000
  result = hour * 3600.tsec + minute * 60.tsec + second * 100

when isMainModule:
  #enable this when to test postgres connection
  let db = connectPostgres()
  while true:
    try:
      main db
    except:
      echo "error happened: ", getCurrentExceptionMsg()

    var
      now = getTime().getLocalTime()
      to00 = 23 - now.hour
      tmin = 59 - now.minute
      tsec = 59 - now.second
    sleep toMilliseconds(to00, tmin, tsec)
