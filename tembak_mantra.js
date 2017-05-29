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
 *
 */
/*
 * Contoh cara pakai:
 * node tembak-mantra.js limit=10 table=m_asto_pegawai fields=all order_by=
 *    order_value= filter_field= filter_value page=1
 */

var http = require('http');
var crypto = require('crypto');
var qs = require('querystring');
//var mantra = '103.24.150.111:83';
var mantra = 'mantra.bandung.go.id';
var path = 'mantra/json/diskominfo/aswd/get_simpeg/lp955o1nj0/limit=?&time=?&key=?&id=?&fields=?&table=?';

function objectifyArgs(arr) {
  var count = -1;
  var result = {};
  arr.forEach(function (el) {
    count++;
    if (count >= 2) {
      var elm = el.split("=");
      result[elm[0]] = encodeURI(elm[1] || '');
    }
  });
  return result;
}

function toSHA1(data) {
  var generator = crypto.createHash("sha1");
  generator.update(data);
  return generator.digest('hex');
}

function getReq(options, callback) {
  console.log(options.path);
  var requesting = http.request(options, function(response) {
    var output = "";
    response.setEncoding("utf8");
    response.on("data", function (chunk) {
      output += chunk;
    });
    response.on("end", function () {
      callback(output);
    });
  });
  requesting.end();
}

var keys = {'7na9aj3awo': 'ib57tkh5rdjk4mj'};
var reqid = '7na9aj3awo';
var args = objectifyArgs(process.argv);
var now = Date.now();
var tokey = keys[reqid] + now;
console.log(tokey);
var shasum = toSHA1(tokey);

console.log(args);

var result;
getReq({
  port: 80,
  method: 'GET',
  host: 'mantra.bandung.go.id',
  //path: '/mantra/json/diskominfo/aswd/get_simpeg/lp955o1nj0/' + 
  path: '/mantra/json/bkpp/simpeg/lihat_isi/' + 
    'time=' + now +
    '&key=' + shasum +
    '&id=' + reqid +
    //'&page=2' +
    '&' + qs.stringify(args),
    /*
    '&fields=' + args.fields || "" +
    '&table=' + args.table +
    '&order_field=' + args.order_field || "" +
    '&order_value=' + args.order_value || "" +
    '&filter_field=' + args.filter_field || "" +
    '&filter_value=' + args.filter_value || "" +
    '&page=' + args.page || "",
    */
  headers: {
    'user-agent': 'MANTRA'
  }
}, function (hasil) {
  result = hasil;
  console.log(hasil);
});
