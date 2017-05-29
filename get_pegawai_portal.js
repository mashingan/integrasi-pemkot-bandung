/*
 * contoh parameter:
 * limit=10
 * page=1
 * q=kesehatan
 *
 */
/*
 * Contoh cara pakai:
 * node get_pegawai_portal.js limit=10 page=1 q=kesehatan
 *
 */

var lib = require('./fetchinglib');
var qs = require('querystring');
//var mantra = '103.24.150.111:83';
var mantra = 'mantra.bandung.go.id';
var path = 'mantra/json/diskominfo/aswd/get_simpeg/lp955o1nj0/limit=?&time=?&key=?&id=?&fields=?&table=?';

var args = lib.objectifyArgs(process.argv);
var now = Date.now();

console.log(args);

var result;
lib.getReq({
  port: 80,
  method: 'GET',
  host: 'mantra.bandung.go.id',
  path: '/mantra/json/diskominfo/portal/query_pegawai/' +
    'time=' + now +
    '&key=' + lib.getSum(now) +
    '&id=' + lib.reqid +
    '&' + qs.stringify(args),
  headers: {
    'user-agent': 'MANTRA'
  }
}, function (hasil) {
  result = hasil;
  console.log(hasil);
});
