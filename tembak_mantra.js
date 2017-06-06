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
 */
/*
 * Contoh cara pakai:
 * node tembak-mantra.js limit=10 table=m_asto_pegawai fields=all order_by=
 *    order_value= filter_field= filter_value page=1
 */

var lib = require('./fetchinglib');
var qs = require('querystring');

var args = lib.objectifyArgs(process.argv);
var now = Date.now();
var shasum = lib.getSum(now);

console.log(args);

var result;
lib.getReq({
  port: 80,
  method: 'GET',
  host: 'mantra.bandung.go.id',
  path: '/mantra/json/bkpp/simpeg/lihat_isi/' + 
    'time=' + now +
    '&key=' + shasum +
    '&id=' + reqid +
    '&' + qs.stringify(args),
  headers: {
    'user-agent': 'MANTRA'
  }
}, function (hasil) {
  result = hasil;
  console.log(hasil);
});
