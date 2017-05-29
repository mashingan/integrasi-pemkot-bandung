from strutils import strip
from xmltree import `$`, findAll, innerText
from htmlparser import parseHtml
from times import parse, Time, TimeInfo, `$`
from xmlparser import parseXml
from streams import newStringStream
from tables import `[]=`, newTable, `$`
#import tables
import httpclient
import asyncdispatch
import typetraits
import asyncmacro


#const totalPage = 55
const totalPage = 1
#let dapodik = "http://dapodik.disdikkota.bandung.go.id/?page="
let dapodik = "http://learn.shayhowe.com/html-css/organizing-data-with-tables/"
var
  lastModSekolah = newTable[string, TimeInfo]()
  asynclient = newAsyncHttpClient()
  client = newHttpClient()
  pages = newSeq[Future[AsyncResponse]](totalPage)

var
  contentHtml = client.get(dapodik).bodyStream.parseHtml
  tbody = contentHtml.findAll("tbody")


proc toquit() {.noconv.} =
  echo "exiting application"
  echo "tbody is ", $tbody
  echo "sync tbody length is ", tbody.len
  echo $lastModSekolah
  asynclient.close
  client.close
  quit QuitSuccess

setControlCHook toquit

for page in 1 .. totalPage:
  echo "dispatch times: ", page
  #pages[page-1] = asynclient.get(dapodik & $page)
  pages[page-1] = asynclient.get dapodik
  pages[page-1].callback = proc (res: Future[AsyncResponse]) {.thread.} =
    var
      asyncres = res.read
      content = waitFor asyncres.body
      html = content.newStringStream.parseHtml
      trbody = html.findAll("trbody")
    echo "trbody is ", $trbody
    echo "html type is ", $html.type.name

#TODO: finish Future[AsyncResponse]


#[
for tr in tbody.findAll("tr"):
  let
    info = tr.findAll("td")
    npsn = info[0].innerText.strip
    last = info[2].innerText.strip
    thetime = last.parse("yyyy-MM-dd' 'HH:mm:ss")
  echo "npsn ", npsn
  echo "last modified ", last
  echo "parsed Time ", thetime

  lastModSekolah[npsn] = thetime
]#

#echo $lastModSekolah

for page in pages:
  echo "page is finished? ", page.finished

runForever()
