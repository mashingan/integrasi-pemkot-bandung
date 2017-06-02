from strutils import strip
from xmltree import `$`, findAll, innerText
from htmlparser import parseHtml
from times import parse, Time, TimeInfo, `$`
from xmlparser import parseXml
import httpclient
import threadpool
import tables

import times
import json
import db_postgres

import disdik_entry

#TODO:
#1. Test whether async fetch result is not separated too far away from
#actual total npsn. [done?]
#
#2. Test the return value of fastRows. [done]
#3. Test the time parsing given from row which returned from sql connection.
# [done]
#
#4. Test the content which gotten from client.getContent with npsnurl
# [done]
#5. Timing won't have a meaning anymore if combined with postgres rows
#fetching so it will be deleted later. [done?]
#
#6. Whether it will use sync or async fetching because of quirk ``spawn``
#result and the paradoxical timing result in Linux. If using sync fetching,
#delete the local ``client`` variable and use global clent defined in
#``disdik_entry`` module [done?]

type
  NpsnMod = TableRef[string, TimeInfo]
  IdMod = object
    id: string
    lastMod: TimeInfo

const totalPage = 55
let
  dapodik = "http://dapodik.disdikkota.bandung.go.id/?page="

  #enable this when to test postgres connection
  db = connectPostgres()
  #[
  db = open("", "", "",
    "host=103.24.150.111 user=postgres password= " &
    "port=5432 dbname=cache_dapodik")
    ]#

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

var start: float


#TODO: Apparently sync is faster than async, but not so in Windows
#which gives a more correct timing it seems
#EDIT: apparently with release compilation, the async indeed faster
#than sync version in Windows
echo "starting at ", $getTime()
start = cpuTime()
for page in 1 .. totalPage:
  echo "dispatch times: ", page
  flowpages[page-1] = spawn(getData page)

#enable this if the connection with server is ok
for row in db.fastRows(sql"select id, npsn, last_modified from sekolah;"):
  echo row
  if not row.isNil and row.len >= 3:
    let
      id = row[0]
      npsn = row[1]
      lastMod = row[2].parse("yyyy-MM-dd' 'HH:mm:ss")
    oldData[npsn] = IdMod(id: id, lastMod: lastMod)

#sync()

for page in flowpages:
  var tabledata = ^page
  for key, val in tabledata.pairs:
    newData[key] = val

echo "async fetch is ", cpuTime() - start
echo "newData length is ", newData.len
#echo $allData

#enable this for comparison with sync operation
#[
start = cpuTime()
for page in 1 .. totalPage:
  for key, val in getData(page).pairs:
    syncdata[key] = val

echo "sync fetch is ", cpuTime() - start
echo "syncdata length is ", syncdata.len
]#

#enable this if all other parts are ok
proc updateOrInsert(entry: Entry, update = true) =
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

proc insertSekolah(npsn: string) =
  let npsnurl = sekolahUrl & "&filter[npsn]=" & npsn
  updateOrInsert(npsnurl.getEntry false, false)

proc retrieveSekolah(id: string) =
  let link = sekolahApi & "/" & id & "?token=" & token
  updateOrInsert link.getEntry

for npsn, newMod in newData.pairs:
  if npsn in oldData:
    let
      oldObj = oldData[npsn]
      oldMod = oldObj.lastMod.toTime
    if oldMod < newMod.toTime:
      retrieveSekolah oldObj.id
  else:
    insertSekolah npsn

echo "ended at ", $getTime()
echo()
