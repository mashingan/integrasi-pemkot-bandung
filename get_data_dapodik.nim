from strutils import strip
from xmltree import `$`, findAll, innerText
from htmlparser import parseHtml
from xmlparser import parseXml
from streams import newStringStream
from sequtils import all
import json, db_postgres, httpclient, asyncdispatch, tables, times

import disdik_entry

type IdMod = object
  id: string
  lastMod: TimeInfo

#const totalPage = 55
const totalPage = 2
let dapodik = "http://dapodik.disdikkota.bandung.go.id/?page="
var
  lastModSekolah = newTable[string, TimeInfo]()
  dbModSekolah = newTable[string, IdMod]()
  asynclient = newAsyncHttpClient()
  client = newHttpClient()
  pages = newSeq[Future[AsyncResponse]](totalPage)
  countProcess = 0
  db = connectPostgres()


proc toquit() {.noconv.} =
  echo "exiting application"
  echo "lastModSekolah length is ", lastModSekolah.len
  asynclient.close
  client.close
  quit QuitSuccess

setControlCHook toquit

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

proc processEntry(themod: TableRef[string, TimeInfo]) =
  for npsn, newMod in themod.pairs:
    if npsn in dbModSekolah:
      let
        oldObj = dbModSekolah[npsn]
        oldMod = oldObj.lastMod.toTime
      if oldMod < newMod.toTime:
        retrieveSekolah db, oldObj.id
    else:
      insertSekolah db, npsn
  inc countProcess
  #[
  if countProcess == totalPage:
    quit QuitSuccess
    ]#

proc processData(fres: Future[AsyncResponse]) {.thread.} =
  var
    toprocess = newTable[string, TimeInfo]()
    asyncres = read fres
    content = waitFor asyncres.body
    html = content.newStringStream.parseHtml
    tbody = html.findAll("tbody")[0]

  for tr in tbody.findAll("tr"):
    let
      info = tr.findAll("td")
      npsn = info[0].innerText.strip
      last = info[2].innerText.strip
      thetime = last.parse("yyyy-MM-dd' 'HH:mm:ss")
    #[
    echo "npsn ", npsn
    echo "last modified ", last
    echo "parsed Time ", thetime
    ]#

    lastModSekolah[npsn] = thetime
    #[
    toprocess[npsn] = thetime
  toprocess.processEntry()
  ]#

for page in 1 .. totalPage:
  echo "dispatch times: ", page
  pages[page-1] = asynclient.get(dapodik & $page)
  pages[page-1].callback = processData
#echo $lastModSekolah

for page in pages:
  echo "page is finished? ", page.finished

for row in db.fastRows(sql"select id, npsn, last_modified from sekolah;"):
  #echo row
  if not row.isNil and row.len >= 3:
    let
      id = row[0]
      npsn = row[1]
      lastMod = row[2].parse("yyyy-MM-dd' 'HH:mm:ss")
    dbModSekolah[npsn] = IdMod(id: id, lastMod: lastMod)

echo "to continue all"
#while not pages.all(finished):
while not sequtils.all(pages, finished):
  continue
echo "continue complete"

for npsn, newMod in themod.pairs:
  if npsn in dbModSekolah:
    let
      oldObj = dbModSekolah[npsn]
      oldMod = oldObj.lastMod.toTime
    if oldMod < newMod.toTime:
      retrieveSekolah db, oldObj.id
  else:
    insertSekolah db, npsn
#runForever()
