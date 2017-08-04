/*
 * contoh parameter:
 * limit=10
 * table=m_asto_pegawai
 * fields=all
 * order_by=
 * order_value=
 * filter_field=
 * filter_value=
 * page=
 * path="/mantra/json/bkpp/simpeg/lihat_isi/"
 * port="443"
 */
/*
 * Contoh cara pakai:
 * node tembak-mantra.js limit=10 table=m_asto_pegawai fields=all order_by=
 *    order_value= filter_field= filter_value page=1
 */

const lib = require('./fetchinglib');
const qs = require('querystring');
const fs = require('fs');

var args = lib.objectifyArgs(process.argv);
var now = Date.now();
var shasum = lib.getSum(now);
var pathurl = lib.getFieldAndDelete(args, "path");
var port = parseInt(lib.getFieldAndDelete(args, "port")) || 443;
var crt = fs.readFileSync("./STAR_bandung_go_id.crt");
var host = lib.getFieldAndDelete(args, "host") || "mantra.bandung.go.id";
var acckey = lib.getFieldAndDelete(args, "accesskey");
if (!acckey || acckey === "") {
  throw Error("Please supply accesskey");
}

var result;
lib.getReq({
  port: port,
  method: 'GET',
  rejectUnauthorized: false,
  //ca: crt,
  //host: 'mantra.bandung.go.id',
  host: host,
  path: pathurl + 
    'time=' + now +
    '&key=' + shasum +
    '&id=' + lib.reqid +
    '&' + qs.stringify(args),
  headers: {
    'User-Agent': 'MANTRA',
    'AccessKey': acckey
  }
}, function (hasil) {
  result = hasil;
  console.log(host + pathurl + qs.stringify(args));
  console.log("id: " + lib.reqid);
  console.log("time: " + now);
  console.log("key: " + shasum);
  console.log(hasil);
});
