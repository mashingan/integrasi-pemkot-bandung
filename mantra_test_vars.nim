import httpclient, uri, json

proc retStatus*(node: JsonNode): bool = node.getNum == 1

proc addAccessKey*(key: string): HttpHeaders =
  newHttpHeaders({ "AccessKey": key })

var client* = newHttpClient(userAgent = "MANTRA")
let urlmantra* = parseUri "https://mantra.bandung.go.id/mantra/json"

template runtestOf*(accesskey, theurl: string) =
  try:
    response = client.request(theurl, headers=addAccessKey(accesskey))
      .body.parseJson["response"]
    check:
      retStatus response["status"]
  except:
    echo getCurrentExceptionMsg()
    fail()
